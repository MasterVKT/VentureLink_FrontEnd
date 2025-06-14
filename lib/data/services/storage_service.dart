import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:venturelink/domain/services/i_storage_service.dart';

class StorageService implements IStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userTypeKey = 'user_type';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _themeKey = 'theme';
  static const String _localeKey = 'locale';
  static const String _languageKey = 'language';
  static const String _userKey = 'user';

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  StorageService(this._prefs, this._secureStorage);

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  // Tokens (stockés en sécurité)
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> deleteRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  // Informations utilisateur
  Future<String?> getUserId() async {
    return _prefs.getString(_userIdKey);
  }

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  Future<void> deleteUserId() async {
    await _prefs.remove(_userIdKey);
  }

  Future<String?> getUserType() async {
    return _prefs.getString(_userTypeKey);
  }

  Future<void> saveUserType(String userType) async {
    await _prefs.setString(_userTypeKey, userType);
  }

  // FCM Token
  Future<String?> getFCMToken() async {
    return _prefs.getString(_fcmTokenKey);
  }

  Future<void> saveFCMToken(String token) async {
    await _prefs.setString(_fcmTokenKey, token);
  }

  // Préférences
  Future<ThemeMode> getThemeMode() async {
    final themeStr = _prefs.getString(_themeKey);
    if (themeStr == null) return ThemeMode.system;

    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode themeMode) async {
    String themeStr;

    switch (themeMode) {
      case ThemeMode.light:
        themeStr = 'light';
        break;
      case ThemeMode.dark:
        themeStr = 'dark';
        break;
      case ThemeMode.system:
        themeStr = 'system';
        break;
    }

    await _prefs.setString(_themeKey, themeStr);
  }

  Future<Locale?> getLocale() async {
    final localeStr = _prefs.getString(_localeKey);
    if (localeStr == null) return null;

    final parts = localeStr.split('_');
    if (parts.length == 1) {
      return Locale(parts[0]);
    } else if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }

    return null;
  }

  Future<void> saveLocale(Locale locale) async {
    final localeStr = locale.countryCode == null
        ? locale.languageCode
        : '${locale.languageCode}_${locale.countryCode}';

    await _prefs.setString(_localeKey, localeStr);
  }

  // Nettoyage complet (déconnexion)
  Future<void> clearAllData() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }

  // Méthodes spécifiques pour l'authentification
  @override
  Future<void> saveAuthToken(String token) async {
    await setString(_tokenKey, token);
  }

  @override
  Future<String?> getAuthToken() async {
    return getString(_tokenKey);
  }

  @override
  Future<void> clearAuthTokens() async {
    await remove(_tokenKey);
    await remove(_refreshTokenKey);
  }

  // Méthodes spécifiques pour les préférences utilisateur
  Future<void> setLanguage(String language) async {
    await setString(_languageKey, language);
  }

  Future<String?> getLanguage() async {
    return await getString(_languageKey);
  }

  // Thème
  Future<void> setTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  String? getTheme() {
    return _prefs.getString(_themeKey);
  }

  // Utilisateur
  Future<void> setUser(Map<String, dynamic> user) async {
    await _prefs.setString(_userKey, jsonEncode(user));
  }

  Map<String, dynamic>? getUser() {
    final userStr = _prefs.getString(_userKey);
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }

  // Nettoyage
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
