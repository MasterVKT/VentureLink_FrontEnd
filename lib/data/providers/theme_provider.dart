import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:venturelink/core/theme/app_theme.dart';
//import 'package:venturelink_mvp/constants/design_constants.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedTheme,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.toString());
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  // Thème clair basé sur la charte graphique VentureLink
  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppTheme.primaryBlue,
        onPrimary: AppTheme.white,
        secondary: AppTheme.successGreen,
        onSecondary: AppTheme.white,
        tertiary: AppTheme.premiumGold,
        error: AppTheme.alertRed,
        surface: AppTheme.white,
        onSurface: AppTheme.black,
      ),
      scaffoldBackgroundColor: AppTheme.lightGrey,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        elevation: AppTheme.elevationSmall,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppTheme.white,
        elevation: AppTheme.elevationSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          textStyle: const TextStyle(
            fontSize: AppTheme.bodyText,
            fontWeight: AppTheme.medium,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryBlue,
          side: const BorderSide(color: AppTheme.primaryBlue, width: 1),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingSmall,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          textStyle: const TextStyle(
            fontSize: AppTheme.bodyText,
            fontWeight: AppTheme.medium,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryBlue,
          textStyle: const TextStyle(
            fontSize: AppTheme.bodyText,
            fontWeight: AppTheme.medium,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          borderSide: const BorderSide(color: AppTheme.mediumGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          borderSide: const BorderSide(color: AppTheme.mediumGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          borderSide: const BorderSide(color: AppTheme.primaryBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          borderSide: const BorderSide(color: AppTheme.alertRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium,
          vertical: AppTheme.paddingSmall,
        ),
        labelStyle: const TextStyle(
          color: AppTheme.darkGrey,
          fontSize: AppTheme.smallText,
        ),
        hintStyle: const TextStyle(
          color: AppTheme.darkGrey,
          fontSize: AppTheme.bodyText,
        ),
        errorStyle: const TextStyle(
          color: AppTheme.alertRed,
          fontSize: AppTheme.smallText,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppTheme.titleLarge,
          fontWeight: AppTheme.bold,
          color: AppTheme.black,
        ),
        displayMedium: TextStyle(
          fontSize: AppTheme.titleMedium,
          fontWeight: AppTheme.semiBold,
          color: AppTheme.black,
        ),
        displaySmall: TextStyle(
          fontSize: AppTheme.titleSmall,
          fontWeight: AppTheme.medium,
          color: AppTheme.black,
        ),
        bodyLarge: TextStyle(
          fontSize: AppTheme.bodyText,
          fontWeight: AppTheme.regular,
          color: AppTheme.black,
        ),
        bodyMedium: TextStyle(
          fontSize: AppTheme.bodyText,
          fontWeight: AppTheme.regular,
          color: AppTheme.darkGrey,
        ),
        bodySmall: TextStyle(
          fontSize: AppTheme.smallText,
          fontWeight: AppTheme.regular,
          color: AppTheme.darkGrey,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTheme.white,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.darkGrey,
        type: BottomNavigationBarType.fixed,
        elevation: AppTheme.elevationSmall,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppTheme.black,
        unselectedLabelColor: AppTheme.darkGrey,
        indicatorColor: AppTheme.primaryBlue,
        labelStyle: TextStyle(
          fontSize: AppTheme.bodyText,
          fontWeight: AppTheme.medium,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppTheme.bodyText,
          fontWeight: AppTheme.regular,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTheme.mediumGrey,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Thème sombre (version simplifiée pour le MVP)
  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppTheme.primaryBlue,
        onPrimary: AppTheme.white,
        secondary: AppTheme.successGreen,
        onSecondary: AppTheme.white,
        tertiary: AppTheme.premiumGold,
        error: AppTheme.alertRed,
      ),
      // Autres configurations similaires au thème clair mais adaptées pour le mode sombre
    );
  }
}
