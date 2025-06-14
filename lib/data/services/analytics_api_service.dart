import 'package:dio/dio.dart';
import 'package:venturelink/core/errors/api_exceptions.dart';
import 'package:venturelink/data/services/api_service.dart';

/// Service API pour les données d'analytics et statistiques
class AnalyticsApiService {
  final ApiService _apiService;
  final String _baseUrl;

  AnalyticsApiService(this._apiService, {String? baseUrl})
      : _baseUrl = baseUrl ?? '/analytics';

  /// Récupère les statistiques générales du tableau de bord
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _apiService.get('$_baseUrl/dashboard');

      // Pour le développement, simulons des données
      if (response.data == null) {
        return _getMockDashboardStats();
      }

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère les statistiques de visiteurs
  Future<List<Map<String, dynamic>>> getVisitorStats({
    required String period,
    required String groupBy,
  }) async {
    try {
      final response = await _apiService.get(
        '$_baseUrl/visitors',
        queryParameters: {
          'period': period,
          'group_by': groupBy,
        },
      );

      // Pour le développement, simulons des données
      if (response.data == null) {
        return _getMockVisitorStats(period, groupBy);
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère les statistiques d'interactions
  Future<List<Map<String, dynamic>>> getInteractionStats({
    required String period,
    required String groupBy,
  }) async {
    try {
      final response = await _apiService.get(
        '$_baseUrl/interactions',
        queryParameters: {
          'period': period,
          'group_by': groupBy,
        },
      );

      // Pour le développement, simulons des données
      if (response.data == null) {
        return _getMockInteractionStats(period, groupBy);
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère les statistiques de conversion
  Future<List<Map<String, dynamic>>> getConversionStats({
    required String period,
    required String groupBy,
  }) async {
    try {
      final response = await _apiService.get(
        '$_baseUrl/conversions',
        queryParameters: {
          'period': period,
          'group_by': groupBy,
        },
      );

      // Pour le développement, simulons des données
      if (response.data == null) {
        return _getMockConversionStats(period, groupBy);
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère les performances des projets
  Future<List<Map<String, dynamic>>> getProjectPerformance({
    required String period,
  }) async {
    try {
      final response = await _apiService.get(
        '$_baseUrl/projects/performance',
        queryParameters: {
          'period': period,
        },
      );

      // Pour le développement, simulons des données
      if (response.data == null) {
        return _getMockProjectPerformance(period);
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère les activités récentes
  Future<List<Map<String, dynamic>>> getRecentActivities(
      {int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '$_baseUrl/activities',
        queryParameters: {
          'limit': limit,
        },
      );

      // Pour le développement, simulons des données
      if (response.data == null) {
        return _getMockRecentActivities(limit);
      }

      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Génère des données simulées pour le développement
  Map<String, dynamic> _getMockDashboardStats() {
    return {
      'total_projects': 5,
      'total_views': 1250,
      'total_interactions': 87,
      'total_messages': 43,
      'total_investments': 2,
      'total_invested': 75000,
      'avg_view_duration': 145,
      'projects': {
        'active': 3,
        'draft': 1,
        'funded': 1,
        'archived': 0,
      },
      'growth': {
        'views': 12.5,
        'interactions': 8.3,
        'messages': -5.2,
        'investments': 100.0,
      },
    };
  }

  List<Map<String, dynamic>> _getMockVisitorStats(
      String period, String groupBy) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    final daysToGenerate = int.tryParse(period) ?? 30;

    // Générer des données quotidiennes
    for (var i = 0; i < daysToGenerate; i++) {
      final date = now.subtract(Duration(days: daysToGenerate - i - 1));
      data.add({
        'date': date.toIso8601String(),
        'views': 30 + (i % 5) * 10 + (i ~/ 7) * 20,
        'unique_visitors': 15 + (i % 3) * 5 + (i ~/ 10) * 10,
        'returning_visitors': 5 + (i % 2) * 3 + (i ~/ 12) * 5,
      });
    }

    // Si groupBy est 'week' ou 'month', agréger les données
    if (groupBy == 'week' || groupBy == 'month') {
      return _aggregateData(data, groupBy);
    }

    return data;
  }

  List<Map<String, dynamic>> _getMockInteractionStats(
      String period, String groupBy) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    final daysToGenerate = int.tryParse(period) ?? 30;

    // Générer des données quotidiennes
    for (var i = 0; i < daysToGenerate; i++) {
      final date = now.subtract(Duration(days: daysToGenerate - i - 1));
      data.add({
        'date': date.toIso8601String(),
        'favorites': 2 + (i % 3),
        'shares': 1 + (i % 2),
        'comments': i % 5,
        'interests': i % 4,
      });
    }

    // Si groupBy est 'week' ou 'month', agréger les données
    if (groupBy == 'week' || groupBy == 'month') {
      return _aggregateData(data, groupBy);
    }

    return data;
  }

  List<Map<String, dynamic>> _getMockConversionStats(
      String period, String groupBy) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    final daysToGenerate = int.tryParse(period) ?? 30;

    // Générer des données quotidiennes
    for (var i = 0; i < daysToGenerate; i++) {
      final date = now.subtract(Duration(days: daysToGenerate - i - 1));
      data.add({
        'date': date.toIso8601String(),
        'view_to_interest': 2.0 + (i % 10) / 10,
        'interest_to_contact': 10.0 + (i % 15),
        'contact_to_investment': i % 5 == 0 ? 5.0 + (i % 10) : 0,
      });
    }

    // Si groupBy est 'week' ou 'month', agréger les données
    if (groupBy == 'week' || groupBy == 'month') {
      return _aggregateData(data, groupBy);
    }

    return data;
  }

  List<Map<String, dynamic>> _getMockProjectPerformance(String period) {
    return [
      {
        'id': 'project1',
        'title': 'Application IA révolutionnaire',
        'views': 450,
        'interests': 35,
        'messages': 22,
        'investments': 1,
        'amount': 25000,
        'conversion_rate': 7.8,
        'growth': 12.5,
      },
      {
        'id': 'project2',
        'title': 'Plateforme éducative innovante',
        'views': 380,
        'interests': 28,
        'messages': 15,
        'investments': 1,
        'amount': 50000,
        'conversion_rate': 7.4,
        'growth': 8.3,
      },
      {
        'id': 'project3',
        'title': 'Solution de finance durable',
        'views': 320,
        'interests': 18,
        'messages': 6,
        'investments': 0,
        'amount': 0,
        'conversion_rate': 5.6,
        'growth': -2.1,
      },
      {
        'id': 'project4',
        'title': 'Service de livraison écologique',
        'views': 100,
        'interests': 6,
        'messages': 0,
        'investments': 0,
        'amount': 0,
        'conversion_rate': 6.0,
        'growth': 0,
      },
    ];
  }

  List<Map<String, dynamic>> _getMockRecentActivities(int limit) {
    final activities = [
      {
        'id': 'activity1',
        'type': 'view',
        'target_type': 'project',
        'target_id': 'project1',
        'target_name': 'Application IA révolutionnaire',
        'user_id': 'user1',
        'user_name': 'Jean Dupont',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'id': 'activity2',
        'type': 'interest',
        'target_type': 'project',
        'target_id': 'project2',
        'target_name': 'Plateforme éducative innovante',
        'user_id': 'user2',
        'user_name': 'Marie Martin',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
      },
      {
        'id': 'activity3',
        'type': 'message',
        'target_type': 'conversation',
        'target_id': 'conv1',
        'target_name': 'Conversation avec Pierre Durand',
        'user_id': 'user3',
        'user_name': 'Pierre Durand',
        'timestamp':
            DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
      },
      {
        'id': 'activity4',
        'type': 'investment',
        'target_type': 'project',
        'target_id': 'project1',
        'target_name': 'Application IA révolutionnaire',
        'user_id': 'user4',
        'user_name': 'Sophie Petit',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 1, hours: 3))
            .toIso8601String(),
        'amount': 25000,
      },
      {
        'id': 'activity5',
        'type': 'comment',
        'target_type': 'project',
        'target_id': 'project3',
        'target_name': 'Solution de finance durable',
        'user_id': 'user5',
        'user_name': 'Paul Grand',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 1, hours: 12))
            .toIso8601String(),
      },
      {
        'id': 'activity6',
        'type': 'view',
        'target_type': 'project',
        'target_id': 'project4',
        'target_name': 'Service de livraison écologique',
        'user_id': 'user6',
        'user_name': 'Lucie Blanc',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 2, hours: 4))
            .toIso8601String(),
      },
      {
        'id': 'activity7',
        'type': 'profile_view',
        'target_type': 'user',
        'target_id': 'current_user',
        'target_name': 'Votre profil',
        'user_id': 'user7',
        'user_name': 'Thomas Noir',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 2, hours: 14))
            .toIso8601String(),
      },
      {
        'id': 'activity8',
        'type': 'investment',
        'target_type': 'project',
        'target_id': 'project2',
        'target_name': 'Plateforme éducative innovante',
        'user_id': 'user8',
        'user_name': 'Claire Vert',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 3, hours: 9))
            .toIso8601String(),
        'amount': 50000,
      },
      {
        'id': 'activity9',
        'type': 'share',
        'target_type': 'project',
        'target_id': 'project1',
        'target_name': 'Application IA révolutionnaire',
        'user_id': 'user9',
        'user_name': 'Antoine Rouge',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 3, hours: 18))
            .toIso8601String(),
      },
      {
        'id': 'activity10',
        'type': 'message',
        'target_type': 'conversation',
        'target_id': 'conv2',
        'target_name': 'Conversation avec Claire Vert',
        'user_id': 'user8',
        'user_name': 'Claire Vert',
        'timestamp': DateTime.now()
            .subtract(const Duration(days: 4, hours: 2))
            .toIso8601String(),
      },
    ];

    return activities.take(limit).toList();
  }

  /// Agrège les données par semaine ou mois
  List<Map<String, dynamic>> _aggregateData(
    List<Map<String, dynamic>> data,
    String groupBy,
  ) {
    final Map<String, Map<String, dynamic>> result = {};

    for (var item in data) {
      final date = DateTime.parse(item['date'] as String);
      String key;

      if (groupBy == 'week') {
        // Obtenir le premier jour de la semaine
        final firstDayOfWeek = date.subtract(Duration(days: date.weekday - 1));
        key = firstDayOfWeek.toIso8601String().substring(0, 10);
      } else if (groupBy == 'month') {
        // Obtenir le premier jour du mois
        key = '${date.year}-${date.month.toString().padLeft(2, '0')}-01';
      } else {
        key = (item['date'] as String).substring(0, 10);
      }

      if (!result.containsKey(key)) {
        result[key] = {
          'date': key,
        };
      }

      // Agréger toutes les valeurs numériques
      item.forEach((k, v) {
        if (k != 'date' && v is num) {
          result[key]![k] = (result[key]![k] as num? ?? 0) + v;
        }
      });
    }

    return result.values.toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }
}
