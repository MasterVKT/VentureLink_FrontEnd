Prompt pour l'implémentation des modifications d'authentification Firebase dans le frontend Flutter VentureLink
Contexte et problématique
Le backend Django de VentureLink a été modifié pour corriger un problème d'authentification Firebase. La solution a consisté à :
Adapter la vérification des tokens Firebase pour fonctionner même sans SDK Firebase Admin correctement configuré
Corriger la création des utilisateurs en supprimant les champs inexistants (firebase_uid, profile_picture, email_verified)
Éviter la création manuelle de profils utilisateurs, car un signal Django le fait déjà automatiquement
Le frontend Flutter doit maintenant être modifié pour s'aligner sur ces changements.
Modifications requises côté Flutter
1. Service d'authentification
Modifiez le fichier lib/services/auth_service.dart pour :
// Mettre à jour la méthode signInWithGoogle pour mieux gérer les erreurs côté backend
Future<User?> signInWithGoogle() async {
  try {
    // Conserver le processus d'authentification Firebase existant
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    // Authentification Firebase
    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User? firebaseUser = authResult.user;
    
    if (firebaseUser == null) return null;
    
    try {
      // Obtenir le token ID pour l'authentification backend
      final String idToken = await firebaseUser.getIdToken();
      
      // Appel au backend avec gestion d'erreur améliorée
      final response = await _apiService.post(
        '/api/v1/auth/firebase/',
        data: {'firebase_token': idToken},
      );
      
      // Mettre à jour le token d'accès et les informations utilisateur
      _secureStorage.write(key: 'access_token', value: response['access']);
      _secureStorage.write(key: 'refresh_token', value: response['refresh']);
      
      // Construire l'utilisateur à partir de la réponse
      final currentUser = await getUserFromToken();
      _userSubject.add(currentUser);
      
      return currentUser;
    } catch (e) {
      // En cas d'erreur avec le backend, utiliser uniquement les données Firebase
      logger.e('Erreur lors de la synchronisation avec le backend: $e');
      
      // Logique de secours pour créer un utilisateur minimal avec les données Firebase
      final User user = User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        firstName: firebaseUser.displayName?.split(' ').first ?? '',
        lastName: firebaseUser.displayName?.split(' ').length > 1 
            ? firebaseUser.displayName?.split(' ').skip(1).join(' ') 
            : '',
        isVerified: firebaseUser.emailVerified,
      );
      
      _userSubject.add(user);
      return user;
    }
  } catch (e) {
    logger.e('Erreur d\'authentification Google: $e');
    return null;
  }
}


2. Modèle d'utilisateur
Modifiez le fichier lib/models/user_model.dart pour s'assurer qu'il correspond au modèle backend :

class User {
  final String? id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? location;
  final String language;
  final bool isVerified;
  final bool isPremium;
  final String? fcmToken;
  final String preferredCurrency;
  final String userType;
  final Profile? profile;
  
  User({
    this.id,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber,
    this.location,
    this.language = 'fr',
    this.isVerified = false,
    this.isPremium = false,
    this.fcmToken,
    this.preferredCurrency = 'EUR',
    this.userType = 'BOTH',
    this.profile,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phoneNumber: json['phone_number'],
      location: json['location'],
      language: json['language'] ?? 'fr',
      isVerified: json['is_verified'] ?? false,
      isPremium: json['is_premium'] ?? false,
      fcmToken: json['fcm_token'],
      preferredCurrency: json['preferred_currency'] ?? 'EUR',
      userType: json['user_type'] ?? 'BOTH',
      profile: json['profile'] != null ? Profile.fromJson(json['profile']) : null,
    );
  }
  
  // Ajoutez la méthode toJson() si nécessaire
  // Assurez-vous de ne pas inclure de champs qui n'existent pas dans le backend
}

class Profile {
  final String? id;
  final String? profilePicture;
  final String? coverPicture;
  final String? bioShort;
  final String? title;
  final String? website;
  final String? socialLinkedin;
  final String? socialTwitter;
  final String? socialFacebook;
  final int viewsCount;
  final double avgRating;
  final int ratingCount;
  final String verificationLevel;
  
  Profile({
    this.id,
    this.profilePicture,
    this.coverPicture,
    this.bioShort,
    this.title,
    this.website,
    this.socialLinkedin,
    this.socialTwitter,
    this.socialFacebook,
    this.viewsCount = 0,
    this.avgRating = 0.0,
    this.ratingCount = 0,
    this.verificationLevel = 'BASIC',
  });
  
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      profilePicture: json['profile_picture'],
      coverPicture: json['cover_picture'],
      bioShort: json['bio_short'],
      title: json['title'],
      website: json['website'],
      socialLinkedin: json['social_linkedin'],
      socialTwitter: json['social_twitter'],
      socialFacebook: json['social_facebook'],
      viewsCount: json['views_count'] ?? 0,
      avgRating: (json['avg_rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? 0,
      verificationLevel: json['verification_level'] ?? 'BASIC',
    );
  }
  
  // Ajoutez la méthode toJson() si nécessaire
}

3. Intercepteur Dio pour une meilleure gestion des erreurs
Modifiez votre fichier de configuration API (probablement lib/services/api_service.dart) :

class ApiService {
  // ... code existant
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log de la requête pour le débogage
          logger.d('[API] *** Request ***');
          logger.d('[API] uri: ${options.uri}');
          // ... autres logs existants
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log de la réponse pour le débogage
          logger.d('[API] *** Response ***');
          logger.d('[API] statusCode: ${response.statusCode}');
          // ... autres logs existants
          
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          logger.e('[API] *** DioException ***:');
          logger.e('[API] uri: ${e.requestOptions.uri}');
          
          // Gestion spécifique pour l'authentification Firebase
          if (e.requestOptions.path.contains('/api/v1/auth/firebase/')) {
            if (e.response?.statusCode == 500) {
              // Analyser le message d'erreur pour diagnostiquer le problème
              final errorMessage = e.response?.data['error'] as String? ?? '';
              
              logger.e('[API] Erreur d\'authentification Firebase: $errorMessage');
              
              // Si c'est une erreur de contrainte unique, on pourrait tenter une approche différente
              if (errorMessage.contains('UNIQUE constraint failed')) {
                // Dans ce cas, on pourrait utiliser les données Firebase locales temporairement
                // ou implémenter une logique de nouvelle tentative
                logger.w('[API] Détection d\'une contrainte d\'unicité, utilisation des données locales');
              }
            }
          }
          
          // Continuer avec la gestion d'erreur normale
          return handler.next(e);
        },
      ),
    );
  }
}

4. Vérification de l'état d'authentification
Modifiez la méthode de vérification de l'état d'authentification dans lib/providers/auth_provider.dart :

Future<bool> checkAuthStatus() async {
  logger.i('Vérification de l\'état d\'authentification...');
  
  try {
    // Vérifier d'abord l'utilisateur Firebase
    final firebaseUser = _auth.currentUser;
    
    if (firebaseUser != null) {
      logger.i('Utilisateur Firebase trouvé, tentative de synchronisation avec l\'API...');
      
      try {
        // Tenter de synchroniser avec le backend
        final String idToken = await firebaseUser.getIdToken();
        final response = await _apiService.post(
          '/api/v1/auth/firebase/',
          data: {'firebase_token': idToken},
        );
        
        // Mise à jour des tokens et de l'utilisateur
        await _secureStorage.write(key: 'access_token', value: response['access']);
        await _secureStorage.write(key: 'refresh_token', value: response['refresh']);
        
        final user = await getUserFromToken();
        _userSubject.add(user);
        _isAuthenticated = true;
        
        logger.i('État d\'authentification: Connecté');
        return true;
      } catch (e) {
        logger.e('Erreur lors de la synchronisation avec l\'API: $e');
        
        // En cas d'échec, essayer d'utiliser un token existant
        final existingToken = await _secureStorage.read(key: 'access_token');
        if (existingToken != null) {
          try {
            final user = await getUserFromToken();
            _userSubject.add(user);
            _isAuthenticated = true;
            logger.i('État d\'authentification: Connecté (token existant)');
            return true;
          } catch (tokenError) {
            logger.e('Erreur lors de la vérification du token existant: $tokenError');
          }
        }
        
        // Si aucune solution ne fonctionne, considérer l'utilisateur comme non authentifié
        _isAuthenticated = false;
        logger.i('État d\'authentification: Non connecté');
        return false;
      }
    } else {
      // Vérifier s'il y a un token JWT existant
      final existingToken = await _secureStorage.read(key: 'access_token');
      if (existingToken != null) {
        try {
          final user = await getUserFromToken();
          _userSubject.add(user);
          _isAuthenticated = true;
          logger.i('État d\'authentification: Connecté (token sans Firebase)');
          return true;
        } catch (e) {
          logger.e('Erreur lors de la vérification du token: $e');
        }
      }
      
      _isAuthenticated = false;
      logger.i('État d\'authentification: Non connecté');
      return false;
    }
  } catch (e) {
    logger.e('Erreur lors de la vérification de l\'état d\'authentification: $e');
    _isAuthenticated = false;
    return false;
  } finally {
    logger.i('AuthProvider: Vérification terminée, isAuthenticated = $_isAuthenticated');
  }
}

Considérations techniques importantes
Les champs firebase_uid et profile_picture ne sont plus utilisés directement dans le modèle User du backend, mais le profile_picture est dans le modèle Profile
L'authentification côté backend utilise désormais un mode de vérification simplifié en développement quand Firebase Admin SDK n'est pas configuré
Assurez-vous que toutes les URL d'API pointent vers le bon environnement (utiliser 10.0.2.2:8000 pour l'émulateur Android)
La création du profil utilisateur est gérée automatiquement par un signal Django, ne pas essayer de le créer manuellement
Cette implémentation garantira une authentification robuste et cohérente entre le frontend Flutter et le backend Django, même en mode développement sans une configuration complète de Firebase.