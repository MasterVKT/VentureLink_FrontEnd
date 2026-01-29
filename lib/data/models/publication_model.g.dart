// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'publication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Publication _$PublicationFromJson(Map<String, dynamic> json) => Publication(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String?,
      content: json['content'] as String?,
      publicationType: json['publication_type'] as String,
      domain: json['domain'] as String,
      tags: json['tags'] as String?,
      tagsList: (json['tags_list'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      status: json['status'] as String,
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      scheduledFor: json['scheduled_for'] == null
          ? null
          : DateTime.parse(json['scheduled_for'] as String),
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      sharesCount: (json['shares_count'] as num?)?.toInt(),
      isFeatured: json['is_featured'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      allowComments: json['allow_comments'] as bool?,
      isSponsored: json['is_sponsored'] as bool? ?? false,
      sponsorName: json['sponsor_name'] as String?,
      sponsorUrl: json['sponsor_url'] as String?,
      metaDescription: json['meta_description'] as String?,
      slug: json['slug'] as String?,
      media: Publication._mediaFromJson(json['media']),
      likes: (json['likes'] as List<dynamic>?)
          ?.map((e) => PublicationLike.fromJson(e as Map<String, dynamic>))
          .toList(),
      userHasLiked: json['user_has_liked'] as bool? ?? false,
      canBeCommented: json['can_be_commented'] as bool?,
      isPublished: json['is_published'] as bool?,
      featuredMedia: Publication._featuredMediaFromJson(json['featured_media']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PublicationToJson(Publication instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'summary': instance.summary,
      'content': instance.content,
      'publication_type': instance.publicationType,
      'domain': instance.domain,
      'tags': instance.tags,
      'tags_list': instance.tagsList,
      'author': instance.author,
      'status': instance.status,
      'published_at': instance.publishedAt?.toIso8601String(),
      'scheduled_for': instance.scheduledFor?.toIso8601String(),
      'views_count': instance.viewsCount,
      'likes_count': instance.likesCount,
      'comments_count': instance.commentsCount,
      'shares_count': instance.sharesCount,
      'is_featured': instance.isFeatured,
      'is_pinned': instance.isPinned,
      'allow_comments': instance.allowComments,
      'is_sponsored': instance.isSponsored,
      'sponsor_name': instance.sponsorName,
      'sponsor_url': instance.sponsorUrl,
      'meta_description': instance.metaDescription,
      'slug': instance.slug,
      'media': instance.media,
      'likes': instance.likes,
      'user_has_liked': instance.userHasLiked,
      'can_be_commented': instance.canBeCommented,
      'is_published': instance.isPublished,
      'featured_media': instance.featuredMedia,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

PublicationMedia _$PublicationMediaFromJson(Map<String, dynamic> json) =>
    PublicationMedia(
      id: json['id'] as String,
      file: json['file'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      mediaType: json['media_type'] as String,
      fileSize: (json['file_size'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      altText: json['alt_text'] as String?,
      order: (json['order'] as num?)?.toInt(),
      isFeatured: json['is_featured'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PublicationMediaToJson(PublicationMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'file': instance.file,
      'title': instance.title,
      'description': instance.description,
      'media_type': instance.mediaType,
      'file_size': instance.fileSize,
      'duration': instance.duration,
      'alt_text': instance.altText,
      'order': instance.order,
      'is_featured': instance.isFeatured,
      'created_at': instance.createdAt.toIso8601String(),
    };

PublicationLike _$PublicationLikeFromJson(Map<String, dynamic> json) =>
    PublicationLike(
      id: json['id'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PublicationLikeToJson(PublicationLike instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'created_at': instance.createdAt.toIso8601String(),
    };

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      content: json['content'] as String,
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      parent: json['parent'] as String?,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] == null
          ? null
          : DateTime.parse(json['edited_at'] as String),
      userHasLiked: json['user_has_liked'] as bool? ?? false,
      depth: (json['depth'] as num?)?.toInt() ?? 0,
      canHaveReplies: json['can_have_replies'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'author': instance.author,
      'parent': instance.parent,
      'likes_count': instance.likesCount,
      'replies_count': instance.repliesCount,
      'is_edited': instance.isEdited,
      'edited_at': instance.editedAt?.toIso8601String(),
      'user_has_liked': instance.userHasLiked,
      'depth': instance.depth,
      'can_have_replies': instance.canHaveReplies,
      'created_at': instance.createdAt.toIso8601String(),
    };
