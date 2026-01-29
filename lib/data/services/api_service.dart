import 'package:dio/dio.dart';
import 'dart:async' as async;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/config/test_config.dart';
import 'package:venturelink/domain/services/i_api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:venturelink/core/utils/logger.dart';

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
        'X-Requested-With': 'XMLHttpRequest',
        'X-DJDT-disable': '1',
        'User-Agent': 'VentureLink-Mobile-App/1.0',
        if (TestConfig.enableTestMode) ...TestConfig.forceJsonHeaders,
      },
    ));

    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
    _dio.interceptors.add(_createSmartLogInterceptor());
  }

  /// Interceptor de logs intelligent qui évite de loguer les réponses HTML
  InterceptorsWrapper _createSmartLogInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        AppLogger.info('[API] ${options.method} ${options.path}');
        if (options.queryParameters.isNotEmpty) {
          AppLogger.info('[API] Query: ${options.queryParameters}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.info(
            '[API] ${response.statusCode} ${response.requestOptions.path}');

        // Vérifier si la réponse est du HTML (Django Debug Toolbar)
        if (response.data is String &&
            (response.data as String).contains('<html')) {
          AppLogger.warning(
              '[API] ⚠️ Réponse HTML détectée (Django Debug Toolbar) - non loggée');
          AppLogger.warning(
              '[API] Début HTML: ${(response.data as String).substring(0, 100)}...');
        } else if (response.data != null) {
          // Loguer seulement les réponses JSON courtes
          final dataStr = response.data.toString();
          if (dataStr.length > 1000) {
            AppLogger.info(
                '[API] Réponse JSON volumineuse (${dataStr.length} chars) - tronquée');
            AppLogger.info('[API] Début: ${dataStr.substring(0, 200)}...');
          } else {
            AppLogger.info('[API] Réponse: $dataStr');
          }
        }

        handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error(
            '[API] ❌ ${error.response?.statusCode ?? 'NETWORK'} ${error.requestOptions.path}');
        AppLogger.error('[API] Erreur: ${error.message}');

        // Vérifier si l'erreur contient du HTML
        if (error.response?.data is String &&
            (error.response!.data as String).contains('<html')) {
          AppLogger.error(
              '[API] ⚠️ Erreur contient du HTML (Django Debug Toolbar) - non loggée');
        } else if (error.response?.data != null) {
          AppLogger.error('[API] Données erreur: ${error.response!.data}');
        }

        handler.next(error);
      },
    );
  }

  InterceptorsWrapper _createAuthInterceptor() {
    int _refreshRetries = 0;
    const int _maxRefreshRetries = 2;

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
        // 🔴 CRITICAL FIX: Éviter boucle infinie en ignorant les erreurs 401
        // sur le endpoint /auth/token/refresh/ lui-même
        if (error.requestOptions.path.contains('/auth/token/refresh/')) {
          return handler.next(error);
        }

        // Si le token a expiré (401), essayer de le rafraîchir (max 2x)
        if (error.response?.statusCode == 401 &&
            _refreshRetries < _maxRefreshRetries) {
          _refreshRetries++;
          AppLogger.warning(
              '[AUTH] Token 401, tentative refresh #$_refreshRetries/$_maxRefreshRetries');

          final refreshed = await _refreshAccessToken();
          if (refreshed) {
            _refreshRetries = 0; // Reset counter on success
            try {
              // Retry la requête originale avec le nouveau token
              final clonedRequest = await _dio.fetch(error.requestOptions);
              return handler.resolve(clonedRequest);
            } catch (retryError) {
              AppLogger.error('[AUTH] Retry after refresh failed: $retryError');
              return handler.next(error);
            }
          }
        }

        // Reset retry counter si ce n'est pas un 401
        _refreshRetries = 0;
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

      // 🔴 CRITICAL FIX: Valider le refresh token avant toute requête
      if (refreshToken == null || refreshToken.isEmpty) {
        AppLogger.error('[AUTH] Refresh token is null or empty');
        await clearAuthTokens();
        return false;
      }

      // 🔴 CRITICAL FIX: Timeout strict pour éviter les blocages
      final response = await _dio
          .post(
        '/auth/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          headers: {
            _authHeader: null
          }, // Retirer l'auth header pour cette requête
        ),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.error('[AUTH] Token refresh timeout after 10 seconds');
          throw async.TimeoutException(
            'Token refresh timeout',
            const Duration(seconds: 10),
          );
        },
      );

      // 🔴 CRITICAL FIX: Validation stricte de la réponse
      if (response.data == null || response.data is! Map<String, dynamic>) {
        AppLogger.error('[AUTH] Invalid refresh response format');
        await clearAuthTokens();
        return false;
      }

      final responseMap = response.data as Map<String, dynamic>;
      if (!responseMap.containsKey('access')) {
        AppLogger.error('[AUTH] No access token in refresh response');
        await clearAuthTokens();
        return false;
      }

      final newAccessToken = responseMap['access'] as String?;
      final newRefreshToken = responseMap['refresh'] as String? ?? refreshToken;

      // 🔴 CRITICAL FIX: Valider que les tokens ne sont pas vides
      if (newAccessToken == null || newAccessToken.isEmpty) {
        AppLogger.error('[AUTH] New access token is null or empty');
        await clearAuthTokens();
        return false;
      }

      if (newRefreshToken.isEmpty) {
        AppLogger.error('[AUTH] New refresh token is empty');
        await clearAuthTokens();
        return false;
      }

      await _storage.write(key: _accessTokenKey, value: newAccessToken);
      await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

      AppLogger.info('[AUTH] Token refresh successful');
      return true;
    } on async.TimeoutException catch (e) {
      AppLogger.error('[AUTH] Token refresh timeout: ${e.message}');
      await clearAuthTokens();
      return false;
    } catch (e) {
      AppLogger.error('[AUTH] Token refresh failed: $e');
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
        return async.TimeoutException('La connexion a expiré');
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
            // Gérer les erreurs structurées
            final errorData = data['error'];
            if (errorData is Map<String, dynamic>) {
              message = errorData['message'] ?? errorData.toString();
            } else if (errorData is String) {
              message = errorData;
            } else {
              message = errorData.toString();
            }
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
