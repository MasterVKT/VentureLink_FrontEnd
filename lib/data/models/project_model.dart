import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:math'; // Ajout de l'import pour la fonction min
import 'package:venturelink/core/config/app_config.dart'; // Import pour la configuration

part 'project_model.g.dart';

/// 🔥 NOUVEAU : Modèle pour les médias du backend (format media_urls)
@JsonSerializable()
class ProjectMedia {
  final String id;
  final String url;
  final String type; // 'IMAGE', 'VIDEO', 'DOCUMENT'
  final String? title;
  final String? description;
  @JsonKey(name: 'is_primary')
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
    try {
      return _$ProjectMediaFromJson(json);
    } catch (e) {
      debugPrint('Erreur parsing ProjectMedia: $e');
      // Créer un objet par défaut en cas d'erreur
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
  }

  Map<String, dynamic> toJson() => _$ProjectMediaToJson(this);

  /// Obtient l'URL complète si elle n'est pas déjà absolue
  String get fullUrl {
    if (url.startsWith('http')) return url;
    return AppConfig.apiBaseUrl + url;
  }
}

@JsonSerializable()
class ProjectModel {
  final String id;
  final UserModel creator;
  @JsonKey(name: 'creator_name')
  final String? creatorName;
  final String title;
  @JsonKey(name: 'short_description')
  final String shortDescription;
  @JsonKey(
    name: 'full_description',
    fromJson: _fullDescriptionFromJson,
  )
  final String fullDescription;
  final CategoryModel category;
  final String stage;
  final String status;
  @JsonKey(name: 'funding_min', fromJson: _fundingFromJson)
  final double fundingMin;
  @JsonKey(name: 'funding_max', fromJson: _fundingFromJson)
  final double fundingMax;
  @JsonKey(name: 'funding_currency')
  final String fundingCurrency;
  @JsonKey(name: 'location_country')
  final String? locationCountry;
  @JsonKey(name: 'location_city')
  final String? locationCity;
  @JsonKey(name: 'business_plan')
  final String? businessPlan;
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @JsonKey(name: 'is_draft')
  final bool isDraft;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'interests_count')
  final int interestsCount;
  @JsonKey(name: 'favorites_count')
  final int favoritesCount;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final List<TagModel>? tags;

  // 🔥 NOUVEAU : Support des médias multiples via media_urls du backend
  @JsonKey(name: 'media_urls', fromJson: _mediaUrlsFromJson)
  final List<ProjectMedia> mediaList;

  // ANCIEN : Support rétrocompatibilité avec le système existant
  final List<ProjectMediaModel>? media;
  @JsonKey(name: 'primary_image_url')
  final String? primaryImageUrl;

  final List<ProjectNeedModel>? needs;
  @JsonKey(name: 'skills_needed')
  final List<SkillModel>? skillsNeeded;

  // Fonction de conversion pour media_urls
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

  // Fonction de conversion sécurisée pour full_description
  static String _fullDescriptionFromJson(dynamic value) {
    if (value is String) return value;
    if (value == null) return '';
    return value.toString();
  }

  // Fonction de conversion sécurisée pour les montants financiers
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

  ProjectModel({
    required this.id,
    required this.creator,
    this.creatorName,
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
    this.viewsCount = 0,
    this.interestsCount = 0,
    this.favoritesCount = 0,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tags,
    this.mediaList = const [], // 🔥 NOUVEAU : Liste des médias du backend
    this.media, // ANCIEN : Compatibilité
    this.needs,
    this.skillsNeeded,
    this.primaryImageUrl, // ANCIEN : Compatibilité
  });

  // 🎯 NOUVELLES MÉTHODES : Unified Media Access

  /// Obtient le média principal (avec priorité aux nouveaux médias)
  ProjectMedia? get primaryMedia {
    // D'abord essayer les nouveaux médias
    if (mediaList.isNotEmpty) {
      final primaryFromList = mediaList.where((m) => m.isPrimary).firstOrNull;
      if (primaryFromList != null) return primaryFromList;
      return mediaList.first;
    }

    // Fallback vers l'ancien système si nécessaire
    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty) {
      return ProjectMedia(
        id: 'primary_legacy',
        url: _buildFullUrl(primaryImageUrl!),
        type: 'IMAGE',
        isPrimary: true,
        order: 0,
      );
    }

    return null;
  }

  /// Obtient toutes les URLs de médias (unifié nouveau + ancien système)
  List<ProjectMedia> get allMedia {
    final allMediaList = <ProjectMedia>[];

    // Priorité aux nouveaux médias
    if (mediaList.isNotEmpty) {
      allMediaList.addAll(mediaList);
    } else {
      // Fallback vers l'ancien système
      // Ajouter l'image principale si disponible
      if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty) {
        allMediaList.add(ProjectMedia(
          id: 'primary_legacy',
          url: _buildFullUrl(primaryImageUrl!),
          type: 'IMAGE',
          isPrimary: true,
          order: 0,
        ));
      }

      // Ajouter les autres médias de l'ancien système
      if (media != null) {
        for (int i = 0; i < media!.length; i++) {
          final mediaItem = media![i];
          if (mediaItem.fileUrl != null && mediaItem.fileUrl!.isNotEmpty) {
            // Éviter les doublons avec l'image principale
            final isDuplicate = primaryImageUrl != null &&
                mediaItem.fileUrl!.contains(primaryImageUrl!.split('/').last);
            if (!isDuplicate) {
              allMediaList.add(ProjectMedia(
                id: mediaItem.id,
                url: _buildFullUrl(mediaItem.fileUrl!),
                type: mediaItem.mediaType,
                isPrimary: false,
                order: mediaItem.displayOrder,
                title: mediaItem.caption,
              ));
            }
          }
        }
      }
    }

    // Trier par ordre d'affichage puis par isPrimary
    allMediaList.sort((a, b) {
      if (a.isPrimary && !b.isPrimary) return -1;
      if (!a.isPrimary && b.isPrimary) return 1;
      return a.order.compareTo(b.order);
    });

    return allMediaList;
  }

  /// Helper pour construire l'URL complète
  String _buildFullUrl(String url) {
    if (url.startsWith('http')) return url;
    return AppConfig.apiBaseUrl + url;
  }

  /// Vérifie si le projet a des médias
  bool get hasAnyMedia => allMedia.isNotEmpty;

  /// Vérifie si le projet a plusieurs médias
  bool get hasMultipleMedia => allMedia.length > 1;

  /// Obtient les médias par type
  List<ProjectMedia> getMediaByType(String mediaType) {
    return allMedia
        .where((media) => media.type.toUpperCase() == mediaType.toUpperCase())
        .toList();
  }

  /// Obtient toutes les images
  List<ProjectMedia> get imageMedias => getMediaByType('IMAGE');

  /// Obtient toutes les vidéos
  List<ProjectMedia> get videoMedias => getMediaByType('VIDEO');

  /// Obtient tous les documents
  List<ProjectMedia> get documentMedias => getMediaByType('DOCUMENT');

  /// Obtient une description des types de médias présents
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

  /// Méthode pour obtenir l'URL complète de l'image
  String? get fullImageUrl {
    final primary = primaryMedia;
    if (primary != null && primary.type == 'IMAGE') {
      return primary.url;
    }

    // Fallback vers l'ancien système
    if (primaryImageUrl != null && primaryImageUrl!.isNotEmpty) {
      return _buildFullUrl(primaryImageUrl!);
    }
    return null;
  }

  /// COMPATIBILITÉ : Ancienne méthode hasImage
  bool get hasImage =>
      primaryMedia?.type == 'IMAGE' ||
      (primaryImageUrl != null && primaryImageUrl!.isNotEmpty);

  // SUPPRIMÉ : Méthodes obsolètes remplacées par le système unifié

  // Méthode fromJson personnalisée avec gestion d'erreurs
  static ProjectModel fromJson(Map<String, dynamic> json) {
    try {
      return _$ProjectModelFromJson(json);
    } catch (e) {
      debugPrint('Erreur de parsing JSON pour ProjectModel: $e');
      debugPrint(
          'JSON problématique: ${json.toString().substring(0, min(500, json.toString().length))}...');

      // En cas d'erreur, corriger les champs problématiques
      final correctedJson = Map<String, dynamic>.from(json);

      // Corrections des champs obligatoires avec valeurs par défaut
      if (json['id'] == null) correctedJson['id'] = '';
      if (json['title'] == null) correctedJson['title'] = 'Sans titre';
      if (json['short_description'] == null) {
        correctedJson['short_description'] = '';
      }
      if (json['full_description'] == null) {
        correctedJson['full_description'] = '';
      }
      if (json['stage'] == null) correctedJson['stage'] = 'IDEA';
      if (json['status'] == null) correctedJson['status'] = 'ACTIVE';
      if (json['funding_currency'] == null) {
        correctedJson['funding_currency'] = 'EUR';
      }

      // Gérer les champs numériques
      if (json['funding_min'] == null) correctedJson['funding_min'] = 0.0;
      if (json['funding_max'] == null) correctedJson['funding_max'] = 0.0;

      // Créer des objets par défaut pour les champs complexes
      if (json['creator'] == null) {
        correctedJson['creator'] = {
          'id': '1',
          'email': 'utilisateur@exemple.com',
          'first_name': json['creator_name'] ?? 'Utilisateur',
          'last_name': 'Inconnu',
          'user_type': 'ENTREPRENEUR',
          'date_joined': DateTime.now().toIso8601String(),
          'is_verified': true,
        };
      }

      if (json['category'] == null) {
        correctedJson['category'] = {
          'id': '',
          'name_fr': 'Non catégorisé',
          'name_en': 'Uncategorized',
          'icon': null,
        };
      }

      // Dates par défaut
      if (json['created_at'] == null) {
        correctedJson['created_at'] = DateTime.now().toIso8601String();
      }
      if (json['updated_at'] == null) {
        correctedJson['updated_at'] = DateTime.now().toIso8601String();
      }

      try {
        return _$ProjectModelFromJson(correctedJson);
      } catch (secondError) {
        debugPrint('Deuxième erreur lors de la conversion JSON: $secondError');
        throw Exception(
            'Impossible de créer le projet à partir des données: $secondError');
      }
    }
  }

  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);

  // Getters de compatibilité pour les widgets existants
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
  List<String> get interestedInvestors =>
      List.generate(interestsCount, (i) => 'investor_$i');

  // Méthode pour compter le nombre total de médias (ancien système)
  int get mediaCount => allMedia.length;
}

@JsonSerializable()
class CategoryModel {
  final String id;
  @JsonKey(name: 'name_fr')
  final String nameFr;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(fromJson: _iconFromJson)
  final String? icon;
  @JsonKey(name: 'description_fr')
  final String? descriptionFr;
  @JsonKey(name: 'description_en')
  final String? descriptionEn;

  CategoryModel({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    this.icon,
    this.descriptionFr,
    this.descriptionEn,
  });

  // Fonction de conversion sécurisée pour l'icône
  static String? _iconFromJson(dynamic value) {
    if (value is String) return value;
    return null; // Retourner null si la valeur n'est pas une chaîne
  }

  // Méthode fromJson sécurisée
  static CategoryModel fromJson(Map<String, dynamic> json) {
    try {
      return _$CategoryModelFromJson(json);
    } catch (e) {
      // Corriger les champs problématiques
      final correctedJson = Map<String, dynamic>.from(json);

      // S'assurer que les champs obligatoires ont des valeurs par défaut
      if (json['id'] == null) correctedJson['id'] = '';
      if (json['name_fr'] == null) correctedJson['name_fr'] = 'Catégorie';
      if (json['name_en'] == null) correctedJson['name_en'] = 'Category';

      // Ne pas mettre de valeur par défaut pour icon puisqu'il est maintenant nullable

      return _$CategoryModelFromJson(correctedJson);
    }
  }

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  String getName(String locale) => locale == 'fr' ? nameFr : nameEn;

  @override
  String toString() => nameFr; // Retourne le nom français par défaut
}

@JsonSerializable()
class TagModel {
  final String id;
  @JsonKey(name: 'name_fr')
  final String nameFr;
  @JsonKey(name: 'name_en')
  final String nameEn;
  @JsonKey(fromJson: _colorFromJson)
  final String? color;

  TagModel({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    this.color,
  });

  // Fonction de conversion sécurisée pour la couleur
  static String? _colorFromJson(dynamic value) {
    if (value is String) return value;
    return '#CCCCCC'; // Retourner une couleur par défaut si null
  }

  // Méthode fromJson sécurisée
  static TagModel fromJson(Map<String, dynamic> json) {
    try {
      return _$TagModelFromJson(json);
    } catch (e) {
      debugPrint('Erreur de parsing JSON pour TagModel: $e');
      // Si c'est une erreur liée au champ 'color' manquant
      if (e.toString().contains("'color'") ||
          e.toString().contains('is not a subtype of type')) {
        // Créer un tag minimal valide avec les champs essentiels
        return TagModel(
          id: json['id'] as String? ?? '',
          nameFr: json['name_fr'] as String? ?? 'Tag',
          nameEn: json['name_en'] as String? ?? 'Tag',
          color: '#CCCCCC', // Couleur par défaut
        );
      }

      // Pour d'autres types d'erreurs, corriger les champs problématiques
      final correctedJson = Map<String, dynamic>.from(json);

      // S'assurer que les champs obligatoires ont des valeurs par défaut
      if (json['id'] == null) correctedJson['id'] = '';
      if (json['name_fr'] == null) correctedJson['name_fr'] = 'Tag';
      if (json['name_en'] == null) correctedJson['name_en'] = 'Tag';
      // Fournir une valeur par défaut pour color si nécessaire
      if (json['color'] == null) correctedJson['color'] = '#CCCCCC';

      try {
        return _$TagModelFromJson(correctedJson);
      } catch (e) {
        // En dernier recours, créer un objet minimal
        debugPrint(
            'Échec de parsing TagModel, utilisation d\'un tag par défaut: $e');
        return TagModel(
          id: json['id'] as String? ?? '',
          nameFr: json['name_fr'] as String? ?? 'Tag',
          nameEn: json['name_en'] as String? ?? 'Tag',
          color: '#CCCCCC',
        );
      }
    }
  }

  Map<String, dynamic> toJson() => _$TagModelToJson(this);

  String getName(String locale) => locale == 'fr' ? nameFr : nameEn;
}

@JsonSerializable()
class ProjectMediaModel {
  final String id;
  @JsonKey(name: 'project_id')
  final String projectId;
  @JsonKey(name: 'media_type')
  final String mediaType;
  @JsonKey(name: 'file_url')
  final String? fileUrl;
  final String? caption;
  @JsonKey(name: 'display_order')
  final int displayOrder;
  @JsonKey(name: 'created_at')
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

  // Méthode fromJson sécurisée
  static ProjectMediaModel fromJson(Map<String, dynamic> json) {
    try {
      return _$ProjectMediaModelFromJson(json);
    } catch (e) {
      // Corriger les champs problématiques
      final correctedJson = Map<String, dynamic>.from(json);

      // S'assurer que les champs obligatoires ont des valeurs par défaut
      if (json['id'] == null) correctedJson['id'] = '';
      if (json['project_id'] == null) correctedJson['project_id'] = '';
      if (json['media_type'] == null) correctedJson['media_type'] = 'IMAGE';
      // file_url peut être null, pas besoin de valeur par défaut
      if (json['display_order'] == null) correctedJson['display_order'] = 0;
      if (json['created_at'] == null) {
        correctedJson['created_at'] = DateTime.now().toIso8601String();
      }

      return _$ProjectMediaModelFromJson(correctedJson);
    }
  }

  Map<String, dynamic> toJson() => _$ProjectMediaModelToJson(this);
}

@JsonSerializable()
class ProjectNeedModel {
  final String id;
  @JsonKey(name: 'project_id')
  final String projectId;
  @JsonKey(name: 'need_type')
  final String needType;
  final String title;
  final String description;
  final double? amount;
  final String? currency;
  @JsonKey(name: 'is_urgent')
  final bool isUrgent;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ProjectNeedModel({
    required this.id,
    required this.projectId,
    required this.needType,
    required this.title,
    required this.description,
    this.amount,
    this.currency,
    this.isUrgent = false,
    required this.createdAt,
  });

  // Méthode fromJson sécurisée
  static ProjectNeedModel fromJson(Map<String, dynamic> json) {
    try {
      return _$ProjectNeedModelFromJson(json);
    } catch (e) {
      // Corriger les champs problématiques
      final correctedJson = Map<String, dynamic>.from(json);

      // S'assurer que les champs obligatoires ont des valeurs par défaut
      if (json['id'] == null) correctedJson['id'] = '';
      if (json['project_id'] == null) correctedJson['project_id'] = '';
      if (json['need_type'] == null) correctedJson['need_type'] = 'FUNDING';
      if (json['title'] == null) correctedJson['title'] = 'Besoin';
      if (json['description'] == null) {
        correctedJson['description'] = 'Description du besoin';
      }
      if (json['is_urgent'] == null) correctedJson['is_urgent'] = false;
      if (json['created_at'] == null) {
        correctedJson['created_at'] = DateTime.now().toIso8601String();
      }

      return _$ProjectNeedModelFromJson(correctedJson);
    }
  }

  Map<String, dynamic> toJson() => _$ProjectNeedModelToJson(this);
}

@JsonSerializable()
class SkillModel {
  final String id;
  @JsonKey(name: 'name_fr')
  final String nameFr;
  @JsonKey(name: 'name_en')
  final String nameEn;
  final String category;
  final String? description;

  SkillModel({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.category,
    this.description,
  });

  // Méthode fromJson sécurisée
  static SkillModel fromJson(Map<String, dynamic> json) {
    try {
      return _$SkillModelFromJson(json);
    } catch (e) {
      // Corriger les champs problématiques
      final correctedJson = Map<String, dynamic>.from(json);

      // S'assurer que les champs obligatoires ont des valeurs par défaut
      if (json['id'] == null) correctedJson['id'] = '';
      if (json['name_fr'] == null) correctedJson['name_fr'] = 'Compétence';
      if (json['name_en'] == null) correctedJson['name_en'] = 'Skill';
      if (json['category'] == null) correctedJson['category'] = 'OTHER';

      return _$SkillModelFromJson(correctedJson);
    }
  }

  Map<String, dynamic> toJson() => _$SkillModelToJson(this);

  String getName(String locale) => locale == 'fr' ? nameFr : nameEn;
}
