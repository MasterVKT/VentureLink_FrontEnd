import 'package:venturelink/data/models/user_model.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'package:venturelink/data/services/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthApiService {
  final IApiService _apiService;

  AuthApiService(this._apiService);

  /// Inscription d'un nouvel utilisateur
  Future<AuthResult> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
    required String passwordConfirmation,
    required String userType,
  }) async {
    try {
      final response = await _apiService.post('/auth/register/', data: {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'user_type': userType,
        'terms_accepted': true,
      });

      final tokens = TokenModel.fromJson(response.data['tokens']);
      final user = UserModel.fromJson(response.data['user']);

      await _apiService.setAuthTokens(tokens.access, tokens.refresh);

      return AuthResult.success(user: user, tokens: tokens);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Connexion avec email et mot de passe
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post('/auth/token/', data: {
        'email': email,
        'password': password,
      });

      final tokens = TokenModel.fromJson({
        'access': response.data['access'],
        'refresh': response.data['refresh'],
      });

      // Sauvegarder les tokens d'abord
      await _apiService.setAuthTokens(tokens.access, tokens.refresh);

      // Ensuite récupérer les informations utilisateur
      final user = await getCurrentUser();

      if (user == null) {
        return AuthResult.failure(
            "Impossible de récupérer les informations utilisateur");
      }

      return AuthResult.success(user: user, tokens: tokens);
    } catch (e) {
      String errorMessage = "Une erreur est survenue";

      // Extraire le message d'erreur approprié
      if (e is ApiException) {
        errorMessage = e.message;
      } else if (e.toString().contains('Map<String, dynamic>')) {
        // Gérer les cas où l'erreur contient une Map
        errorMessage = "Erreur d'authentification";
      } else {
        errorMessage = e.toString();
      }

      return AuthResult.failure(errorMessage);
    }
  }

  /// Authentification via Firebase
  Future<AuthResult> loginWithFirebase({
    required String firebaseToken,
  }) async {
    try {
      debugPrint(
          '[AuthApiService] Tentative d\'authentification Firebase avec token');

      final response = await _apiService.post('/auth/firebase/', data: {
        'firebase_token': firebaseToken,
      });

      debugPrint(
          '[AuthApiService] Réponse reçue du backend: ${response.data.runtimeType}');

      // Analyser la structure de la réponse
      TokenModel tokens;
      UserModel? user;

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        debugPrint(
            '[AuthApiService] Clés dans la réponse: ${data.keys.toList()}');

        // Extraire les tokens selon le format
        if (data.containsKey('tokens')) {
          // Format avec objet tokens contenant access et refresh
          tokens = TokenModel.fromJson(data['tokens']);
        } else if (data.containsKey('access') && data.containsKey('refresh')) {
          // Format direct avec access et refresh au premier niveau
          tokens = TokenModel.fromJson({
            'access': data['access'],
            'refresh': data['refresh'],
          });
        } else {
          throw Exception('Format de tokens invalide dans la réponse');
        }

        // Extraire les données utilisateur selon le format
        if (data.containsKey('user')) {
          user = UserModel.fromJson(data['user']);
        } else {
          debugPrint(
              '[AuthApiService] Aucune donnée utilisateur dans la réponse, tentative de récupération séparée');

          // Sauvegarder les tokens d'abord
          await _apiService.setAuthTokens(tokens.access, tokens.refresh);

          // Puis récupérer l'utilisateur séparément
          user = await getCurrentUser();
        }

        if (user == null) {
          return AuthResult.failure(
              "Impossible de récupérer les informations utilisateur");
        }

        // Sauvegarder les tokens
        await _apiService.setAuthTokens(tokens.access, tokens.refresh);

        debugPrint(
            '[AuthApiService] Authentification Firebase réussie pour ${user.email}');
        return AuthResult.success(user: user, tokens: tokens);
      } else {
        throw Exception(
            'Format de réponse inattendu: ${response.data.runtimeType}');
      }
    } catch (e) {
      debugPrint(
          '[AuthApiService] Erreur lors de l\'authentification Firebase: $e');
      return AuthResult.failure(e.toString());
    }
  }

  /// Authentification via Google
  Future<AuthResult> loginWithGoogle({
    required String googleToken,
  }) async {
    try {
      final response = await _apiService.post('/auth/google/', data: {
        'google_token': googleToken,
      });

      final tokens = TokenModel.fromJson(response.data['tokens']);
      final user = UserModel.fromJson(response.data['user']);

      await _apiService.setAuthTokens(tokens.access, tokens.refresh);

      return AuthResult.success(user: user, tokens: tokens);
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout/');
    } catch (e) {
      // Ignore l'erreur de déconnexion côté serveur
    } finally {
      await _apiService.clearAuthTokens();
    }
  }

  /// Réinitialisation du mot de passe
  Future<bool> requestPasswordReset(String email) async {
    try {
      await _apiService.post('/auth/password-reset/', data: {
        'email': email,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Confirmation de réinitialisation du mot de passe
  Future<bool> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _apiService.post('/auth/password-reset/confirm/', data: {
        'token': token,
        'new_password': newPassword,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Vérification du compte par email
  Future<bool> verifyAccount(String token) async {
    try {
      await _apiService.get('/auth/verify-account/$token/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Demande de vérification email
  Future<bool> requestEmailVerification() async {
    try {
      await _apiService.post('/auth/request-email-verification/');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir le profil utilisateur actuel
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.get('/users/me/');
      return UserModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}

class TokenModel {
  final String access;
  final String refresh;

  TokenModel({
    required this.access,
    required this.refresh,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      access: json['access'],
      refresh: json['refresh'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }
}

class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final TokenModel? tokens;
  final String? error;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.tokens,
    this.error,
  });

  factory AuthResult.success({
    required UserModel user,
    required TokenModel tokens,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      tokens: tokens,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      isSuccess: false,
      error: error,
    );
  }
}
