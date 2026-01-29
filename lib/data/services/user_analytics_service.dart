import 'package:dio/dio.dart';
import 'package:venturelink/core/errors/api_exceptions.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'package:venturelink/core/utils/logger.dart';

/// Service pour récupérer les statistiques réelles de l'utilisateur
class UserAnalyticsService {
  final ApiService _apiService;

  UserAnalyticsService(this._apiService);

  /// Récupère les statistiques d'un utilisateur
  Future<Map<String, dynamic>> getUserStats({String? currency = 'EUR'}) async {
    try {
      AppLogger.info(
          'UserAnalyticsService: Récupération des stats utilisateur avec devise: $currency');

      final response = await _apiService
          .get('/analytics/user/', queryParameters: {'currency': currency});

      // Vérifier si la réponse est du HTML (Django Debug Toolbar)
      if (_isHtmlResponse(response.data)) {
        AppLogger.error(
            'UserAnalyticsService: Réponse HTML détectée (Django Debug Toolbar)');
        return _getDefaultStats();
      }

      if (response.data is Map<String, dynamic>) {
        AppLogger.info(
            'UserAnalyticsService: Stats utilisateur récupérées avec succès');
        return response.data as Map<String, dynamic>;
      } else {
        AppLogger.error(
            'UserAnalyticsService: Format de réponse inattendu: ${response.data.runtimeType}');
        return _getDefaultStats();
      }
    } on DioException catch (e) {
      AppLogger.error('UserAnalyticsService: Erreur Dio: ${e.message}');
      if (e.response?.statusCode == 404) {
        AppLogger.info(
            'UserAnalyticsService: Endpoint analytics non disponible (404), utilisation de données par défaut');
      }
      return _getDefaultStats();
    } catch (e) {
      AppLogger.error('UserAnalyticsService: Erreur générique: $e');
      return _getDefaultStats();
    }
  }

  /// Vérifie si la réponse est du HTML
  bool _isHtmlResponse(dynamic data) {
    return data is String && data.contains('<html');
  }

  /// Retourne des statistiques par défaut
  Map<String, dynamic> _getDefaultStats() {
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

  /// Récupère les statistiques d'un projet spécifique
  Future<Map<String, dynamic>> getProjectStats(String projectId,
      {String? currency = 'EUR'}) async {
    try {
      AppLogger.info(
          'UserAnalyticsService: Récupération des stats projet: $projectId');

      final response = await _apiService.get(
          '/api/v1/analytics/project/$projectId/',
          queryParameters: {'currency': currency});

      // Vérifier si la réponse est du HTML
      if (response.data is String &&
          (response.data as String).contains('<html')) {
        AppLogger.error(
            'UserAnalyticsService: L\'API projet retourne du HTML au lieu de JSON');
        return _getDefaultProjectStats();
      }

      if (response.data != null && response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }

      return _getDefaultProjectStats();
    } on DioException catch (e) {
      AppLogger.error(
          'UserAnalyticsService: Erreur projet - StatusCode: ${e.response?.statusCode}');

      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        return _getDefaultProjectStats();
      }

      // Vérifier si l'erreur contient du HTML
      if (e.response?.data is String &&
          (e.response!.data as String).contains('<html')) {
        AppLogger.error('UserAnalyticsService: Erreur projet contient du HTML');
        return _getDefaultProjectStats();
      }

      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      AppLogger.error(
          'UserAnalyticsService: Erreur générique projet: ${e.toString()}');
      return _getDefaultProjectStats();
    }
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
