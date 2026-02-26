import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Couleurs secondaires
  static const Color lightGrey = Color(0xFFF0F2F5);
  static const Color mediumGrey = Color(0xFFE4E6EB);
  static const Color darkGrey = Color(0xFF65676B);

  // Couleurs d'accentuation
  static const Color successGreen = Color(0xFF42B72A);
  static const Color alertRed = Color(0xFFFF3B30);
  static const Color notificationYellow = Color(0xFFFFBA00);

  // Couleurs Premium
  static const Color premiumGold = Color(0xFFFFD700);
  static const Color premiumOrange = Color(0xFFFFA500);
  static const Color premiumDarkBlue = Color(0xFF0A2463);

  // Alias pour compatibilité avec les autres fichiers
  static const Color primaryColor = primaryBlue;
  static const Color secondaryColor = successGreen;
  static const Color accentColor = premiumOrange;
  static const Color successColor = successGreen;
  static const Color warningColor = notificationYellow;
  static const Color errorColor = alertRed;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, premiumDarkBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [premiumGold, premiumOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;
  static const double defaultSmallIconSize = 20.0;

  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Elevation
  static const double elevationSmall = 1.0;
  static const double elevationMedium = 2.0;
  static const double elevationLarge = 4.0;

  // Typography
  static const double titleLarge = 24.0;
  static const double titleMedium = 20.0;
  static const double titleSmall = 16.0;
  static const double bodyText = 14.0;
  static const double smallText = 12.0;

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Typographie
  static const String fontFamily = 'Poppins';

  // Thème clair
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: successGreen,
      error: alertRed,
      surface: white,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension.light,
    ],
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: black),
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: black,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: black,
      ),
      displaySmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: black,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: black,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: darkGrey,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: darkGrey,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: mediumGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: mediumGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: alertRed),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
    ),
    cardTheme: CardThemeData(
      color: white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    ),
  );

  // Thème sombre
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: successGreen,
      error: alertRed,
      surface: darkGrey,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppThemeExtension.dark,
    ],
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: white),
      titleTextStyle: TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: white,
      ),
      displayMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: white,
      ),
      displaySmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: white,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: white,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.normal,
        color: mediumGrey,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: mediumGrey,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 2,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: mediumGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: mediumGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        borderSide: const BorderSide(color: alertRed),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkGrey,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultBorderRadius),
      ),
    ),
  );
}

/// Extension de thème personnalisée pour VentureLink
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color backgroundColor;
  final Color textPrimaryColor;
  final Color textSecondaryColor;

  const AppThemeExtension({
    required this.backgroundColor,
    required this.textPrimaryColor,
    required this.textSecondaryColor,
  });

  @override
  AppThemeExtension copyWith({
    Color? backgroundColor,
    Color? textPrimaryColor,
    Color? textSecondaryColor,
  }) {
    return AppThemeExtension(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textPrimaryColor: textPrimaryColor ?? this.textPrimaryColor,
      textSecondaryColor: textSecondaryColor ?? this.textSecondaryColor,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      textPrimaryColor:
          Color.lerp(textPrimaryColor, other.textPrimaryColor, t)!,
      textSecondaryColor:
          Color.lerp(textSecondaryColor, other.textSecondaryColor, t)!,
    );
  }

  /// Extension pour le thème clair
  static const AppThemeExtension light = AppThemeExtension(
    backgroundColor: AppTheme.white,
    textPrimaryColor: AppTheme.black,
    textSecondaryColor: AppTheme.darkGrey,
  );

  /// Extension pour le thème sombre
  static const AppThemeExtension dark = AppThemeExtension(
    backgroundColor: AppTheme.black,
    textPrimaryColor: AppTheme.white,
    textSecondaryColor: AppTheme.mediumGrey,
  );
}

/// Extension pour faciliter l'accès aux propriétés de AppThemeExtension depuis BuildContext
extension ThemeExtensions on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}

/// Extension pour faciliter l'accès direct aux propriétés de AppThemeExtension depuis Theme
extension AppThemeHelpers on AppTheme {
  // Ces méthodes statiques permettent d'accéder aux valeurs de l'extension actuelle
  // en fonction du mode (clair/sombre)
  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()!.backgroundColor;

  static Color textPrimaryColor(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()!.textPrimaryColor;

  static Color textSecondaryColor(BuildContext context) =>
      Theme.of(context).extension<AppThemeExtension>()!.textSecondaryColor;
}
