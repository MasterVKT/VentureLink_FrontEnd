import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../../domain/services/i_api_service.dart';

/// Provider pour la gestion des recommandations et du matching
class MatchingProvider with ChangeNotifier {
  final IApiService _apiService;

  MatchingProvider(this._apiService);

  // États
  bool _isLoading = false;
  String? _error;
  List<ProjectModel> _recommendations = [];
  List<UserModel> _recommendedUsers = [];
  bool _hasMoreRecommendations = true;
  int _page = 1;

  // Filtres
  Map<String, dynamic> _filters = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProjectModel> get recommendations => _recommendations;
  List<UserModel> get recommendedUsers => _recommendedUsers;
  bool get hasMoreRecommendations => _hasMoreRecommendations;
  Map<String, dynamic> get filters => _filters;

  /// Obtenir les recommandations de projets
  Future<void> getRecommendations({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _page = 1;
      _hasMoreRecommendations = true;
    }

    if (!_hasMoreRecommendations && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = {
        'page': _page,
        'page_size': 10,
        ..._filters,
      };

      final response = await _apiService.get('/api/v1/matching/projects/',
          queryParameters: params);
      final List<dynamic> results = response.data['results'] ?? [];
      final newRecommendations =
          results.map((json) => ProjectModel.fromJson(json)).toList();

      if (refresh) {
        _recommendations = newRecommendations;
      } else {
        _recommendations.addAll(newRecommendations);
      }

      _hasMoreRecommendations = newRecommendations.isNotEmpty;
      if (_hasMoreRecommendations) _page++;
    } catch (e) {
      _error = 'Erreur lors du chargement des recommandations: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtenir les recommandations d'utilisateurs
  Future<void> getRecommendedUsers({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/v1/matching/users/');
      final List<dynamic> results = response.data['results'] ?? [];
      _recommendedUsers =
          results.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des utilisateurs recommandés: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour les filtres
  void updateFilters(Map<String, dynamic> newFilters) {
    _filters = newFilters;
    _page = 1;
    _hasMoreRecommendations = true;
    notifyListeners();
  }

  /// Ajouter un filtre
  void addFilter(String key, dynamic value) {
    _filters[key] = value;
    _page = 1;
    _hasMoreRecommendations = true;
    notifyListeners();
  }

  /// Supprimer un filtre
  void removeFilter(String key) {
    _filters.remove(key);
    _page = 1;
    _hasMoreRecommendations = true;
    notifyListeners();
  }

  /// Effacer tous les filtres
  void clearFilters() {
    _filters = {};
    _page = 1;
    _hasMoreRecommendations = true;
    notifyListeners();
  }

  /// Indiquer un intérêt pour un projet
  Future<bool> showInterest(String projectId) async {
    try {
      await _apiService.post('/api/v1/projects/$projectId/interest/');
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'indication d\'intérêt: $e';
      notifyListeners();
      return false;
    }
  }

  /// Refuser un projet
  Future<bool> dismissProject(String projectId) async {
    try {
      await _apiService.post('/api/v1/projects/$projectId/dismiss/');
      _recommendations.removeWhere((project) => project.id == projectId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors du refus du projet: $e';
      notifyListeners();
      return false;
    }
  }

  /// Réinitialiser l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
