import 'package:flutter/material.dart';
import 'package:venturelink/data/models/notification_model.dart';
import 'package:venturelink/data/services/notification_api_service.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'package:venturelink/services/firebase_messaging_service.dart';

class NotificationProvider extends ChangeNotifier {
  late final NotificationApiService _notificationApiService;
  late final FirebaseMessagingService _firebaseMessagingService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  bool _isInitialized = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  bool get isInitialized => _isInitialized;

  // Getters pour filtrer les notifications
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<NotificationModel> get importantNotifications =>
      _notifications.where((n) => n.isImportant).toList();

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

    _isInitialized = true;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Charger les notifications
  Future<void> loadNotifications() async {
    _setLoading(true);
    _setError(null);

    try {
      // Appel API réel
      final notifications = await _notificationApiService.getNotifications();
      _notifications = notifications;

      // Compter les notifications non lues
      _unreadCount = _notifications.where((n) => !n.isRead).length;

      debugPrint(
          '✅ ${_notifications.length} notifications chargées, $_unreadCount non lues');
    } catch (e) {
      debugPrint('❌ Erreur lors du chargement des notifications: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
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
      // Ne pas définir d'erreur ici pour éviter d'interrompre l'UI
    }
  }

  /// Marquer une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      // Appel API réel
      final success = await _notificationApiService.markAsRead(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && !_notifications[index].isRead) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _unreadCount = (_unreadCount - 1).clamp(0, double.infinity).toInt();
          notifyListeners();

          debugPrint('✅ Notification $notificationId marquée comme lue');
        }
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du marquage de la notification comme lue: $e');
      _setError(e.toString());
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      // Appel API réel
      final success = await _notificationApiService.markAllAsRead();

      if (success) {
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = _notifications[i].copyWith(isRead: true);
          }
        }
        _unreadCount = 0;
        notifyListeners();

        debugPrint('✅ Toutes les notifications marquées comme lues');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du marquage de toutes les notifications: $e');
      _setError(e.toString());
    }
  }

  /// Supprimer une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      // Appel API réel
      final success =
          await _notificationApiService.deleteNotification(notificationId);

      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          if (!_notifications[index].isRead) {
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

  /// Effacer toutes les notifications
  Future<void> clearAllNotifications() async {
    try {
      // Appel API réel
      final success = await _notificationApiService.clearAllNotifications();

      if (success) {
        _notifications.clear();
        _unreadCount = 0;
        notifyListeners();

        debugPrint('✅ Toutes les notifications effacées');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'effacement des notifications: $e');
      _setError(e.toString());
    }
  }

  /// Synchroniser les notifications (appelé après réception d'une push notification)
  Future<void> syncNotifications() async {
    // Éviter de déclencher le loading state pour une mise à jour silencieuse
    try {
      final notifications = await _notificationApiService.getNotifications();
      _notifications = notifications;
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();

      debugPrint('✅ Notifications synchronisées avec le serveur');
    } catch (e) {
      debugPrint('❌ Erreur lors de la synchronisation des notifications: $e');
      // Ne pas définir d'erreur pour éviter d'interrompre l'UI
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
