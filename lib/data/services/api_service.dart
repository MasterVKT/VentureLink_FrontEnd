import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'package:flutter/foundation.dart';

class ApiService implements IApiService {
  late final Dio _dio;
  static const String _authHeader = 'Authorization';
  static const _storage = FlutterSecureStorage();
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.fullApiUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => debugPrint('[API] $object'),
    ));
  }

  InterceptorsWrapper _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ajouter le token d'accès s'il existe
        final token = await _storage.read(key: _accessTokenKey);
        if (token != null) {
          options.headers[_authHeader] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Si le token a expiré (401), essayer de le rafraîchir
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshAccessToken();
          if (refreshed) {
            // Retry la requête originale avec le nouveau token
            final clonedRequest = await _dio.fetch(error.requestOptions);
            handler.resolve(clonedRequest);
            return;
          }
        }
        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException e, handler) async {
        // Gestion spécifique pour l'authentification Firebase
        if (e.requestOptions.path.contains('/api/v1/auth/firebase/')) {
          if (e.response?.statusCode == 500) {
            // Analyser le message d'erreur pour diagnostiquer le problème
            final errorData = e.response?.data;
            String errorMessage = '';

            if (errorData is Map<String, dynamic> &&
                errorData.containsKey('error')) {
              errorMessage = errorData['error'] as String? ?? '';
              debugPrint(
                  '[API] Erreur d\'authentification Firebase: $errorMessage');

              // Si c'est une erreur de token, traiter en conséquence
              if (errorMessage.contains('Token Firebase invalide') ||
                  errorMessage.contains('Token issuer invalide')) {
                debugPrint(
                    '[API] Problème de validation du token Firebase côté backend');

                // Vous pourriez ajouter une logique spécifique ici pour notifier l'application
                // ou pour tenter une approche alternative
              }

              // Si c'est une erreur de contrainte unique, on pourrait tenter une approche différente
              if (errorMessage.contains('UNIQUE constraint failed')) {
                debugPrint(
                    '[API] Détection d\'une contrainte d\'unicité, utilisation des données locales');
              }
            }
          }
        }

        // Continuer avec la gestion d'erreur normale
        handler.next(e);
      },
    );
  }

  Future<bool> _refreshAccessToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/auth/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          headers: {
            _authHeader: null
          }, // Retirer l'auth header pour cette requête
        ),
      );

      final newAccessToken = response.data['access'];
      final newRefreshToken = response.data['refresh'] ?? refreshToken;

      await _storage.write(key: _accessTokenKey, value: newAccessToken);
      await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

      return true;
    } catch (e) {
      // Échec du rafraîchissement, supprimer les tokens
      await clearAuthTokens();
      return false;
    }
  }

  @override
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Response> upload(String path, FormData formData) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<void> setAuthTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clearAuthTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  @override
  void setAuthToken(String token) {
    _dio.options.headers[_authHeader] = 'Bearer $token';
  }

  @override
  void clearAuthToken() {
    _dio.options.headers.remove(_authHeader);
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('La connexion a expiré');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        String message = 'Une erreur est survenue';

        if (data is Map<String, dynamic>) {
          // Gestion des erreurs de validation Django
          if (data.containsKey('detail')) {
            message = data['detail'];
          } else if (data.containsKey('message')) {
            message = data['message'];
          } else if (data.containsKey('error')) {
            message = data['error'];
          } else {
            // Gérer les erreurs de champs
            final errors = <String>[];
            data.forEach((key, value) {
              if (value is List) {
                errors.addAll(value.map((e) => '$key: $e'));
              } else {
                errors.add('$key: $value');
              }
            });
            if (errors.isNotEmpty) {
              message = errors.join(', ');
            }
          }
        }

        return ApiException(
          statusCode: statusCode,
          message: message,
        );
      case DioExceptionType.cancel:
        return RequestCancelledException();
      default:
        return NetworkException('Erreur de connexion');
    }
  }
}

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException({this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class RequestCancelledException implements Exception {
  @override
  String toString() => 'RequestCancelledException: La requête a été annulée';
}
