import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:venturelink/core/config/config_service.dart'; // Inutilisé
import 'package:venturelink/data/services/api_service.dart';
import 'package:venturelink/data/services/notification_api_service.dart';
// import 'package:venturelink/data/models/notification_model.dart'; // Inutilisé

// Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Notification reçue en arrière-plan: ${message.messageId}");

  // Ici, nous ne faisons qu'un log, mais des actions supplémentaires pourraient être ajoutées
  // si nécessaire (comme la mise à jour des données locales)
}

class FirebaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService;
  final NotificationApiService _notificationApiService;

  // Canaux de notification Android
  static const AndroidNotificationChannel _channelMessages =
      AndroidNotificationChannel(
    'messages',
    'Messages',
    description: 'Notifications pour les nouveaux messages',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _channelInterests =
      AndroidNotificationChannel(
    'interests',
    'Marques d\'intérêt',
    description: 'Notifications pour les marques d\'intérêt sur les projets',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel _channelQuestions =
      AndroidNotificationChannel(
    'questions',
    'Questions',
    description: 'Notifications pour les questions sur les projets',
    importance: Importance.defaultImportance,
  );

  static const AndroidNotificationChannel _channelGeneral =
      AndroidNotificationChannel(
    'general',
    'Général',
    description: 'Notifications générales et annonces',
    importance: Importance.low,
  );

  FirebaseMessagingService(this._apiService)
      : _notificationApiService = NotificationApiService(_apiService);

  // Initialisation du service
  Future<void> initialize() async {
    // Configurer le handler pour les messages en arrière-plan
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Demander les permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Statut des autorisations FCM: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Initialiser les notifications locales
      await _initializeLocalNotifications();

      // Configurer les canaux Android
      if (Platform.isAndroid) {
        await _setupAndroidNotificationChannels();
      }

      // Configurer les handlers pour les notifications
      _configureNotificationHandlers();

      // Obtenir et enregistrer le token FCM
      await _registerToken();

      // Écouter les rafraîchissements de token
      _messaging.onTokenRefresh.listen(_updateToken);

      // S'abonner aux topics généraux
      await _subscribeToTopics();

      debugPrint('✅ Service FCM initialisé avec succès');
    } else {
      debugPrint('❌ Permissions de notification refusées par l\'utilisateur');
    }
  }

  // Initialiser les notifications locales
  Future<void> _initializeLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false);

    final initializationSettings = const InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Configurer les canaux de notification Android
  Future<void> _setupAndroidNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Créer chaque canal individuellement
      await androidPlugin.createNotificationChannel(_channelMessages);
      await androidPlugin.createNotificationChannel(_channelInterests);
      await androidPlugin.createNotificationChannel(_channelQuestions);
      await androidPlugin.createNotificationChannel(_channelGeneral);

      debugPrint('✅ Canaux Android configurés avec succès');
    }
  }

  // Configurer les handlers pour les différents états de l'application
  void _configureNotificationHandlers() {
    // Handler pour les messages reçus quand l'app est au premier plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handler pour les notifications cliquées quand l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  // Gérer les messages reçus au premier plan
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
        '📱 Message reçu en premier plan: ${message.notification?.title}');

    // Afficher une notification locale
    await _showLocalNotification(message);

    // Synchroniser avec le backend pour mettre à jour la liste des notifications
    _syncNotifications();
  }

  // Gérer les messages ouverts (cliqués) depuis l'arrière-plan
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint(
        '🔔 Notification cliquée depuis l\'arrière-plan: ${message.notification?.title}');

    // Extraire les données pour la navigation
    final data = message.data;
    final type = data['type'];
    final entityId = data['entity_id'];
    final action = data['action'];

    // TODO: Implémenter la navigation en fonction de l'action
    debugPrint('Action à effectuer: $action, entityId: $entityId, type: $type');
  }

  // Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      // Déterminer le canal à utiliser
      String channelId = 'general';
      if (message.data.containsKey('type')) {
        final type = message.data['type'];
        channelId = _getChannelIdFromType(type);
      }

      // Configurer les détails de la notification
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId == 'messages'
            ? 'Messages'
            : channelId == 'interests'
                ? 'Marques d\'intérêt'
                : channelId == 'questions'
                    ? 'Questions'
                    : 'Général',
        importance: Importance.high,
        priority: Priority.high,
        icon: android?.smallIcon ?? 'ic_notification',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Afficher la notification
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Notification',
        notification.body ?? '',
        details,
        payload: jsonEncode(message.data),
      );
    }
  }

  // Gérer les clics sur les notifications locales
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        final type = data['type'] as String? ?? 'UNKNOWN';
        final entityId = data['entity_id'] as String? ?? '';
        final action = data['action'] as String? ?? 'OPEN';

        // TODO: Implémenter la navigation en fonction de l'action
        debugPrint(
            'Notification locale cliquée: action=$action, entityId=$entityId, type=$type');
      } catch (e) {
        debugPrint('Erreur lors du décodage du payload: $e');
      }
    }
  }

  // Déterminer le canal approprié en fonction du type de notification
  String _getChannelIdFromType(String type) {
    switch (type) {
      case 'NEW_MESSAGE':
        return 'messages';
      case 'NEW_INTEREST':
      case 'INTEREST_ACCEPTED':
      case 'INTEREST_REJECTED':
        return 'interests';
      case 'PROJECT_QUESTION':
      case 'QUESTION_ANSWERED':
        return 'questions';
      default:
        return 'general';
    }
  }

  // Obtenir et enregistrer le token FCM
  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _updateToken(token);
        debugPrint('✅ Token FCM obtenu: ${token.substring(0, 10)}...');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'obtention du token FCM: $e');
    }
  }

  // Mettre à jour le token sur le serveur
  Future<void> _updateToken(String token) async {
    try {
      // Envoyer le token au backend
      await _apiService.post(
        '/users/fcm-token',
        data: {'token': token},
      );
      debugPrint('✅ Token FCM mis à jour sur le serveur');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour du token: $e');
    }
  }

  // S'abonner aux topics généraux
  Future<void> _subscribeToTopics() async {
    try {
      await _messaging.subscribeToTopic('announcements');

      // Si utilisateur connecté, s'abonner à son topic personnel
      // Cette fonctionnalité dépend de l'authentification
      final userId = _getUserId();
      if (userId != null) {
        await _messaging.subscribeToTopic('user_$userId');
      }

      debugPrint('✅ Abonnement aux topics réussi');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'abonnement aux topics: $e');
    }
  }

  // Synchroniser les notifications avec le backend
  Future<void> _syncNotifications() async {
    try {
      // Cette méthode sera appelée pour mettre à jour les notifications locales
      // après réception d'une notification push
      await _notificationApiService.getNotifications();
      debugPrint('✅ Synchronisation des notifications réussie');
    } catch (e) {
      debugPrint('❌ Erreur lors de la synchronisation des notifications: $e');
    }
  }

  // Obtenir l'ID de l'utilisateur courant (à implémenter selon l'auth)
  String? _getUserId() {
    // TODO: Implémenter la récupération de l'ID utilisateur
    // selon le système d'authentification utilisé
    return null;
  }
}
