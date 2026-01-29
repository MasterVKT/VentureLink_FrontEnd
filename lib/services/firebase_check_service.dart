import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:venturelink/firebase_options.dart';

class FirebaseCheckService {
  static bool _isFirebaseInitialized = false;
  static bool _hasCheckedFirebase = false;

  static Future<bool> ensureFirebaseInitialized() async {
    if (_isFirebaseInitialized) {
      return true;
    }

    if (_hasCheckedFirebase) {
      return false;
    }

    _hasCheckedFirebase = true;

    try {
      debugPrint(
          'FirebaseCheckService: Vérification de l\'initialisation de Firebase...');

      // Vérifier si Firebase est déjà initialisé
      try {
        final apps = Firebase.apps;
        if (apps.isNotEmpty) {
          debugPrint(
              'FirebaseCheckService: Firebase est déjà initialisé avec ${apps.length} applications.');
          _isFirebaseInitialized = true;
          return true;
        }
      } catch (e) {
        debugPrint(
            'FirebaseCheckService: Erreur lors de la vérification des applications Firebase: $e');
      }

      // Tenter d'initialiser Firebase
      debugPrint(
          'FirebaseCheckService: Tentative d\'initialisation de Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      debugPrint('FirebaseCheckService: Firebase initialisé avec succès.');
      _isFirebaseInitialized = true;
      return true;
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        debugPrint(
            'FirebaseCheckService: Firebase est déjà initialisé (détecté comme duplicate-app).');
        _isFirebaseInitialized = true;
        return true;
      }

      debugPrint(
          'FirebaseCheckService: Erreur lors de l\'initialisation de Firebase: $e');
      return false;
    }
  }

  static Future<bool> validateAuthentication() async {
    try {
      if (!await ensureFirebaseInitialized()) {
        return false;
      }

      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;

      debugPrint(
          'FirebaseCheckService: État d\'authentification actuel - User: ${currentUser?.email ?? 'Non connecté'}');

      return true;
    } catch (e) {
      debugPrint(
          'FirebaseCheckService: Erreur lors de la validation de l\'authentification: $e');
      return false;
    }
  }
}
