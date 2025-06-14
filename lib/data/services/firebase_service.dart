import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:venturelink/core/config/app_config.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static FirebaseAnalytics? _sharedAnalytics;
  static FirebaseMessaging? _sharedMessaging;

  static FirebaseAnalytics get analytics => _sharedAnalytics!;
  static FirebaseMessaging get messaging => _sharedMessaging!;

  // Initialisation de Firebase
  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: AppConfig.firebaseApiKey,
          appId: AppConfig.firebaseAppId,
          messagingSenderId: AppConfig.firebaseMessagingSenderId,
          projectId: AppConfig.firebaseProjectId,
          storageBucket: AppConfig.firebaseStorageBucket,
        ),
      );

      _sharedAnalytics = FirebaseAnalytics.instance;
      _sharedMessaging = FirebaseMessaging.instance;

      // Configuration des notifications push
      await _configureMessaging();
    } catch (e) {
      // Gérer l'erreur d'initialisation de Firebase
      print('Erreur lors de l\'initialisation de Firebase: $e');
    }
  }

  static Future<void> _configureMessaging() async {
    // Demander la permission pour les notifications
    await _sharedMessaging?.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtenir le token FCM
    final token = await _sharedMessaging?.getToken();
    print('FCM Token: $token');

    // Configurer les gestionnaires de messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message reçu en premier plan: ${message.notification?.title}');
      // TODO: Afficher une notification locale
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          'Message ouvert depuis la notification: ${message.notification?.title}');
      // TODO: Naviguer vers l'écran approprié
    });
  }

  // Auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // Messaging
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  // Firestore
  Future<void> setDocument(
      String collection, String document, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(document).set(data);
  }

  Future<void> updateDocument(
      String collection, String document, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(document).update(data);
  }

  Future<void> deleteDocument(String collection, String document) async {
    await _firestore.collection(collection).doc(document).delete();
  }

  Future<DocumentSnapshot> getDocument(
      String collection, String document) async {
    return await _firestore.collection(collection).doc(document).get();
  }

  Stream<QuerySnapshot> getCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Analytics
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _sharedAnalytics?.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'événement: $e');
    }
  }

  static Future<void> setUserProperties({
    required String userId,
    String? userRole,
    bool? isPremium,
  }) async {
    try {
      await _sharedAnalytics?.setUserId(id: userId);
      if (userRole != null) {
        await _sharedAnalytics?.setUserProperty(
            name: 'user_role', value: userRole);
      }
      if (isPremium != null) {
        await _sharedAnalytics?.setUserProperty(
          name: 'is_premium',
          value: isPremium.toString(),
        );
      }
    } catch (e) {
      print('Erreur lors de la définition des propriétés utilisateur: $e');
    }
  }

  // Méthodes d'authentification
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserProfile(
      {String? displayName, String? photoURL}) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Gestion des erreurs Firebase
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('Aucun utilisateur trouvé avec cet email.');
      case 'wrong-password':
        return AuthException('Mot de passe incorrect.');
      case 'email-already-in-use':
        return AuthException('Cet email est déjà utilisé.');
      case 'weak-password':
        return AuthException('Le mot de passe est trop faible.');
      case 'invalid-email':
        return AuthException('L\'adresse email est invalide.');
      case 'operation-not-allowed':
        return AuthException('Cette opération n\'est pas autorisée.');
      case 'user-disabled':
        return AuthException('Ce compte a été désactivé.');
      default:
        return AuthException('Une erreur d\'authentification est survenue.');
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
