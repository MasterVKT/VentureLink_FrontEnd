import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/foundation.dart';
import 'user_model.dart';
import '../../core/config/app_config.dart';

part 'publication_model.g.dart';

@JsonSerializable()
class Publication {
  final String id;
  final String title;
  final String? summary;
  final String? content;
  @JsonKey(name: 'publication_type')
  final String publicationType;
  final String domain;
  final String? tags;
  @JsonKey(name: 'tags_list')
  final List<String> tagsList;
  final UserModel author;
  final String status;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  @JsonKey(name: 'scheduled_for')
  final DateTime? scheduledFor;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'comments_count')
  final int commentsCount;
  @JsonKey(name: 'shares_count')
  final int? sharesCount;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  @JsonKey(name: 'allow_comments')
  final bool? allowComments;
  @JsonKey(name: 'is_sponsored')
  final bool isSponsored;
  @JsonKey(name: 'sponsor_name')
  final String? sponsorName;
  @JsonKey(name: 'sponsor_url')
  final String? sponsorUrl;
  @JsonKey(name: 'meta_description')
  final String? metaDescription;
  final String? slug;
  @JsonKey(fromJson: _mediaFromJson)
  final List<PublicationMedia>? media;
  final List<PublicationLike>? likes;
  @JsonKey(name: 'user_has_liked')
  final bool userHasLiked;
  @JsonKey(name: 'can_be_commented')
  final bool? canBeCommented;
  @JsonKey(name: 'is_published')
  final bool? isPublished;
  @JsonKey(name: 'featured_media', fromJson: _featuredMediaFromJson)
  final PublicationMedia? featuredMedia;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Publication({
    required this.id,
    required this.title,
    this.summary,
    this.content,
    required this.publicationType,
    required this.domain,
    this.tags,
    this.tagsList = const [],
    required this.author,
    required this.status,
    this.publishedAt,
    this.scheduledFor,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount,
    this.isFeatured = false,
    this.isPinned = false,
    this.allowComments,
    this.isSponsored = false,
    this.sponsorName,
    this.sponsorUrl,
    this.metaDescription,
    this.slug,
    this.media,
    this.likes,
    this.userHasLiked = false,
    this.canBeCommented,
    this.isPublished,
    this.featuredMedia,
    this.createdAt,
    this.updatedAt,
  });

  // Fonctions de parsing personnalisées pour les médias (similaires aux projets)
  static List<PublicationMedia>? _mediaFromJson(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;

    return value
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return PublicationMedia.fromJson(item);
            }
            return null;
          } catch (e) {
            debugPrint('Erreur parsing PublicationMedia dans media: $e');
            debugPrint('Données problématiques: $item');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<PublicationMedia>()
        .toList();
  }

  static PublicationMedia? _featuredMediaFromJson(dynamic value) {
    if (value == null) return null;

    try {
      if (value is Map<String, dynamic>) {
        return PublicationMedia.fromJson(value);
      }
      return null;
    } catch (e) {
      debugPrint('Erreur parsing PublicationMedia dans featured_media: $e');
      debugPrint('Données problématiques: $value');
      return null;
    }
  }

  factory Publication.fromJson(Map<String, dynamic> json) =>
      _$PublicationFromJson(json);
  Map<String, dynamic> toJson() => _$PublicationToJson(this);

  // Getters utilitaires
  String get typeDisplayName {
    switch (publicationType) {
      case 'EDUCATIONAL':
        return 'Éducatif';
      case 'NEWS':
        return 'Actualité';
      case 'TIPS':
        return 'Conseil';
      case 'TUTORIAL':
        return 'Tutoriel';
      case 'MOTIVATIONAL':
        return 'Motivant';
      case 'PROMOTIONAL':
        return 'Promotionnel';
      case 'ANNOUNCEMENT':
        return 'Annonce';
      default:
        return publicationType;
    }
  }

  String get domainDisplayName {
    switch (domain) {
      case 'ENTREPRENEURSHIP':
        return 'Entrepreneuriat';
      case 'FINANCE_INVESTMENT':
        return 'Finance & Investissement';
      case 'TECHNOLOGY':
        return 'Technologie';
      case 'MARKETING':
        return 'Marketing';
      case 'LEADERSHIP':
        return 'Leadership';
      case 'PERSONAL_DEVELOPMENT':
        return 'Développement personnel';
      case 'PROJECT_MANAGEMENT':
        return 'Gestion de projet';
      default:
        return domain;
    }
  }

  String get formattedPublishedDate {
    if (publishedAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inDays > 7) {
      return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }

  bool get hasMedia => featuredMedia != null || (media?.isNotEmpty ?? false);

  String? get primaryImageUrl {
    final imageMedia = media?.where((m) => m.isImage).toList() ?? [];
    if (imageMedia.isNotEmpty) {
      return imageMedia.first.file;
    }
    return featuredMedia?.isImage == true ? featuredMedia!.file : null;
  }

  /// Obtient l'URL complète de l'image principale
  String? get primaryImageFullUrl {
    // Prioriser featuredMedia (image de couverture) puis fallback vers media
    if (featuredMedia?.isImage == true) {
      debugPrint(
          '[PUBLICATION] 🎯 Utilisation featuredMedia: ${featuredMedia!.file}');
      return featuredMedia!.fullUrl;
    }

    final imageMedia = media?.where((m) => m.isImage).toList() ?? [];
    if (imageMedia.isNotEmpty) {
      debugPrint(
          '[PUBLICATION] 🎯 Utilisation premier media: ${imageMedia.first.file}');
      return imageMedia.first.fullUrl;
    }

    debugPrint('[PUBLICATION] ❌ Aucune image trouvée');
    return null;
  }
}

@JsonSerializable()
class PublicationMedia {
  final String id;
  final String file;
  final String? title;
  final String? description;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'file_size')
  final int? fileSize;
  final int? duration;
  @JsonKey(name: 'alt_text')
  final String? altText;
  final int? order;
  @JsonKey(name: 'is_featured')
  final bool? isFeatured;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  PublicationMedia({
    required this.id,
    required this.file,
    this.title,
    this.description,
    required this.mediaType,
    this.fileSize,
    this.duration,
    this.altText,
    this.order,
    this.isFeatured,
    required this.createdAt,
  });

  factory PublicationMedia.fromJson(Map<String, dynamic> json) {
    try {
      return _$PublicationMediaFromJson(json);
    } catch (e) {
      debugPrint('Erreur parsing PublicationMedia: $e');
      debugPrint('JSON: $json');
      // Créer un objet par défaut en cas d'erreur
      return PublicationMedia(
        id: json['id']?.toString() ?? '',
        file: json['file']?.toString() ?? '',
        title: json['title']?.toString(),
        description: json['description']?.toString(),
        mediaType: json['media_type']?.toString() ?? 'image/jpeg',
        fileSize: (json['file_size'] as num?)?.toInt(),
        duration: (json['duration'] as num?)?.toInt(),
        altText: json['alt_text']?.toString(),
        order: (json['order'] as num?)?.toInt(),
        isFeatured: json['is_featured'] as bool?,
        createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );
    }
  }
  Map<String, dynamic> toJson() => _$PublicationMediaToJson(this);

  bool get isImage =>
      mediaType.toUpperCase() == 'IMAGE' || mediaType.startsWith('image/');

  bool get isVideo =>
      mediaType.toUpperCase() == 'VIDEO' || mediaType.startsWith('video/');

  bool get isAudio =>
      mediaType.toUpperCase() == 'AUDIO' || mediaType.startsWith('audio/');

  bool get isDocument =>
      mediaType.toUpperCase() == 'DOCUMENT' ||
      mediaType == 'application/pdf' ||
      mediaType.startsWith('application/') ||
      mediaType.startsWith('text/');

  /// Obtient l'URL complète du média
  String get fullUrl {
    debugPrint('[MEDIA] 🔗 Génération URL pour file: $file');

    if (file.startsWith('http')) {
      debugPrint('[MEDIA] ✅ URL absolue détectée: $file');
      return file;
    }

    // 🚫 Filtrer les fichiers de test invalides
    if (file.contains('test1.jpg') ||
        file.contains('test2.jpg') ||
        file.contains('test3.jpg')) {
      debugPrint(
          '[MEDIA] ⚠️ Fichier de test détecté, utilisation d\'une image placeholder');
      return 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}';
    }

    String finalUrl;

    // Selon le guide : {BACKEND_URL}/media/publications/media/{filename}
    // Mais nous devons gérer plusieurs cas possibles

    if (file.startsWith('/media/')) {
      // Le fichier commence par /media/, utilisons-le tel quel
      finalUrl = '${AppConfig.apiBaseUrl}$file';
      debugPrint('[MEDIA] 📁 URL avec /media/ détectée: $finalUrl');
    } else if (file.startsWith('media/')) {
      // Le fichier commence par media/ (sans le slash initial)
      finalUrl = '${AppConfig.apiBaseUrl}/$file';
      debugPrint('[MEDIA] 📁 URL avec media/ détectée: $finalUrl');
    } else if (file.contains('publications/')) {
      // Le fichier contient publications/, supposons qu'il faut juste ajouter /media/
      finalUrl = '${AppConfig.apiBaseUrl}/media/$file';
      debugPrint('[MEDIA] 📁 URL avec publications/ détectée: $finalUrl');
    } else {
      // Cas par défaut : construire l'URL selon le guide
      // {BACKEND_URL}/media/publications/media/{filename}
      final filename = file.split('/').last;
      finalUrl = '${AppConfig.apiBaseUrl}/media/publications/media/$filename';
      debugPrint('[MEDIA] 🔧 URL construite selon guide: $finalUrl');
    }

    debugPrint('[MEDIA] 🎯 URL finale: $finalUrl');

    // Test de plusieurs variantes si nécessaire
    debugPrint('[MEDIA] 🧪 Variantes possibles:');
    debugPrint('[MEDIA]   - Direct: ${AppConfig.apiBaseUrl}$file');
    debugPrint('[MEDIA]   - Avec /media/: ${AppConfig.apiBaseUrl}/media/$file');
    debugPrint(
        '[MEDIA]   - Guide format: ${AppConfig.apiBaseUrl}/media/publications/media/${file.split('/').last}');

    return finalUrl;
  }
}

@JsonSerializable()
class PublicationLike {
  final String id;
  final UserModel user;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  PublicationLike({
    required this.id,
    required this.user,
    required this.createdAt,
  });

  factory PublicationLike.fromJson(Map<String, dynamic> json) =>
      _$PublicationLikeFromJson(json);
  Map<String, dynamic> toJson() => _$PublicationLikeToJson(this);
}

@JsonSerializable()
class Comment {
  final String id;
  final String content;
  final UserModel author;
  final String? parent;
  @JsonKey(name: 'likes_count')
  final int likesCount;
  @JsonKey(name: 'replies_count')
  final int repliesCount;
  @JsonKey(name: 'is_edited')
  final bool isEdited;
  @JsonKey(name: 'edited_at')
  final DateTime? editedAt;
  @JsonKey(name: 'user_has_liked')
  final bool userHasLiked;
  final int depth;
  @JsonKey(name: 'can_have_replies')
  final bool canHaveReplies;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  // Réponses chargées localement
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    required this.author,
    this.parent,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isEdited = false,
    this.editedAt,
    this.userHasLiked = false,
    this.depth = 0,
    this.canHaveReplies = true,
    required this.createdAt,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);

  bool get hasReplies => replies.isNotEmpty;

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'À l\'instant';
    }
  }
}

// Extensions pour les listes
extension PublicationListExtensions on List<Publication> {
  List<Publication> get featured => where((p) => p.isFeatured).toList();
  List<Publication> get pinned => where((p) => p.isPinned).toList();
  List<Publication> get sponsored => where((p) => p.isSponsored).toList();

  List<Publication> byType(String type) =>
      where((p) => p.publicationType == type).toList();

  List<Publication> byDomain(String domain) =>
      where((p) => p.domain == domain).toList();
}
