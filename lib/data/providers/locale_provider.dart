import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language_code');

    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  void setLocale(String languageCode) async {
    if (!['fr', 'en'].contains(languageCode)) return;
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }

  void toggleLocale() async {
    // Basculer entre le français et l'anglais
    final String newLanguageCode = _locale.languageCode == 'fr' ? 'en' : 'fr';
    setLocale(newLanguageCode);
  }

  bool isCurrentLanguage(String languageCode) {
    return _locale.languageCode == languageCode;
  }
}
