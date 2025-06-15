import 'package:venturelink/data/models/investment_model.dart';
import 'package:venturelink/data/models/investment_stats_model.dart' as stats;
import 'package:venturelink/data/services/api_service.dart';

class InvestmentApiService {
  final ApiService _apiService;

  InvestmentApiService(this._apiService);

  /// Récupérer la liste des investissements avec filtres
  Future<List<InvestmentModel>> getInvestments({
    String? projectId,
    String? status,
    String? investmentType,
    String? ordering = '-created_at',
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, dynamic>{};
    if (projectId != null) queryParams['project_id'] = projectId;
    if (status != null) queryParams['status'] = status;
    if (investmentType != null) queryParams['investment_type'] = investmentType;
    if (ordering != null) queryParams['ordering'] = ordering;
    if (page != null) queryParams['page'] = page;
    if (pageSize != null) queryParams['page_size'] = pageSize;

    final response = await _apiService.get(
      '/investments/',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final results = data['results'] as List? ?? data as List;
      return results.map((json) => InvestmentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load investments: ${response.statusCode}');
    }
  }

  /// Récupérer un investissement spécifique
  Future<InvestmentModel?> getInvestment(String investmentId) async {
    final response = await _apiService.get('/investments/$investmentId/');

    if (response.statusCode == 200) {
      return InvestmentModel.fromJson(response.data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load investment: ${response.statusCode}');
    }
  }

  /// Créer un nouvel investissement
  Future<InvestmentModel?> createInvestment({
    required String projectId,
    required double amount,
    String currency = 'EUR',
    required String investmentType,
    double? equityPercentage,
    double? interestRate,
    int? termMonths,
    String? description,
  }) async {
    final body = {
      'project_id': projectId,
      'amount': amount.toString(),
      'currency': currency,
      'investment_type': investmentType,
      if (equityPercentage != null)
        'equity_percentage': equityPercentage.toString(),
      if (interestRate != null) 'interest_rate': interestRate.toString(),
      if (termMonths != null) 'term_months': termMonths,
      if (description != null) 'description': description,
    };

    final response = await _apiService.post('/investments/', data: body);

    if (response.statusCode == 201) {
      return InvestmentModel.fromJson(response.data);
    } else {
      // Essayer de parser l'erreur pour un message plus spécifique
      try {
        final errorData = response.data;
        if (errorData is Map<String, dynamic>) {
          final errors = <String>[];
          errorData.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.map((e) => '$key: $e'));
            } else {
              errors.add('$key: $value');
            }
          });
          throw Exception('Erreur de validation: ${errors.join(', ')}');
        }
      } catch (_) {
        // Ignorer les erreurs de parsing et utiliser le message générique
      }

      throw Exception('Failed to create investment: ${response.statusCode}');
    }
  }

  /// Mettre à jour un investissement (uniquement si PENDING)
  Future<InvestmentModel?> updateInvestment(
      String investmentId, Map<String, dynamic> data) async {
    final response =
        await _apiService.put('/investments/$investmentId/', data: data);

    if (response.statusCode == 200) {
      return InvestmentModel.fromJson(response.data);
    } else {
      throw Exception('Failed to update investment: ${response.statusCode}');
    }
  }

  /// Mettre à jour le statut d'un investissement
  Future<bool> updateInvestmentStatus(String investmentId, String status,
      {String? comment}) async {
    final body = {
      'status': status,
      if (comment != null) 'comment': comment,
    };

    final response = await _apiService
        .patch('/investments/$investmentId/update_status/', data: body);
    return response.statusCode == 200;
  }

  /// Approuver un investissement
  Future<bool> approveInvestment(String investmentId, {String? comment}) async {
    return updateInvestmentStatus(investmentId, 'APPROVED', comment: comment);
  }

  /// Rejeter un investissement
  Future<bool> rejectInvestment(String investmentId, {String? reason}) async {
    return updateInvestmentStatus(investmentId, 'REJECTED', comment: reason);
  }

  /// Annuler un investissement
  Future<bool> cancelInvestment(String investmentId, {String? reason}) async {
    return updateInvestmentStatus(investmentId, 'CANCELLED', comment: reason);
  }

  /// Finaliser un investissement
  Future<bool> completeInvestment(String investmentId) async {
    return updateInvestmentStatus(investmentId, 'COMPLETED');
  }

  /// Récupérer les statistiques d'investissement
  Future<stats.InvestmentStatsModel?> getInvestmentStats() async {
    final response = await _apiService.get('/investments/stats/');

    if (response.statusCode == 200) {
      return stats.InvestmentStatsModel.fromJson(response.data);
    } else {
      throw Exception(
          'Failed to load investment statistics: ${response.statusCode}');
    }
  }

  /// Récupérer les investissements par statut
  Future<List<InvestmentModel>> getInvestmentsByStatus(String status) async {
    return getInvestments(status: status);
  }

  /// Récupérer les investissements d'un projet
  Future<List<InvestmentModel>> getProjectInvestments(String projectId) async {
    return getInvestments(projectId: projectId);
  }

  /// Supprimer un investissement (uniquement si PENDING)
  Future<bool> deleteInvestment(String investmentId) async {
    final response = await _apiService.delete('/investments/$investmentId/');
    return response.statusCode == 204;
  }
}
