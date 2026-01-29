import 'package:flutter/foundation.dart';

/// Configuration pour les tests et le développement
class TestConfig {
  // Identifiants de test pour le développement
  static const String testEmail = 'admin@venturelink.com';
  static const String testPassword = 'admin123';

  // Activer l'authentification automatique en mode debug uniquement
  static bool get autoLoginEnabled => kDebugMode;

  // URL de base pour les tests
  static const String testApiBaseUrl = 'http://10.0.2.2:8000';

  // Token de test (sera mis à jour dynamiquement)
  static String? testAccessToken;
  static String? testRefreshToken;

  /// Vérifie si nous sommes en mode test
  static bool get isTestMode => kDebugMode;

  /// Données de test pour l'authentification automatique
  static Map<String, String> get testCredentials => {
        'email': testEmail,
        'password': testPassword,
      };

  static const bool enableTestMode = true;
  static const bool enableDebugLogs = true;
  static const bool enableAutoLogin = true;

  // Endpoints de test pour vérification
  static const Map<String, String> testEndpoints = {
    'projects': '/projects/projects/',
    'featured_projects': '/projects/projects/?is_featured=true',
    'publications': '/content/publications/',
    'featured_publications': '/content/publications/?is_featured=true',
  };

  // Headers requis pour forcer JSON au lieu d'HTML
  static const Map<String, String> forceJsonHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest', // Force Django à retourner JSON
    'X-DJDT-disable': '1', // Désactive Django Debug Toolbar
    'X-DJDT-hide': '1', // Cache Django Debug Toolbar
    'Cache-Control': 'no-cache', // Évite les réponses en cache
    'Pragma': 'no-cache',
    'Accept-Encoding': 'gzip, deflate',
    'User-Agent': 'VentureLink-Mobile-App-JSON/1.0',
  };

  // Configuration pour éviter le debug toolbar Django
  static const Map<String, String> avoidDjangoDebug = {
    'HTTP_ACCEPT': 'application/json',
    'HTTP_X_REQUESTED_WITH': 'XMLHttpRequest',
  };
}
