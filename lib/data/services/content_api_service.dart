import '../models/publication_model.dart';
import 'api_service.dart';
import '../../core/utils/logger.dart';

class ContentApiService extends ApiService {
  static const String _baseEndpoint = '/content';

  // Récupérer toutes les publications
  Future<List<Publication>> getPublications({
    String? publicationType,
    String? domain,
    String? search,
    bool? isFeatured,
    bool? isSponsored,
    String ordering = '-published_at',
    int page = 1,
    int pageSize = 20,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'ordering': ordering,
      'status': 'PUBLISHED', // Seules les publications publiées
    };

    if (publicationType != null) {
      queryParams['publication_type'] = publicationType;
    }
    if (domain != null) {
      queryParams['domain'] = domain;
    }
    if (search != null) {
      queryParams['search'] = search;
    }
    if (isFeatured != null) {
      queryParams['is_featured'] = isFeatured.toString();
    }
    if (isSponsored != null) {
      queryParams['is_sponsored'] = isSponsored.toString();
    }

    try {
      final response = await get(
        '$_baseEndpoint/publications/',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data['results'];

      // Parcourir chaque élément et parser individuellement pour isoler l'erreur
      final List<Publication> publications = [];
      for (int i = 0; i < data.length; i++) {
        try {
          final publication = Publication.fromJson(data[i]);

          // Debug : Logger les informations sur les médias
          AppLogger.info(
              'Publication ${publication.id} - Titre: ${publication.title}');
          AppLogger.info(
              'Publication ${publication.id} - Featured media: ${publication.featuredMedia?.file ?? 'null'}');
          AppLogger.info(
              'Publication ${publication.id} - Nombre de médias: ${publication.media?.length ?? 0}');

          // Debug supplémentaire : vérifier les données brutes reçues
          if (data[i]['media'] != null) {
            AppLogger.info(
                'Publication ${publication.id} - Données media brutes: ${data[i]['media']}');
          }
          if (data[i]['featured_media'] != null) {
            AppLogger.info(
                'Publication ${publication.id} - Données featured_media brutes: ${data[i]['featured_media']}');
          }

          if (publication.media != null && publication.media!.isNotEmpty) {
            for (int j = 0; j < publication.media!.length; j++) {
              final media = publication.media![j];
              AppLogger.info(
                  '  Média $j - Type: ${media.mediaType}, File: ${media.file}, FullURL: ${media.fullUrl}');
            }
          }

          publications.add(publication);
        } catch (e) {
          AppLogger.error(
              'Erreur lors du parsing de la publication à l\'index $i: $e');
          AppLogger.error(
              'Données de la publication problématique: ${data[i]}');
          // Continuer avec les autres publications au lieu de tout arrêter
        }
      }
      return publications;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des publications: $e');
    }
  }

  // Récupérer une publication par ID
  Future<Publication> getPublicationById(String id) async {
    try {
      final response = await get('$_baseEndpoint/publications/$id/');
      return Publication.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la publication: $e');
    }
  }

  // Récupérer les publications mises en avant
  Future<List<Publication>> getFeaturedPublications() async {
    try {
      final response = await get(
        '$_baseEndpoint/publications/',
        queryParameters: {
          'is_featured': 'true',
          'status': 'PUBLISHED',
          'page_size': '10',
          'ordering': '-published_at'
        },
      );

      // Vérifier si la réponse contient des résultats
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('results')) {
        final List<dynamic> data = response.data['results'];

        // Parcourir chaque élément et parser individuellement pour isoler l'erreur
        final List<Publication> publications = [];
        for (int i = 0; i < data.length; i++) {
          try {
            final publication = Publication.fromJson(data[i]);
            publications.add(publication);
          } catch (e) {
            AppLogger.error(
                'Erreur lors du parsing de la publication à l\'index $i: $e');
            AppLogger.error(
                'Données de la publication problématique: ${data[i]}');
            // Continuer avec les autres publications au lieu de tout arrêter
          }
        }
        return publications;
      } else if (response.data is List) {
        // Si la réponse est directement une liste
        final List<dynamic> data = response.data;

        // Parcourir chaque élément et parser individuellement pour isoler l'erreur
        final List<Publication> publications = [];
        for (int i = 0; i < data.length; i++) {
          try {
            final publication = Publication.fromJson(data[i]);
            publications.add(publication);
          } catch (e) {
            AppLogger.error(
                'Erreur lors du parsing de la publication à l\'index $i: $e');
            AppLogger.error(
                'Données de la publication problématique: ${data[i]}');
            // Continuer avec les autres publications au lieu de tout arrêter
          }
        }
        return publications;
      } else {
        AppLogger.warning(
            'Format de réponse inattendu pour les publications mises en avant: ${response.data}');
        return [];
      }
    } catch (e) {
      AppLogger.error(
          'Erreur lors de la récupération des publications mises en avant: $e');
      // Retourner une liste vide plutôt que de lancer une exception
      return [];
    }
  }

  // Récupérer les publications épinglées
  Future<List<Publication>> getPinnedPublications() async {
    try {
      // Utiliser l'endpoint général avec paramètre is_pinned
      final response = await get(
        '$_baseEndpoint/publications/',
        queryParameters: {
          'is_pinned': 'true',
          'status': 'PUBLISHED',
          'page_size': '10',
          'ordering': '-published_at'
        },
      );

      AppLogger.info(
          'Pinned publications response type: ${response.data.runtimeType}');
      AppLogger.info('Pinned publications response: ${response.data}');

      // Vérifier si c'est du HTML au lieu de JSON
      if (response.data is String &&
          response.data.toString().contains('<!DOCTYPE html>')) {
        AppLogger.error(
            'Réponse HTML reçue au lieu de JSON pour les publications épinglées');
        return [];
      }

      // Vérifier si la réponse contient des résultats
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('results')) {
        final List<dynamic> data = response.data['results'];

        // Parcourir chaque élément et parser individuellement pour isoler l'erreur
        final List<Publication> publications = [];
        for (int i = 0; i < data.length; i++) {
          try {
            final publication = Publication.fromJson(data[i]);
            publications.add(publication);
          } catch (e) {
            AppLogger.error(
                'Erreur lors du parsing de la publication épinglée à l\'index $i: $e');
            AppLogger.error(
                'Données de la publication épinglée problématique: ${data[i]}');
            // Continuer avec les autres publications au lieu de tout arrêter
          }
        }
        return publications;
      }

      AppLogger.error(
          'Structure de réponse inattendue pour les publications épinglées');
      return [];
    } catch (e) {
      AppLogger.error(
          'Erreur lors du chargement des publications épinglées: $e');
      return [];
    }
  }

  // Filtrer par type de publication
  Future<List<Publication>> getPublicationsByType(String type) async {
    try {
      final response = await get(
        '$_baseEndpoint/publications/',
        queryParameters: {'publication_type': type, 'status': 'PUBLISHED'},
      );

      final List<dynamic> data = response.data['results'];
      return data.map((json) => Publication.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des publications par type: $e');
    }
  }

  // Filtrer par domaine
  Future<List<Publication>> getPublicationsByDomain(String domain) async {
    try {
      final response = await get(
        '$_baseEndpoint/publications/',
        queryParameters: {'domain': domain, 'status': 'PUBLISHED'},
      );

      final List<dynamic> data = response.data['results'];
      return data.map((json) => Publication.fromJson(json)).toList();
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des publications par domaine: $e');
    }
  }

  // Liker/Unliker une publication
  Future<Map<String, dynamic>> togglePublicationLike(
      String publicationId) async {
    try {
      final response = await post(
        '$_baseEndpoint/publications/$publicationId/like/',
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du like de la publication: $e');
    }
  }

  // Partager une publication
  Future<Map<String, dynamic>> sharePublication(String publicationId) async {
    try {
      final response = await post(
        '$_baseEndpoint/publications/$publicationId/share/',
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du partage de la publication: $e');
    }
  }

  // Récupérer les commentaires d'une publication
  Future<List<Comment>> getPublicationComments(String publicationId) async {
    try {
      final response = await get(
        '$_baseEndpoint/publications/$publicationId/comments/',
        queryParameters: {
          'ordering': '-created_at',
          'parent__isnull':
              'true', // Seulement les commentaires de premier niveau
        },
      );

      final List<dynamic> data = response.data['results'];
      final comments = data.map((json) => Comment.fromJson(json)).toList();

      // Charger les réponses pour chaque commentaire
      for (var i = 0; i < comments.length; i++) {
        final replies = await _getCommentReplies(comments[i].id);
        comments[i] = Comment(
          id: comments[i].id,
          content: comments[i].content,
          author: comments[i].author,
          parent: comments[i].parent,
          likesCount: comments[i].likesCount,
          repliesCount: comments[i].repliesCount,
          isEdited: comments[i].isEdited,
          editedAt: comments[i].editedAt,
          userHasLiked: comments[i].userHasLiked,
          depth: comments[i].depth,
          canHaveReplies: comments[i].canHaveReplies,
          createdAt: comments[i].createdAt,
          replies: replies,
        );
      }

      return comments;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des commentaires: $e');
    }
  }

  // Créer un commentaire
  Future<Comment> createComment({
    required String publicationId,
    required String content,
    String? parentId,
  }) async {
    final Map<String, dynamic> body = {
      'content': content,
    };

    if (parentId != null) {
      body['parent'] = parentId;
    }

    try {
      final response = await post(
        '$_baseEndpoint/publications/$publicationId/comments/',
        data: body,
      );
      return Comment.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors de la création du commentaire: $e');
    }
  }

  // Liker/Unliker un commentaire
  Future<Map<String, dynamic>> toggleCommentLike(String commentId) async {
    try {
      final response = await post(
        '$_baseEndpoint/comments/$commentId/like/',
      );
      return response.data;
    } catch (e) {
      throw Exception('Erreur lors du like du commentaire: $e');
    }
  }

  // Supprimer un commentaire
  Future<void> deleteComment(String commentId) async {
    try {
      await delete('$_baseEndpoint/comments/$commentId/');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du commentaire: $e');
    }
  }

  // Récupérer les réponses à un commentaire
  Future<List<Comment>> _getCommentReplies(String commentId) async {
    try {
      final response = await get(
        '$_baseEndpoint/comments/',
        queryParameters: {
          'parent': commentId,
          'ordering': 'created_at',
        },
      );

      final List<dynamic> data = response.data['results'];
      final replies = data.map((json) => Comment.fromJson(json)).toList();

      // Charger récursivement les réponses des réponses (jusqu'à une certaine profondeur)
      for (var i = 0; i < replies.length; i++) {
        if (replies[i].repliesCount > 0 && replies[i].depth < 2) {
          final subReplies = await _getCommentReplies(replies[i].id);
          replies[i] = Comment(
            id: replies[i].id,
            content: replies[i].content,
            author: replies[i].author,
            parent: replies[i].parent,
            likesCount: replies[i].likesCount,
            repliesCount: replies[i].repliesCount,
            isEdited: replies[i].isEdited,
            editedAt: replies[i].editedAt,
            userHasLiked: replies[i].userHasLiked,
            depth: replies[i].depth,
            canHaveReplies: replies[i].canHaveReplies,
            createdAt: replies[i].createdAt,
            replies: subReplies,
          );
        }
      }

      return replies;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des réponses: $e');
    }
  }

  // Méthodes utilitaires pour les types et domaines
  static const Map<String, String> publicationTypes = {
    'EDUCATIONAL': 'Éducatif',
    'ENTERTAINING': 'Divertissant',
    'MOTIVATIONAL': 'Motivant',
    'INFORMATIONAL': 'Informatif',
    'TIPS': 'Conseils',
    'ADVERTISING': 'Publicitaire',
    'SPONSORED': 'Sponsorisé',
    'NEWS': 'Actualités',
    'TUTORIAL': 'Tutoriel',
    'CASE_STUDY': 'Étude de cas',
  };

  static const Map<String, String> publicationDomains = {
    'PROJECT_MANAGEMENT': 'Gestion de projets',
    'FINANCE_INVESTMENT': 'Finances et investissements',
    'ENTREPRENEURSHIP': 'Entrepreneuriat',
    'PERSONAL_DEVELOPMENT': 'Développement personnel',
    'MARKETING_COMMUNICATION': 'Marketing et communication',
    'TECHNOLOGY': 'Technologie',
    'BUSINESS_STRATEGY': 'Stratégie d\'entreprise',
    'LEADERSHIP': 'Leadership',
    'INNOVATION': 'Innovation',
    'NETWORKING': 'Réseautage',
  };

  static List<String> get availableTypes => publicationTypes.keys.toList();
  static List<String> get availableDomains => publicationDomains.keys.toList();
}
