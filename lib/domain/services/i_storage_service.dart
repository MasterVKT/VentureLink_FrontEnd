abstract class IStorageService {
  Future<void> init();
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
  Future<void> setBool(String key, bool value);
  Future<bool?> getBool(String key);
  Future<void> setInt(String key, int value);
  Future<int?> getInt(String key);
  Future<void> remove(String key);
  Future<void> clear();

  // Méthodes d'authentification
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<void> clearAuthTokens();
}
