import 'package:venturelink/data/models/notification_model.dart';
import 'package:venturelink/data/services/api_service.dart';

class NotificationApiService {
  final ApiService _apiService;

  NotificationApiService(this._apiService);

  /// Récupérer les notifications
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (isRead != null) queryParams['is_read'] = isRead;

    final response = await _apiService.get(
      '/notifications/',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des notifications');
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    final response = await _apiService.patch(
      '/notifications/$notificationId/',
      data: {'is_read': true},
    );

    return response.statusCode == 200;
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    final response = await _apiService.post('/notifications/mark-all-read/');
    return response.statusCode == 200;
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    final response =
        await _apiService.delete('/notifications/$notificationId/');
    return response.statusCode == 204;
  }

  /// Effacer toutes les notifications
  Future<bool> clearAllNotifications() async {
    final response = await _apiService.delete('/notifications/clear-all/');
    return response.statusCode == 204;
  }

  /// Récupérer le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    final response = await _apiService.get('/notifications/unread-count/');

    if (response.statusCode == 200) {
      return response.data['count'] ?? 0;
    } else {
      throw Exception('Erreur lors du chargement du compteur');
    }
  }
}
