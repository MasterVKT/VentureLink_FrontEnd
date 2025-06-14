import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer les préférences utilisateur
class UserPreferencesService {
  final SharedPreferences _prefs;

  // Clés pour les préférences
  static const String _currencyKey = 'preferred_currency';
  static const String _languageKey = 'preferred_language';
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'notifications_enabled';

  // Constantes de devise
  static const String defaultCurrency = 'XAF';
  static const List<String> validCurrencies = ['XAF', 'EUR', 'USD'];

  /// Constructeur qui prend une instance de SharedPreferences
  UserPreferencesService(this._prefs);

  /// Obtenir la devise préférée de l'utilisateur
  String getPreferredCurrency() {
    return _prefs.getString(_currencyKey) ?? defaultCurrency;
  }

  /// Définir la devise préférée de l'utilisateur
  Future<bool> setPreferredCurrency(String currencyCode) async {
    if (!validCurrencies.contains(currencyCode)) {
      throw ArgumentError('Code de devise invalide: $currencyCode');
    }
    return await _prefs.setString(_currencyKey, currencyCode);
  }

  /// Obtenir la langue préférée de l'utilisateur
  String getPreferredLanguage() {
    return _prefs.getString(_languageKey) ?? 'fr'; // Français par défaut
  }

  /// Définir la langue préférée de l'utilisateur
  Future<bool> setPreferredLanguage(String languageCode) async {
    // Valider le code de langue (fr ou en pour l'internationalisation)
    if (languageCode != 'fr' && languageCode != 'en') {
      throw ArgumentError('Code de langue invalide: $languageCode');
    }
    return await _prefs.setString(_languageKey, languageCode);
  }

  /// Obtenir le thème préféré de l'utilisateur
  /// Retourne: 0 pour automatique, 1 pour clair, 2 pour sombre
  int getThemeMode() {
    return _prefs.getInt(_themeKey) ?? 0; // Automatique par défaut
  }

  /// Définir le thème préféré de l'utilisateur
  /// mode: 0 pour automatique, 1 pour clair, 2 pour sombre
  Future<bool> setThemeMode(int mode) async {
    if (mode < 0 || mode > 2) {
      throw ArgumentError('Mode de thème invalide: $mode');
    }
    return await _prefs.setInt(_themeKey, mode);
  }

  /// Vérifier si les notifications sont activées
  bool getNotificationsEnabled() {
    return _prefs.getBool(_notificationsKey) ?? true; // Activées par défaut
  }

  /// Activer ou désactiver les notifications
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await _prefs.setBool(_notificationsKey, enabled);
  }

  /// Effacer toutes les préférences utilisateur
  Future<bool> clearPreferences() async {
    return await _prefs.clear();
  }
}
