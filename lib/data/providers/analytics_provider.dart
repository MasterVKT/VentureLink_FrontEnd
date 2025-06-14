import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venturelink/data/services/analytics_api_service.dart';

/// Provider pour la gestion des données d'analytics et de statistiques
class AnalyticsProvider with ChangeNotifier {
  final AnalyticsApiService _apiService;

  // États
  bool _isLoading = false;
  String? _error;

  // Données
  Map<String, dynamic>? _dashboardStats;
  List<Map<String, dynamic>> _visitorStats = [];
  List<Map<String, dynamic>> _interactionStats = [];
  List<Map<String, dynamic>> _conversionStats = [];
  List<Map<String, dynamic>> _projectPerformance = [];
  List<Map<String, dynamic>> _recentActivities = [];

  // Filtres et paramètres
  String _period = '30'; // Par défaut: 30 jours
  String _groupBy = 'day'; // Par défaut: groupé par jour

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;
  List<Map<String, dynamic>> get visitorStats => _visitorStats;
  List<Map<String, dynamic>> get interactionStats => _interactionStats;
  List<Map<String, dynamic>> get conversionStats => _conversionStats;
  List<Map<String, dynamic>> get projectPerformance => _projectPerformance;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  String get period => _period;
  String get groupBy => _groupBy;

  // Constructeur
  AnalyticsProvider(this._apiService);

  /// Charge les statistiques générales du tableau de bord
  Future<void> loadDashboardStats() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getDashboardStats();
      _dashboardStats = response;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des statistiques: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les statistiques de visiteurs pour la période sélectionnée
  Future<void> loadVisitorStats() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getVisitorStats(
        period: _period,
        groupBy: _groupBy,
      );
      _visitorStats = response;
      notifyListeners();
    } catch (e) {
      _setError(
          'Erreur lors du chargement des statistiques de visiteurs: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les statistiques d'interactions pour la période sélectionnée
  Future<void> loadInteractionStats() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getInteractionStats(
        period: _period,
        groupBy: _groupBy,
      );
      _interactionStats = response;
      notifyListeners();
    } catch (e) {
      _setError(
          'Erreur lors du chargement des statistiques d\'interactions: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les statistiques de conversion pour la période sélectionnée
  Future<void> loadConversionStats() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getConversionStats(
        period: _period,
        groupBy: _groupBy,
      );
      _conversionStats = response;
      notifyListeners();
    } catch (e) {
      _setError(
          'Erreur lors du chargement des statistiques de conversion: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les performances des projets
  Future<void> loadProjectPerformance() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getProjectPerformance(
        period: _period,
      );
      _projectPerformance = response;
      notifyListeners();
    } catch (e) {
      _setError(
          'Erreur lors du chargement des performances des projets: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge les activités récentes
  Future<void> loadRecentActivities({int limit = 10}) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getRecentActivities(limit: limit);
      _recentActivities = response;
      notifyListeners();
    } catch (e) {
      _setError(
          'Erreur lors du chargement des activités récentes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Change la période d'analyse
  void setPeriod(String period) {
    if (_period != period) {
      _period = period;
      notifyListeners();

      // Recharger les données avec la nouvelle période
      loadVisitorStats();
      loadInteractionStats();
      loadConversionStats();
      loadProjectPerformance();
    }
  }

  /// Change le regroupement des données
  void setGroupBy(String groupBy) {
    if (_groupBy != groupBy) {
      _groupBy = groupBy;
      notifyListeners();

      // Recharger les données avec le nouveau regroupement
      loadVisitorStats();
      loadInteractionStats();
      loadConversionStats();
    }
  }

  /// Charge toutes les données d'analytics en une seule fois
  Future<void> loadAllAnalytics() async {
    _setLoading(true);
    _setError(null);

    try {
      await Future.wait([
        loadDashboardStats(),
        loadVisitorStats(),
        loadInteractionStats(),
        loadConversionStats(),
        loadProjectPerformance(),
        loadRecentActivities(),
      ]);
    } catch (e) {
      _setError(
          'Erreur lors du chargement des données d\'analytics: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  /// Formatte une date pour l'affichage
  String formatDate(DateTime date, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Calcule le pourcentage de variation entre deux valeurs
  double calculatePercentageChange(double current, double previous) {
    if (previous == 0) return current > 0 ? 100 : 0;
    return ((current - previous) / previous) * 100;
  }

  /// Obtient la couleur associée à une variation (positive, négative, neutre)
  Color getChangeColor(double change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Colors.red;
    return Colors.grey;
  }

  /// Obtient l'icône associée à une variation (positive, négative, neutre)
  IconData getChangeIcon(double change) {
    if (change > 0) return Icons.arrow_upward;
    if (change < 0) return Icons.arrow_downward;
    return Icons.remove;
  }
}
