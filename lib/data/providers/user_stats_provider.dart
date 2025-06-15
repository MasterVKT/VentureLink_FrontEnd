import 'package:flutter/material.dart';
import 'package:venturelink/data/services/user_analytics_service.dart';

/// Provider pour la gestion des statistiques utilisateur
class UserStatsProvider with ChangeNotifier {
  final UserAnalyticsService _userAnalyticsService;

  UserStatsProvider(this._userAnalyticsService);

  // État
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _userStats;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get userStats => _userStats;

  // Getters pour les statistiques spécifiques
  int get projectsCreated => _userStats?['projects_created_count'] ?? 0;
  int get projectsPublished => _userStats?['projects_published_count'] ?? 0;
  int get totalProjectViews => _userStats?['total_project_views'] ?? 0;
  int get totalProjectInterests => _userStats?['total_project_interests'] ?? 0;
  int get totalCommentsReceived => _userStats?['total_comments_received'] ?? 0;
  int get investmentsMade => _userStats?['investments_made_count'] ?? 0;
  double get totalInvestmentAmount =>
      (_userStats?['total_investment_amount'] as num?)?.toDouble() ?? 0.0;
  String get totalInvestmentCurrency =>
      _userStats?['total_investment_currency'] ?? 'EUR';
  int get messagesSent => _userStats?['messages_sent_count'] ?? 0;
  int get messagesReceived => _userStats?['messages_received_count'] ?? 0;
  int get loginCount => _userStats?['login_count'] ?? 0;

  // Getters pour affichage formaté
  String get formattedInvestmentAmount {
    if (totalInvestmentAmount == 0) return '0 $totalInvestmentCurrency';

    if (totalInvestmentAmount >= 1000000) {
      return '${(totalInvestmentAmount / 1000000).toStringAsFixed(1)}M $totalInvestmentCurrency';
    } else if (totalInvestmentAmount >= 1000) {
      return '${(totalInvestmentAmount / 1000).toStringAsFixed(1)}K $totalInvestmentCurrency';
    } else {
      return '${totalInvestmentAmount.toStringAsFixed(0)} $totalInvestmentCurrency';
    }
  }

  String get averageRating {
    // Utiliser les données du profil si disponibles, sinon calculer à partir des commentaires
    if (totalCommentsReceived > 0) {
      // Estimation basique: si l'utilisateur a des commentaires positifs, on estime une note
      double estimatedRating =
          4.0 + (totalProjectInterests / (totalProjectViews + 1)) * 1.0;
      return estimatedRating.clamp(0.0, 5.0).toStringAsFixed(1);
    }
    return '0.0';
  }

  /// Charge les statistiques utilisateur
  Future<void> loadUserStats({String? currency}) async {
    _setLoading(true);
    _setError(null);

    try {
      final stats =
          await _userAnalyticsService.getUserStats(currency: currency);
      _userStats = stats;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des statistiques: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Rafraîchit les statistiques
  Future<void> refreshStats({String? currency}) async {
    await loadUserStats(currency: currency);
  }

  /// Met à jour une statistique spécifique (pour les mises à jour en temps réel)
  void updateStat(String key, dynamic value) {
    if (_userStats != null) {
      _userStats![key] = value;
      notifyListeners();
    }
  }

  /// Incrémente une statistique numérique
  void incrementStat(String key, [int increment = 1]) {
    if (_userStats != null) {
      final currentValue = (_userStats![key] as int?) ?? 0;
      _userStats![key] = currentValue + increment;
      notifyListeners();
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

  /// Nettoie les données
  void clear() {
    _userStats = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
