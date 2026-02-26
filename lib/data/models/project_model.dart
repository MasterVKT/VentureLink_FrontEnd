import 'package:flutter/foundation.dart';
import 'user_model.dart';
import 'package:venturelink/core/config/app_config.dart';

/// Modèle pour les médias du projet
class ProjectMedia {
  final String id;
  final String url;
  final String type; // 'IMAGE', 'VIDEO', 'DOCUMENT'
  final String? title;
  final String? description;
  final bool isPrimary;
  final int order;

  ProjectMedia({
    required this.id,
    required this.url,
    required this.type,
    this.title,
    this.description,
    this.isPrimary = false,
    this.order = 0,
  });

  factory ProjectMedia.fromJson(Map<String, dynamic> json) {
    return ProjectMedia(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? 'IMAGE',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      isPrimary: json['is_primary'] == true,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'type': type,
        'title': title,
        'description': description,
        'is_primary': isPrimary,
        'order': order,
      };

  /// Obtient l'URL complète si elle n'est pas déjà absolue
  String get fullUrl {
    if (url.startsWith('http')) return url;
    return AppConfig.apiBaseUrl + url;
  }
}

class ProjectModel {
  final String id;
  final UserModel creator;
  final String? creatorName;
  final String? creatorId;
  final String? creatorProfilePicture;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final CategoryModel category;
  final String stage;
  final String status;
  final double fundingMin;
  final double fundingMax;
  final String fundingCurrency;
  final String? locationCountry;
  final String? locationCity;
  final String? businessPlan;
  final String? videoUrl;
  final bool isPremium;
  final bool isFeatured;
  final bool isDraft;
  final bool isFavorite;
  final int viewsCount;
  final int interestsCount;
  final int favoritesCount;
  final bool isFavorite;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<TagModel>? tags;
  final List<ProjectMedia> mediaList;
  final String? primaryImageUrl;
  final List<ProjectMediaModel>? media; // Ancien système de médias
  final List<ProjectNeedModel>? needs;
  final List<SkillModel>? skillsNeeded;

  ProjectModel({
    required this.id,
    required this.creator,
    this.creatorName,
    this.creatorId,
    this.creatorProfilePicture,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.category,
    required this.stage,
    this.status = 'ACTIVE',
    required this.fundingMin,
    required this.fundingMax,
    this.fundingCurrency = 'EUR',
    this.locationCountry,
    this.locationCity,
    this.businessPlan,
    this.videoUrl,
    this.isPremium = false,
    this.isFeatured = false,
    this.isDraft = false,
    this.isFavorite = false,
    this.viewsCount = 0,
    this.interestsCount = 0,
    this.isFavorite = false,
    this.favoritesCount = 0,
    this.publishedAt,
    this.createdAt,
    this.updatedAt,
    this.tags,
    this.mediaList = const [],
    this.primaryImageUrl,
    this.media,
    this.needs,
    this.skillsNeeded,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // Reconstruire le creator à partir des champs individuels
    final creator = _createCreatorFromProjectData(json);

    return ProjectModel(
      id: json['id']?.toString() ?? '',
      creator: creator,
      creatorName: json['creator_name']?.toString(),
      creatorId: json['creator_id']?.toString(),
      creatorProfilePicture: json['creator_profile_picture']?.toString(),
      title: json['title']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      fullDescription: json['full_description']?.toString() ?? '',
      category: _categoryFromJson(json['category']),
      stage: json['stage']?.toString() ?? 'IDEA',
      status: json['status']?.toString() ?? 'ACTIVE',
      fundingMin: _fundingFromJson(json['funding_min']),
      fundingMax: _fundingFromJson(json['funding_max']),
      fundingCurrency: json['funding_currency']?.toString() ?? 'EUR',
      locationCountry: json['location_country']?.toString(),
      locationCity: json['location_city']?.toString(),
      businessPlan: json['business_plan']?.toString(),
      videoUrl: json['video_url']?.toString(),
      isPremium: json['is_premium'] == true,
      isFeatured: json['is_featured'] == true,
      isDraft: json['is_draft'] == true,
      isFavorite: json['is_favorite'] == true,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      interestsCount: (json['interests_count'] as num?)?.toInt() ?? 0,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      isFavorite: json['is_favorite'] == true,
      publishedAt: _dateTimeFromJson(json['published_at']),
      createdAt: _dateTimeFromJson(json['created_at']),
      updatedAt: _dateTimeFromJson(json['updated_at']),
      tags: _tagsFromJson(json['tags']),
      mediaList: _mediaUrlsFromJson(json['media_urls']),
      primaryImageUrl: json['primary_image_url']?.toString(),
      media: _oldMediaFromJson(json['media']),
      needs: _needsFromJson(json['needs']),
      skillsNeeded: _skillsFromJson(json['skills_needed']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'creator_name': creatorName,
        'creator_id': creatorId,
        'creator_profile_picture': creatorProfilePicture,
        'title': title,
        'short_description': shortDescription,
        'full_description': fullDescription,
        'category': category.toJson(),
        'stage': stage,
        'status': status,
        'funding_min': fundingMin,
        'funding_max': fundingMax,
        'funding_currency': fundingCurrency,
        'location_country': locationCountry,
        'location_city': locationCity,
        'business_plan': businessPlan,
        'video_url': videoUrl,
        'is_premium': isPremium,
        'is_featured': isFeatured,
        'is_draft': isDraft,
        'is_favorite': isFavorite,
        'views_count': viewsCount,
        'interests_count': interestsCount,
        'favorites_count': favoritesCount,
        'is_favorite': isFavorite,
        'published_at': publishedAt?.toIso8601String(),
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'tags': tags?.map((t) => t.toJson()).toList(),
        'media_urls': mediaList.map((m) => m.toJson()).toList(),
        'primary_image_url': primaryImageUrl,
        'media': media?.map((m) => m.toJson()).toList(),
        'needs': needs?.map((n) => n.toJson()).toList(),
        'skills_needed': skillsNeeded?.map((s) => s.toJson()).toList(),
      };

  // Fonctions de conversion statiques
  static List<ProjectMedia> _mediaUrlsFromJson(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    return value
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return ProjectMedia.fromJson(item);
            }
            return null;
          } catch (e) {
            debugPrint('Erreur parsing ProjectMedia: $e');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<ProjectMedia>()
        .toList();
  }

  static double _fundingFromJson(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('Erreur parsing montant: $value -> $e');
        return 0.0;
      }
    }
    return 0.0;
  }

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('Erreur parsing date: $value -> $e');
        return null;
      }
    }
    return null;
  }

  static List<TagModel> _tagsFromJson(dynamic value) {
    if (value == null) return [];
    if (value is! List) return [];

    return value
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return TagModel.fromJson(item);
            }
            return null;
          } catch (e) {
            debugPrint('Erreur parsing TagModel: $e');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<TagModel>()
        .toList();
  }

  static List<ProjectMediaModel>? _oldMediaFromJson(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;

    return value
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return ProjectMediaModel.fromJson(item);
            }
            return null;
          } catch (e) {
            debugPrint('Erreur parsing ProjectMediaModel: $e');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<ProjectMediaModel>()
        .toList();
  }

  static List<ProjectNeedModel>? _needsFromJson(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;

    return value
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return ProjectNeedModel.fromJson(item);
            }
            return null;
          } catch (e) {
            debugPrint('Erreur parsing ProjectNeedModel: $e');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<ProjectNeedModel>()
        .toList();
  }

  static List<SkillModel>? _skillsFromJson(dynamic value) {
    if (value == null) return null;
    if (value is! List) return null;

    return value
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return SkillModel.fromJson(item);
            }
            return null;
          } catch (e) {
            debugPrint('Erreur parsing SkillModel: $e');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<SkillModel>()
        .toList();
  }

  static CategoryModel _categoryFromJson(dynamic value) {
    if (value == null) {
      return CategoryModel(
        id: 'unknown',
        nameFr: 'Non catégorisé',
        nameEn: 'Uncategorized',
        icon: null,
      );
    }

    if (value is Map<String, dynamic>) {
      try {
        return CategoryModel.fromJson(value);
      } catch (e) {
        debugPrint('Erreur parsing CategoryModel: $e');
        return CategoryModel(
          id: value['id']?.toString() ?? 'unknown',
          nameFr: value['name_fr']?.toString() ?? 'Non catégorisé',
          nameEn: value['name_en']?.toString() ?? 'Uncategorized',
          icon: value['icon']?.toString(),
        );
      }
    }

    return CategoryModel(
      id: 'unknown',
      nameFr: 'Non catégorisé',
      nameEn: 'Uncategorized',
      icon: null,
    );
  }

  static UserModel _createCreatorFromProjectData(Map<String, dynamic> json) {
    final creatorId = json['creator_id']?.toString();
    final creatorName = json['creator_name']?.toString();
    final creatorProfilePicture = json['creator_profile_picture']?.toString();

    debugPrint(
        '[PROJECT] 💡 Reconstruction creator - ID: $creatorId, Nom: $creatorName');

    if (creatorName == null || creatorName.isEmpty) {
      debugPrint(
          '[PROJECT] 🔴 Champ creator_name manquant, utilisation d\'un utilisateur par défaut');
      return UserModel(
        id: creatorId ?? 'unknown',
        email: 'utilisateur@exemple.com',
        firstName: 'Utilisateur',
        lastName: 'Inconnu',
        userType: 'ENTREPRENEUR',
        dateJoined: DateTime.now(),
        isVerified: false,
      );
    }

    // Diviser le nom en prénom et nom si possible
    final nameParts = creatorName.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : creatorName;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    debugPrint('[PROJECT] ✅ Creator reconstruit: $firstName $lastName');

    // Créer un profil avec l'image si disponible
    ProfileModel? profile;
    if (creatorProfilePicture != null && creatorProfilePicture.isNotEmpty) {
      profile = ProfileModel(
        id: 'profile_${creatorId ?? 'unknown'}',
        userId: creatorId ?? 'unknown',
        profilePicture: creatorProfilePicture,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return UserModel(
      id: creatorId ??
          'project_creator_${DateTime.now().millisecondsSinceEpoch}',
      email: 'creator@venturelink.com',
      firstName: firstName,
      lastName: lastName,
      userType: 'ENTREPRENEUR',
      dateJoined: DateTime.now(),
      isVerified: true,
      profile: profile,
    );
  }

  // Getters utilitaires
  ProjectMedia? get primaryMedia {
    if (mediaList.isNotEmpty) {
      final primary = mediaList.where((m) => m.isPrimary).firstOrNull;
      if (primary != null) return primary;
      return mediaList.first;
    }

    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty) {
      return ProjectMedia(
        id: 'legacy',
        url: primaryImageUrl!,
        type: 'IMAGE',
        isPrimary: true,
      );
    }

    return null;
  }

  String? get primaryImageFullUrl {
    final primary = primaryMedia;
    if (primary != null) {
      return primary.fullUrl;
    }
    return null;
  }

  bool get hasImage => primaryMedia != null;

  List<ProjectMedia> get allMedia {
    final List<ProjectMedia> allMediaList = [];

    // Ajouter les nouveaux médias
    allMediaList.addAll(mediaList);

    // Ajouter les anciens médias convertis (si pas déjà présents)
    if (media != null) {
      for (final oldMedia in media!) {
        if (oldMedia.fileUrl != null) {
          // Vérifier qu'on n'a pas déjà ce média
          final alreadyExists =
              allMediaList.any((m) => m.url == oldMedia.fileUrl);
          if (!alreadyExists) {
            allMediaList.add(ProjectMedia(
              id: oldMedia.id,
              url: oldMedia.fileUrl!,
              type: oldMedia.mediaType.toUpperCase(),
              title: oldMedia.caption,
              order: oldMedia.displayOrder,
            ));
          }
        }
      }
    }

    return allMediaList;
  }

  // Getters de compatibilité
  String get description => fullDescription;
  List<String> get images =>
      allMedia.where((m) => m.type == 'IMAGE').map((m) => m.url).toList();
  String get location => [locationCity, locationCountry]
      .where((l) => l != null && l.isNotEmpty)
      .join(', ');
  bool get isVerified => isPremium || isFeatured;
  double get fundingGoal => fundingMax;
  double get fundingRaised =>
      fundingMax * (interestsCount / 100.0).clamp(0.0, 1.0);
  double get progressPercentage {
    if (fundingMax <= 0) return 0.0;
    return ((fundingRaised / fundingMax) * 100).clamp(0.0, 100.0);
  }
  List<String> get interestedInvestors =>
      List.generate(interestsCount, (i) => 'investor_$i');
  int get mediaCount => allMedia.length;

  // Getters pour compatibilité avec l'ancien code
  bool get hasAnyMedia => allMedia.isNotEmpty || (media?.isNotEmpty ?? false);
  bool get hasMultipleMedia => allMedia.length > 1 || (media?.length ?? 0) > 1;

  List<ProjectMedia> get imageMedias =>
      allMedia.where((m) => m.type.toUpperCase() == 'IMAGE').toList();

  List<ProjectMedia> get videoMedias =>
      allMedia.where((m) => m.type.toUpperCase() == 'VIDEO').toList();

  List<ProjectMedia> get documentMedias =>
      allMedia.where((m) => m.type.toUpperCase() == 'DOCUMENT').toList();

  String get mediaTypesDescription {
    final types = <String>[];
    if (imageMedias.isNotEmpty) {
      types.add(
          '${imageMedias.length} image${imageMedias.length > 1 ? 's' : ''}');
    }
    if (videoMedias.isNotEmpty) {
      types.add(
          '${videoMedias.length} vidéo${videoMedias.length > 1 ? 's' : ''}');
    }
    if (documentMedias.isNotEmpty) {
      types.add(
          '${documentMedias.length} document${documentMedias.length > 1 ? 's' : ''}');
    }

    if (types.isEmpty) return 'Aucun média';
    if (types.length == 1) return types.first;
    if (types.length == 2) return '${types[0]} et ${types[1]}';
    return '${types.sublist(0, types.length - 1).join(', ')} et ${types.last}';
  }

  String? get fullImageUrl {
    final primary = primaryMedia;
    if (primary != null && primary.type.toUpperCase() == 'IMAGE') {
      return primary.fullUrl;
    }
    return null;
  }

  /// Crée une copie du projet avec les champs modifiés
  ProjectModel copyWith({
    String? id,
    UserModel? creator,
    String? creatorName,
    String? creatorId,
    String? creatorProfilePicture,
    String? title,
    String? shortDescription,
    String? fullDescription,
    CategoryModel? category,
    String? stage,
    String? status,
    double? fundingMin,
    double? fundingMax,
    String? fundingCurrency,
    String? locationCountry,
    String? locationCity,
    String? businessPlan,
    String? videoUrl,
    bool? isPremium,
    bool? isFeatured,
    bool? isDraft,
    bool? isFavorite,
    int? viewsCount,
    int? interestsCount,
    int? favoritesCount,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TagModel>? tags,
    List<ProjectMedia>? mediaList,
    String? primaryImageUrl,
    List<ProjectMediaModel>? media,
    List<ProjectNeedModel>? needs,
    List<SkillModel>? skillsNeeded,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      creator: creator ?? this.creator,
      creatorName: creatorName ?? this.creatorName,
      creatorId: creatorId ?? this.creatorId,
      creatorProfilePicture:
          creatorProfilePicture ?? this.creatorProfilePicture,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      fullDescription: fullDescription ?? this.fullDescription,
      category: category ?? this.category,
      stage: stage ?? this.stage,
      status: status ?? this.status,
      fundingMin: fundingMin ?? this.fundingMin,
      fundingMax: fundingMax ?? this.fundingMax,
      fundingCurrency: fundingCurrency ?? this.fundingCurrency,
      locationCountry: locationCountry ?? this.locationCountry,
      locationCity: locationCity ?? this.locationCity,
      businessPlan: businessPlan ?? this.businessPlan,
      videoUrl: videoUrl ?? this.videoUrl,
      isPremium: isPremium ?? this.isPremium,
      isFeatured: isFeatured ?? this.isFeatured,
      isDraft: isDraft ?? this.isDraft,
      isFavorite: isFavorite ?? this.isFavorite,
      viewsCount: viewsCount ?? this.viewsCount,
      interestsCount: interestsCount ?? this.interestsCount,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      mediaList: mediaList ?? this.mediaList,
      primaryImageUrl: primaryImageUrl ?? this.primaryImageUrl,
      media: media ?? this.media,
      needs: needs ?? this.needs,
      skillsNeeded: skillsNeeded ?? this.skillsNeeded,
    );
  }
}

class CategoryModel {
  final String id;
  final String nameFr;
  final String nameEn;
  final String? icon;
  final String? descriptionFr;
  final String? descriptionEn;

  CategoryModel({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    this.icon,
    this.descriptionFr,
    this.descriptionEn,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? 'Catégorie',
      nameEn: json['name_en']?.toString() ?? 'Category',
      icon: json['icon']?.toString(),
      descriptionFr: json['description_fr']?.toString(),
      descriptionEn: json['description_en']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_fr': nameFr,
        'name_en': nameEn,
        'icon': icon,
        'description_fr': descriptionFr,
        'description_en': descriptionEn,
      };

  String getName(String locale) => locale == 'fr' ? nameFr : nameEn;

  @override
  String toString() => nameFr;
}

class TagModel {
  final String id;
  final String nameFr;
  final String nameEn;
  final String? color;

  TagModel({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    this.color,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id']?.toString() ?? '',
      nameFr: json['name_fr']?.toString() ?? 'Tag',
      nameEn: json['name_en']?.toString() ?? 'Tag',
      color: json['color']?.toString() ?? '#CCCCCC',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name_fr': nameFr,
        'name_en': nameEn,
        'color': color,
      };

  String getName(String locale) => locale == 'fr' ? nameFr : nameEn;
}

// Classe pour compatibilité avec l'ancien système
class ProjectMediaModel {
  final String id;
  final String projectId;
  final String mediaType;
  final String? fileUrl;
  final String? caption;
  final int displayOrder;
  final DateTime createdAt;

  ProjectMediaModel({
    required this.id,
    required this.projectId,
    required this.mediaType,
    this.fileUrl,
    this.caption,
    this.displayOrder = 0,
    required this.createdAt,
  });

  factory ProjectMediaModel.fromJson(Map<String, dynamic> json) {
    return ProjectMediaModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      mediaType: json['media_type']?.toString() ?? 'IMAGE',
      fileUrl: json['file_url']?.toString(),
      caption: json['caption']?.toString(),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'media_type': mediaType,
        'file_url': fileUrl,
        'caption': caption,
        'display_order': displayOrder,
        'created_at': createdAt.toIso8601String(),
      };
}

class ProjectNeedModel {
  final String id;
  final String projectId;
  final String resourceType;
  final String title;
  final String? description;
  final double? amount;
  final String? amountCurrency;
  final bool isCritical;
  final DateTime? deadline;
  final bool isSatisfied;
  final DateTime createdAt;

  ProjectNeedModel({
    required this.id,
    required this.projectId,
    required this.resourceType,
    required this.title,
    this.description,
    this.amount,
    this.amountCurrency,
    this.isCritical = false,
    this.deadline,
    this.isSatisfied = false,
    required this.createdAt,
  });

  factory ProjectNeedModel.fromJson(Map<String, dynamic> json) {
    return ProjectNeedModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      resourceType: json['resource_type']?.toString() ?? 'FUNDING',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      amount: _parseDouble(json['amount']),
      amountCurrency: json['amount_currency']?.toString(),
      isCritical: json['is_critical'] == true,
      deadline: _parseDateTime(json['deadline']),
      isSatisfied: json['is_satisfied'] == true,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'project_id': projectId,
        'resource_type': resourceType,
        'title': title,
        'description': description,
        'amount': amount,
        'amount_currency': amountCurrency,
        'is_critical': isCritical,
        'deadline': deadline?.toIso8601String(),
        'is_satisfied': isSatisfied,
        'created_at': createdAt.toIso8601String(),
      };

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

class SkillModel {
  final String id;
  final String name;
  final String? description;
  final String priority;
  final int requiredLevel;
  final bool isSatisfied;
  final DateTime createdAt;

  SkillModel({
    required this.id,
    required this.name,
    this.description,
    required this.priority,
    required this.requiredLevel,
    this.isSatisfied = false,
    required this.createdAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      priority: json['priority']?.toString() ?? 'MEDIUM',
      requiredLevel: (json['required_level'] as num?)?.toInt() ?? 1,
      isSatisfied: json['is_satisfied'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'priority': priority,
        'required_level': requiredLevel,
        'is_satisfied': isSatisfied,
        'created_at': createdAt.toIso8601String(),
      };
}
