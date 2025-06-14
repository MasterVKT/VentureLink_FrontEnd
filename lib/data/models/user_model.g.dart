// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: _idFromJson(json['id']),
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      userType: json['user_type'] as String,
      phoneNumber: json['phone_number'] as String?,
      location: json['location'] as String?,
      language: json['language'] as String? ?? 'fr',
      preferredCurrency: json['preferred_currency'] as String? ?? 'EUR',
      isVerified: json['is_verified'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      isStaff: json['is_staff'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      fcmToken: json['fcm_token'] as String?,
      dateJoined: DateTime.parse(json['date_joined'] as String),
      lastLogin: json['last_login'] == null
          ? null
          : DateTime.parse(json['last_login'] as String),
      profile: json['profile'] == null
          ? null
          : ProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'user_type': instance.userType,
      'phone_number': instance.phoneNumber,
      'location': instance.location,
      'language': instance.language,
      'preferred_currency': instance.preferredCurrency,
      'is_verified': instance.isVerified,
      'is_premium': instance.isPremium,
      'is_staff': instance.isStaff,
      'is_active': instance.isActive,
      'fcm_token': instance.fcmToken,
      'date_joined': instance.dateJoined.toIso8601String(),
      'last_login': instance.lastLogin?.toIso8601String(),
      'profile': instance.profile,
    };

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
      id: _idFromJson(json['id']),
      userId: _idFromJson(json['user_id']),
      profilePicture: json['profile_picture'] as String?,
      coverPicture: json['cover_picture'] as String?,
      bioShort: json['bio_short'] as String?,
      title: json['title'] as String?,
      website: json['website'] as String?,
      socialLinkedin: json['social_linkedin'] as String?,
      socialTwitter: json['social_twitter'] as String?,
      socialFacebook: json['social_facebook'] as String?,
      viewsCount: (json['views_count'] as num?)?.toInt() ?? 0,
      avgRating: (json['avg_rating'] as num?)?.toDouble(),
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      verificationLevel: json['verification_level'] as String? ?? 'BASIC',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'profile_picture': instance.profilePicture,
      'cover_picture': instance.coverPicture,
      'bio_short': instance.bioShort,
      'title': instance.title,
      'website': instance.website,
      'social_linkedin': instance.socialLinkedin,
      'social_twitter': instance.socialTwitter,
      'social_facebook': instance.socialFacebook,
      'views_count': instance.viewsCount,
      'avg_rating': instance.avgRating,
      'rating_count': instance.ratingCount,
      'verification_level': instance.verificationLevel,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
