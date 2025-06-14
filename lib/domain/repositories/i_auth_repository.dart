abstract class IAuthRepository {
  Future<bool> login(String email, String password);
  Future<bool> register(String name, String email, String password);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> getAuthToken();
  Future<void> refreshToken();
}
