import 'package:dio/dio.dart';

import '../services/api_service.dart';
import '../services/storage_service.dart';

class UserRepository {
  final ApiService _apiService;
  final StorageService _storageService;

  UserRepository(this._apiService, this._storageService);

  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get('/users/profile');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> userData) async {
    try {
      final response = await _apiService.put(
        '/users/profile',
        data: userData,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserAvatar(String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imagePath),
      });
      await _apiService.post(
        '/users/avatar',
        data: formData,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserAccount() async {
    try {
      await _apiService.delete('/users/account');
      await _storageService.clear();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserProjects() async {
    try {
      final response = await _apiService.get('/users/projects');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserFavorites() async {
    try {
      final response = await _apiService.get('/users/favorites');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToFavorites(String projectId) async {
    try {
      await _apiService.post(
        '/users/favorites',
        data: {'projectId': projectId},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String projectId) async {
    try {
      await _apiService.delete('/users/favorites/$projectId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications() async {
    try {
      final response = await _apiService.get('/users/notifications');
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _apiService.put('/users/notifications/$notificationId/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      await _apiService.put('/users/notifications/read-all');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserSettings() async {
    try {
      final response = await _apiService.get('/users/settings');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      await _apiService.put(
        '/users/settings',
        data: settings,
      );
    } catch (e) {
      rethrow;
    }
  }
}
