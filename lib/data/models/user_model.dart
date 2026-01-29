import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

// Fonction de conversion pour l'id
String _idFromJson(dynamic value) {
  if (value is String) return value;
  if (value is int) return value.toString();
  if (value == null) {
    return ''; // Retourner une valeur par défaut en cas de null
  }
  throw ArgumentError('Invalid id type: ${value.runtimeType}');
}

@JsonSerializable()
class UserModel {
  @JsonKey(fromJson: _idFromJson)
  final String id;
  final String email;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'user_type')
  final String userType;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? location;
  final String language;
  @JsonKey(name: 'preferred_currency')
  final String preferredCurrency;
  @JsonKey(name: 'is_verified')
  final bool isVerified;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @JsonKey(name: 'is_staff')
  final bool isStaff;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'fcm_token')
  final String? fcmToken;
  @JsonKey(name: 'date_joined')
  final DateTime dateJoined;
  @JsonKey(name: 'last_login')
  final DateTime? lastLogin;
  final ProfileModel? profile;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.phoneNumber,
    this.location,
    this.language = 'fr',
    this.preferredCurrency = 'EUR',
    this.isVerified = false,
    this.isPremium = false,
    this.isStaff = false,
    this.isActive = true,
    this.fcmToken,
    required this.dateJoined,
    this.lastLogin,
    this.profile,
  });

  // Ajout d'une méthode fromJson personnalisée pour gérer les cas où le profil est null
  static UserModel fromJson(Map<String, dynamic> json) {
    try {
      // Gérer le cas où l'API renvoie full_name au lieu de first_name et last_name
      final correctedJson = Map<String, dynamic>.from(json);

      if (json.containsKey('full_name') && !json.containsKey('first_name')) {
        final fullName = json['full_name'] as String? ?? '';
        final nameParts = fullName.split(' ');

        correctedJson['first_name'] =
            nameParts.isNotEmpty ? nameParts.first : '';
        correctedJson['last_name'] =
            nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
      }

      // Fournir des valeurs par défaut pour les champs obligatoires manquants
      correctedJson['first_name'] ??= '';
      correctedJson['last_name'] ??= '';
      correctedJson['email'] ??= '';
      correctedJson['user_type'] ??= 'ENTREPRENEUR';

      // S'assurer que date_joined existe
      if (!correctedJson.containsKey('date_joined') ||
          correctedJson['date_joined'] == null) {
        correctedJson['date_joined'] = DateTime.now().toIso8601String();
      }

      // Gérer le cas où profile est null ou non valide
      if (json['profile'] != null && json['profile'] is! Map<String, dynamic>) {
        correctedJson['profile'] = null;
      }

      return _$UserModelFromJson(correctedJson);
    } catch (e) {
      // En cas d'erreur, créer un UserModel avec des valeurs par défaut
      return UserModel(
        id: json['id']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        firstName: json['first_name']?.toString() ??
            (json['full_name']?.toString().split(' ').first ?? ''),
        lastName: json['last_name']?.toString() ??
            (json['full_name']?.toString().split(' ').skip(1).join(' ') ?? ''),
        userType: json['user_type']?.toString() ?? 'ENTREPRENEUR',
        dateJoined: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? userType,
    String? phoneNumber,
    String? location,
    String? language,
    String? preferredCurrency,
    bool? isVerified,
    bool? isPremium,
    bool? isStaff,
    bool? isActive,
    String? fcmToken,
    DateTime? dateJoined,
    DateTime? lastLogin,
    ProfileModel? profile,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      language: language ?? this.language,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      isStaff: isStaff ?? this.isStaff,
      isActive: isActive ?? this.isActive,
      fcmToken: fcmToken ?? this.fcmToken,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      profile: profile ?? this.profile,
    );
  }
}

@JsonSerializable()
class ProfileModel {
  @JsonKey(fromJson: _idFromJson)
  final String id;
  @JsonKey(name: 'user_id', fromJson: _idFromJson)
  final String userId;
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;
  @JsonKey(name: 'cover_picture')
  final String? coverPicture;
  @JsonKey(name: 'bio_short')
  final String? bioShort;
  final String? title;
  final String? website;
  @JsonKey(name: 'social_linkedin')
  final String? socialLinkedin;
  @JsonKey(name: 'social_twitter')
  final String? socialTwitter;
  @JsonKey(name: 'social_facebook')
  final String? socialFacebook;
  @JsonKey(name: 'views_count')
  final int viewsCount;
  @JsonKey(name: 'avg_rating')
  final double? avgRating;
  @JsonKey(name: 'rating_count')
  final int ratingCount;
  @JsonKey(name: 'verification_level')
  final String verificationLevel;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.userId,
    this.profilePicture,
    this.coverPicture,
    this.bioShort,
    this.title,
    this.website,
    this.socialLinkedin,
    this.socialTwitter,
    this.socialFacebook,
    this.viewsCount = 0,
    this.avgRating,
    this.ratingCount = 0,
    this.verificationLevel = 'BASIC',
    required this.createdAt,
    required this.updatedAt,
  });

  // Ajout d'une méthode fromJson personnalisée pour gérer les cas où des champs sont null
  static ProfileModel fromJson(Map<String, dynamic> json) {
    try {
      return _$ProfileModelFromJson(json);
    } catch (e) {
      // Corriger le JSON si nécessaire
      final correctedJson = Map<String, dynamic>.from(json);

      // S'assurer que les dates sont présentes
      if (json['created_at'] == null) {
        correctedJson['created_at'] = DateTime.now().toIso8601String();
      }
      if (json['updated_at'] == null) {
        correctedJson['updated_at'] = DateTime.now().toIso8601String();
      }

      // S'assurer que les champs numériques ont des valeurs par défaut
      if (json['views_count'] == null) {
        correctedJson['views_count'] = 0;
      }
      if (json['rating_count'] == null) {
        correctedJson['rating_count'] = 0;
      }

      return _$ProfileModelFromJson(correctedJson);
    }
  }

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
