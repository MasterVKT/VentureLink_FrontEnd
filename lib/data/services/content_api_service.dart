import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/publication_model.dart';
import 'api_service.dart';

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
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'ordering': ordering,
      'status': 'PUBLISHED', // Seules les publications publiées
    };

    if (publicationType != null)
      queryParams['publication_type'] = publicationType;
    if (domain != null) queryParams['domain'] = domain;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (isFeatured != null) queryParams['is_featured'] = isFeatured.toString();
    if (isSponsored != null)
      queryParams['is_sponsored'] = isSponsored.toString();

    final response = await get(
      '$_baseEndpoint/publications/',
      queryParams: queryParams,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Publication.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des publications: ${response.statusCode}');
    }
  }

  // Récupérer une publication par ID
  Future<Publication> getPublicationById(String id) async {
    final response = await get('$_baseEndpoint/publications/$id/');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Publication.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Publication non trouvée');
    } else {
      throw Exception(
          'Erreur lors du chargement de la publication: ${response.statusCode}');
    }
  }

  // Récupérer les publications mises en avant
  Future<List<Publication>> getFeaturedPublications() async {
    final response = await get('$_baseEndpoint/publications/featured/');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Publication.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des publications mises en avant: ${response.statusCode}');
    }
  }

  // Récupérer les publications épinglées
  Future<List<Publication>> getPinnedPublications() async {
    final response = await get('$_baseEndpoint/publications/pinned/');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Publication.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des publications épinglées: ${response.statusCode}');
    }
  }

  // Récupérer les publications par type
  Future<List<Publication>> getPublicationsByType(String type) async {
    final response = await get(
      '$_baseEndpoint/publications/by_type/',
      queryParams: {'type': type},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Publication.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des publications par type: ${response.statusCode}');
    }
  }

  // Récupérer les publications par domaine
  Future<List<Publication>> getPublicationsByDomain(String domain) async {
    final response = await get(
      '$_baseEndpoint/publications/by_domain/',
      queryParams: {'domain': domain},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((json) => Publication.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des publications par domaine: ${response.statusCode}');
    }
  }

  // Liker/Unliker une publication
  Future<Map<String, dynamic>> togglePublicationLike(
      String publicationId) async {
    final response =
        await post('$_baseEndpoint/publications/$publicationId/like/');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Erreur lors du like de la publication: ${response.statusCode}');
    }
  }

  // Partager une publication (incrémenter le compteur)
  Future<Map<String, dynamic>> sharePublication(String publicationId) async {
    final response =
        await post('$_baseEndpoint/publications/$publicationId/share/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Erreur lors du partage de la publication: ${response.statusCode}');
    }
  }

  // Récupérer les commentaires d'une publication
  Future<List<Comment>> getPublicationComments(String publicationId) async {
    final response = await get(
      '$_baseEndpoint/comments/for_object/',
      queryParams: {
        'content_type': 'content.publication',
        'object_id': publicationId,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des commentaires: ${response.statusCode}');
    }
  }

  // Créer un commentaire sur une publication
  Future<Comment> createComment({
    required String publicationId,
    required String content,
    String? parentId,
  }) async {
    final body = {
      'content_type': 'content.publication',
      'object_id': publicationId,
      'content': content,
    };

    if (parentId != null) {
      body['parent'] = parentId;
    }

    final response = await post(
      '$_baseEndpoint/comments/',
      body: body,
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Comment.fromJson(data);
    } else {
      throw Exception(
          'Erreur lors de la création du commentaire: ${response.statusCode}');
    }
  }

  // Modifier un commentaire
  Future<Comment> updateComment(String commentId, String content) async {
    final response = await put(
      '$_baseEndpoint/comments/$commentId/',
      body: {'content': content},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Comment.fromJson(data);
    } else {
      throw Exception(
          'Erreur lors de la modification du commentaire: ${response.statusCode}');
    }
  }

  // Supprimer un commentaire
  Future<void> deleteComment(String commentId) async {
    final response = await delete('$_baseEndpoint/comments/$commentId/');

    if (response.statusCode != 204) {
      throw Exception(
          'Erreur lors de la suppression du commentaire: ${response.statusCode}');
    }
  }

  // Liker/Unliker un commentaire
  Future<Map<String, dynamic>> toggleCommentLike(String commentId) async {
    final response = await post('$_baseEndpoint/comments/$commentId/like/');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Erreur lors du like du commentaire: ${response.statusCode}');
    }
  }

  // Signaler un commentaire
  Future<void> flagComment(String commentId) async {
    final response = await post('$_baseEndpoint/comments/$commentId/flag/');

    if (response.statusCode != 200) {
      throw Exception(
          'Erreur lors du signalement du commentaire: ${response.statusCode}');
    }
  }

  // Récupérer les réponses d'un commentaire
  Future<List<Comment>> getCommentReplies(String commentId) async {
    final response = await get('$_baseEndpoint/comments/$commentId/replies/');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception(
          'Erreur lors du chargement des réponses: ${response.statusCode}');
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
