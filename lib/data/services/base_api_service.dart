import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../core/config/app_config.dart';

part 'base_api_service.g.dart';

/// Service API de base utilisant Retrofit
@RestApi(baseUrl: "http://localhost:8000/api/v1/")
abstract class BaseApiService {
  factory BaseApiService(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) = _BaseApiService;

  static Dio createDio() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: AppConfig.fullApiUrl,
      connectTimeout: AppConfig.connectionTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Intercepteur d'authentification
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Ajouter le token JWT si disponible
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Gestion des erreurs communes
          if (error.response?.statusCode == 401) {
            // Token expiré, rediriger vers login
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Intercepteur de logs en mode debug
    if (AppConfig.apiTimeout > 0) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
      ));
    }

    return dio;
  }

  static String? _getAuthToken() {
    // TODO: Récupérer le token depuis le stockage sécurisé
    return null;
  }

  static void _handleUnauthorized() {
    // TODO: Rediriger vers l'écran de connexion
  }
}

/// Modèle de réponse paginée simplifié
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'count': count,
      if (next != null) 'next': next,
      if (previous != null) 'previous': previous,
      'results': results.map(toJsonT).toList(),
    };
  }
}

/// Modèle de réponse API standard simplifié
class ApiResponse {
  final bool success;
  final String? message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
      if (errors != null) 'errors': errors,
    };
  }
}

/// Exceptions personnalisées pour l'API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final Map<String, dynamic> errors;

  ValidationException(this.errors);

  @override
  String toString() => 'ValidationException: $errors';
}
