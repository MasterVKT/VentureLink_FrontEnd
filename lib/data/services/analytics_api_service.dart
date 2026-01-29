import 'package:dio/dio.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'package:venturelink/core/utils/logger.dart';

/// Service API pour les données d'analytics et statistiques
class AnalyticsApiService {
  final ApiService _apiService;
  final String _baseUrl;

  AnalyticsApiService(this._apiService, {String? baseUrl})
      : _baseUrl = baseUrl ?? '/analytics';

  /// Vérifie si la réponse est du HTML (Django Debug Toolbar)
  bool _isHtmlResponse(dynamic data) {
    return data is String && data.contains('<html');
  }

  /// Gère les réponses HTML en retournant des données par défaut
  T _handleHtmlResponse<T>(dynamic data, T defaultData, String context) {
    if (_isHtmlResponse(data)) {
      AppLogger.error(
          '$context: Réponse HTML détectée (Django Debug Toolbar) - utilisation des données par défaut');
      return defaultData;
    }
    return data as T;
  }

  /// Récupère les statistiques de l'utilisateur connecté
  Future<Map<String, dynamic>> getUserStats({String? currency}) async {
    try {
      AppLogger.info('AnalyticsApiService: Récupération des stats utilisateur');

      final response = await _apiService.get(
        '$_baseUrl/user/',
        queryParameters: currency != null ? {'currency': currency} : null,
      );

      if (_isHtmlResponse(response.data)) {
        return _getDefaultUserStats();
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      AppLogger.error(
          'AnalyticsApiService: Erreur lors de la récupération des stats utilisateur: ${e.message}');
      if (e.response?.statusCode == 404) {
        AppLogger.info(
            'AnalyticsApiService: Endpoint user stats non disponible, utilisation des données par défaut');
      }
      return _getDefaultUserStats();
    } catch (e) {
      AppLogger.error('AnalyticsApiService: Erreur générique getUserStats: $e');
      return _getDefaultUserStats();
    }
  }

  /// Récupère les statistiques d'un projet spécifique
  Future<Map<String, dynamic>> getProjectStats(String projectId,
      {String? currency}) async {
    try {
      AppLogger.info(
          'AnalyticsApiService: Récupération des stats du projet $projectId');

      final response = await _apiService.get(
        '$_baseUrl/project/$projectId/',
        queryParameters: currency != null ? {'currency': currency} : null,
      );

      if (_isHtmlResponse(response.data)) {
        return _getDefaultProjectStats();
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      AppLogger.error(
          'AnalyticsApiService: Erreur lors de la récupération des stats du projet: ${e.message}');
      if (e.response?.statusCode == 404) {
        AppLogger.info(
            'AnalyticsApiService: Endpoint project stats non disponible, utilisation des données par défaut');
      }
      return _getDefaultProjectStats();
    } catch (e) {
      AppLogger.error(
          'AnalyticsApiService: Erreur générique getProjectStats: $e');
      return _getDefaultProjectStats();
    }
  }

  /// Récupère les métriques du tableau de bord (admin uniquement)
  Future<Map<String, dynamic>> getDashboardStats({
    String period = 'week',
    String? startDate,
    String? currency,
  }) async {
    try {
      AppLogger.info(
          'AnalyticsApiService: Récupération des stats du dashboard');

      final queryParams = <String, dynamic>{'period': period};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (currency != null) queryParams['currency'] = currency;

      final response = await _apiService.get(
        '$_baseUrl/dashboard/',
        queryParameters: queryParams,
      );

      if (_isHtmlResponse(response.data)) {
        return _getDefaultDashboardStats();
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      AppLogger.error(
          'AnalyticsApiService: Erreur lors de la récupération des stats dashboard: ${e.message}');
      if (e.response?.statusCode == 404) {
        AppLogger.info(
            'AnalyticsApiService: Endpoint dashboard stats non disponible, utilisation des données par défaut');
      }
      return _getDefaultDashboardStats();
    } catch (e) {
      AppLogger.error(
          'AnalyticsApiService: Erreur générique getDashboardStats: $e');
      return _getDefaultDashboardStats();
    }
  }

  /// Récupère les projets les plus performants
  Future<Map<String, dynamic>> getTopProjects({
    String metric = 'view_count',
    int limit = 10,
    int periodDays = 30,
    String? currency,
  }) async {
    try {
      AppLogger.info('AnalyticsApiService: Récupération des top projets');

      final queryParams = <String, dynamic>{
        'metric': metric,
        'limit': limit,
        'period_days': periodDays,
      };
      if (currency != null) queryParams['currency'] = currency;

      final response = await _apiService.get(
        '$_baseUrl/top-projects/',
        queryParameters: queryParams,
      );

      if (_isHtmlResponse(response.data)) {
        return _getDefaultTopProjects();
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      AppLogger.error(
          'AnalyticsApiService: Erreur lors de la récupération des top projets: ${e.message}');
      if (e.response?.statusCode == 404) {
        AppLogger.info(
            'AnalyticsApiService: Endpoint top projects non disponible, utilisation des données par défaut');
      }
      return _getDefaultTopProjects();
    } catch (e) {
      AppLogger.error(
          'AnalyticsApiService: Erreur générique getTopProjects: $e');
      return _getDefaultTopProjects();
    }
  }

  /// Récupère les statistiques de visiteurs (méthode pour compatibilité avec AnalyticsProvider)
  Future<Map<String, dynamic>> getVisitorStats({
    String period = 'week',
    String groupBy = 'day',
  }) async {
    try {
      AppLogger.info('AnalyticsApiService: Récupération des stats visiteurs');

      // Utilise getDashboardStats comme base car les endpoints spécialisés n'existent pas
      final response = await getDashboardStats(period: period);

      // Adapte les données pour le format attendu par AnalyticsProvider
      return {
        'period': period,
        'group_by': groupBy,
        'data': [
          {
            'date': DateTime.now()
                .subtract(const Duration(days: 7))
                .toIso8601String()
                .split('T')[0],
            'visitors': response['active_users'] ?? 0,
            'unique_visitors': response['new_users'] ?? 0,
          },
        ],
        'total_visitors': response['active_users'] ?? 0,
        'total_unique_visitors': response['new_users'] ?? 0,
      };
    } catch (e) {
      AppLogger.error('AnalyticsApiService: Erreur getVisitorStats: $e');
      return _getDefaultVisitorStats();
    }
  }

  /// Récupère les statistiques d'interactions (méthode pour compatibilité avec AnalyticsProvider)
  Future<Map<String, dynamic>> getInteractionStats({
    String period = 'week',
    String groupBy = 'day',
  }) async {
    try {
      AppLogger.info(
          'AnalyticsApiService: Récupération des stats interactions');

      final response = await getDashboardStats(period: period);

      return {
        'period': period,
        'group_by': groupBy,
        'data': [
          {
            'date': DateTime.now()
                .subtract(const Duration(days: 7))
                .toIso8601String()
                .split('T')[0],
            'views': response['total_views'] ?? 0,
            'interests': response['total_interests'] ?? 0,
            'comments': 0,
            'shares': 0,
          },
        ],
        'total_views': response['total_views'] ?? 0,
        'total_interests': response['total_interests'] ?? 0,
        'total_comments': 0,
        'total_shares': 0,
      };
    } catch (e) {
      AppLogger.error('AnalyticsApiService: Erreur getInteractionStats: $e');
      return _getDefaultInteractionStats();
    }
  }

  /// Récupère les statistiques de conversion (méthode pour compatibilité avec AnalyticsProvider)
  Future<Map<String, dynamic>> getConversionStats({
    String period = 'week',
    String groupBy = 'day',
  }) async {
    try {
      AppLogger.info('AnalyticsApiService: Récupération des stats conversion');

      final response = await getDashboardStats(period: period);

      final views = response['total_views'] ?? 1;
      final interests = response['total_interests'] ?? 0;
      final investments = response['total_investment'] ?? 0.0;

      return {
        'period': period,
        'group_by': groupBy,
        'data': [
          {
            'date': DateTime.now()
                .subtract(const Duration(days: 7))
                .toIso8601String()
                .split('T')[0],
            'view_to_interest_rate':
                views > 0 ? (interests / views * 100) : 0.0,
            'interest_to_investment_rate':
                interests > 0 ? (investments > 0 ? 10.0 : 0.0) : 0.0,
          },
        ],
        'avg_view_to_interest_rate':
            views > 0 ? (interests / views * 100) : 0.0,
        'avg_interest_to_investment_rate':
            interests > 0 ? (investments > 0 ? 10.0 : 0.0) : 0.0,
      };
    } catch (e) {
      AppLogger.error('AnalyticsApiService: Erreur getConversionStats: $e');
      return _getDefaultConversionStats();
    }
  }

  /// Récupère les performances des projets (méthode pour compatibilité avec AnalyticsProvider)
  Future<Map<String, dynamic>> getProjectPerformance({
    String period = 'week',
  }) async {
    try {
      AppLogger.info(
          'AnalyticsApiService: Récupération des performances projets');

      // Utilise getTopProjects comme base
      final response =
          await getTopProjects(limit: 5, periodDays: period == 'week' ? 7 : 30);

      return {
        'period': period,
        'projects': response['projects'] ?? [],
        'total_projects': (response['projects'] as List?)?.length ?? 0,
      };
    } catch (e) {
      AppLogger.error('AnalyticsApiService: Erreur getProjectPerformance: $e');
      return _getDefaultProjectPerformance();
    }
  }

  /// Récupère les activités récentes (méthode pour compatibilité avec AnalyticsProvider)
  Future<Map<String, dynamic>> getRecentActivities({int limit = 10}) async {
    try {
      AppLogger.info(
          'AnalyticsApiService: Récupération des activités récentes');

      // Retourne des données par défaut car cet endpoint n'existe pas dans la documentation
      return _getDefaultRecentActivities(limit);
    } catch (e) {
      AppLogger.error('AnalyticsApiService: Erreur getRecentActivities: $e');
      return _getDefaultRecentActivities(limit);
    }
  }

  /// Données par défaut pour les stats utilisateur
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

  /// Données par défaut pour les stats de projet
  Map<String, dynamic> _getDefaultProjectStats() {
    return {
      'project_id': '',
      'project_name': '',
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

  /// Données par défaut pour les stats du dashboard
  Map<String, dynamic> _getDefaultDashboardStats() {
    return {
      'period_start': DateTime.now()
          .subtract(const Duration(days: 7))
          .toIso8601String()
          .split('T')[0],
      'period_end': DateTime.now().toIso8601String().split('T')[0],
      'days_count': 7,
      'currency': 'EUR',
      'new_users': 0,
      'active_users': 0,
      'new_projects': 0,
      'published_projects': 0,
      'total_views': 0,
      'total_interests': 0,
      'total_investment': 0.0,
      'new_subscriptions': 0,
      'subscription_revenue': 0.0,
      'avg_new_users_per_day': 0.0,
      'avg_active_users_per_day': 0.0,
    };
  }

  /// Données par défaut pour les top projets
  Map<String, dynamic> _getDefaultTopProjects() {
    return {
      'projects': <Map<String, dynamic>>[],
      'currency': 'EUR',
      'metric': 'view_count',
      'period_days': 30,
    };
  }

  /// Données par défaut pour les stats de visiteurs
  Map<String, dynamic> _getDefaultVisitorStats() {
    return {
      'period': 'week',
      'group_by': 'day',
      'data': <Map<String, dynamic>>[],
      'total_visitors': 0,
      'total_unique_visitors': 0,
    };
  }

  /// Données par défaut pour les stats d'interactions
  Map<String, dynamic> _getDefaultInteractionStats() {
    return {
      'period': 'week',
      'group_by': 'day',
      'data': <Map<String, dynamic>>[],
      'total_views': 0,
      'total_interests': 0,
      'total_comments': 0,
      'total_shares': 0,
    };
  }

  /// Données par défaut pour les stats de conversion
  Map<String, dynamic> _getDefaultConversionStats() {
    return {
      'period': 'week',
      'group_by': 'day',
      'data': <Map<String, dynamic>>[],
      'avg_view_to_interest_rate': 0.0,
      'avg_interest_to_investment_rate': 0.0,
    };
  }

  /// Données par défaut pour les performances de projets
  Map<String, dynamic> _getDefaultProjectPerformance() {
    return {
      'period': 'week',
      'projects': <Map<String, dynamic>>[],
      'total_projects': 0,
    };
  }

  /// Données par défaut pour les activités récentes
  Map<String, dynamic> _getDefaultRecentActivities(int limit) {
    return {
      'activities': <Map<String, dynamic>>[],
      'limit': limit,
      'total_count': 0,
    };
  }
}
