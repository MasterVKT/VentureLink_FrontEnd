import 'package:flutter/material.dart';
import 'package:venturelink/data/models/notification_model.dart';
import 'package:venturelink/data/services/notification_api_service.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'package:venturelink/services/firebase_messaging_service.dart';

class NotificationProvider extends ChangeNotifier {
  late final NotificationApiService _notificationApiService;
  late final FirebaseMessagingService _firebaseMessagingService;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  int _unreadCount = 0;
  bool _isInitialized = false;
  String _searchQuery = '';
  Map<String, dynamic> _preferences = {};

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;
  String get searchQuery => _searchQuery;
  Map<String, dynamic> get preferences => _preferences;

  // Getters pour filtrer les notifications
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => n.isUnread).toList();

  List<NotificationModel> get importantNotifications =>
      _notifications.where((n) => n.isHighPriority).toList();

  // Notifications par catégorie
  List<NotificationModel> get projectNotifications =>
      _notifications.where((n) => n.isProjectCategory).toList();

  List<NotificationModel> get investmentNotifications =>
      _notifications.where((n) => n.isInvestmentCategory).toList();

  List<NotificationModel> get messageNotifications =>
      _notifications.where((n) => n.isMessageCategory).toList();

  List<NotificationModel> get paymentNotifications =>
      _notifications.where((n) => n.isPaymentCategory).toList();

  List<NotificationModel> get systemNotifications =>
      _notifications.where((n) => n.isSystemCategory).toList();

  NotificationProvider() {
    final apiService = ApiService();
    _notificationApiService = NotificationApiService(apiService);
    _firebaseMessagingService = FirebaseMessagingService(apiService);
    _init();
  }

  Future<void> _init() async {
    // Initialiser Firebase Messaging
    try {
      await _firebaseMessagingService.initialize();
      debugPrint('✅ Service de messagerie Firebase initialisé avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation du service FCM: $e');
    }

    // Charger les notifications depuis l'API
    await loadNotifications();

    // Charger les préférences de manière optionnelle (ne pas bloquer si l'endpoint n'existe pas)
    loadNotificationPreferences();

    _isInitialized = true;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSearching(bool searching) {
    _isSearching = searching;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Charger les notifications
  Future<void> loadNotifications({
    String? category,
    String? status,
    String? priority,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final notifications = await _notificationApiService.getNotifications(
        category: category,
        status: status,
        priority: priority,
      );
      _notifications = notifications;

      // Compter les notifications non lues
      _unreadCount = _notifications.where((n) => n.isUnread).length;

      debugPrint(
          '✅ ${_notifications.length} notifications chargées, $_unreadCount non lues');
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des notifications: $e');

      // En cas d'erreur, créer des données de test pour permettre le développement
      _createTestNotifications();

      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Créer des notifications de test pour le développement
  void _createTestNotifications() {
    final now = DateTime.now();
    _notifications = [
      NotificationModel(
        id: '1',
        recipient: 'user123',
        title: 'Nouvel investissement reçu !',
        content:
            'John Doe a investi 5000 EUR dans votre projet: Application Mobile',
        category: 'INVESTMENT',
        priority: 'HIGH',
        status: 'UNREAD',
        createdAt: now.subtract(const Duration(minutes: 30)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
        actionUrl: '/projects/123/investments',
        icon: 'investment',
      ),
      NotificationModel(
        id: '2',
        recipient: 'user123',
        title: 'Nouveau message',
        content:
            'Marie Martin vous a envoyé un message concernant votre projet',
        category: 'MESSAGE',
        priority: 'NORMAL',
        status: 'UNREAD',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        actionUrl: '/messages/456',
        icon: 'message',
      ),
      NotificationModel(
        id: '3',
        recipient: 'user123',
        title: 'Projet mis à jour',
        content:
            'Votre projet "Application Mobile" a été mis à jour avec succès',
        category: 'PROJECT',
        priority: 'LOW',
        status: 'READ',
        readAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        actionUrl: '/projects/123',
        icon: 'project',
      ),
      NotificationModel(
        id: '4',
        recipient: 'user123',
        title: 'Paiement traité',
        content: 'Votre paiement de 29.99 EUR a été traité avec succès',
        category: 'PAYMENT',
        priority: 'NORMAL',
        status: 'READ',
        readAt: now.subtract(const Duration(hours: 6)),
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        actionUrl: '/payments/789',
        icon: 'payment',
      ),
      NotificationModel(
        id: '5',
        recipient: 'user123',
        title: 'Maintenance système',
        content: 'Une maintenance système est prévue ce soir de 22h à 2h',
        category: 'SYSTEM',
        priority: 'HIGH',
        status: 'UNREAD',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
        icon: 'system',
      ),
    ];

    // Compter les notifications non lues
    _unreadCount = _notifications.where((n) => n.isUnread).length;

    debugPrint(
        '✅ ${_notifications.length} notifications de test créées, $_unreadCount non lues');
  }

  /// Rechercher dans les notifications
  Future<void> searchNotifications(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResults = [];
      _setSearching(false);
      return;
    }

    _setSearching(true);
    _setError(null);

    try {
      final results = await _notificationApiService.searchNotifications(
        query: query,
      );
      _searchResults = results;

      debugPrint('✅ ${_searchResults.length} résultats trouvés pour "$query"');
    } catch (e) {
      debugPrint('❌ Erreur lors de la recherche: $e');

      // En cas d'erreur API, effectuer une recherche locale
      debugPrint('🔍 Recherche locale dans les notifications chargées');
      _performLocalSearch(query);
    } finally {
      _setSearching(false);
    }
  }

  /// Effectuer une recherche locale dans les notifications déjà chargées
  void _performLocalSearch(String query) {
    final lowercaseQuery = query.toLowerCase();

    _searchResults = _notifications.where((notification) {
      return notification.title.toLowerCase().contains(lowercaseQuery) ||
          notification.content.toLowerCase().contains(lowercaseQuery) ||
          _getCategoryLabel(notification.category)
              .toLowerCase()
              .contains(lowercaseQuery);
    }).toList();

    debugPrint(
        '✅ ${_searchResults.length} résultats trouvés localement pour "$query"');
  }

  /// Obtenir le libellé d'une catégorie
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'PROJECT':
        return 'Projets';
      case 'INVESTMENT':
        return 'Investissements';
      case 'MESSAGE':
        return 'Messages';
      case 'PAYMENT':
        return 'Paiements';
      case 'SYSTEM':
        return 'Système';
      default:
        return 'Général';
    }
  }

  /// Filtrer les notifications par catégorie
  List<NotificationModel> getNotificationsByCategory(String? category) {
    if (category == null) return _notifications;
    return _notifications.where((n) => n.category == category).toList();
  }

  /// Filtrer les notifications par statut
  List<NotificationModel> getNotificationsByStatus(String status) {
    return _notifications.where((n) => n.status == status).toList();
  }

  /// Filtrer les notifications par priorité
  List<NotificationModel> getNotificationsByPriority(String priority) {
    return _notifications.where((n) => n.priority == priority).toList();
  }

  /// Obtenir les statistiques des notifications
  Map<String, int> getNotificationStats() {
    return {
      'total': _notifications.length,
      'unread': _notifications.where((n) => n.isUnread).length,
      'high_priority': _notifications.where((n) => n.isHighPriority).length,
      'project': _notifications.where((n) => n.isProjectCategory).length,
      'investment': _notifications.where((n) => n.isInvestmentCategory).length,
      'message': _notifications.where((n) => n.isMessageCategory).length,
      'payment': _notifications.where((n) => n.isPaymentCategory).length,
      'system': _notifications.where((n) => n.isSystemCategory).length,
    };
  }

  /// Effacer la recherche
  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }

  /// Charger le nombre de notifications non lues
  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationApiService.getUnreadCount();
      _unreadCount = count;
      notifyListeners();

      debugPrint(
          '✅ Compteur de notifications non lues mis à jour: $_unreadCount');
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement du compteur: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationApiService.markAsRead(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && _notifications[index].isUnread) {
          _notifications[index] = _notifications[index].copyWith(
            status: 'read',
            readAt: DateTime.now(),
          );
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          notifyListeners();

          debugPrint('✅ Notification $notificationId marquée comme lue');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du marquage de la notification comme lue: $e');

      // En cas d'erreur API, simuler l'action localement pour les données de test
      debugPrint(
          '🔄 Simulation locale du marquage de la notification comme lue');

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && _notifications[index].isUnread) {
        _notifications[index] = _notifications[index].copyWith(
          status: 'read',
          readAt: DateTime.now(),
        );
        _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
        notifyListeners();

        debugPrint(
            '✅ Notification $notificationId marquée comme lue (mode local)');
      }
    }
  }

  /// Archiver une notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      final success =
          await _notificationApiService.archiveNotification(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(
            status: 'ARCHIVED',
          );
          if (_notifications[index].isUnread) {
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          }
          notifyListeners();

          debugPrint('✅ Notification $notificationId archivée');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'archivage de la notification: $e');
      _setError(e.toString());
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead({String? category}) async {
    try {
      final success =
          await _notificationApiService.markAllAsRead(category: category);

      if (success) {
        for (int i = 0; i < _notifications.length; i++) {
          if (_notifications[i].isUnread &&
              (category == null || _notifications[i].category == category)) {
            _notifications[i] = _notifications[i].copyWith(
              status: 'read',
              readAt: DateTime.now(),
            );
          }
        }
        _unreadCount = category == null
            ? 0
            : _notifications.where((n) => n.isUnread).length;
        notifyListeners();

        debugPrint(
            '✅ Toutes les notifications ${category != null ? 'de $category ' : ''}marquées comme lues');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du marquage de toutes les notifications: $e');

      // En cas d'erreur API, simuler l'action localement pour les données de test
      debugPrint(
          '🔄 Simulation locale du marquage de toutes les notifications comme lues');

      for (int i = 0; i < _notifications.length; i++) {
        if (_notifications[i].isUnread &&
            (category == null || _notifications[i].category == category)) {
          _notifications[i] = _notifications[i].copyWith(
            status: 'read',
            readAt: DateTime.now(),
          );
        }
      }
      _unreadCount =
          category == null ? 0 : _notifications.where((n) => n.isUnread).length;
      notifyListeners();

      debugPrint(
          '✅ Toutes les notifications ${category != null ? 'de $category ' : ''}marquées comme lues (mode local)');

      // Extraire le message d'erreur proprement mais ne pas l'afficher pour cette action
      // car on a réussi à la simuler localement
      // String errorMessage = 'Erreur lors du marquage des notifications';
      // if (e.toString().contains('ApiException:')) {
      //   final parts = e.toString().split('ApiException: ');
      //   if (parts.length > 1) {
      //     errorMessage = parts[1].split(' (Status:')[0];
      //   }
      // } else {
      //   errorMessage = e.toString();
      // }
      // _setError(errorMessage);
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      final success =
          await _notificationApiService.deleteNotification(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          if (_notifications[index].isUnread) {
            _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          }
          _notifications.removeAt(index);
          notifyListeners();

          debugPrint('✅ Notification $notificationId supprimée');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de la notification: $e');
      _setError(e.toString());
    }
  }

  /// Charger les préférences de notification
  Future<void> loadNotificationPreferences() async {
    try {
      final preferences =
          await _notificationApiService.getNotificationPreferences();
      _preferences = preferences;
      notifyListeners();

      debugPrint('✅ Préférences de notification chargées');
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des préférences: $e');
      // Ne pas définir d'erreur pour éviter d'interrompre l'UI
      // Les préférences par défaut seront utilisées
      _preferences = {
        'enable_push': true,
        'enable_email': true,
        'enable_sms': false,
        'enable_app': true,
        'project_notifications': true,
        'investment_notifications': true,
        'message_notifications': true,
        'payment_notifications': true,
        'system_notifications': true,
      };
      notifyListeners();
    }
  }

  /// Mettre à jour les préférences de notification
  Future<void> updateNotificationPreferences(
      Map<String, dynamic> preferences) async {
    try {
      final success = await _notificationApiService
          .updateNotificationPreferences(preferences);

      if (success) {
        _preferences = {..._preferences, ...preferences};
        notifyListeners();

        debugPrint('✅ Préférences de notification mises à jour');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour des préférences: $e');
      _setError(e.toString());
    }
  }

  /// Synchroniser les notifications (appelé après réception d'une push notification)
  Future<void> syncNotifications() async {
    try {
      final notifications = await _notificationApiService.getNotifications();
      _notifications = notifications;
      _unreadCount = _notifications.where((n) => n.isUnread).length;
      notifyListeners();

      debugPrint('✅ Notifications synchronisées avec le serveur');
    } catch (e) {
      debugPrint('❌ Erreur lors de la synchronisation des notifications: $e');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
