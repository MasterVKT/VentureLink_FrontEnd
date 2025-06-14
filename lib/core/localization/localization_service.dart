import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService {
  static const String _languageKey = 'language';
  static const String _defaultLanguage = 'fr';

  final SharedPreferences _prefs;
  final List<Locale> _supportedLocales = [
    const Locale('fr', 'FR'),
    const Locale('en', 'US'),
  ];

  LocalizationService(this._prefs);

  List<Locale> get supportedLocales => _supportedLocales;

  Locale get currentLocale {
    final language = _prefs.getString(_languageKey) ?? _defaultLanguage;
    return Locale(language);
  }

  Future<void> setLocale(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  Future<void> resetLocale() async {
    await _prefs.setString(_languageKey, _defaultLanguage);
  }

  bool isSupported(Locale locale) {
    return _supportedLocales.any(
      (supportedLocale) =>
          supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode,
    );
  }

  Locale? localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale == null) {
      return const Locale('fr', 'FR');
    }

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode &&
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }

    return const Locale('fr', 'FR');
  }
}
