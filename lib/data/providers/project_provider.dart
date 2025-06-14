import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/services/project_api_service.dart';
import 'package:venturelink/data/services/api_service.dart';

class ProjectProvider extends ChangeNotifier {
  late final ProjectApiService _projectApiService;

  List<ProjectModel> _projects = [];
  List<CategoryModel> _categories = [];
  List<TagModel> _tags = [];
  ProjectModel? _currentProject;
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;
  int _currentPage = 1;

  List<ProjectModel> get projects => _projects;
  List<CategoryModel> get categories => _categories;
  List<TagModel> get tags => _tags;
  ProjectModel? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Getter pour les projets de l'utilisateur actuel
  List<ProjectModel> get userProjects =>
      _projects.where((p) => p.creator.id == 'current_user_id').toList();

  ProjectProvider() {
    _projectApiService = ProjectApiService(ApiService());
    _init();
  }

  Future<void> _init() async {
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

  /// Charger les projets avec filtres
  Future<void> loadProjects({
    bool refresh = false,
    String? search,
    String? category,
    String? stage,
    String? location,
    double? fundingMin,
    double? fundingMax,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
  }) async {
    debugPrint('[ProjectProvider] loadProjects appelé - refresh: $refresh');
    debugPrint(
        '[ProjectProvider] Paramètres: search=$search, category=$category, stage=$stage');

    if (refresh) {
      _currentPage = 1;
      _projects.clear();
      _hasMore = true;
      debugPrint('[ProjectProvider] Mode refresh - reset des données');
    }

    if (!_hasMore && !refresh) {
      debugPrint('[ProjectProvider] Pas plus de données à charger');
      return;
    }

    _setLoading(true);
    _setError(null);
    debugPrint(
        '[ProjectProvider] État mis à jour - isLoading: true, error: null');

    try {
      debugPrint('[ProjectProvider] Appel API - page: $_currentPage');
      final result = await _projectApiService.getProjects(
        page: _currentPage,
        search: search,
        category: category,
        stage: stage,
        location: location,
        fundingMin: fundingMin,
        fundingMax: fundingMax,
        tags: tags,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      debugPrint(
          '[ProjectProvider] Résultat API reçu - isSuccess: ${result.isSuccess}');

      if (result.isSuccess && result.projects != null) {
        debugPrint(
            '[ProjectProvider] ${result.projects!.length} projets reçus');

        if (refresh) {
          _projects = result.projects!;
          debugPrint('[ProjectProvider] Projets remplacés (refresh)');
        } else {
          _projects.addAll(result.projects!);
          debugPrint('[ProjectProvider] Projets ajoutés (pagination)');
        }

        // Trier les projets pour mettre les premium en premier
        _sortProjectsWithPremiumFirst();

        _hasMore = result.hasNext ?? false;
        _currentPage++;
        debugPrint(
            '[ProjectProvider] hasMore: $_hasMore, prochaine page: $_currentPage');
        debugPrint(
            '[ProjectProvider] Total projets dans la liste: ${_projects.length}');
      } else {
        debugPrint(
            '[ProjectProvider] Erreur dans le résultat: ${result.error}');
        // Si l'erreur est liée à une pagination (page introuvable), nous marquons simplement
        // qu'il n'y a plus de données à charger, sans afficher d'erreur à l'utilisateur
        if (result.error?.contains("Page non valide") == true ||
            result.error?.contains("404") == true) {
          _hasMore = false;
          debugPrint('[ProjectProvider] Erreur 404 - fin de pagination');
        } else {
          _setError(result.error ?? 'Erreur lors du chargement des projets');
          debugPrint('[ProjectProvider] Erreur définie: $_error');
        }
      }
    } catch (e) {
      debugPrint('[ProjectProvider] Exception attrapée: $e');
      // Ignorer les erreurs 404 pour la pagination
      if (e.toString().contains("404") && _currentPage > 1) {
        _hasMore = false;
        debugPrint(
            '[ProjectProvider] Exception 404 en pagination - hasMore = false');
      } else {
        _setError(e.toString());
        debugPrint('[ProjectProvider] Exception définie comme erreur: $_error');
      }
    } finally {
      _setLoading(false);
      debugPrint('[ProjectProvider] Chargement terminé - isLoading: false');
      debugPrint(
          '[ProjectProvider] État final: ${_projects.length} projets, hasMore: $_hasMore, error: $_error');
    }
  }

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
      return b.createdAt.compareTo(a.createdAt);
    });
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
        // Mettre à jour localement (on pourrait aussi recharger le projet)
        final index = _projects.indexWhere((p) => p.id == projectId);
        if (index != -1) {
          // Note: Il faudrait ajouter un champ isFavorite au modèle
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
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
    await loadProjects(refresh: true, search: query);
  }

  /// Filtrer par catégorie
  Future<void> filterByCategory(String categoryId) async {
    await loadProjects(refresh: true, category: categoryId);
  }

  /// Filtrer par stage
  Future<void> filterByStage(String stage) async {
    await loadProjects(refresh: true, stage: stage);
  }

  /// Réinitialiser les filtres
  Future<void> clearFilters() async {
    await loadProjects(refresh: true);
  }

  /// Charger plus de projets (pagination)
  Future<void> loadMoreProjects() async {
    if (!_isLoading && _hasMore) {
      await loadProjects();
    }
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
    await loadProjects(refresh: true);
    // Note: Dans une vraie app, on filtrerait par l'ID de l'utilisateur connecté
  }
}
