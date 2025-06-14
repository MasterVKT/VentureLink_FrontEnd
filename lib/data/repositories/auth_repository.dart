import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'package:venturelink/domain/repositories/i_auth_repository.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'package:venturelink/domain/services/i_storage_service.dart';

class AuthRepository implements IAuthRepository {
  final IApiService _apiService;
  final IStorageService _storageService;

  AuthRepository({
    required IApiService apiService,
    required IStorageService storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  // Firebase Auth
  Stream<User?> get authStateChanges => _firebaseService.authStateChanges;
  User? get currentUser => _firebaseService.currentUser;

  final FirebaseService _firebaseService = FirebaseService();

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );
      await _storageService.setString('user_id', userCredential.user!.uid);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential =
          await _firebaseService.createUserWithEmailAndPassword(
        email,
        password,
      );
      await _storageService.setString('user_id', userCredential.user!.uid);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      await _storageService.remove('user_id');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // API Auth
  @override
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storageService.saveAuthToken(token);
        _apiService.setAuthToken(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final token = response.data['token'];
        await _storageService.saveAuthToken(token);
        _apiService.setAuthToken(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _storageService.remove('auth_token');
    _apiService.clearAuthToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getAuthToken();
    return token != null;
  }

  @override
  Future<String?> getAuthToken() async {
    return _storageService.getAuthToken();
  }

  @override
  Future<void> refreshToken() async {
    try {
      final response = await _apiService.post('/auth/refresh');
      if (response.statusCode == 200) {
        final token = response.data['token'];
        await _storageService.saveAuthToken(token);
        _apiService.setAuthToken(token);
      }
    } catch (e) {
      await logout();
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> verifyEmail(String token) async {
    try {
      await _apiService.post(
        '/auth/verify-email',
        data: {'token': token},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _apiService.post('/auth/resend-verification');
    } catch (e) {
      rethrow;
    }
  }
}
