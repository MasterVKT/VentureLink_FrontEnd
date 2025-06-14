import 'package:dio/dio.dart';
import '../../core/config/app_config.dart';

/// Exception de base pour les erreurs API
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Exception pour les erreurs réseau (pas de connexion internet)
class NetworkException extends ApiException {
  NetworkException()
      : super(
          AppConfig.errorMessages['network'] ?? 'Erreur de connexion réseau',
        );

  factory NetworkException.fromDioError(DioException error) {
    String message =
        AppConfig.errorMessages['network'] ?? 'Erreur de connexion réseau';

    if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Délai de connexion dépassé';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      message = 'Délai de réception dépassé';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'Erreur de connexion au serveur';
    }

    return NetworkException();
  }
}

/// Exception pour les erreurs d'authentification (401, 403)
class AuthException extends ApiException {
  final bool isTokenExpired;

  AuthException({
    String? message,
    this.isTokenExpired = false,
    int? statusCode,
  }) : super(
          message ??
              AppConfig.errorMessages['auth'] ??
              'Erreur d\'authentification',
          statusCode: statusCode,
        );

  factory AuthException.fromDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    String message =
        AppConfig.errorMessages['auth'] ?? 'Erreur d\'authentification';
    bool isTokenExpired = false;

    if (statusCode == 401) {
      message = 'Votre session a expiré, veuillez vous reconnecter';
      isTokenExpired = true;
    } else if (statusCode == 403) {
      message = 'Vous n\'avez pas les droits nécessaires pour cette action';
    }

    // Extraire le message d'erreur personnalisé de l'API si disponible
    if (data is Map && data['message'] is String) {
      message = data['message'];
    }

    return AuthException(
      message: message,
      isTokenExpired: isTokenExpired,
      statusCode: statusCode,
    );
  }
}

/// Exception pour les erreurs de validation (422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String? message,
    this.errors,
    int? statusCode,
  }) : super(
          message ??
              AppConfig.errorMessages['validation'] ??
              'Données invalides',
          statusCode: statusCode,
        );

  factory ValidationException.fromDioError(DioException error) {
    final data = error.response?.data;
    Map<String, dynamic>? errors;
    String message =
        AppConfig.errorMessages['validation'] ?? 'Données invalides';

    if (data is Map) {
      if (data['message'] is String) {
        message = data['message'];
      }

      if (data['errors'] is Map) {
        errors = Map<String, dynamic>.from(data['errors']);
      }
    }

    return ValidationException(
      message: message,
      errors: errors,
      statusCode: error.response?.statusCode,
    );
  }

  /// Récupère le premier message d'erreur pour un champ spécifique
  String? getFieldError(String fieldName) {
    if (errors == null || !errors!.containsKey(fieldName)) return null;

    final fieldErrors = errors![fieldName];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    } else if (fieldErrors is String) {
      return fieldErrors;
    }

    return null;
  }

  /// Récupère tous les messages d'erreur sous forme de liste
  List<String> getAllErrorMessages() {
    List<String> messages = [];

    if (errors != null) {
      errors!.forEach((field, error) {
        if (error is List) {
          for (var msg in error) {
            messages.add('$field: $msg');
          }
        } else {
          messages.add('$field: $error');
        }
      });
    }

    return messages;
  }
}

/// Exception pour les erreurs serveur (500, etc.)
class ServerException extends ApiException {
  ServerException({
    String? message,
    int? statusCode,
  }) : super(
          message ?? AppConfig.errorMessages['server'] ?? 'Erreur du serveur',
          statusCode: statusCode,
        );

  factory ServerException.fromDioError(DioException error) {
    final data = error.response?.data;
    String message = AppConfig.errorMessages['server'] ?? 'Erreur du serveur';

    if (data is Map && data['message'] is String) {
      message = data['message'];
    }

    return ServerException(
      message: message,
      statusCode: error.response?.statusCode,
    );
  }
}

/// Exception pour toute autre erreur non gérée
class UnknownException extends ApiException {
  UnknownException([String? message])
      : super(
          message ??
              AppConfig.errorMessages['unknown'] ??
              'Une erreur inconnue est survenue',
        );
}

/// Utilitaire pour convertir les erreurs Dio en exceptions API
class ApiExceptionHandler {
  /// Convertit une DioException en exception API appropriée
  static ApiException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException.fromDioError(error);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        if (statusCode == 401 || statusCode == 403) {
          return AuthException.fromDioError(error);
        } else if (statusCode == 422 || statusCode == 400) {
          return ValidationException.fromDioError(error);
        } else if (statusCode != null && statusCode >= 500) {
          return ServerException.fromDioError(error);
        }
        return UnknownException('Erreur de réponse HTTP: $statusCode');

      case DioExceptionType.cancel:
        return UnknownException('Requête annulée');

      case DioExceptionType.unknown:
      default:
        if (error.error is Exception) {
          return UnknownException(error.error.toString());
        }
        return UnknownException();
    }
  }

  /// Gère les erreurs génériques (non-Dio)
  static ApiException handleError(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    } else if (error is ApiException) {
      return error;
    } else {
      return UnknownException(error.toString());
    }
  }
}
