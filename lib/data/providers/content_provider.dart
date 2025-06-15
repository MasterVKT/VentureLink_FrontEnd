import 'package:flutter/foundation.dart';
import '../models/publication_model.dart';
import '../services/content_api_service.dart';

class ContentProvider extends ChangeNotifier {
  final ContentApiService _contentApiService = ContentApiService();

  // État des publications
  List<Publication> _publications = [];
  List<Publication> _featuredPublications = [];
  List<Publication> _pinnedPublications = [];

  // État de chargement
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  // Pagination
  int _currentPage = 1;
  static const int _pageSize = 20;

  // Filtres actuels
  String? _currentType;
  String? _currentDomain;
  String? _currentSearch;
  bool? _currentIsFeatured;
  bool? _currentIsSponsored;

  // Erreurs
  String? _error;

  // Commentaires par publication
  final Map<String, List<Comment>> _publicationComments = {};
  final Map<String, bool> _commentsLoading = {};

  // Getters
  List<Publication> get publications => _publications;
  List<Publication> get featuredPublications => _featuredPublications;
  List<Publication> get pinnedPublications => _pinnedPublications;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  String? get error => _error;

  List<Comment> getCommentsForPublication(String publicationId) =>
      _publicationComments[publicationId] ?? [];

  bool isLoadingComments(String publicationId) =>
      _commentsLoading[publicationId] ?? false;

  // Charger les publications initiales
  Future<void> loadPublications({
    String? type,
    String? domain,
    String? search,
    bool? isFeatured,
    bool? isSponsored,
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) return;

    try {
      if (refresh) {
        _currentPage = 1;
        _hasMoreData = true;
        _publications.clear();
      }

      _isLoading = true;
      _error = null;
      _currentType = type;
      _currentDomain = domain;
      _currentSearch = search;
      _currentIsFeatured = isFeatured;
      _currentIsSponsored = isSponsored;
      notifyListeners();

      final newPublications = await _contentApiService.getPublications(
        publicationType: type,
        domain: domain,
        search: search,
        isFeatured: isFeatured,
        isSponsored: isSponsored,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (refresh) {
        _publications = newPublications;
      } else {
        _publications.addAll(newPublications);
      }

      _hasMoreData = newPublications.length == _pageSize;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur lors du chargement des publications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger plus de publications (pagination)
  Future<void> loadMorePublications() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      final newPublications = await _contentApiService.getPublications(
        publicationType: _currentType,
        domain: _currentDomain,
        search: _currentSearch,
        isFeatured: _currentIsFeatured,
        isSponsored: _currentIsSponsored,
        page: _currentPage,
        pageSize: _pageSize,
      );

      _publications.addAll(newPublications);
      _hasMoreData = newPublications.length == _pageSize;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erreur lors du chargement de plus de publications: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Charger les publications mises en avant
  Future<void> loadFeaturedPublications() async {
    try {
      _featuredPublications =
          await _contentApiService.getFeaturedPublications();
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Erreur lors du chargement des publications mises en avant: $e');
    }
  }

  // Charger les publications épinglées
  Future<void> loadPinnedPublications() async {
    try {
      _pinnedPublications = await _contentApiService.getPinnedPublications();
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur lors du chargement des publications épinglées: $e');
    }
  }

  // Récupérer une publication par ID
  Future<Publication?> getPublicationById(String id) async {
    try {
      // Vérifier d'abord dans la liste locale
      final localPublication =
          _publications.where((p) => p.id == id).firstOrNull;
      if (localPublication != null) {
        return localPublication;
      }

      // Sinon, charger depuis l'API
      return await _contentApiService.getPublicationById(id);
    } catch (e) {
      debugPrint('Erreur lors du chargement de la publication: $e');
      return null;
    }
  }

  // Liker/Unliker une publication
  Future<bool> togglePublicationLike(String publicationId) async {
    try {
      final result =
          await _contentApiService.togglePublicationLike(publicationId);
      final liked = result['liked'] as bool;

      // Mettre à jour la publication dans la liste locale
      final index = _publications.indexWhere((p) => p.id == publicationId);
      if (index != -1) {
        final publication = _publications[index];
        final updatedPublication = Publication(
          id: publication.id,
          title: publication.title,
          summary: publication.summary,
          content: publication.content,
          publicationType: publication.publicationType,
          domain: publication.domain,
          tags: publication.tags,
          tagsList: publication.tagsList,
          author: publication.author,
          status: publication.status,
          publishedAt: publication.publishedAt,
          scheduledFor: publication.scheduledFor,
          viewsCount: publication.viewsCount,
          likesCount:
              liked ? publication.likesCount + 1 : publication.likesCount - 1,
          commentsCount: publication.commentsCount,
          sharesCount: publication.sharesCount,
          isFeatured: publication.isFeatured,
          isPinned: publication.isPinned,
          allowComments: publication.allowComments,
          isSponsored: publication.isSponsored,
          sponsorName: publication.sponsorName,
          sponsorUrl: publication.sponsorUrl,
          metaDescription: publication.metaDescription,
          slug: publication.slug,
          media: publication.media,
          likes: publication.likes,
          userHasLiked: liked,
          canBeCommented: publication.canBeCommented,
          isPublished: publication.isPublished,
          featuredMedia: publication.featuredMedia,
          createdAt: publication.createdAt,
          updatedAt: publication.updatedAt,
        );

        _publications[index] = updatedPublication;
        notifyListeners();
      }

      return liked;
    } catch (e) {
      debugPrint('Erreur lors du like de la publication: $e');
      return false;
    }
  }

  // Partager une publication
  Future<bool> sharePublication(String publicationId) async {
    try {
      final result = await _contentApiService.sharePublication(publicationId);
      final sharesCount = result['shares_count'] as int;

      // Mettre à jour le compteur de partages dans la liste locale
      final index = _publications.indexWhere((p) => p.id == publicationId);
      if (index != -1) {
        final publication = _publications[index];
        final updatedPublication = Publication(
          id: publication.id,
          title: publication.title,
          summary: publication.summary,
          content: publication.content,
          publicationType: publication.publicationType,
          domain: publication.domain,
          tags: publication.tags,
          tagsList: publication.tagsList,
          author: publication.author,
          status: publication.status,
          publishedAt: publication.publishedAt,
          scheduledFor: publication.scheduledFor,
          viewsCount: publication.viewsCount,
          likesCount: publication.likesCount,
          commentsCount: publication.commentsCount,
          sharesCount: sharesCount,
          isFeatured: publication.isFeatured,
          isPinned: publication.isPinned,
          allowComments: publication.allowComments,
          isSponsored: publication.isSponsored,
          sponsorName: publication.sponsorName,
          sponsorUrl: publication.sponsorUrl,
          metaDescription: publication.metaDescription,
          slug: publication.slug,
          media: publication.media,
          likes: publication.likes,
          userHasLiked: publication.userHasLiked,
          canBeCommented: publication.canBeCommented,
          isPublished: publication.isPublished,
          featuredMedia: publication.featuredMedia,
          createdAt: publication.createdAt,
          updatedAt: publication.updatedAt,
        );

        _publications[index] = updatedPublication;
        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors du partage de la publication: $e');
      return false;
    }
  }

  // Charger les commentaires d'une publication
  Future<void> loadPublicationComments(String publicationId) async {
    if (_commentsLoading[publicationId] == true) return;

    try {
      _commentsLoading[publicationId] = true;
      notifyListeners();

      final comments =
          await _contentApiService.getPublicationComments(publicationId);
      _publicationComments[publicationId] = comments;
    } catch (e) {
      debugPrint('Erreur lors du chargement des commentaires: $e');
    } finally {
      _commentsLoading[publicationId] = false;
      notifyListeners();
    }
  }

  // Créer un commentaire
  Future<bool> createComment({
    required String publicationId,
    required String content,
    String? parentId,
  }) async {
    try {
      final newComment = await _contentApiService.createComment(
        publicationId: publicationId,
        content: content,
        parentId: parentId,
      );

      // Ajouter le commentaire à la liste locale
      if (_publicationComments[publicationId] != null) {
        if (parentId == null) {
          // Commentaire de niveau supérieur
          _publicationComments[publicationId]!.insert(0, newComment);
        } else {
          // Réponse à un commentaire existant
          _addReplyToComment(
              _publicationComments[publicationId]!, parentId, newComment);
        }
      } else {
        _publicationComments[publicationId] = [newComment];
      }

      // Mettre à jour le compteur de commentaires de la publication
      final index = _publications.indexWhere((p) => p.id == publicationId);
      if (index != -1) {
        final publication = _publications[index];
        final updatedPublication = Publication(
          id: publication.id,
          title: publication.title,
          summary: publication.summary,
          content: publication.content,
          publicationType: publication.publicationType,
          domain: publication.domain,
          tags: publication.tags,
          tagsList: publication.tagsList,
          author: publication.author,
          status: publication.status,
          publishedAt: publication.publishedAt,
          scheduledFor: publication.scheduledFor,
          viewsCount: publication.viewsCount,
          likesCount: publication.likesCount,
          commentsCount: publication.commentsCount + 1,
          sharesCount: publication.sharesCount,
          isFeatured: publication.isFeatured,
          isPinned: publication.isPinned,
          allowComments: publication.allowComments,
          isSponsored: publication.isSponsored,
          sponsorName: publication.sponsorName,
          sponsorUrl: publication.sponsorUrl,
          metaDescription: publication.metaDescription,
          slug: publication.slug,
          media: publication.media,
          likes: publication.likes,
          userHasLiked: publication.userHasLiked,
          canBeCommented: publication.canBeCommented,
          isPublished: publication.isPublished,
          featuredMedia: publication.featuredMedia,
          createdAt: publication.createdAt,
          updatedAt: publication.updatedAt,
        );

        _publications[index] = updatedPublication;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la création du commentaire: $e');
      return false;
    }
  }

  // Liker/Unliker un commentaire
  Future<bool> toggleCommentLike(String publicationId, String commentId) async {
    try {
      final result = await _contentApiService.toggleCommentLike(commentId);
      final liked = result['liked'] as bool;

      // Mettre à jour le commentaire dans la liste locale
      if (_publicationComments[publicationId] != null) {
        _updateCommentLike(
            _publicationComments[publicationId]!, commentId, liked);
        notifyListeners();
      }

      return liked;
    } catch (e) {
      debugPrint('Erreur lors du like du commentaire: $e');
      return false;
    }
  }

  // Supprimer un commentaire
  Future<bool> deleteComment(String publicationId, String commentId) async {
    try {
      await _contentApiService.deleteComment(commentId);

      // Supprimer le commentaire de la liste locale
      if (_publicationComments[publicationId] != null) {
        _removeCommentFromList(_publicationComments[publicationId]!, commentId);

        // Mettre à jour le compteur de commentaires de la publication
        final index = _publications.indexWhere((p) => p.id == publicationId);
        if (index != -1) {
          final publication = _publications[index];
          final updatedPublication = Publication(
            id: publication.id,
            title: publication.title,
            summary: publication.summary,
            content: publication.content,
            publicationType: publication.publicationType,
            domain: publication.domain,
            tags: publication.tags,
            tagsList: publication.tagsList,
            author: publication.author,
            status: publication.status,
            publishedAt: publication.publishedAt,
            scheduledFor: publication.scheduledFor,
            viewsCount: publication.viewsCount,
            likesCount: publication.likesCount,
            commentsCount: publication.commentsCount - 1,
            sharesCount: publication.sharesCount,
            isFeatured: publication.isFeatured,
            isPinned: publication.isPinned,
            allowComments: publication.allowComments,
            isSponsored: publication.isSponsored,
            sponsorName: publication.sponsorName,
            sponsorUrl: publication.sponsorUrl,
            metaDescription: publication.metaDescription,
            slug: publication.slug,
            media: publication.media,
            likes: publication.likes,
            userHasLiked: publication.userHasLiked,
            canBeCommented: publication.canBeCommented,
            isPublished: publication.isPublished,
            featuredMedia: publication.featuredMedia,
            createdAt: publication.createdAt,
            updatedAt: publication.updatedAt,
          );

          _publications[index] = updatedPublication;
        }

        notifyListeners();
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la suppression du commentaire: $e');
      return false;
    }
  }

  // Rechercher des publications
  Future<void> searchPublications(String query) async {
    await loadPublications(search: query, refresh: true);
  }

  // Filtrer par type
  Future<void> filterByType(String type) async {
    await loadPublications(type: type, refresh: true);
  }

  // Filtrer par domaine
  Future<void> filterByDomain(String domain) async {
    await loadPublications(domain: domain, refresh: true);
  }

  // Réinitialiser les filtres
  Future<void> clearFilters() async {
    await loadPublications(refresh: true);
  }

  // Méthodes utilitaires privées
  void _addReplyToComment(
      List<Comment> comments, String parentId, Comment reply) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == parentId) {
        comments[i].replies.insert(0, reply);
        return;
      }
      if (comments[i].hasReplies) {
        _addReplyToComment(comments[i].replies, parentId, reply);
      }
    }
  }

  void _updateCommentLike(
      List<Comment> comments, String commentId, bool liked) {
    for (int i = 0; i < comments.length; i++) {
      if (comments[i].id == commentId) {
        final comment = comments[i];
        final updatedComment = Comment(
          id: comment.id,
          content: comment.content,
          author: comment.author,
          parent: comment.parent,
          likesCount: liked ? comment.likesCount + 1 : comment.likesCount - 1,
          repliesCount: comment.repliesCount,
          isEdited: comment.isEdited,
          editedAt: comment.editedAt,
          userHasLiked: liked,
          depth: comment.depth,
          canHaveReplies: comment.canHaveReplies,
          createdAt: comment.createdAt,
          replies: comment.replies,
        );
        comments[i] = updatedComment;
        return;
      }
      if (comments[i].hasReplies) {
        _updateCommentLike(comments[i].replies, commentId, liked);
      }
    }
  }

  void _removeCommentFromList(List<Comment> comments, String commentId) {
    comments.removeWhere((comment) {
      if (comment.id == commentId) {
        return true;
      }
      if (comment.hasReplies) {
        _removeCommentFromList(comment.replies, commentId);
      }
      return false;
    });
  }

  // Nettoyer les données
  void dispose() {
    _publications.clear();
    _featuredPublications.clear();
    _pinnedPublications.clear();
    _publicationComments.clear();
    _commentsLoading.clear();
    super.dispose();
  }
}
