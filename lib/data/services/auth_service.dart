import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:venturelink/data/models/user.dart' as app;
import 'package:venturelink/services/firebase_check_service.dart';
import 'package:flutter/services.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    clientId: kIsWeb ? 'web-client-id' : null,
  );

  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  app.User? get currentUser => _auth.currentUser != null
      ? _createUserFromFirebaseUser(_auth.currentUser!)
      : null;

  // Stream des changements d'état d'authentification
  Stream<app.User?> get authStateChanges => _auth.authStateChanges().map(
        (user) => user != null ? _createUserFromFirebaseUser(user) : null,
      );

  // Vérifier que Firebase est initialisé
  Future<void> _ensureFirebaseInitialized() async {
    final isInitialized =
        await FirebaseCheckService.ensureFirebaseInitialized();
    if (!isInitialized) {
      throw Exception(
          "Impossible d'initialiser Firebase. Veuillez redémarrer l'application.");
    }
  }

  // Connexion avec email et mot de passe
  Future<app.User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      print("Tentative de connexion avec: $email");

      // S'assurer que Firebase est initialisé
      await _ensureFirebaseInitialized();

      // Tenter de se connecter
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("Connexion réussie pour: ${userCredential.user?.email}");

      if (userCredential.user == null) {
        print("Erreur: Utilisateur null après connexion");
        throw Exception("Échec de récupération des données utilisateur");
      }

      // Attendre un court instant pour s'assurer que Firebase a bien enregistré l'authentification
      await Future.delayed(const Duration(milliseconds: 300));

      // Vérifier que l'utilisateur est bien connecté
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print(
            "Erreur: L'utilisateur n'est pas connecté après authentification");
        throw Exception(
            "L'authentification a réussi mais l'utilisateur n'est pas connecté");
      }

      print(
          "Vérification finale de l'authentification réussie: ${currentUser.email}");

      return _createUserFromFirebaseUser(userCredential.user!);
    } catch (e) {
      print("Erreur de connexion détaillée: $e");
      if (e is firebase_auth.FirebaseAuthException) {
        print("Code d'erreur Firebase: ${e.code}");
        print("Message d'erreur Firebase: ${e.message}");
      }
      throw _handleAuthException(e);
    }
  }

  // Inscription avec email et mot de passe
  Future<app.User> createUserWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      // S'assurer que Firebase est initialisé
      await _ensureFirebaseInitialized();

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Mettre à jour le profil utilisateur
      await userCredential.user?.updateDisplayName('$firstName $lastName');

      return _createUserFromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Vérifier la configuration Google Sign-In et la disponibilité des services Google Play
  Future<bool> _isGoogleSignInConfigured() async {
    try {
      // Vérifier si Google Play Services est disponible
      final isAvailable = await _checkGooglePlayServicesAvailability();
      if (!isAvailable) {
        debugPrint("Google Play Services n'est pas disponible ou à jour");
        return false;
      }

      // Vérifier si l'authentification silencieuse fonctionne
      await _googleSignIn.signInSilently();
      return true;
    } catch (e) {
      debugPrint("Configuration Google Sign-In non disponible: $e");
      return false;
    }
  }

  // Vérifier la disponibilité et la version de Google Play Services
  Future<bool> _checkGooglePlayServicesAvailability() async {
    try {
      // Vérifier si nous pouvons obtenir les services Google sans erreur
      final googleSignIn = GoogleSignIn(
        // Désactiver la vérification de clientId en mode web
        clientId: kIsWeb ? 'web-client-id' : null,
      );
      await googleSignIn.signOut(); // Nettoyer d'abord tout état existant

      // Tenter simplement d'accéder aux scopes sans se connecter
      // Cela va générer une erreur si Google Play Services n'est pas disponible
      googleSignIn.scopes;
      return true;
    } catch (e) {
      debugPrint("Erreur lors de la vérification de Google Play Services: $e");
      return false;
    }
  }

  // Méthode auxiliaire pour la connexion Google avec gestion robuste des erreurs
  Future<GoogleSignInAccount?> _performGoogleSignIn(
      {bool isRetry = false}) async {
    try {
      // Créer une nouvelle instance si c'est une tentative de récupération
      final googleSignIn = isRetry
          ? GoogleSignIn(
              scopes: ['email', 'profile'],
              // Désactiver la vérification de clientId en mode web
              clientId: kIsWeb ? 'web-client-id' : null,
            )
          : _googleSignIn;

      // Nettoyer l'état si nécessaire
      if (isRetry) {
        try {
          await googleSignIn.signOut();
        } catch (_) {}
      }

      return await googleSignIn.signIn();
    } catch (e) {
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>') ||
          e.toString().contains('is not a subtype of type')) {
        print("Erreur de cast Pigeon dans _performGoogleSignIn: $e");
        if (!isRetry) {
          print("Tentative de récupération...");
          await Future.delayed(const Duration(milliseconds: 500));
          return await _performGoogleSignIn(isRetry: true);
        }
      }
      rethrow;
    }
  }

  // Connexion avec Google
  Future<app.User> signInWithGoogle() async {
    try {
      debugPrint("Début de la connexion Google...");

      // S'assurer que Firebase est initialisé
      await _ensureFirebaseInitialized();

      // Vérifier si Google Play Services est disponible et à jour
      final isGooglePlayAvailable =
          await _checkGooglePlayServicesAvailability();
      if (!isGooglePlayAvailable) {
        throw Exception(
            'Google Play Services n\'est pas disponible ou n\'est pas à jour.\n\n'
            'Veuillez :\n'
            '• Vérifier que Google Play Services est installé et à jour\n'
            '• Vérifier votre connexion Internet\n'
            '• Redémarrer l\'appareil et réessayer');
      }

      // Ajouter un délai court pour s'assurer que tout état précédent est effacé
      await Future.delayed(const Duration(milliseconds: 300));

      // Tentative avec nouvelle instance pour éviter les problèmes d'état
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // Désactiver la vérification de clientId en mode web
        clientId: kIsWeb ? 'web-client-id' : null,
      );

      // Déconnexion préalable pour éviter les problèmes d'état
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      // Tentative de connexion
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("Connexion Google annulée par l'utilisateur");
        throw Exception('La connexion avec Google a été annulée.');
      }

      debugPrint("Utilisateur Google obtenu: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint("Tokens Google obtenus");

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("Credential Firebase créé");

      final userCredential = await _auth.signInWithCredential(credential);
      final firebase_auth.User? firebaseUser = userCredential.user;

      debugPrint("Authentification Firebase réussie");

      if (firebaseUser == null) {
        throw Exception("Utilisateur Firebase null après authentification");
      }

      try {
        // Obtenir le token ID pour l'authentification backend
        final String? idToken = await firebaseUser.getIdToken();

        if (idToken == null) {
          throw Exception("Impossible d'obtenir le token Firebase");
        }

        // Appel au backend avec meilleure gestion d'erreur
        final response = await _apiService.post(
          '/auth/firebase/',
          data: {'firebase_token': idToken},
        );

        // Stocker les tokens
        debugPrint(
            '[Auth] Réponse du backend pour Firebase auth: ${response.data}');

        // Vérifier si la réponse contient les tokens ou une structure différente
        String accessToken;
        String refreshToken;

        if (response.data is Map<String, dynamic>) {
          if (response.data.containsKey('access') &&
              response.data.containsKey('refresh')) {
            // Format direct de tokens
            accessToken = response.data['access'];
            refreshToken = response.data['refresh'];
          } else if (response.data.containsKey('tokens')) {
            // Format avec objet tokens
            var tokens = response.data['tokens'];
            accessToken = tokens['access'];
            refreshToken = tokens['refresh'];
          } else {
            throw Exception("Format de réponse d'authentification inattendu");
          }

          await _secureStorage.write(key: 'access_token', value: accessToken);
          await _secureStorage.write(key: 'refresh_token', value: refreshToken);

          debugPrint('[Auth] Tokens stockés avec succès');
        } else {
          throw Exception(
              "Réponse de type inattendu: ${response.data.runtimeType}");
        }

        // Construire l'utilisateur depuis la réponse API
        // Le profil est automatiquement créé par le backend
        return _createUserFromFirebaseUser(firebaseUser);
      } catch (e) {
        // En cas d'erreur avec le backend, utiliser les données Firebase
        debugPrint('Erreur lors de la synchronisation avec le backend: $e');

        // Si l'erreur contient "Token issuer invalide", c'est un problème de configuration
        if (e.toString().contains('Token Firebase invalide')) {
          debugPrint('Problème de validation du token Firebase côté backend');
        }

        // Créer un utilisateur minimal avec les données Firebase
        final String firstName =
            firebaseUser.displayName?.split(' ').first ?? '';
        final String lastName = firebaseUser.displayName != null &&
                firebaseUser.displayName!.split(' ').length > 1
            ? firebaseUser.displayName!.split(' ').skip(1).join(' ')
            : '';

        return app.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          firstName: firstName,
          lastName: lastName,
          isVerified: firebaseUser.emailVerified,
        );
      }
    } on PlatformException catch (e) {
      debugPrint("Erreur PlatformException lors de la connexion Google: $e");

      // Gestion spécifique de l'erreur network_error (ApiException: 7)
      if (e.code == 'network_error' ||
          e.message?.contains('ApiException: 7') == true) {
        // Nettoyer l'état
        try {
          await _googleSignIn.signOut();
          await _auth.signOut();
        } catch (_) {}

        throw Exception('Erreur de connexion Google (ApiException: 7).\n\n'
            'Causes possibles:\n'
            '• Problème de connexion Internet\n'
            '• Google Play Services n\'est pas à jour\n'
            '• Problème de configuration SHA-1 dans Firebase\n'
            '• L\'émulateur n\'a pas Google Play Services\n\n'
            'Solutions:\n'
            '• Vérifiez votre connexion Internet\n'
            '• Mettez à jour Google Play Services\n'
            '• Utilisez un appareil physique au lieu d\'un émulateur\n'
            '• Redémarrez l\'application et réessayez');
      }

      throw Exception(
          'Erreur technique Google Sign-In: ${e.code} - ${e.message}');
    } catch (e) {
      print("Erreur lors de la connexion Google: $e");

      // Gestion spécifique des erreurs de cast Pigeon
      if (e.toString().contains('PigeonUserDetails') ||
          e.toString().contains('List<Object?>') ||
          e.toString().contains('is not a subtype of type')) {
        print("Erreur de cast Pigeon détectée au niveau principal");

        // Nettoyer l'état
        try {
          await _googleSignIn.signOut();
          await _auth.signOut();
        } catch (_) {}

        throw Exception(
            'Erreur technique de connexion Google. Cette erreur est généralement temporaire.\n\n'
            'Solutions à essayer:\n'
            '• Redémarrer l\'application\n'
            '• Utiliser un appareil physique\n'
            '• Vérifier la configuration Google Sign-In\n'
            '• Mettre à jour Google Play Services');
      }
      throw _handleAuthException(e);
    }
  }

  // Connexion avec Apple
  Future<app.User> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential =
          firebase_auth.OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);
      return _createUserFromFirebaseUser(userCredential.user!);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Réinitialisation du mot de passe
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Mise à jour du mot de passe
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Mise à jour du profil utilisateur
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _auth.currentUser?.updateDisplayName(displayName);
      await _auth.currentUser?.updatePhotoURL(photoURL);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Obtenir le token d'accès pour les appels API et WebSocket
  Future<String?> getAccessToken() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      // Récupérer le token ID Firebase
      final token = await currentUser.getIdToken();
      return token;
    } catch (e) {
      print('Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  // Rafraîchir le token si nécessaire
  Future<String?> refreshToken() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      // Forcer le rafraîchissement du token
      final token = await currentUser.getIdToken(true);
      return token;
    } catch (e) {
      print('Erreur lors du rafraîchissement du token: $e');
      return null;
    }
  }

  // Créer un objet User à partir d'un User Firebase
  app.User _createUserFromFirebaseUser(firebase_auth.User firebaseUser) {
    // Séparer le nom complet en prénom et nom
    String firstName = '';
    String lastName = '';

    if (firebaseUser.displayName != null) {
      final nameParts = firebaseUser.displayName!.split(' ');
      firstName = nameParts.first;
      if (nameParts.length > 1) {
        lastName = nameParts.skip(1).join(' ');
      }
    }

    return app.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      firstName: firstName,
      lastName: lastName,
      isVerified: firebaseUser.emailVerified,
      // Valeurs par défaut pour les autres champs
      language: 'fr',
      preferredCurrency: 'EUR',
      userType: 'BOTH',
    );
  }

  String _handleAuthException(dynamic e) {
    print("Traitement de l'exception d'authentification: $e");

    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Aucun utilisateur trouvé avec cet email.';
        case 'wrong-password':
          return 'Mot de passe incorrect.';
        case 'invalid-credential':
          return 'Identifiants de connexion invalides.';
        case 'user-disabled':
          return 'Ce compte a été désactivé.';
        case 'email-already-in-use':
          return 'Cet email est déjà utilisé.';
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'invalid-email':
          return 'L\'adresse email est invalide.';
        case 'operation-not-allowed':
          return 'Cette opération n\'est pas autorisée.';
        case 'network-request-failed':
          return 'Problème de connexion réseau. Vérifiez votre connexion Internet.';
        case 'too-many-requests':
          return 'Trop de tentatives. Veuillez réessayer plus tard.';
        case 'account-exists-with-different-credential':
          return 'Un compte existe déjà avec cette adresse email mais avec une méthode de connexion différente.';
        default:
          return 'Erreur d\'authentification: ${e.code} - ${e.message ?? ""}';
      }
    } else if (e is Exception) {
      return e.toString().replaceAll('Exception: ', '');
    }
    return 'Une erreur inattendue est survenue lors de l\'authentification.';
  }
}
