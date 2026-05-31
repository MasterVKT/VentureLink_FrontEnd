import 'package:flutter/foundation.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/data/services/project_api_service.dart';
import 'package:venturelink/data/services/api_service.dart';

class ProjectProvider extends ChangeNotifier {
  late final ProjectApiService _projectApiService;

  List<ProjectModel> _projects = [];
  List<ProjectModel> _featuredProjects = [];
  List<ProjectModel> _trendingProjects = [];
  List<ProjectModel> _recommendedProjects = [];
  List<CategoryModel> _categories = [];
  List<TagModel> _tags = [];
  ProjectModel? _currentProject;
  bool _isLoading = false;
  String? _error;
  bool _isLoadingProjects = false;

// Favoris
List<ProjectModel> _favoriteProjects = [];
bool _isLoadingFavorites = false;

  // Pagination
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  static const int pageSize = 20;

  // Filtres
  ProjectFilters _filters = ProjectFilters();

  List<ProjectModel> get projects => _projects;
  List<ProjectModel> get featuredProjects => _featuredProjects;
  List<ProjectModel> get trendingProjects => _trendingProjects;
  List<ProjectModel> get recommendedProjects => _recommendedProjects;
  List<CategoryModel> get categories => _categories;
  List<TagModel> get tags => _tags;
  ProjectModel? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  bool get isLoadingProjects => _isLoadingProjects;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  ProjectFilters get filters => _filters;
  bool get isLoadingMore => _isLoadingMore;

List<ProjectModel> get favoriteProjects => _favoriteProjects;
bool get isLoadingFavorites => _isLoadingFavorites;

  // Getter pour les projets de l'utilisateur actuel
  List<ProjectModel> get userProjects =>
      _projects.where((p) => p.creator.id == 'current_user_id').toList();

  ProjectProvider() {
    _projectApiService = ProjectApiService(ApiService());
    _init();
  }

  Future<void> _init() async {
    // Diagnostiquer les problèmes d'API en mode debug
    if (kDebugMode) {
      await _projectApiService.diagnoseApiIssues();
    }

    await loadCategories();
    await loadTags();
    await loadProjects();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Charger les projets depuis l'API avec pagination et filtres
  Future<void> loadProjects({
    bool forceRefresh = false,
    int? page,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
      notifyListeners();
    } else {
      if (_isLoadingProjects && !forceRefresh) return;
      _isLoadingProjects = true;
      _currentPage = 1;
      notifyListeners();
    }

    try {
      final targetPage = page ?? _currentPage;

      // Charger tous les projets avec filtres et pagination
      final allProjectsResult = await _projectApiService.getProjects(
        page: targetPage,
        pageSize: pageSize,
        search: _filters.searchQuery,
        category: _filters.categoryId,
        stage: _filters.stage,
        location: _filters.locationCountry,
        fundingMin: _filters.fundingMin,
        fundingMax: _filters.fundingMax,
        tags: _filters.tagIds.isEmpty ? null : _filters.tagIds,
        sortBy: _filters.sortBy,
      );

      if (allProjectsResult.isSuccess && allProjectsResult.projects != null) {
        final newProjects = allProjectsResult.projects!;
        
        if (loadMore) {
          // Ajouter aux projets existants
          _projects.addAll(newProjects);
          _currentPage = targetPage + 1;
          _hasMore = newProjects.length >= pageSize;
        } else {
          // Remplacer la liste
          _projects = newProjects;
          _currentPage = targetPage + 1;
          _hasMore = newProjects.length >= pageSize;
        }
        
        debugPrint(
            '[ProjectProvider] ${_projects.length} projets au total chargés (page $targetPage)');
      } else {
        debugPrint(
            '[ProjectProvider] Erreur lors du chargement de tous les projets: ${allProjectsResult.error}');
        if (!loadMore) {
          _projects = [];
        }
        _hasMore = false;
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des projets: $e');
      if (!loadMore) {
        _projects = [];
      }
      _hasMore = false;
    } finally {
      _isLoadingProjects = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Charger un projet spécifique
  Future<void> loadProject(String projectId) async {
    _setLoading(true);
    _setError(null);

    try {
      final project = await _projectApiService.getProject(projectId);
      if (project != null) {
        _currentProject = project;
      } else {
        _setError('Projet non trouvé');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  /// Charger les projets avec pagination
Future<List<ProjectModel>> fetchProjectsPage({
  required int page,
  int pageSize = 20,
}) async {
  try {
    debugPrint('[ProjectProvider] 📥 Chargement page $page ($pageSize projets)');
    
    // Charger tous les projets (pour l'instant)
    await loadProjects();
    
    // Calculer les index de début et fin
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;
    
    // Retourner les projets de cette page
    if (startIndex >= _projects.length) {
      return []; // Pas de projets pour cette page
    }
    
    final end = endIndex > _projects.length ? _projects.length : endIndex;
    return _projects.sublist(startIndex, end);
    
  } catch (e) {
    debugPrint('[ProjectProvider] ❌ Erreur chargement page: $e');
    rethrow;
  }
}

  /// Créer un nouveau projet
  Future<bool> createProject({
    required String title,
    required String shortDescription,
    required String fullDescription,
    required String categoryId,
    required String stage,
    required double fundingMin,
    required double fundingMax,
    String? fundingCurrency,
    String? locationCountry,
    String? locationCity,
    String? businessPlan,
    String? videoUrl,
    List<String>? tagIds,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final project = await _projectApiService.createProject(
        title: title,
        shortDescription: shortDescription,
        fullDescription: fullDescription,
        categoryId: categoryId,
        stage: stage,
        fundingMin: fundingMin,
        fundingMax: fundingMax,
        fundingCurrency: fundingCurrency,
        locationCountry: locationCountry,
        locationCity: locationCity,
        businessPlan: businessPlan,
        videoUrl: videoUrl,
        tagIds: tagIds,
      );

      if (project != null) {
        _projects.insert(0, project);
        _sortProjectsWithPremiumFirst();
        _currentProject = project;
        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la création du projet');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Mettre à jour un projet
  Future<bool> updateProject(
      String projectId, Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedProject =
          await _projectApiService.updateProject(projectId, data);

      if (updatedProject != null) {
        // Mettre à jour dans la liste
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          _projects[index] = updatedProject;
        }

        // Mettre à jour le projet actuel si c'est le même
        if (_currentProject?.id == projectId) {
          _currentProject = updatedProject;
        }

        // Trier pour maintenir l'ordre correct des projets premium
        _sortProjectsWithPremiumFirst();

        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la mise à jour du projet');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Supprimer un projet
  Future<bool> deleteProject(String projectId) async {
    _setLoading(true);
    _setError(null);

    try {
      final success = await _projectApiService.deleteProject(projectId);

      if (success) {
        _projects.removeWhere((p) => p.id == projectId);
        if (_currentProject?.id == projectId) {
          _currentProject = null;
        }
        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la suppression du projet');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Basculer le statut favori
  Future<bool> toggleFavorite(String projectId) async {
    try {
      final success = await _projectApiService.toggleFavorite(projectId);
      if (success) {
        // Mettre à jour localement avec copyWith pour refléter le changement dans l'UI
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          _projects[index] = _projects[index].copyWith(
            isFavorite: !_projects[index].isFavorite,
          );
        }
        // Mettre à jour aussi le projet courant si c'est le même
        if (_currentProject?.id == projectId) {
          _currentProject = _currentProject!.copyWith(
            isFavorite: !_currentProject!.isFavorite,
          );
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Signaler un projet (return succès)
  Future<bool> reportProject(String projectId, {String? reason}) async {
    final success =
        await _projectApiService.reportProject(projectId, reason: reason);
    return success;
  }

  /// Masquer un projet pour l'utilisateur courant
  Future<bool> hideProject(String projectId) async {
    final success = await _projectApiService.hideProject(projectId);
    if (success) {
      // Retirer le projet de la liste locale pour ne plus l'afficher
      _projects.removeWhere((p) => p.id == projectId);
      notifyListeners();
    }
    return success;
  }

  /// Exprimer un intérêt
  Future<bool> toggleInterest(String projectId) async {
    try {
      final success = await _projectApiService.toggleInterest(projectId);
      if (success) {
        // Mettre à jour le compteur d'intérêts
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          // Note: Il faudrait gérer le compteur d'intérêts
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Publier un projet
  Future<bool> publishProject(String projectId) async {
    try {
      return await _projectApiService.publishProject(projectId);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Charger les catégories
  Future<void> loadCategories() async {
    try {
      _categories = await _projectApiService.getCategories();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Charger les tags
  Future<void> loadTags() async {
    try {
      _tags = await _projectApiService.getTags();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Rechercher des projets
  Future<void> searchProjects(String query) async {
    _filters = _filters.copyWith(searchQuery: query.isEmpty ? null : query);
    await loadProjects(forceRefresh: true);
  }

  /// Filtrer par catégorie
  Future<void> filterByCategory(String? categoryId) async {
    _filters = _filters.copyWith(categoryId: categoryId);
    await loadProjects(forceRefresh: true);
  }

  /// Filtrer par stage
  Future<void> filterByStage(String? stage) async {
    _filters = _filters.copyWith(stage: stage);
    await loadProjects(forceRefresh: true);
  }

  /// Filtrer par localisation
  Future<void> filterByLocation(String? country, String? city) async {
    _filters = _filters.copyWith(locationCountry: country, locationCity: city);
    await loadProjects(forceRefresh: true);
  }

  /// Filtrer par budget (min/max)
  Future<void> filterByBudget(double? min, double? max) async {
    _filters = _filters.copyWith(fundingMin: min, fundingMax: max);
    await loadProjects(forceRefresh: true);
  }

  /// Réinitialiser les filtres
  Future<void> clearFilters() async {
    _filters.clear();
    await loadProjects(forceRefresh: true);
  }

  /// Appliquer plusieurs filtres à la fois
  Future<void> applyFilters(ProjectFilters newFilters) async {
    _filters = newFilters;
    await loadProjects(forceRefresh: true);
  }

  /// Charger plus de projets (pagination)
  Future<void> loadMoreProjects() async {
    await loadProjects(loadMore: true);
  }

  void clearCurrentProject() {
    _currentProject = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Charger les projets de l'utilisateur connecté
  Future<void> loadUserProjects() async {
    await loadProjects(forceRefresh: true);
    // Note: Dans une vraie app, on filtrerait par l'ID de l'utilisateur connecté
  }

  /// Charger les projets en vedette (featured)
  Future<void> loadFeaturedProjects() async {
    try {
      debugPrint('[ProjectProvider] Chargement des projets featured');
      final result = await _projectApiService.getFeaturedProjects();

      if (result.isSuccess && result.projects != null) {
        _featuredProjects = result.projects!;
        debugPrint(
            '[ProjectProvider] ${_featuredProjects.length} projets featured chargés');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ProjectProvider] Erreur chargement projets featured: $e');
    }
  }

  /// Charger les projets tendance (trending)
  Future<void> loadTrendingProjects() async {
    try {
      debugPrint('[ProjectProvider] Chargement des projets trending');
      final result = await _projectApiService.getTrendingProjects();

      if (result.isSuccess && result.projects != null) {
        _trendingProjects = result.projects!;
        debugPrint(
            '[ProjectProvider] ${_trendingProjects.length} projets trending chargés');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ProjectProvider] Erreur chargement projets trending: $e');
    }
  }

  /// Charger les projets recommandés (pour l'utilisateur connecté)
  Future<void> loadRecommendedProjects() async {
    try {
      debugPrint('[ProjectProvider] Chargement des projets recommandés');
      final result = await _projectApiService.getRecommendedProjects();

      if (result.isSuccess && result.projects != null) {
        _recommendedProjects = result.projects!;
        debugPrint(
            '[ProjectProvider] ${_recommendedProjects.length} projets recommandés chargés');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[ProjectProvider] Erreur chargement projets recommandés: $e');
    }
  }

  /// Exprimer un intérêt avec message et montant
  Future<bool> expressInterest(
    String projectId, {
    String? message,
    double? amount,
    bool isAnonymous = false,
  }) async {
    try {
      final success = await _projectApiService.expressInterest(
        projectId,
        message: message,
        amount: amount,
        isAnonymous: isAnonymous,
      );

      if (success) {
        // Mettre à jour le compteur d'intérêts
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          // Incrémenter le compteur d'intérêts
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sauvegarder un projet comme brouillon
  Future<bool> saveDraft({
    required String title,
    required String shortDescription,
    required String fullDescription,
    required String categoryId,
    required String stage,
    required double fundingMin,
    required double fundingMax,
    String? fundingCurrency,
    String? locationCountry,
    String? locationCity,
    String? businessPlan,
    String? videoUrl,
    List<String>? tagIds,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final project = await _projectApiService.saveDraft(
        title: title,
        shortDescription: shortDescription,
        fullDescription: fullDescription,
        categoryId: categoryId,
        stage: stage,
        fundingMin: fundingMin,
        fundingMax: fundingMax,
        fundingCurrency: fundingCurrency,
        locationCountry: locationCountry,
        locationCity: locationCity,
        businessPlan: businessPlan,
        videoUrl: videoUrl,
        tagIds: tagIds,
      );

      if (project != null) {
        _projects.insert(0, project);
        _currentProject = project;
        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la sauvegarde du brouillon');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Mettre à jour un brouillon existant
  Future<bool> updateDraft(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedProject =
          await _projectApiService.updateDraft(projectId, data);

      if (updatedProject != null) {
        // Mettre à jour dans la liste
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          _projects[index] = updatedProject;
        }

        // Mettre à jour le projet actuel si c'est le même
        if (_currentProject?.id == projectId) {
          _currentProject = updatedProject;
        }

        _setLoading(false);
        return true;
      } else {
        _setError('Erreur lors de la mise à jour du brouillon');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Récupérer les brouillons de l'utilisateur
  Future<void> loadUserDrafts() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _projectApiService.getUserDrafts();

      if (result.isSuccess && result.projects != null) {
        _projects = result.projects!;
        debugPrint('[ProjectProvider] ${_projects.length} brouillons chargés');
        notifyListeners();
      } else {
        _setError(result.error ?? 'Erreur lors du chargement des brouillons');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Getter pour les brouillons de l'utilisateur
  List<ProjectModel> get userDrafts =>
      _projects.where((p) => p.isDraft).toList();

  /// Getter pour accéder à l'API service (utilisé par PagingController)
  ProjectApiService getApiService() => _projectApiService;

  /// Tri des projets pour mettre les premium en premier
  void _sortProjectsWithPremiumFirst() {
    _projects.sort((a, b) {
      // D'abord trier par premium (true vient avant false)
      if (a.isPremium && !b.isPremium) return -1;
      if (!a.isPremium && b.isPremium) return 1;

      // Si même statut premium, trier par featured
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;

      // Si même statut premium et featured, trier par date de publication (plus récent d'abord)
      if (a.publishedAt != null && b.publishedAt != null) {
        return b.publishedAt!.compareTo(a.publishedAt!);
      } else if (a.publishedAt != null) {
        return -1;
      } else if (b.publishedAt != null) {
        return 1;
      }

      // Sinon trier par date de création
      return (b.createdAt ?? DateTime.now())
          .compareTo(a.createdAt ?? DateTime.now());
    });
  }

Future<void> loadFavoriteProjects() async {
  _isLoadingFavorites = true;
  notifyListeners();

  try {
    final result = await _projectApiService.getFavorites();

    if (result.isSuccess && result.projects != null) {
      _favoriteProjects = result.projects!;
    } else {
      _favoriteProjects = [];
    }
  } catch (e) {
    debugPrint('[ProjectProvider] Erreur chargement favoris: $e');
    _favoriteProjects = [];
  } finally {
    _isLoadingFavorites = false;
    notifyListeners();
  }
}

Future<void> addToFavorites(String projectId) async {
  // Le projet n'est pas encore favori → on appelle toggleFavorite
  final success = await _projectApiService.toggleFavorite(projectId);

  if (success) {
    // Mettre à jour dans la liste principale
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(isFavorite: true);
    }

    // Mettre à jour le projet courant si c'est le même
    if (_currentProject?.id == projectId) {
      _currentProject = _currentProject!.copyWith(isFavorite: true);
    }

    notifyListeners();
  } else {
    // Si l'API échoue, on remonte l'erreur pour que ProjectCard fasse le rollback
    throw Exception('Impossible d\'ajouter aux favoris');
  }
}

Future<void> removeFromFavorites(String projectId) async {
  // Le projet est déjà favori → on appelle toggleFavorite pour l'enlever
  final success = await _projectApiService.toggleFavorite(projectId);

  if (success) {
    // Mettre à jour dans la liste principale
    final index = _projects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      _projects[index] = _projects[index].copyWith(isFavorite: false);
    }

    // Mettre à jour le projet courant si c'est le même
    if (_currentProject?.id == projectId) {
      _currentProject = _currentProject!.copyWith(isFavorite: false);
    }

    // Retirer aussi de la liste favoris si elle est chargée
    _favoriteProjects.removeWhere((p) => p.id == projectId);

    notifyListeners();
  } else {
    throw Exception('Impossible de retirer des favoris');
  }
}
}
