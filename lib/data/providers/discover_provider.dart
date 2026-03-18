import 'package:flutter/foundation.dart';
import 'package:venturelink/data/services/discover_api_service.dart';
import 'package:venturelink/data/models/project_model.dart';

/// Provider pour l'écran de découverte (Discover)
/// Gère l'état et les données des 4 sections de projets
class DiscoverProvider extends ChangeNotifier {
  final DiscoverApiService _apiService;

  List<ProjectModel> _recommendedProjects = [];
  List<ProjectModel> _trendingProjects = [];
  List<ProjectModel> _newProjects = [];
  List<ProjectModel> _almostFundedProjects = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<ProjectModel> get recommendedProjects => _recommendedProjects;
  List<ProjectModel> get trendingProjects => _trendingProjects;
  List<ProjectModel> get newProjects => _newProjects;
  List<ProjectModel> get almostFundedProjects => _almostFundedProjects;
  bool get isLoading => _isLoading;
  String? get error => _error;

  DiscoverProvider(this._apiService);

  /// Charge toutes les données de l'écran de découverte
  Future<void> loadDiscoverData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getDiscoverData();

      _recommendedProjects = response.recommended;
      _trendingProjects = response.trending;
      _newProjects = response.newProjects;
      _almostFundedProjects = response.almostFunded;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Réinitialise les données (pour pull-to-refresh)
  void clearData() {
    _recommendedProjects = [];
    _trendingProjects = [];
    _newProjects = [];
    _almostFundedProjects = [];
    _error = null;
    notifyListeners();
  }
}
