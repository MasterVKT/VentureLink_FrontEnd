import 'package:dio/dio.dart';
import 'package:venturelink/core/errors/api_exceptions.dart';
import 'package:venturelink/data/services/api_service.dart';

/// Service pour récupérer les statistiques réelles de l'utilisateur
class UserAnalyticsService {
  final ApiService _apiService;

  UserAnalyticsService(this._apiService);

  /// Récupère les statistiques d'un utilisateur
  Future<Map<String, dynamic>> getUserStats({String? currency = 'EUR'}) async {
    try {
      final response = await _apiService
          .get('/api/analytics/user/', queryParameters: {'currency': currency});

      if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }

      // Retourner des données par défaut si l'API ne répond pas
      return _getDefaultUserStats();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 401) {
        // L'utilisateur n'a pas encore de données analytics ou n'est pas connecté
        return _getDefaultUserStats();
      }
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      // En cas d'erreur, retourner des données par défaut
      return _getDefaultUserStats();
    }
  }

  /// Récupère les statistiques d'un projet spécifique
  Future<Map<String, dynamic>> getProjectStats(String projectId,
      {String? currency = 'EUR'}) async {
    try {
      final response = await _apiService.get(
          '/api/analytics/project/$projectId/',
          queryParameters: {'currency': currency});

      if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }

      return _getDefaultProjectStats();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        return _getDefaultProjectStats();
      }
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      return _getDefaultProjectStats();
    }
  }

  /// Données par défaut pour un utilisateur sans analytics
  Map<String, dynamic> _getDefaultUserStats() {
    return {
      'projects_created_count': 0,
      'projects_published_count': 0,
      'total_project_views': 0,
      'total_project_interests': 0,
      'total_comments_received': 0,
      'investments_made_count': 0,
      'total_investment_amount': 0.0,
      'total_investment_currency': 'EUR',
      'messages_sent_count': 0,
      'messages_received_count': 0,
      'login_count': 1,
      'last_login': DateTime.now().toIso8601String(),
    };
  }

  /// Données par défaut pour un projet sans analytics
  Map<String, dynamic> _getDefaultProjectStats() {
    return {
      'view_count': 0,
      'interest_count': 0,
      'favorite_count': 0,
      'comment_count': 0,
      'share_count': 0,
      'investment_count': 0,
      'total_investment_amount': 0.0,
      'total_investment_currency': 'EUR',
      'view_to_interest_rate': 0.0,
      'interest_to_investment_rate': 0.0,
    };
  }
}
