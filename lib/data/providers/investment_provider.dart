import 'package:flutter/material.dart';
import 'package:venturelink/data/models/investment_model.dart';
import 'package:venturelink/data/services/investment_api_service.dart';
import 'package:venturelink/data/services/api_service.dart';

class InvestmentProvider extends ChangeNotifier {
  late final InvestmentApiService _investmentApiService;

  List<InvestmentModel> _investments = [];
  InvestmentModel? _currentInvestment;
  bool _isLoading = false;
  String? _error;
  InvestmentStatsModel? _stats;

  List<InvestmentModel> get investments => _investments;
  InvestmentModel? get currentInvestment => _currentInvestment;
  bool get isLoading => _isLoading;
  String? get error => _error;
  InvestmentStatsModel? get stats => _stats;

  InvestmentProvider() {
    _investmentApiService = InvestmentApiService(ApiService());
    _init();
  }

  Future<void> _init() async {
    await loadInvestments();
    await loadStats();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Charger les investissements
  Future<void> loadInvestments({
    String? status,
    String? investmentType,
    String? projectId,
    String? investorId,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      _investments = await _investmentApiService.getInvestments(
        status: status,
        investmentType: investmentType,
        projectId: projectId,
        investorId: investorId,
      );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Charger un investissement spécifique
  Future<void> loadInvestment(String investmentId) async {
    _setLoading(true);
    _setError(null);

    try {
      final investment =
          await _investmentApiService.getInvestment(investmentId);
      if (investment != null) {
        _currentInvestment = investment;
      } else {
        _setError('Investissement non trouvé');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Créer un nouvel investissement
  Future<bool> createInvestment({
    required String projectId,
    required double amount,
    String? currency,
    required String investmentType,
    double? equityPercentage,
    double? interestRate,
    int? termMonths,
    String? description,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final investment = await _investmentApiService.createInvestment(
        projectId: projectId,
        amount: amount,
        currency: currency,
        investmentType: investmentType,
        equityPercentage: equityPercentage,
        interestRate: interestRate,
        termMonths: termMonths,
        description: description,
      );

      if (investment != null) {
        _investments.insert(0, investment);
        _currentInvestment = investment;
        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la création de l\'investissement');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Mettre à jour un investissement
  Future<bool> updateInvestment(
      String investmentId, Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedInvestment =
          await _investmentApiService.updateInvestment(investmentId, data);

      if (updatedInvestment != null) {
        final index = _investments.indexWhere((i) => i.id == investmentId);
        if (index != -1) {
          _investments[index] = updatedInvestment;
        }

        if (_currentInvestment?.id == investmentId) {
          _currentInvestment = updatedInvestment;
        }

        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la mise à jour de l\'investissement');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Approuver un investissement
  Future<bool> approveInvestment(String investmentId) async {
    try {
      final success =
          await _investmentApiService.approveInvestment(investmentId);
      if (success) {
        await loadInvestment(investmentId);
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Rejeter un investissement
  Future<bool> rejectInvestment(String investmentId, {String? reason}) async {
    try {
      final success = await _investmentApiService.rejectInvestment(
        investmentId,
        reason: reason,
      );
      if (success) {
        await loadInvestment(investmentId);
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Annuler un investissement
  Future<bool> cancelInvestment(String investmentId, {String? reason}) async {
    try {
      final success = await _investmentApiService.cancelInvestment(
        investmentId,
        reason: reason,
      );
      if (success) {
        await loadInvestment(investmentId);
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Finaliser un investissement
  Future<bool> completeInvestment(String investmentId) async {
    try {
      final success =
          await _investmentApiService.completeInvestment(investmentId);
      if (success) {
        await loadInvestment(investmentId);
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Charger les statistiques d'investissement
  Future<void> loadStats() async {
    try {
      _stats = await _investmentApiService.getInvestmentStats();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Filtrer les investissements par statut
  List<InvestmentModel> getInvestmentsByStatus(String status) {
    return _investments.where((i) => i.status == status).toList();
  }

  /// Obtenir les investissements en attente
  List<InvestmentModel> get pendingInvestments =>
      getInvestmentsByStatus('PENDING');

  /// Obtenir les investissements approuvés
  List<InvestmentModel> get approvedInvestments =>
      getInvestmentsByStatus('APPROVED');

  /// Obtenir les investissements complétés
  List<InvestmentModel> get completedInvestments =>
      getInvestmentsByStatus('COMPLETED');

  void clearCurrentInvestment() {
    _currentInvestment = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
