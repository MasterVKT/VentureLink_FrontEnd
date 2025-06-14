import 'package:dio/dio.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'package:flutter/foundation.dart';

class ProjectApiService {
  final IApiService _apiService;

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
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (stage != null) queryParams['stage'] = stage;
      if (location != null) queryParams['location'] = location;
      if (fundingMin != null) queryParams['funding_min'] = fundingMin;
      if (fundingMax != null) queryParams['funding_max'] = fundingMax;
      if (tags != null && tags.isNotEmpty) queryParams['tags'] = tags.join(',');
      if (sortBy != null) {
        queryParams['ordering'] = sortOrder == 'desc' ? '-$sortBy' : sortBy;
      }

      final response =
          await _apiService.get('/projects/', queryParameters: queryParams);

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
      final response = await _apiService.get('/projects/$projectId/');
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

      final response = await _apiService.post('/projects/', data: data);
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
          await _apiService.patch('/projects/$projectId/', data: data);
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// Supprimer un projet
  Future<bool> deleteProject(String projectId) async {
    try {
      await _apiService.delete('/projects/$projectId/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Publier un projet
  Future<bool> publishProject(String projectId) async {
    try {
      await _apiService.post('/projects/$projectId/publish/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Archiver un projet
  Future<bool> archiveProject(String projectId) async {
    try {
      await _apiService.post('/projects/$projectId/archive/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Basculer le statut favori d'un projet
  Future<bool> toggleFavorite(String projectId) async {
    try {
      await _apiService.post('/projects/$projectId/toggle_favorite/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Exprimer un intérêt pour un projet
  Future<bool> toggleInterest(String projectId) async {
    try {
      await _apiService.post('/projects/$projectId/toggle_interest/');
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
      final response = await _apiService.get('/categories/');
      if (response.data == null ||
          response.data is! Map ||
          response.data['results'] is! List) {
        debugPrint("Format de réponse API inattendu pour les catégories");
        return [];
      }

      final categories = [];
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

      return categories.cast<CategoryModel>();
    } catch (e) {
      debugPrint("Erreur lors de la récupération des catégories: $e");
      return [];
    }
  }

  /// Récupérer les tags
  Future<List<TagModel>> getTags() async {
    try {
      final response = await _apiService.get('/tags/');
      if (response.data == null ||
          response.data is! Map ||
          response.data['results'] is! List) {
        debugPrint("Format de réponse API inattendu pour les tags");
        return [];
      }

      final tags = [];
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

      return tags.cast<TagModel>();
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
        debugPrint('[API] Réponse API nulle');
        return ProjectListResult.failure('Réponse API nulle');
      }

      // Vérifier la structure attendue
      if (response is! Map<String, dynamic>) {
        debugPrint(
            '[API] Format de réponse API invalide: ${response.runtimeType}');
        return ProjectListResult.failure('Format de réponse API invalide');
      }

      // Vérifier si la réponse contient les résultats
      final results = response['results'];
      if (results == null) {
        debugPrint('[API] Aucun résultat trouvé dans la réponse');
        return ProjectListResult.empty();
      }

      if (results is! List) {
        debugPrint(
            '[API] Format de résultats invalide: ${results.runtimeType}');
        return ProjectListResult.failure('Format de résultats invalide');
      }

      // Filtrer et parser les résultats
      final projects = [];
      int skippedCount = 0;

      for (var item in results) {
        if (item != null && item is Map<String, dynamic>) {
          try {
            // Examinons les champs problématiques pour le débogage
            if (item['full_description'] == null) {
              debugPrint(
                  '[API] Champ full_description manquant dans un projet: ${item['id']}');
            }

            if (item['created_at'] == null) {
              debugPrint(
                  '[API] Champ created_at manquant dans un projet: ${item['id']}');
            }

            if (item['updated_at'] == null) {
              debugPrint(
                  '[API] Champ updated_at manquant dans un projet: ${item['id']}');
            }

            if (item['category'] == null) {
              debugPrint(
                  '[API] Champ category manquant dans un projet: ${item['id']}');
            } else if (item['category'] is Map &&
                item['category']['icon'] == null) {
              debugPrint(
                  '[API] Champ category.icon manquant dans un projet: ${item['id']}');
            }

            // Essayons de parser le projet
            final project = ProjectModel.fromJson(item);
            projects.add(project);
          } catch (e) {
            skippedCount++;
            debugPrint('[API] Erreur lors du parsing d\'un projet, ignoré: $e');
            // Continuer avec le prochain projet au lieu d'échouer
          }
        }
      }

      // Journaliser des informations sur le traitement des résultats
      debugPrint('[API] Projets traités avec succès: ${projects.length}');
      if (skippedCount > 0) {
        debugPrint('[API] Projets ignorés en raison d\'erreurs: $skippedCount');
      }

      // Debug des images de projets
      _debugProjectImages(projects.cast<ProjectModel>());

      // Extraire les autres informations
      final count = response['count'] is int ? response['count'] as int : 0;
      final hasNext = response['next'] != null;
      final hasPrevious = response['previous'] != null;

      return ProjectListResult.success(
        projects: projects.cast<ProjectModel>(),
        totalCount: count,
        hasNext: hasNext,
        hasPrevious: hasPrevious,
      );
    } catch (e) {
      debugPrint(
          '[API] Erreur critique lors du traitement de la réponse API: $e');
      return ProjectListResult.failure(
          'Erreur lors du traitement de la réponse API: $e');
    }
  }

  // Méthode de debug pour les images des projets
  static void _debugProjectImages(List<ProjectModel> projects) {
    debugPrint('🖼️ Debug des images de projets:');
    debugPrint('   Nombre de projets: ${projects.length}');
    debugPrint('');

    for (var project in projects) {
      debugPrint('📁 Projet: ${project.title}');
      debugPrint('   primaryImageUrl brut: ${project.primaryImageUrl}');
      debugPrint('   fullImageUrl construit: ${project.fullImageUrl}');
      debugPrint('   hasImage: ${project.hasImage}');

      // Debug détaillé des médias
      if (project.media != null && project.media!.isNotEmpty) {
        debugPrint('   🎬 MÉDIAS ADDITIONNELS:');
        debugPrint('   Nombre de médias: ${project.media!.length}');
        for (int i = 0; i < project.media!.length; i++) {
          final media = project.media![i];
          debugPrint('   Media $i:');
          debugPrint('     - Type: ${media.mediaType}');
          debugPrint('     - URL: ${media.fileUrl}');
          debugPrint('     - Caption: ${media.caption}');
          debugPrint('     - Display order: ${media.displayOrder}');
        }
        debugPrint(
            '   🎯 TOTAL MÉDIAS (avec primary): ${project.allMedia.length}');
        debugPrint('   hasMultipleMedia: ${project.hasMultipleMedia}');
        debugPrint('   Types présents: ${project.mediaTypesDescription}');
      } else {
        debugPrint('   ❌ Aucun média additionnel');
      }
      debugPrint('---');
    }
  }
}
