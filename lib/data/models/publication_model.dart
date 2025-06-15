import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

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
  final int sharesCount;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  @JsonKey(name: 'allow_comments')
  final bool allowComments;
  @JsonKey(name: 'is_sponsored')
  final bool isSponsored;
  @JsonKey(name: 'sponsor_name')
  final String? sponsorName;
  @JsonKey(name: 'sponsor_url')
  final String? sponsorUrl;
  @JsonKey(name: 'meta_description')
  final String? metaDescription;
  final String? slug;
  final List<PublicationMedia> media;
  final List<PublicationLike> likes;
  @JsonKey(name: 'user_has_liked')
  final bool userHasLiked;
  @JsonKey(name: 'can_be_commented')
  final bool canBeCommented;
  @JsonKey(name: 'is_published')
  final bool isPublished;
  @JsonKey(name: 'featured_media')
  final PublicationMedia? featuredMedia;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

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
    this.sharesCount = 0,
    this.isFeatured = false,
    this.isPinned = false,
    this.allowComments = true,
    this.isSponsored = false,
    this.sponsorName,
    this.sponsorUrl,
    this.metaDescription,
    this.slug,
    this.media = const [],
    this.likes = const [],
    this.userHasLiked = false,
    this.canBeCommented = true,
    this.isPublished = false,
    this.featuredMedia,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Publication.fromJson(Map<String, dynamic> json) => _$PublicationFromJson(json);
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

  bool get hasMedia => media.isNotEmpty;
  
  String? get primaryImageUrl {
    final imageMedia = media.where((m) => m.isImage).toList();
    if (imageMedia.isNotEmpty) {
      return imageMedia.first.file;
    }
    return featuredMedia?.isImage == true ? featuredMedia!.file : null;
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
    required this.createdAt,
  });

  factory PublicationMedia.fromJson(Map<String, dynamic> json) => _$PublicationMediaFromJson(json);
  Map<String, dynamic> toJson() => _$PublicationMediaToJson(this);

  bool get isImage => mediaType.startsWith('image/');
  bool get isVideo => mediaType.startsWith('video/');
  bool get isDocument => mediaType == 'application/pdf' || 
                        mediaType.startsWith('application/') ||
                        mediaType.startsWith('text/');
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

  factory PublicationLike.fromJson(Map<String, dynamic> json) => _$PublicationLikeFromJson(json);
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

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
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
