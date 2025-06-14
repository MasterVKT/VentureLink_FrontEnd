import 'package:dio/dio.dart';

abstract class IApiService {
  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters});

  /// POST request
  Future<Response> post(String path, {dynamic data});

  /// PUT request
  Future<Response> put(String path, {dynamic data});

  /// PATCH request
  Future<Response> patch(String path, {dynamic data});

  /// DELETE request
  Future<Response> delete(String path);

  /// Upload file
  Future<Response> upload(String path, FormData formData);

  /// Set authentication tokens
  Future<void> setAuthTokens(String accessToken, String refreshToken);

  /// Clear authentication tokens
  Future<void> clearAuthTokens();

  /// Get access token
  Future<String?> getAccessToken();

  /// Set auth token in headers
  void setAuthToken(String token);

  /// Clear auth token from headers
  void clearAuthToken();
}
