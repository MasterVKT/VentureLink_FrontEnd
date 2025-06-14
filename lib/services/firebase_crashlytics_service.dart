import 'dart:async';
import 'dart:isolate';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Service qui gère le monitoring des crashes via Firebase Crashlytics
class FirebaseCrashlyticsService {
  static final FirebaseCrashlyticsService _instance =
      FirebaseCrashlyticsService._internal();
  factory FirebaseCrashlyticsService() => _instance;

  FirebaseCrashlyticsService._internal();

  /// Initialise le service Crashlytics
  Future<void> initialize() async {
    try {
      // Passer les erreurs Flutter à Crashlytics
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        // Forward to original handler
        debugPrint(
            'FlutterError capturé par Crashlytics: ${errorDetails.exception}');
      };

      // Passer les erreurs asynchrones à Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        debugPrint('PlatformDispatcher error capturé par Crashlytics: $error');
        return true;
      };

      // Configurer Crashlytics pour les erreurs dans d'autres isolates
      Isolate.current.addErrorListener(RawReceivePort((pair) async {
        final List<dynamic> errorAndStacktrace = pair;
        await FirebaseCrashlytics.instance.recordError(
          errorAndStacktrace.first,
          errorAndStacktrace.last,
          fatal: true,
        );
        debugPrint(
            'Isolate error capturé par Crashlytics: ${errorAndStacktrace.first}');
      }).sendPort);

      // Activer/désactiver la collection de crashes en fonction de l'environnement
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      debugPrint('✅ Firebase Crashlytics initialisé avec succès');
    } catch (e) {
      debugPrint(
          '❌ Erreur lors de l\'initialisation de Firebase Crashlytics: $e');
    }
  }

  /// Enregistre un utilisateur dans Crashlytics pour faciliter le débogage
  void setUserIdentifier(String userId) {
    FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Ajoute des informations personnalisées pour faciliter le débogage
  void setCustomKey(String key, dynamic value) {
    FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Enregistre un message dans les logs Crashlytics
  void log(String message) {
    FirebaseCrashlytics.instance.log(message);
  }

  /// Enregistre une erreur non fatale
  Future<void> recordError(dynamic exception, StackTrace? stack,
      {bool fatal = false}) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      fatal: fatal,
    );
  }

  /// Force un crash pour tester Crashlytics (à utiliser uniquement en dev)
  void crash() {
    FirebaseCrashlytics.instance.crash();
  }
}
