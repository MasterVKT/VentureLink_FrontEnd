// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectMedia _$ProjectMediaFromJson(Map<String, dynamic> json) => ProjectMedia(
      id: json['id'] as String,
      url: json['url'] as String,
      type: json['type'] as String,
      title: json['title'] as String?,
      description: json['description'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProjectMediaToJson(ProjectMedia instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'is_primary': instance.isPrimary,
      'order': instance.order,
    };

ProjectModel _$ProjectModelFromJson(Map<String, dynamic> json) => ProjectModel(
      id: json['id'] as String,
      creator: UserModel.fromJson(json['creator'] as Map<String, dynamic>),
      creatorName: json['creator_name'] as String?,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String,
      fullDescription:
          ProjectModel._fullDescriptionFromJson(json['full_description']),
      category:
          CategoryModel.fromJson(json['category'] as Map<String, dynamic>),
      stage: json['stage'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
      fundingMin: ProjectModel._fundingFromJson(json['funding_min']),
      fundingMax: ProjectModel._fundingFromJson(json['funding_max']),
      fundingCurrency: json['funding_currency'] as String? ?? 'EUR',
      locationCountry: json['location_country'] as String?,
      locationCity: json['location_city'] as String?,
      businessPlan: json['business_plan'] as String?,
      videoUrl: json['video_url'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isDraft: json['is_draft'] as bool? ?? false,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      interestsCount: (json['interests_count'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      publishedAt: ProjectModel._dateTimeFromJson(json['published_at']),
      createdAt: ProjectModel._dateTimeFromJsonRequired(json['created_at']),
      updatedAt: ProjectModel._dateTimeFromJsonRequired(json['updated_at']),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mediaList: json['media_urls'] == null
          ? const []
          : ProjectModel._mediaUrlsFromJson(json['media_urls']),
      media: (json['media'] as List<dynamic>?)
          ?.map((e) => ProjectMediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      needs: (json['needs'] as List<dynamic>?)
          ?.map((e) => ProjectNeedModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      skillsNeeded: (json['skills_needed'] as List<dynamic>?)
          ?.map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryImageUrl: json['primary_image_url'] as String?,
    );

Map<String, dynamic> _$ProjectModelToJson(ProjectModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creator': instance.creator,
      'creator_name': instance.creatorName,
      'title': instance.title,
      'short_description': instance.shortDescription,
      'full_description': instance.fullDescription,
      'category': instance.category,
      'stage': instance.stage,
      'status': instance.status,
      'funding_min': instance.fundingMin,
      'funding_max': instance.fundingMax,
      'funding_currency': instance.fundingCurrency,
      'location_country': instance.locationCountry,
      'location_city': instance.locationCity,
      'business_plan': instance.businessPlan,
      'video_url': instance.videoUrl,
      'is_premium': instance.isPremium,
      'is_featured': instance.isFeatured,
      'is_draft': instance.isDraft,
      'views_count': instance.viewsCount,
      'interests_count': instance.interestsCount,
      'favorites_count': instance.favoritesCount,
      'published_at': instance.publishedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'tags': instance.tags,
      'media_urls': instance.mediaList,
      'media': instance.media,
      'primary_image_url': instance.primaryImageUrl,
      'needs': instance.needs,
      'skills_needed': instance.skillsNeeded,
    };

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: json['id'] as String,
      nameFr: json['name_fr'] as String,
      nameEn: json['name_en'] as String,
      icon: CategoryModel._iconFromJson(json['icon']),
      descriptionFr: json['description_fr'] as String?,
      descriptionEn: json['description_en'] as String?,
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_fr': instance.nameFr,
      'name_en': instance.nameEn,
      'icon': instance.icon,
      'description_fr': instance.descriptionFr,
      'description_en': instance.descriptionEn,
    };

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
      id: json['id'] as String,
      nameFr: json['name_fr'] as String,
      nameEn: json['name_en'] as String,
      color: TagModel._colorFromJson(json['color']),
    );

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
      'id': instance.id,
      'name_fr': instance.nameFr,
      'name_en': instance.nameEn,
      'color': instance.color,
    };

ProjectMediaModel _$ProjectMediaModelFromJson(Map<String, dynamic> json) =>
    ProjectMediaModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      mediaType: json['media_type'] as String,
      fileUrl: json['file_url'] as String?,
      caption: json['caption'] as String?,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProjectMediaModelToJson(ProjectMediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'media_type': instance.mediaType,
      'file_url': instance.fileUrl,
      'caption': instance.caption,
      'display_order': instance.displayOrder,
      'created_at': instance.createdAt.toIso8601String(),
    };

ProjectNeedModel _$ProjectNeedModelFromJson(Map<String, dynamic> json) =>
    ProjectNeedModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      needType: json['need_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      isUrgent: json['is_urgent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ProjectNeedModelToJson(ProjectNeedModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'project_id': instance.projectId,
      'need_type': instance.needType,
      'title': instance.title,
      'description': instance.description,
      'amount': instance.amount,
      'currency': instance.currency,
      'is_urgent': instance.isUrgent,
      'created_at': instance.createdAt.toIso8601String(),
    };

SkillModel _$SkillModelFromJson(Map<String, dynamic> json) => SkillModel(
      id: json['id'] as String,
      nameFr: json['name_fr'] as String,
      nameEn: json['name_en'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SkillModelToJson(SkillModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_fr': instance.nameFr,
      'name_en': instance.nameEn,
      'category': instance.category,
      'description': instance.description,
    };
