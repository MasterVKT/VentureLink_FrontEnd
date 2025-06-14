import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Service pour gérer les préférences utilisateur
class UserPreferencesService {
  static const String _kLanguageKey = 'language_code';
  static const String _kThemeModeKey = 'theme_mode';
  static const String _kCurrencyKey = 'currency';
  static const String _kOnboardingCompletedKey = 'onboarding_completed';
  static const String _kNotificationsEnabledKey = 'notifications_enabled';
  static const String _kBiometricEnabledKey = 'biometric_enabled';
  static const String _kLastSyncKey = 'last_sync';

  final SharedPreferences _prefs;

  UserPreferencesService(this._prefs);

  // Langue
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_kLanguageKey, languageCode);
  }

  String getLanguage() {
    return _prefs.getString(_kLanguageKey) ?? 'fr';
  }

  // Thème
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs.setString(_kThemeModeKey, themeMode.toString());
  }

  ThemeMode getThemeMode() {
    final String? themeModeString = _prefs.getString(_kThemeModeKey);
    if (themeModeString == 'ThemeMode.dark') {
      return ThemeMode.dark;
    } else if (themeModeString == 'ThemeMode.light') {
      return ThemeMode.light;
    } else {
      return ThemeMode.system;
    }
  }

  // Devise préférée
  Future<void> setCurrency(String currency) async {
    await _prefs.setString(_kCurrencyKey, currency);
  }

  String getCurrency() {
    return _prefs.getString(_kCurrencyKey) ?? 'XAF';
  }

  // Onboarding
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(_kOnboardingCompletedKey, completed);
  }

  bool isOnboardingCompleted() {
    return _prefs.getBool(_kOnboardingCompletedKey) ?? false;
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_kNotificationsEnabledKey, enabled);
  }

  bool areNotificationsEnabled() {
    return _prefs.getBool(_kNotificationsEnabledKey) ?? true;
  }

  // Authentification biométrique
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_kBiometricEnabledKey, enabled);
  }

  bool isBiometricEnabled() {
    return _prefs.getBool(_kBiometricEnabledKey) ?? false;
  }

  // Dernière synchronisation
  Future<void> setLastSync(DateTime dateTime) async {
    await _prefs.setString(_kLastSyncKey, dateTime.toIso8601String());
  }

  DateTime? getLastSync() {
    final String? dateTimeString = _prefs.getString(_kLastSyncKey);
    if (dateTimeString == null) return null;
    return DateTime.parse(dateTimeString);
  }

  // Effacer toutes les préférences
  Future<void> clear() async {
    // Ne pas effacer certaines préférences comme la langue
    final String language = getLanguage();
    final ThemeMode themeMode = getThemeMode();

    await _prefs.clear();

    await setLanguage(language);
    await setThemeMode(themeMode);
  }

  // Récupérer la devise internationalisée
  String getFormattedCurrency(double amount) {
    final String currency = getCurrency();
    switch (currency) {
      case 'EUR':
        return '${amount.toStringAsFixed(2)} €';
      case 'XAF':
        return '${amount.toStringAsFixed(0)} FCFA';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }
}
