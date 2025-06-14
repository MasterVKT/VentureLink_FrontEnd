import 'package:venturelink/data/models/investment_model.dart';
import 'package:venturelink/data/services/api_service.dart';

class InvestmentApiService {
  final ApiService _apiService;

  InvestmentApiService(this._apiService);

  /// Récupérer la liste des investissements
  Future<List<InvestmentModel>> getInvestments({
    String? status,
    String? investmentType,
    String? projectId,
    String? investorId,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null) queryParams['status'] = status;
    if (investmentType != null) queryParams['investment_type'] = investmentType;
    if (projectId != null) queryParams['project_id'] = projectId;
    if (investorId != null) queryParams['investor_id'] = investorId;

    final response = await _apiService.get(
      '/investments/',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['results'] ?? response.data;
      return data.map((json) => InvestmentModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des investissements');
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
      throw Exception('Erreur lors du chargement de l\'investissement');
    }
  }

  /// Créer un nouvel investissement
  Future<InvestmentModel?> createInvestment({
    required String projectId,
    required double amount,
    String? currency,
    required String investmentType,
    double? equityPercentage,
    double? interestRate,
    int? termMonths,
    String? description,
  }) async {
    final data = {
      'project_id': projectId,
      'amount': amount,
      'currency': currency ?? 'EUR',
      'investment_type': investmentType,
      if (equityPercentage != null) 'equity_percentage': equityPercentage,
      if (interestRate != null) 'interest_rate': interestRate,
      if (termMonths != null) 'term_months': termMonths,
      if (description != null) 'description': description,
    };

    final response = await _apiService.post('/investments/', data: data);

    if (response.statusCode == 201) {
      return InvestmentModel.fromJson(response.data);
    } else {
      throw Exception('Erreur lors de la création de l\'investissement');
    }
  }

  /// Mettre à jour un investissement
  Future<InvestmentModel?> updateInvestment(
    String investmentId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/investments/$investmentId/',
      data: data,
    );

    if (response.statusCode == 200) {
      return InvestmentModel.fromJson(response.data);
    } else {
      throw Exception('Erreur lors de la mise à jour de l\'investissement');
    }
  }

  /// Approuver un investissement
  Future<bool> approveInvestment(String investmentId) async {
    final response = await _apiService.post(
      '/investments/$investmentId/approve/',
    );

    return response.statusCode == 200;
  }

  /// Rejeter un investissement
  Future<bool> rejectInvestment(String investmentId, {String? reason}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;

    final response = await _apiService.post(
      '/investments/$investmentId/reject/',
      data: data,
    );

    return response.statusCode == 200;
  }

  /// Annuler un investissement
  Future<bool> cancelInvestment(String investmentId, {String? reason}) async {
    final data = <String, dynamic>{};
    if (reason != null) data['reason'] = reason;

    final response = await _apiService.post(
      '/investments/$investmentId/cancel/',
      data: data,
    );

    return response.statusCode == 200;
  }

  /// Finaliser un investissement
  Future<bool> completeInvestment(String investmentId) async {
    final response = await _apiService.post(
      '/investments/$investmentId/complete/',
    );

    return response.statusCode == 200;
  }

  /// Récupérer les statistiques d'investissement
  Future<InvestmentStatsModel?> getInvestmentStats() async {
    final response = await _apiService.get('/investments/stats/');

    if (response.statusCode == 200) {
      return InvestmentStatsModel.fromJson(response.data);
    } else {
      throw Exception('Erreur lors du chargement des statistiques');
    }
  }

  /// Télécharger un contrat d'investissement
  Future<String?> downloadContract(String investmentId) async {
    final response = await _apiService.get(
      '/investments/$investmentId/contract/',
    );

    if (response.statusCode == 200) {
      return response.data['download_url'];
    } else {
      throw Exception('Erreur lors du téléchargement du contrat');
    }
  }

  /// Uploader un contrat signé
  Future<bool> uploadSignedContract(
    String investmentId,
    String filePath,
  ) async {
    // TODO: Implémenter l'upload de fichiers quand la méthode sera disponible
    return false;
  }
}

// Modèles supplémentaires pour l'historique et les paiements
class InvestmentHistoryModel {
  final String id;
  final String investmentId;
  final String action;
  final String? description;
  final DateTime createdAt;

  InvestmentHistoryModel({
    required this.id,
    required this.investmentId,
    required this.action,
    this.description,
    required this.createdAt,
  });

  factory InvestmentHistoryModel.fromJson(Map<String, dynamic> json) {
    return InvestmentHistoryModel(
      id: json['id'],
      investmentId: json['investment_id'],
      action: json['action'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class PaymentModel {
  final String id;
  final String investmentId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? description;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.investmentId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.description,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'],
      investmentId: json['investment_id'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
