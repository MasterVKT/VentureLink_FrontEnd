import 'package:dio/dio.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:venturelink/core/utils/logger.dart';

class ProjectApiService {
  final IApiService _apiService;

  /// Endpoint racine des projets (le préfixe /api/v1 est déjà inclus dans ApiService.baseUrl)
  static const String _baseEndpoint = '/projects';

  ProjectApiService(this._apiService);

  /// Récupérer la liste des projets avec filtres
  Future<ProjectListResult> getProjects({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? category,
    String? stage,
    String? location,
    double? fundingMin,
    double? fundingMax,
    List<String>? tags,
    String? sortBy,
    String? sortOrder,
    ProjectFilters? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      // Utiliser les paramètres explicites ou ceux du filtre
      final effectiveSearch = search ?? filters?.searchQuery;
      final effectiveCategory = category ?? filters?.categoryId;
      final effectiveStage = stage ?? filters?.stage;
      final effectiveFundingMin = fundingMin ?? filters?.fundingMin;
      final effectiveFundingMax = fundingMax ?? filters?.fundingMax;
      final effectiveTags = tags ?? (filters?.tagIds.isNotEmpty == true ? filters?.tagIds : null);
      final effectiveSortBy = sortBy ?? filters?.sortBy;

      if (effectiveSearch != null) queryParams['search'] = effectiveSearch;
      if (effectiveCategory != null) queryParams['category'] = effectiveCategory;
      if (effectiveStage != null) queryParams['stage'] = effectiveStage;
      if (filters?.locationCountry != null) queryParams['location_country'] = filters!.locationCountry;
      if (filters?.locationCity != null) queryParams['location_city'] = filters!.locationCity;
      if (effectiveFundingMin != null) queryParams['funding_min'] = effectiveFundingMin;
      if (effectiveFundingMax != null) queryParams['funding_max'] = effectiveFundingMax;
      if (effectiveTags != null && effectiveTags.isNotEmpty) queryParams['tags'] = effectiveTags.join(',');
      if (effectiveSortBy != null) {
        queryParams['ordering'] = sortOrder == 'desc' ? '-$effectiveSortBy' : effectiveSortBy;
      }
      if (filters?.isFeatured == true) queryParams['is_featured'] = 'true';
      if (filters?.isPremium == true) queryParams['is_premium'] = 'true';

      final response = await _apiService.get('$_baseEndpoint/',
          queryParameters: queryParams);

      return ProjectListResult.safeParseApiResponse(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des projets: $e');

      // Si c'est une erreur 404 et qu'on est en pagination (page > 1)
      // On retourne un résultat vide avec hasNext = false au lieu d'une erreur
      if (e is DioException && e.response?.statusCode == 404 && page > 1) {
        debugPrint('Page $page non trouvée, fin de la pagination');
        return ProjectListResult._(
          isSuccess: true,
          projects: [],
          totalCount: 0,
          hasNext: false,
          hasPrevious: true,
          error: null,
        );
      }

      // Pour toutes les autres erreurs, inclure l'erreur Dio si disponible
      String errorMessage = e.toString();
      if (e is DioException && e.response?.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is Map<String, dynamic>) {
            // Extraire le message d'erreur du format API
            if (errorData['error'] is Map<String, dynamic>) {
              final errorDetails = errorData['error'] as Map<String, dynamic>;
              errorMessage =
                  errorDetails['message']?.toString() ?? errorMessage;
            } else if (errorData['message'] != null) {
              errorMessage = errorData['message'].toString();
            } else if (errorData['detail'] != null) {
              errorMessage = errorData['detail'].toString();
            }
          }
        } catch (parseError) {
          // Si on ne peut pas parser l'erreur, utiliser le message original
          debugPrint('Impossible de parser la réponse d\'erreur: $parseError');
        }
      }

      return ProjectListResult.failure(errorMessage);
    }
  }

  /// Récupérer un projet par son ID
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/$projectId/');
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Créer un nouveau projet
  Future<ProjectModel?> createProject({
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
    try {
      final data = {
        'title': title,
        'short_description': shortDescription,
        'full_description': fullDescription,
        'category': categoryId,
        'stage': stage,
        'funding_min': fundingMin,
        'funding_max': fundingMax,
        'funding_currency': fundingCurrency ?? 'EUR',
        'location_country': locationCountry,
        'location_city': locationCity,
        'business_plan': businessPlan,
        'video_url': videoUrl,
        'tags': tagIds,
      };

      final response = await _apiService.post('$_baseEndpoint/', data: data);
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Mettre à jour un projet
  Future<ProjectModel?> updateProject(
      String projectId, Map<String, dynamic> data) async {
    try {
      final response =
          await _apiService.patch('$_baseEndpoint/$projectId/', data: data);
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Supprimer un projet
  Future<bool> deleteProject(String projectId) async {
    try {
      await _apiService.delete('$_baseEndpoint/$projectId/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Publier un projet
  Future<bool> publishProject(String projectId) async {
    try {
      await _apiService.post('$_baseEndpoint/$projectId/publish/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Archiver un projet
  Future<bool> archiveProject(String projectId) async {
    try {
      await _apiService.post('$_baseEndpoint/$projectId/archive/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Basculer le statut favori d'un projet
  Future<bool> toggleFavorite(String projectId) async {
    try {
      await _apiService.post('$_baseEndpoint/$projectId/toggle_favorite/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Signaler un projet pour contenu inapproprié ou fraude
  Future<bool> reportProject(
    String projectId, {
    String? reason,
  }) async {
    try {
      await _apiService.post(
        '$_baseEndpoint/$projectId/report/',
        data: reason != null ? {'reason': reason} : null,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Masquer (ou désactiver l'affichage) d'un projet pour l'utilisateur courant
  Future<bool> hideProject(String projectId) async {
    try {
      await _apiService.post('$_baseEndpoint/$projectId/hide/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Exprimer un intérêt pour un projet
  Future<bool> toggleInterest(String projectId) async {
    try {
      await _apiService.post('$_baseEndpoint/$projectId/toggle_interest/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer les projets en vedette
  Future<ProjectListResult> getFeaturedProjects({int limit = 10}) async {
    try {
      // Utiliser l'endpoint correct avec filtrage is_featured=true
      final response =
          await _apiService.get('$_baseEndpoint/', queryParameters: {
        'limit': limit,
        'is_featured': true,
        'ordering': '-published_at',
      });

      debugPrint(
          '[API] Featured projects response type: ${response.data.runtimeType}');
      debugPrint('[API] Featured projects response: ${response.data}');

      // Détecter si c'est une réponse API root au lieu des données de projets
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('projects') &&
            responseMap['projects'] is String &&
            responseMap['projects']
                .toString()
                .contains('/projects/projects/')) {
          debugPrint('[API] Réponse API root détectée, retour liste vide');
          return ProjectListResult.success(
            projects: [],
            totalCount: 0,
            hasNext: false,
            hasPrevious: false,
          );
        }
      }

      // Gérer le cas où l'API retourne directement une liste
      if (response.data is List) {
        debugPrint('[API] Featured projects: réponse directe en liste');
        final projects = <ProjectModel>[];
        final list = response.data as List;

        for (var item in list) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              final project = ProjectModel.fromJson(item);
              projects.add(project);
            } catch (e) {
              debugPrint('[API] Erreur parsing projet featured: $e');
            }
          }
        }

        return ProjectListResult.success(
          projects: projects,
          totalCount: projects.length,
          hasNext: false,
          hasPrevious: false,
        );
      }

      // Sinon, utiliser le parsing standard
      return ProjectListResult.safeParseApiResponse(response.data);
    } catch (e) {
      debugPrint('[API] Erreur featured projects: $e');
      return ProjectListResult.failure(e.toString());
    }
  }

  /// Récupérer les projets tendance
  Future<ProjectListResult> getTrendingProjects({
    int days = 7,
    int limit = 10,
  }) async {
    try {
      // Utiliser l'endpoint principal avec tri par vues récentes
      final response =
          await _apiService.get('$_baseEndpoint/', queryParameters: {
        'limit': limit,
        'ordering': '-views_count',
        'status': 'ACTIVE',
      });

      debugPrint(
          '[API] Trending projects response type: ${response.data.runtimeType}');
      debugPrint('[API] Trending projects response: ${response.data}');

      // Détecter si c'est une réponse API root au lieu des données de projets
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('projects') &&
            responseMap['projects'] is String &&
            responseMap['projects']
                .toString()
                .contains('/projects/projects/')) {
          debugPrint('[API] Réponse API root détectée, retour liste vide');
          return ProjectListResult.success(
            projects: [],
            totalCount: 0,
            hasNext: false,
            hasPrevious: false,
          );
        }
      }

      // Gérer le cas où l'API retourne directement une liste
      if (response.data is List) {
        debugPrint('[API] Trending projects: réponse directe en liste');
        final projects = <ProjectModel>[];
        final list = response.data as List;

        for (var item in list) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              final project = ProjectModel.fromJson(item);
              projects.add(project);
            } catch (e) {
              debugPrint('[API] Erreur parsing projet trending: $e');
            }
          }
        }

        return ProjectListResult.success(
          projects: projects,
          totalCount: projects.length,
          hasNext: false,
          hasPrevious: false,
        );
      }

      // Sinon, utiliser le parsing standard
      return ProjectListResult.safeParseApiResponse(response.data);
    } catch (e) {
      debugPrint('[API] Erreur trending projects: $e');
      return ProjectListResult.failure(e.toString());
    }
  }

  /// Récupérer les projets recommandés pour l'utilisateur connecté
  Future<ProjectListResult> getRecommendedProjects({int limit = 10}) async {
    try {
      // Utiliser l'endpoint principal avec tri par intérêts
      final response =
          await _apiService.get('$_baseEndpoint/', queryParameters: {
        'limit': limit,
        'ordering': '-interests_count',
        'status': 'ACTIVE',
      });

      debugPrint(
          '[API] Recommended projects response type: ${response.data.runtimeType}');
      debugPrint('[API] Recommended projects response: ${response.data}');

      // Détecter si c'est une réponse API root au lieu des données de projets
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap.containsKey('projects') &&
            responseMap['projects'] is String &&
            responseMap['projects']
                .toString()
                .contains('/projects/projects/')) {
          debugPrint('[API] Réponse API root détectée, retour liste vide');
          return ProjectListResult.success(
            projects: [],
            totalCount: 0,
            hasNext: false,
            hasPrevious: false,
          );
        }
      }

      // Gérer le cas où l'API retourne directement une liste
      if (response.data is List) {
        debugPrint('[API] Recommended projects: réponse directe en liste');
        final projects = <ProjectModel>[];
        final list = response.data as List;

        for (var item in list) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              final project = ProjectModel.fromJson(item);
              projects.add(project);
            } catch (e) {
              debugPrint('[API] Erreur parsing projet recommended: $e');
            }
          }
        }

        return ProjectListResult.success(
          projects: projects,
          totalCount: projects.length,
          hasNext: false,
          hasPrevious: false,
        );
      }

      // Sinon, utiliser le parsing standard
      return ProjectListResult.safeParseApiResponse(response.data);
    } catch (e) {
      debugPrint('[API] Erreur recommended projects: $e');
      return ProjectListResult.failure(e.toString());
    }
  }

  /// Exprimer un intérêt détaillé pour un projet
  Future<bool> expressInterest(
    String projectId, {
    String? message,
    double? amount,
    bool isAnonymous = false,
  }) async {
    try {
      final data = <String, dynamic>{
        if (message != null) 'message': message,
        if (amount != null) 'investment_amount': amount,
        'is_anonymous': isAnonymous,
      };

      await _apiService.post('/projects/$projectId/toggle-interest/',
          data: data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dupliquer un projet
  Future<ProjectModel?> duplicateProject(String projectId) async {
    try {
      final response =
          await _apiService.post('/projects/$projectId/duplicate/');
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Ajouter un média à un projet
  Future<ProjectMediaModel?> addProjectMedia({
    required String projectId,
    required String mediaType,
    required FormData formData,
    String? caption,
    int? displayOrder,
  }) async {
    try {
      final response =
          await _apiService.upload('/projects/$projectId/media/', formData);
      return ProjectMediaModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Récupérer les médias d'un projet
  Future<List<ProjectMediaModel>> getProjectMedia(String projectId) async {
    try {
      final response = await _apiService.get('/projects/$projectId/media/');
      return (response.data as List)
          .map((json) => ProjectMediaModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Supprimer un média de projet
  Future<bool> deleteProjectMedia(String projectId, String mediaId) async {
    try {
      await _apiService.delete('/projects/$projectId/media/$mediaId/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer les catégories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get('/projects/categories/');

      // Gérer le cas où l'API retourne directement une liste
      if (response.data is List) {
        debugPrint('[API] Categories: réponse directe en liste');
        final categories = <CategoryModel>[];
        final list = response.data as List;

        for (var item in list) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              final category = CategoryModel.fromJson(item);
              categories.add(category);
            } catch (e) {
              debugPrint('[API] Erreur parsing catégorie: $e');
            }
          }
        }

        return categories;
      }

      // Format standard avec results
      if (response.data == null ||
          response.data is! Map ||
          response.data['results'] is! List) {
        debugPrint("Format de réponse API inattendu pour les catégories");
        return [];
      }

      final categories = <CategoryModel>[];
      final categoriesList = response.data['results'] as List;

      for (var item in categoriesList) {
        if (item != null && item is Map<String, dynamic>) {
          try {
            final category = CategoryModel.fromJson(item);
            categories.add(category);
          } catch (e) {
            debugPrint(
                "Erreur lors de la conversion d'une catégorie, ignorée: $e");
            // Continuer avec la prochaine catégorie au lieu d'échouer
          }
        }
      }

      return categories;
    } catch (e) {
      debugPrint("Erreur lors de la récupération des catégories: $e");
      return [];
    }
  }

  /// Récupérer les tags
  Future<List<TagModel>> getTags() async {
    try {
      final response = await _apiService.get('/projects/tags/');

      // Gérer le cas où l'API retourne directement une liste
      if (response.data is List) {
        debugPrint('[API] Tags: réponse directe en liste');
        final tags = <TagModel>[];
        final list = response.data as List;

        for (var item in list) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              final tag = TagModel.fromJson(item);
              tags.add(tag);
            } catch (e) {
              debugPrint('[API] Erreur parsing tag: $e');
            }
          }
        }

        return tags;
      }

      // Format standard avec results
      if (response.data == null ||
          response.data is! Map ||
          response.data['results'] is! List) {
        debugPrint("Format de réponse API inattendu pour les tags");
        return [];
      }

      final tags = <TagModel>[];
      final tagsList = response.data['results'] as List;

      for (var item in tagsList) {
        if (item != null && item is Map<String, dynamic>) {
          try {
            final tag = TagModel.fromJson(item);
            tags.add(tag);
          } catch (e) {
            debugPrint("Erreur lors de la conversion d'un tag, ignoré: $e");
            // Continuer avec le prochain tag au lieu d'échouer
          }
        }
      }

      return tags;
    } catch (e) {
      debugPrint("Erreur lors de la récupération des tags: $e");
      return [];
    }
  }

  /// Récupérer les projets favoris de l'utilisateur
  Future<List<ProjectModel>> getFavoriteProjects() async {
    try {
      final response = await _apiService.get('/favorites/');
      return (response.data as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Récupérer les projets d'intérêt de l'utilisateur
  Future<List<ProjectModel>> getInterestProjects() async {
    try {
      final response = await _apiService.get('/interests/');
      return (response.data as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder un projet comme brouillon
  Future<ProjectModel?> saveDraft({
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
    try {
      final data = {
        'title': title,
        'short_description': shortDescription,
        'full_description': fullDescription,
        'category': categoryId,
        'stage': stage,
        'funding_min': fundingMin,
        'funding_max': fundingMax,
        'funding_currency': fundingCurrency ?? 'EUR',
        'location_country': locationCountry,
        'location_city': locationCity,
        'business_plan': businessPlan,
        'video_url': videoUrl,
        'tags': tagIds,
        'is_draft': true, // Marquer comme brouillon
      };

      final response = await _apiService.post('/projects/', data: data);
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde du brouillon: $e');
      return null;
    }
  }

  /// Mettre à jour un brouillon existant
  Future<ProjectModel?> updateDraft(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    try {
      // S'assurer que le projet reste un brouillon
      data['is_draft'] = true;

      final response =
          await _apiService.patch('/projects/$projectId/', data: data);
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du brouillon: $e');
      return null;
    }
  }

  /// Récupérer les brouillons de l'utilisateur
  Future<ProjectListResult> getUserDrafts() async {
    try {
      final response = await _apiService
          .get('/projects/my-projects/', queryParameters: {'is_draft': true});
      return ProjectListResult.safeParseApiResponse(response.data);
    } catch (e) {
      debugPrint('Erreur lors de la récupération des brouillons: $e');
      return ProjectListResult.failure(e.toString());
    }
  }

  /// Diagnostiquer les problèmes d'API et suggérer des solutions
  Future<void> diagnoseApiIssues() async {
    debugPrint('🔍 [API DIAGNOSTIC] Début du diagnostic des endpoints...');

    try {
      // Test de l'endpoint principal
      final response = await _apiService.get('/projects/', queryParameters: {
        'limit': 1,
      });

      debugPrint('📊 [API DIAGNOSTIC] Réponse de /projects/:');
      debugPrint('   Type: ${response.data.runtimeType}');
      debugPrint('   Contenu: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Vérifier si c'est une réponse de navigation API
        if (data.containsKey('projects') && data['projects'] is String) {
          debugPrint(
              '❌ [API DIAGNOSTIC] PROBLÈME DÉTECTÉ: Réponse de navigation API au lieu des données');
          debugPrint('💡 [API DIAGNOSTIC] SOLUTION BACKEND REQUISE:');
          debugPrint(
              '   1. Vérifier que l\'endpoint /api/v1/projects/ retourne bien les projets');
          debugPrint('   2. Vérifier la configuration des URLs Django');
          debugPrint(
              '   3. S\'assurer que les projets existent dans la base de données');
          debugPrint('   4. Vérifier les permissions d\'accès aux projets');
        } else if (data.containsKey('results')) {
          debugPrint(
              '✅ [API DIAGNOSTIC] Structure de réponse correcte détectée');
          final results = data['results'] as List?;
          if (results?.isEmpty == true) {
            debugPrint(
                '⚠️ [API DIAGNOSTIC] Aucun projet trouvé dans la base de données');
            debugPrint(
                '💡 [API DIAGNOSTIC] SOLUTION: Créer des projets de test dans le backend');
          }
        }
      }
    } catch (e) {
      debugPrint('❌ [API DIAGNOSTIC] Erreur lors du test de l\'endpoint: $e');
      debugPrint('💡 [API DIAGNOSTIC] SOLUTIONS POSSIBLES:');
      debugPrint('   1. Vérifier que le serveur Django est démarré');
      debugPrint('   2. Vérifier l\'URL de base de l\'API');
      debugPrint('   3. Vérifier les CORS si nécessaire');
    }
  }
}

class ProjectListResult {
  final bool isSuccess;
  final List<ProjectModel>? projects;
  final int? totalCount;
  final bool? hasNext;
  final bool? hasPrevious;
  final String? error;

  ProjectListResult._({
    required this.isSuccess,
    this.projects,
    this.totalCount,
    this.hasNext,
    this.hasPrevious,
    this.error,
  });

  factory ProjectListResult.success({
    required List<ProjectModel> projects,
    required int totalCount,
    required bool hasNext,
    required bool hasPrevious,
  }) {
    return ProjectListResult._(
      isSuccess: true,
      projects: projects,
      totalCount: totalCount,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
    );
  }

  factory ProjectListResult.empty() {
    return ProjectListResult._(
      isSuccess: true,
      projects: [],
      totalCount: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }

  factory ProjectListResult.failure(String error) {
    return ProjectListResult._(
      isSuccess: false,
      error: error,
      projects: [], // Toujours fournir une liste vide pour éviter les erreurs null
    );
  }

  // Méthode pour traiter les résultats de l'API de manière sécurisée
  static ProjectListResult safeParseApiResponse(dynamic response) {
    try {
      if (response == null) {
        AppLogger.error('[API] Réponse API nulle');
        return ProjectListResult.failure('Réponse API nulle');
      }

      // Cas 1: Réponse directe en liste (pour trending, featured, etc.)
      if (response is List) {
        AppLogger.info(
            '[API] Format de réponse: Liste directe (${response.length} éléments)');
        final projects = <ProjectModel>[];

        for (var item in response) {
          if (item != null && item is Map<String, dynamic>) {
            try {
              final project = ProjectModel.fromJson(item);
              projects.add(project);
            } catch (e) {
              AppLogger.warning('[API] Erreur parsing projet dans liste: $e');
            }
          }
        }

        return ProjectListResult.success(
          projects: projects,
          totalCount: projects.length,
          hasNext: false,
          hasPrevious: false,
        );
      }

      // Cas 2: Réponse avec structure d'API (pagination)
      if (response is! Map<String, dynamic>) {
        AppLogger.error(
            '[API] Format de réponse API invalide: ${response.runtimeType}');
        return ProjectListResult.failure('Format de réponse API invalide');
      }

      final responseMap = response;

      // Cas 3: Réponse contenant des liens vers d'autres endpoints (API root)
      if (responseMap.containsKey('projects') &&
          responseMap['projects'] is String &&
          !responseMap.containsKey('results')) {
        AppLogger.info('[API] Réponse API root détectée, retour liste vide');
        return ProjectListResult.empty();
      }

      // Cas 4: Structure normale avec results
      final results = responseMap['results'];
      if (results == null) {
        AppLogger.info('[API] Aucun résultat trouvé dans la réponse');
        return ProjectListResult.empty();
      }

      if (results is! List) {
        AppLogger.error(
            '[API] Format de résultats invalide: ${results.runtimeType}');
        return ProjectListResult.failure('Format de résultats invalide');
      }

      // Filtrer et parser les résultats
      final projects = <ProjectModel>[];
      int skippedCount = 0;
      int missingFieldsCount = 0;

      for (var item in results) {
        if (item != null && item is Map<String, dynamic>) {
          try {
            // Compter les champs manquants sans les logger individuellement
            int missingFieldsCount = 0;

            if (item['updated_at'] == null ||
                item['created_at'] == null ||
                item['category'] == null ||
                (item['category'] is Map && item['category']['icon'] == null)) {
              missingFieldsCount++;
            }

            // Parser le projet (le modèle gère les champs manquants)
            final project = ProjectModel.fromJson(item);
            projects.add(project);
          } catch (e) {
            skippedCount++;
            AppLogger.warning('[API] Projet ignoré (ID: ${item['id']}): $e');
            // Continuer avec le prochain projet au lieu d'échouer
          }
        }
      }

      // Journaliser un résumé uniquement
      AppLogger.info(
          '[API] Projets traités: ${projects.length} succès, $skippedCount ignorés');
      if (missingFieldsCount > 0) {
        AppLogger.info(
            '[API] $missingFieldsCount projets avec champs optionnels manquants (normal)');
      }

      // Extraire les autres informations
      final count = responseMap['count'] is int
          ? responseMap['count'] as int
          : projects.length;
      final hasNext = responseMap['next'] != null;
      final hasPrevious = responseMap['previous'] != null;

      return ProjectListResult.success(
        projects: projects,
        totalCount: count,
        hasNext: hasNext,
        hasPrevious: hasPrevious,
      );
    } catch (e) {
      AppLogger.error(
          '[API] Erreur critique lors du traitement de la réponse API: $e');
      return ProjectListResult.failure(
          'Erreur lors du traitement de la réponse API: $e');
    }
  }
}
