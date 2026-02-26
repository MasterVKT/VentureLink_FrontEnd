import 'package:flutter/foundation.dart';
import 'dart:io'
    if (dart.library.html) 'package:venturelink/core/utils/platform_web.dart';

class AppConfig {
  // Configuration API
  static const String baseUrl = 'http:// 192.168.26.1:8000/api/v1';
  static String get _devApiBaseUrl {
    // Vérifier si nous sommes sur le web
    if (kIsWeb) {
      return 'http:// 192.168.26.1:8000';
    }

    // Pour l'émulateur Android, utiliser 10.0.2.2 au lieu de localhost
    try {
      if (Platform.isAndroid) {
        return 'http:// 192.168.26.1:8000';
      }
    } catch (e) {
      // Ignorer les erreurs de plateforme non supportée
    }
    return 'http:// 192.168.26.1:8000';
  }

  static const String _prodApiBaseUrl = 'https://api.venturelink.com';

  static String get apiBaseUrl => kDebugMode ? _devApiBaseUrl : _prodApiBaseUrl;
  static const String apiVersion = 'v1';
  static String get apiPrefix => '/api/$apiVersion';
  static String get fullApiUrl => '$apiBaseUrl$apiPrefix';

  // Configuration WebSocket
  static String get _devWebsocketBaseUrl {
    // Vérifier si nous sommes sur le web
    if (kIsWeb) {
      return 'ws:// 192.168.26.1:8000';
    }

    try {
      if (Platform.isAndroid) {
        return 'ws:// 192.168.26.1:8000';
      }
    } catch (e) {
      // Ignorer les erreurs de plateforme non supportée
    }
    return 'ws:// 192.168.26.1:8000';
  }

  static const String _prodWebsocketBaseUrl = 'wss://api.venturelink.com';

  static String get websocketBaseUrl =>
      kDebugMode ? _devWebsocketBaseUrl : _prodWebsocketBaseUrl;

  // Configuration Firebase
  static const String firebaseProjectId = 'venturelink-app';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API Configuration
  static const int apiTimeout = 15000; // 15 seconds

  // Firebase Configuration
  static const String firebaseApiKey = 'YOUR_API_KEY';
  static const String firebaseAppId = 'YOUR_APP_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';
  static const String firebaseStorageBucket = 'YOUR_STORAGE_BUCKET';

  // App Configuration
  static const String appName = 'VentureLink';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Cache Configuration
  static const int cacheMaxAge = 7; // days
  static const int cacheMaxSize = 50 * 1024 * 1024; // 50 MB

  // Pagination Configuration
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation Configuration
  static const String passwordRegex = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // Theme Configuration
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;

  // Animation Configuration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Error Messages
  static const Map<String, String> errorMessages = {
    'network': 'Erreur de connexion réseau',
    'server': 'Erreur du serveur',
    'validation': 'Données invalides',
    'auth': 'Erreur d\'authentification',
    'unknown': 'Une erreur inconnue est survenue',
  };

  // Success Messages
  static const Map<String, String> successMessages = {
    'login': 'Connexion réussie',
    'register': 'Inscription réussie',
    'logout': 'Déconnexion réussie',
    'update': 'Mise à jour réussie',
    'delete': 'Suppression réussie',
  };

  // Feature Flags
  static const Map<String, bool> featureFlags = {
    'pushNotifications': true,
    'biometricAuth': true,
    'darkMode': true,
    'offlineMode': true,
    'analytics': true,
    'crashlytics': true,
  };
}
