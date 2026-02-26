class ConfigService {
  // API
  static const String apiBaseUrl = 'http://10.0.2.2:8001/api/v1';
  static const int apiTimeout = 15000;

  // Debug
  static const bool isDebugMode = true;

  // Firebase
  static const String firebaseApiKey =
      'AIzaSyA5Ox6r37DWCZCKxmbziEKO6llVDZ4g_j0';
  static const String firebaseAppId =
      '1:149697014585:android:0b01bf7eae8dca160716e8';
  static const String firebaseMessagingSenderId = '149697014585';
  static const String firebaseProjectId = 'venturelink-5b045';
  static const String firebaseStorageBucket =
      'venturelink-5b045.firebasestorage.app';

  // App
  static const String appName = 'VentureLink';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // Cache
  static const Duration cacheMaxAge = Duration(days: 7);
  static const int cacheMaxSize = 50 * 1024 * 1024; // 50 MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Validation
  static const String passwordRegex = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$';
  static const String emailRegex = r'^[^@]+@[^@]+\.[^@]+$';
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;

  // Theme
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double defaultSpacing = 8.0;

  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Messages d'erreur
  static const Map<String, String> errorMessages = {
    'network':
        'Erreur de connexion. Veuillez vérifier votre connexion internet.',
    'server': 'Erreur serveur. Veuillez réessayer plus tard.',
    'validation': 'Veuillez vérifier les informations saisies.',
    'auth': 'Erreur d\'authentification. Veuillez vous reconnecter.',
    'unknown': 'Une erreur inattendue est survenue.',
  };

  // Messages de succès
  static const Map<String, String> successMessages = {
    'login': 'Connexion réussie.',
    'register': 'Inscription réussie.',
    'logout': 'Déconnexion réussie.',
    'update': 'Mise à jour réussie.',
    'delete': 'Suppression réussie.',
  };

  // Feature flags
  static const Map<String, bool> featureFlags = {
    'pushNotifications': true,
    'biometricAuth': true,
    'darkMode': true,
    'offlineMode': true,
    'analytics': true,
    'crashlytics': true,
  };
}
