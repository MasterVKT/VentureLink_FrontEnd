import 'package:venturelink/data/models/notification_model.dart';
import 'package:venturelink/data/services/api_service.dart';

class NotificationApiService {
  final ApiService _apiService;

  NotificationApiService(this._apiService);

  /// Récupérer les notifications avec pagination et filtres
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
    String? category,
    String? status,
    String? priority,
    String ordering = '-created_at',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'ordering': ordering,
    };

    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;

    try {
      final response = await _apiService.get(
        '/notifications/notifications/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Vérifier si la réponse est bien structurée avec des résultats
        if (data is Map<String, dynamic>) {
          // Si c'est un Map avec pagination
          if (data.containsKey('results')) {
            final results = data['results'] as List<dynamic>;
            return results
                .map((json) => NotificationModel.fromJson(json))
                .toList();
          }
          // Si c'est juste un Map avec des URLs d'endpoints, retourner une liste vide
          else if (data.containsKey('notifications') ||
              data.containsKey('notification-templates')) {
            return [];
          }
        }
        // Si c'est directement une liste
        else if (data is List) {
          return data.map((json) => NotificationModel.fromJson(json)).toList();
        }

        // Format inattendu
        return [];
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des notifications: $e');
    }
  }

  /// Obtenir une notification spécifique par ID
  Future<NotificationModel> getNotification(String notificationId) async {
    try {
      final response = await _apiService
          .get('/notifications/notifications/$notificationId/');

      if (response.statusCode == 200) {
        return NotificationModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        throw Exception('Notification non trouvée');
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement de la notification: $e');
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _apiService.post(
        '/notifications/notifications/$notificationId/mark_as_read/',
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors du marquage comme lu: $e');
    }
  }

  /// Archiver une notification
  Future<bool> archiveNotification(String notificationId) async {
    try {
      final response = await _apiService.post(
        '/notifications/notifications/$notificationId/archive/',
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de l\'archivage: $e');
    }
  }

  /// Supprimer une notification (soft delete)
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final response = await _apiService
          .delete('/notifications/notifications/$notificationId/');
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead({String? category}) async {
    try {
      final data = <String, dynamic>{};
      if (category != null) {
        data['category'] = category;
      }

      final response = await _apiService.post(
        '/notifications/notifications/mark_all_read/',
        data: data.isNotEmpty ? data : null,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors du marquage global: $e');
    }
  }

  /// Obtenir le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response =
          await _apiService.get('/notifications/notifications/unread_count/');

      if (response.statusCode == 200) {
        return response.data['unread_count'] as int? ?? 0;
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement du compteur: $e');
    }
  }

  /// Rechercher dans les notifications
  Future<List<NotificationModel>> searchNotifications({
    required String query,
    String? category,
    String? status,
    String? priority,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'search': query,
      'page': page,
      'page_size': pageSize,
      'ordering': '-created_at',
    };

    if (category != null) queryParams['category'] = category;
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;

    try {
      final response = await _apiService.get(
        '/notifications/notifications/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> results = data['results'] ?? data;
        return results.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erreur lors de la recherche: $e');
    }
  }

  /// Récupérer les préférences de notification de l'utilisateur
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final response = await _apiService.get('/notification-preferences/');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else if (response.statusCode == 404) {
        // Retourner des préférences par défaut si aucune n'existe
        return _getDefaultPreferences();
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      // En cas d'erreur, retourner des préférences par défaut
      return _getDefaultPreferences();
    }
  }

  /// Mettre à jour les préférences de notification
  Future<bool> updateNotificationPreferences(
      Map<String, dynamic> preferences) async {
    try {
      final response = await _apiService.patch(
        '/notification-preferences/',
        data: preferences,
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des préférences: $e');
    }
  }

  /// Créer les préférences de notification (première fois)
  Future<bool> createNotificationPreferences(
      Map<String, dynamic> preferences) async {
    try {
      final response = await _apiService.post(
        '/notification-preferences/',
        data: preferences,
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de la création des préférences: $e');
    }
  }

  /// Obtenir les statistiques des notifications
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final response = await _apiService.get('/notifications/stats/');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(response.data);
      } else {
        throw Exception(
            'Erreur ${response.statusCode}: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: $e');
    }
  }

  /// Tester la connectivité avec l'API de notifications
  Future<bool> testConnection() async {
    try {
      final response = await _apiService.get('/notifications/unread_count/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Préférences par défaut
  Map<String, dynamic> _getDefaultPreferences() {
    return {
      'enable_push': true,
      'enable_email': true,
      'enable_sms': false,
      'enable_app': true,
      'project_notifications': true,
      'investment_notifications': true,
      'message_notifications': true,
      'payment_notifications': true,
      'system_notifications': true,
      'quiet_hours_start': null,
      'quiet_hours_end': null,
      'minimum_priority': 'LOW',
    };
  }
}
