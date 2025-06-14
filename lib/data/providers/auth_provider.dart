import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:venturelink/data/models/user_model.dart';
import 'package:venturelink/data/services/auth_api_service.dart';
import 'package:venturelink/data/services/auth_service.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final AuthService _firebaseAuthService = AuthService();
  late final AuthApiService _authApiService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    debugPrint("AuthProvider: Initialisation du provider");
    _authApiService = AuthApiService(ApiService());
    debugPrint("AuthProvider: Service API initialisé");
    _init();
    debugPrint("AuthProvider: Méthode _init appelée");
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _checkExistingAuth();
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation de l\'authentification.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkExistingAuth() async {
    print("Vérification de l'état d'authentification...");

    try {
      // Vérifier s'il y a un token d'accès stocké
      final apiService = ApiService();
      final accessToken = await apiService.getAccessToken();

      if (accessToken != null) {
        // Essayer de récupérer l'utilisateur actuel avec le token
        _currentUser = await _authApiService.getCurrentUser();
        if (_currentUser != null) {
          print("Utilisateur connecté via API: ${_currentUser?.email}");
          notifyListeners();
          return;
        }
      }

      // Si pas de token valide, vérifier Firebase
      final firebaseUser = _firebaseAuthService.currentUser;
      if (firebaseUser != null) {
        print(
            "Utilisateur Firebase trouvé, tentative de synchronisation avec l'API...");
        await _syncFirebaseWithApi();
      }

      print(
          "État d'authentification: ${_currentUser != null ? 'Connecté' : 'Non connecté'}");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la vérification de l'état d'authentification: $e");
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _syncFirebaseWithApi() async {
    try {
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        final String? firebaseToken = await firebaseUser.getIdToken();
        if (firebaseToken != null) {
          try {
            final result = await _authApiService.loginWithFirebase(
              firebaseToken: firebaseToken,
            );

            if (result.isSuccess && result.user != null) {
              _currentUser = result.user;
              debugPrint(
                  "AuthProvider: Synchronisation Firebase-API réussie pour ${_currentUser?.email}");
            } else {
              debugPrint(
                  "AuthProvider: Échec de la synchronisation Firebase-API: ${result.error}");
            }
          } catch (e) {
            debugPrint(
                "AuthProvider: Erreur lors de la synchronisation avec l'API: $e");

            // Gérer les erreurs de token Firebase
            if (e.toString().contains('Token Firebase invalide') ||
                e.toString().contains('Token issuer invalide')) {
              debugPrint(
                  "AuthProvider: Utilisation des données Firebase locales suite à l'erreur de validation du token");

              // Extraire les informations de nom et prénom
              String firstName = '';
              String lastName = '';

              if (firebaseUser.displayName != null) {
                final nameParts = firebaseUser.displayName!.split(' ');
                firstName = nameParts.first;
                if (nameParts.length > 1) {
                  lastName = nameParts.skip(1).join(' ');
                }
              }

              _currentUser = UserModel(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? '',
                firstName: firstName,
                lastName: lastName,
                userType: 'BOTH',
                dateJoined: DateTime.now(),
                isVerified: firebaseUser.emailVerified,
              );

              debugPrint(
                  "AuthProvider: Utilisateur local créé: ${_currentUser?.email}");
            }
          }
        }
      }
    } catch (e) {
      debugPrint(
          "AuthProvider: Erreur lors de la synchronisation Firebase-API: $e");
    }
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    _clearError();
    notifyListeners();

    try {
      print("AuthProvider: Début de connexion pour $email");

      // Tenter de se connecter via l'API backend
      final result = await _authApiService.login(
        email: email,
        password: password,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        print(
            "AuthProvider: Connexion API réussie pour ${_currentUser?.email}");
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error ?? "Échec de connexion";
        print("AuthProvider: Erreur de connexion API: $_error");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("AuthProvider: Erreur de connexion: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String userType,
  ) async {
    _isLoading = true;
    _error = null;
    _clearError();
    notifyListeners();

    try {
      print("AuthProvider: Début d'inscription pour $email");

      final result = await _authApiService.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password,
        passwordConfirmation: password,
        userType: userType,
      );

      if (result.isSuccess && result.user != null) {
        _currentUser = result.user;
        print("AuthProvider: Inscription réussie pour ${_currentUser?.email}");
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result.error ?? "Échec d'inscription";
        print("AuthProvider: Erreur d'inscription: $_error");
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("AuthProvider: Erreur d'inscription: $e");
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    _clearError();
    notifyListeners();

    try {
      // D'abord, se connecter avec Firebase
      final firebaseUser = await _firebaseAuthService.signInWithGoogle();

      // Ensuite, synchroniser avec l'API
      await _syncFirebaseWithApi();

      if (_currentUser != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = "Échec de connexion avec Google";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    _isLoading = true;
    _error = null;
    _clearError();
    notifyListeners();

    try {
      // D'abord, se connecter avec Firebase
      final firebaseUser = await _firebaseAuthService.signInWithApple();

      // Ensuite, synchroniser avec l'API
      await _syncFirebaseWithApi();

      if (_currentUser != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = "Échec de connexion avec Apple";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      return await _authApiService.requestPasswordReset(email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Déconnexion de l'API
      await _authApiService.logout();

      // Déconnexion de Firebase
      await _firebaseAuthService.signOut();

      _currentUser = null;
      _error = null;

      print("AuthProvider: Déconnexion réussie");
    } catch (e) {
      print("AuthProvider: Erreur lors de la déconnexion: $e");
      // Même en cas d'erreur, on efface les données locales
      _currentUser = null;
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    try {
      final updatedUser = await _authApiService.getCurrentUser();
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      print("Erreur lors du rafraîchissement de l'utilisateur: $e");
    }
  }

  /// Mettre à jour l'utilisateur courant
  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> checkAndRefreshAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint(
          "AuthProvider: Début de la vérification de l'état d'authentification");

      // Vérifier d'abord si l'utilisateur Firebase est disponible
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        debugPrint(
            "AuthProvider: Utilisateur Firebase trouvé, tentative de synchronisation avec l'API...");

        try {
          // Tenter de synchroniser avec le backend
          final String? idToken = await firebaseUser.getIdToken();

          if (idToken != null) {
            try {
              final response = await _authApiService.loginWithFirebase(
                firebaseToken: idToken,
              );

              if (response.isSuccess && response.user != null) {
                _currentUser = response.user;
                debugPrint(
                    "AuthProvider: Synchronisation Firebase-API réussie pour ${_currentUser?.email}");
              } else {
                debugPrint(
                    "AuthProvider: Échec de la synchronisation Firebase-API: ${response.error}");
              }
            } catch (e) {
              debugPrint(
                  "AuthProvider: Erreur lors de la synchronisation avec l'API: $e");

              // Créer un utilisateur minimal avec les données Firebase en cas d'erreur
              // En environnement de développement, cela permettra de continuer à travailler
              if (e.toString().contains('Token Firebase invalide') ||
                  e.toString().contains('Token issuer invalide')) {
                debugPrint(
                    "AuthProvider: Utilisation des données Firebase locales suite à l'erreur de validation du token");

                // Extraire les informations de nom et prénom
                String firstName = '';
                String lastName = '';

                if (firebaseUser.displayName != null) {
                  final nameParts = firebaseUser.displayName!.split(' ');
                  firstName = nameParts.first;
                  if (nameParts.length > 1) {
                    lastName = nameParts.skip(1).join(' ');
                  }
                }

                _currentUser = UserModel(
                  id: firebaseUser.uid,
                  email: firebaseUser.email ?? '',
                  firstName: firstName,
                  lastName: lastName,
                  userType: 'BOTH',
                  dateJoined: DateTime.now(),
                  isVerified: firebaseUser.emailVerified,
                );

                debugPrint(
                    "AuthProvider: Utilisateur local créé: ${_currentUser?.email}");
              }
            }
          }
        } catch (e) {
          debugPrint(
              "AuthProvider: Erreur lors de l'obtention du token Firebase: $e");
        }
      } else {
        // Si pas d'utilisateur Firebase, essayer d'utiliser un token existant
        final apiService = ApiService();
        final accessToken = await apiService.getAccessToken();

        if (accessToken != null) {
          try {
            _currentUser = await _authApiService.getCurrentUser();
            if (_currentUser != null) {
              debugPrint(
                  "AuthProvider: Utilisateur connecté via token API: ${_currentUser?.email}");
            }
          } catch (e) {
            debugPrint(
                "AuthProvider: Erreur lors de la vérification du token: $e");
            _currentUser = null;
          }
        }
      }

      debugPrint(
          "AuthProvider: Vérification terminée, isAuthenticated = $isAuthenticated");
      if (_currentUser != null) {
        debugPrint(
            "AuthProvider: Utilisateur connecté: ${_currentUser?.email}");
      } else {
        debugPrint("AuthProvider: Aucun utilisateur connecté");
      }
    } catch (e) {
      _error =
          'Erreur lors de la vérification de l\'état d\'authentification: ${e.toString()}';
      debugPrint("AuthProvider: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
