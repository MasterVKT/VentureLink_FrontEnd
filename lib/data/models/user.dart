class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? location;
  final String language;
  final bool isVerified;
  final bool isPremium;
  final String? fcmToken;
  final String preferredCurrency;
  final String userType;
  final Profile? profile;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.location,
    this.language = 'fr',
    this.isVerified = false,
    this.isPremium = false,
    this.fcmToken,
    this.preferredCurrency = 'EUR',
    this.userType = 'BOTH',
    this.profile,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? location,
    String? language,
    bool? isVerified,
    bool? isPremium,
    String? fcmToken,
    String? preferredCurrency,
    String? userType,
    Profile? profile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      language: language ?? this.language,
      isVerified: isVerified ?? this.isVerified,
      isPremium: isPremium ?? this.isPremium,
      fcmToken: fcmToken ?? this.fcmToken,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      userType: userType ?? this.userType,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'location': location,
      'language': language,
      'is_verified': isVerified,
      'is_premium': isPremium,
      'fcm_token': fcmToken,
      'preferred_currency': preferredCurrency,
      'user_type': userType,
      'profile': profile?.toJson(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      location: json['location'] as String?,
      language: json['language'] as String? ?? 'fr',
      isVerified: json['is_verified'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      fcmToken: json['fcm_token'] as String?,
      preferredCurrency: json['preferred_currency'] as String? ?? 'EUR',
      userType: json['user_type'] as String? ?? 'BOTH',
      profile:
          json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode;
  }
}

class Profile {
  final String? id;
  final String? profilePicture;
  final String? coverPicture;
  final String? bioShort;
  final String? title;
  final String? website;
  final String? socialLinkedin;
  final String? socialTwitter;
  final String? socialFacebook;
  final int viewsCount;
  final double avgRating;
  final int ratingCount;
  final String verificationLevel;

  const Profile({
    this.id,
    this.profilePicture,
    this.coverPicture,
    this.bioShort,
    this.title,
    this.website,
    this.socialLinkedin,
    this.socialTwitter,
    this.socialFacebook,
    this.viewsCount = 0,
    this.avgRating = 0.0,
    this.ratingCount = 0,
    this.verificationLevel = 'BASIC',
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id']?.toString(),
      profilePicture: json['profile_picture'] as String?,
      coverPicture: json['cover_picture'] as String?,
      bioShort: json['bio_short'] as String?,
      title: json['title'] as String?,
      website: json['website'] as String?,
      socialLinkedin: json['social_linkedin'] as String?,
      socialTwitter: json['social_twitter'] as String?,
      socialFacebook: json['social_facebook'] as String?,
      viewsCount: json['views_count'] as int? ?? 0,
      avgRating: (json['avg_rating'] as num? ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] as int? ?? 0,
      verificationLevel: json['verification_level'] as String? ?? 'BASIC',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_picture': profilePicture,
      'cover_picture': coverPicture,
      'bio_short': bioShort,
      'title': title,
      'website': website,
      'social_linkedin': socialLinkedin,
      'social_twitter': socialTwitter,
      'social_facebook': socialFacebook,
      'views_count': viewsCount,
      'avg_rating': avgRating,
      'rating_count': ratingCount,
      'verification_level': verificationLevel,
    };
  }
}
