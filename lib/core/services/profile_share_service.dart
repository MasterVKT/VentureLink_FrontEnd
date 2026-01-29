import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:venturelink/data/models/user_model.dart';

/// Service pour le partage de profils utilisateur
class ProfileShareService {
  /// Partage le profil d'un utilisateur
  static Future<void> shareProfile(
    BuildContext context,
    UserModel user, {
    Rect? sharePositionOrigin,
  }) async {
    try {
      final shareText = _generateShareText(user);

      await Share.share(
        shareText,
        subject: 'Profil VentureLink - ${user.fullName}',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors du partage: ${e.toString()}');
      }
    }
  }

  /// Partage le profil avec des informations supplémentaires
  static Future<void> shareProfileWithDetails(
    BuildContext context,
    UserModel user, {
    String? customMessage,
    List<String>? projectTitles,
    Rect? sharePositionOrigin,
  }) async {
    try {
      final shareText = _generateDetailedShareText(
        user,
        customMessage: customMessage,
        projectTitles: projectTitles,
      );

      await Share.share(
        shareText,
        subject: 'Découvrez le profil de ${user.fullName} sur VentureLink',
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors du partage: ${e.toString()}');
      }
    }
  }

  /// Copie le lien du profil dans le presse-papier
  static Future<void> copyProfileLink(
    BuildContext context,
    UserModel user,
  ) async {
    try {
      final profileUrl = _generateProfileUrl(user.id);

      await Share.share(profileUrl);

      if (context.mounted) {
        _showSuccessSnackBar(context, 'Lien du profil copié !');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Erreur lors de la copie: ${e.toString()}');
      }
    }
  }

  /// Partage le profil via une application spécifique
  static Future<void> shareProfileVia(
    BuildContext context,
    UserModel user,
    String app, // 'linkedin', 'twitter', 'facebook', 'email', 'sms'
  ) async {
    try {
      final profileUrl = _generateProfileUrl(user.id);
      final shareText = _generateShareTextForPlatform(user, app);

      switch (app.toLowerCase()) {
        case 'linkedin':
          await _shareToLinkedIn(shareText, profileUrl);
          break;
        case 'twitter':
          await _shareToTwitter(shareText, profileUrl);
          break;
        case 'facebook':
          await _shareToFacebook(shareText, profileUrl);
          break;
        case 'email':
          await _shareViaEmail(user, shareText, profileUrl);
          break;
        case 'sms':
          await _shareViaSMS(shareText, profileUrl);
          break;
        default:
          await Share.share('$shareText\n\n$profileUrl');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(
            context, 'Erreur lors du partage via $app: ${e.toString()}');
      }
    }
  }

  /// Génère l'URL du profil
  static String _generateProfileUrl(String userId) {
    // TODO: Remplacer par l'URL réelle de votre application
    return 'https://app.venturelink.com/profile/$userId';
  }

  /// Génère le texte de partage de base
  static String _generateShareText(UserModel user) {
    final StringBuffer text = StringBuffer();

    text.writeln(
        '🚀 Découvrez le profil de ${user.fullName} sur VentureLink !');

    if (user.profile?.title != null) {
      text.writeln('📋 ${user.profile!.title}');
    }

    if (user.profile?.bioShort != null) {
      text.writeln('\n💡 ${user.profile!.bioShort}');
    }

    // Ajouter le type d'utilisateur
    final userType = _getUserTypeDisplayName(user.userType);
    text.writeln('\n👤 $userType');

    if (user.isVerified) {
      text.writeln('✅ Profil vérifié');
    }

    text.writeln('\n#VentureLink #Entrepreneuriat #Innovation');

    return text.toString();
  }

  /// Génère un texte de partage détaillé
  static String _generateDetailedShareText(
    UserModel user, {
    String? customMessage,
    List<String>? projectTitles,
  }) {
    final StringBuffer text = StringBuffer();

    if (customMessage != null) {
      text.writeln(customMessage);
      text.writeln();
    }

    text.writeln('🌟 Profil ${user.fullName}');

    if (user.profile?.title != null) {
      text.writeln('🎯 ${user.profile!.title}');
    }

    if (user.profile?.bioShort != null) {
      text.writeln('📝 ${user.profile!.bioShort}');
    }

    if (projectTitles != null && projectTitles.isNotEmpty) {
      text.writeln('\n📊 Projets:');
      for (final project in projectTitles.take(3)) {
        text.writeln('• $project');
      }
      if (projectTitles.length > 3) {
        text.writeln('• et ${projectTitles.length - 3} autres...');
      }
    }

    if (user.profile?.avgRating != null && user.profile!.avgRating! > 0) {
      text.writeln(
          '\n⭐ Note: ${user.profile!.avgRating!.toStringAsFixed(1)}/5.0');
    }

    text.writeln('\n🔗 Rejoignez la communauté VentureLink');
    text.writeln('#Startup #Investissement #Innovation');

    return text.toString();
  }

  /// Génère un texte adapté à une plateforme spécifique
  static String _generateShareTextForPlatform(UserModel user, String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return 'Je vous recommande de découvrir le profil de ${user.fullName} sur VentureLink. '
            '${user.profile?.title ?? 'Entrepreneur'} passionné(e) d\'innovation !';

      case 'twitter':
        return '🚀 Découvrez ${user.fullName} sur @VentureLink ! '
            '${user.profile?.title ?? 'Entrepreneur'} #Startup #Innovation';

      case 'facebook':
        return 'Je partage avec vous le profil de ${user.fullName}, '
            '${user.profile?.title ?? 'entrepreneur'} sur VentureLink. '
            'Une personne inspirante dans le monde de l\'innovation !';

      default:
        return _generateShareText(user);
    }
  }

  /// Partage vers LinkedIn
  static Future<void> _shareToLinkedIn(String text, String url) async {
    final linkedInUrl =
        'https://www.linkedin.com/sharing/share-offsite/?url=${Uri.encodeComponent(url)}';
    await Share.share('$text\n\n$linkedInUrl');
  }

  /// Partage vers Twitter
  static Future<void> _shareToTwitter(String text, String url) async {
    final twitterUrl =
        'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}&url=${Uri.encodeComponent(url)}';
    await Share.share(twitterUrl);
  }

  /// Partage vers Facebook
  static Future<void> _shareToFacebook(String text, String url) async {
    final facebookUrl =
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(url)}';
    await Share.share('$text\n\n$facebookUrl');
  }

  /// Partage via email
  static Future<void> _shareViaEmail(
      UserModel user, String text, String url) async {
    await Share.share(
      '$text\n\nCliquez ici pour voir le profil: $url',
      subject: 'Profil VentureLink - ${user.fullName}',
    );
  }

  /// Partage via SMS
  static Future<void> _shareViaSMS(String text, String url) async {
    final smsText = '$text\n\nLien: $url';
    await Share.share(smsText);
  }

  /// Affiche un SnackBar de succès
  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Affiche un SnackBar d'erreur
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Retourne le nom d'affichage du type d'utilisateur
  static String _getUserTypeDisplayName(String userType) {
    switch (userType) {
      case 'ENTREPRENEUR':
        return 'Entrepreneur';
      case 'INVESTOR':
        return 'Investisseur';
      case 'MENTOR':
        return 'Mentor';
      case 'BOTH':
        return 'Entrepreneur & Investisseur';
      default:
        return userType;
    }
  }
}
