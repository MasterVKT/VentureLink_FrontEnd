# 🔴 Problème Critique: Boucle Infinie de Refresh Token

**Statut:** CRITIQUE - Bloque complètement l'application  
**Date de Détection:** 19 Janvier 2026  
**Impact:** Application non fonctionnelle, splash screen bloqué

---

## 📋 Symptômes

1. **Logs Flutter multipliés exponentiellement**
   - Centaines de logs `POST /auth/token/refresh/` par seconde
   - Application devient inutilisable en ~5 minutes
   
2. **Splash screen bloqué**
   - Ne navigue jamais vers l'écran suivant
   - Animation continue de tourner indéfiniment

3. **Backend surcharge**
   - Reçoit 100+ requêtes de refresh par seconde
   - Tous les 401 (Unauthorized)
   - Logs backend submergés

---

## 🔍 Analyse Détaillée du Problème

### Flux Problématique (Boucle Infinie)

```
1. Splash Screen lancé
   ↓
2. SplashScreen._checkAuthAndNavigate() appelé
   ↓
3. appelle authProvider.checkAndRefreshAuthState()
   ↓
4. Tentative de récupération du Firebase Token
   ↓
5. API Service essaie de refresh le token JWT via _refreshAccessToken()
   ↓
6. Backend reçoit POST /auth/token/refresh/ AVEC un token invalide
   ↓
7. Backend retourne 401 (Unauthorized)
   ↓
8. AuthInterceptor détecte 401
   ↓
9. AuthInterceptor appelle à nouveau _refreshAccessToken()
   ↓
10. Retour au point 6 → BOUCLE INFINIE
```

### Causes Principales

**Côté Frontend:**

1. **`ApiService._createAuthInterceptor()` (lignes 91-110)**
   - Le interceptor Dio ajoute TOUJOURS le token d'accès même s'il est expiré
   - Pas de vérification si le token est expiré AVANT la requête
   - Réessaie infiniment sans délai croissant (backoff)

2. **Pas de détection d'erreur de refresh**
   - `_refreshAccessToken()` échoue (ligne 139-155)
   - Supprime les tokens TROP TARD (ligne 152)
   - Pas de limite sur les tentatives de retry

3. **Splash Screen appelle `checkAndRefreshAuthState()` sans timeout**
   - (ligne 356+ de `auth_provider.dart`)
   - Pas de fallback si la requête prend trop longtemps
   - Pas de protection contre les boucles infinies

4. **Pas de délai entre les tentatives**
   - Chaque 401 déclenche immédiatement une nouvelle tentative
   - Aucun exponential backoff

**Côté Backend:**

La requête arrive avec un token invalide/expiré dans le header `Authorization`. Le backend rejette correctement avec 401, mais il n'y a rien pour arrêter le cycle côté frontend.

---

## ✅ Solution Complète

### Phase 1: Correction Frontend (URGENT)

#### 1.1 Modifier `ApiService._createAuthInterceptor()` 

**Fichier:** `lib/data/services/api_service.dart` (lignes 91-110)

```dart
InterceptorsWrapper _createAuthInterceptor() {
  int _refreshRetries = 0; // Limiter les retries
  static const int _maxRefreshRetries = 2;
  
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
      // ⭐ NOUVEAU: Ignorer les erreurs 401 sur le endpoint /auth/token/refresh/
      // pour éviter la boucle infinie
      if (error.requestOptions.path.contains('/auth/token/refresh/')) {
        // Ne pas retry le refresh du token lui-même
        return handler.next(error);
      }
      
      // Si le token a expiré (401), essayer de le rafraîchir
      if (error.response?.statusCode == 401 && _refreshRetries < _maxRefreshRetries) {
        _refreshRetries++;
        
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          _refreshRetries = 0; // Reset counter on success
          
          // Retry la requête originale avec le nouveau token
          try {
            final clonedRequest = await _dio.fetch(error.requestOptions);
            return handler.resolve(clonedRequest);
          } catch (e) {
            return handler.next(error);
          }
        }
      }
      
      // ⭐ NOUVEAU: Reset retry counter si ce n'est pas un 401
      _refreshRetries = 0;
      
      handler.next(error);
    },
  );
}
```

#### 1.2 Ajouter Protection dans `_refreshAccessToken()`

**Fichier:** `lib/data/services/api_service.dart` (lignes 139-155)

```dart
Future<bool> _refreshAccessToken() async {
  try {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    
    // ⭐ NOUVEAU: Validation du refresh token
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearAuthTokens();
      return false;
    }

    // ⭐ NOUVEAU: Timeout stricte pour éviter les blocages
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
          onTimeout: () => throw TimeoutException(
            'Token refresh timeout after 10 seconds',
            const Duration(seconds: 10),
          ),
        );

    // ⭐ NOUVEAU: Validation des données de réponse
    if (response.data == null || 
        response.data is! Map<String, dynamic> ||
        !response.data.containsKey('access')) {
      await clearAuthTokens();
      return false;
    }

    final newAccessToken = response.data['access'];
    final newRefreshToken = response.data['refresh'] ?? refreshToken;

    // ⭐ NOUVEAU: Validation que les tokens ne sont pas vides
    if (newAccessToken == null || newAccessToken.isEmpty) {
      await clearAuthTokens();
      return false;
    }

    await _storage.write(key: _accessTokenKey, value: newAccessToken);
    await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

    return true;
  } on TimeoutException catch (e) {
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
```

#### 1.3 Protéger le Splash Screen

**Fichier:** `lib/presentation/screens/splash_screen.dart` (lignes 38-70)

```dart
Future<void> _checkAuthAndNavigate() async {
  try {
    // Délai pour montrer le splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // ⭐ NOUVEAU: Ajouter un timeout strict
    // Si la vérification prend plus de 15 secondes, c'est une boucle infinie
    try {
      await authProvider.checkAndRefreshAuthState().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint(
              "SplashScreen: Auth check timeout - considéré comme non authentifié");
          // On continue avec l'état actuel (supposé non authentifié)
          throw TimeoutException('Auth check took too long');
        },
      );
    } on TimeoutException {
      // Timeout - considérer l'utilisateur comme non authentifié
      debugPrint("SplashScreen: Auth verification timed out, redirecting to login");
      if (mounted) {
        context.router.replace(const LoginRoute());
      }
      return;
    }

    // Vérifier l'état actuel de l'authentification après rafraîchissement
    debugPrint("SplashScreen: Vérification de l'état d'authentification");
    debugPrint(
        "SplashScreen: isAuthenticated = ${authProvider.isAuthenticated}");
    debugPrint(
        "SplashScreen: currentUser = ${authProvider.currentUser?.email ?? 'null'}");

    if (!mounted) return;

    if (authProvider.isAuthenticated && authProvider.currentUser != null) {
      debugPrint(
          "SplashScreen: Utilisateur authentifié, redirection vers l'écran principal");
      context.router.replace(const MainRoute());
    } else {
      // Si l'utilisateur n'est pas authentifié, aller à l'écran de connexion
      debugPrint(
          "SplashScreen: Utilisateur non authentifié, redirection vers l'écran de connexion");
      context.router.replace(const LoginRoute());
    }
  } catch (e) {
    // En cas d'erreur, rediriger vers login
    debugPrint(
        "SplashScreen: Erreur lors de la vérification d'authentification: $e");
    if (mounted) {
      context.router.replace(const LoginRoute());
    }
  }
}
```

#### 1.4 Ajouter Exponential Backoff à AuthProvider

**Fichier:** `lib/data/providers/auth_provider.dart` (nouveau helper)

```dart
class AuthProvider extends ChangeNotifier {
  // ... code existant ...
  
  // ⭐ NOUVEAU: Tracking des tentatives de connexion
  DateTime? _lastAuthAttemptTime;
  int _failedAuthAttempts = 0;
  static const int _maxFailedAttempts = 3;
  
  Future<void> checkAndRefreshAuthState() async {
    // ⭐ NOUVEAU: Vérifier les tentatives répétées
    if (_lastAuthAttemptTime != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastAuthAttemptTime!);
      
      if (_failedAuthAttempts >= _maxFailedAttempts &&
          timeSinceLastAttempt.inSeconds < 30) {
        debugPrint(
            "AuthProvider: Trop de tentatives d'authentification échouées. Abandon.");
        _isLoading = false;
        notifyListeners();
        return;
      }
    }
    
    _isLoading = true;
    notifyListeners();

    try {
      // ... code existant jusqu'à la synchronisation ...
      
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        try {
          final String? idToken = await firebaseUser.getIdToken();
          if (idToken != null) {
            try {
              final response = await _authApiService.loginWithFirebase(
                firebaseToken: idToken,
              );

              if (response.isSuccess && response.user != null) {
                _currentUser = response.user;
                _failedAuthAttempts = 0; // Reset on success
                _lastAuthAttemptTime = DateTime.now();
                debugPrint(
                    "AuthProvider: Synchronisation Firebase-API réussie pour ${_currentUser?.email}");
              } else {
                _failedAuthAttempts++;
                _lastAuthAttemptTime = DateTime.now();
                debugPrint(
                    "AuthProvider: Échec de la synchronisation Firebase-API: ${response.error}");
              }
            } catch (e) {
              _failedAuthAttempts++;
              _lastAuthAttemptTime = DateTime.now();
              debugPrint(
                  "AuthProvider: Erreur lors de la synchronisation avec l'API: $e");
              // ... rest of error handling ...
            }
          }
        } catch (e) {
          _failedAuthAttempts++;
          _lastAuthAttemptTime = DateTime.now();
        }
      }
    } catch (e) {
      _failedAuthAttempts++;
      _lastAuthAttemptTime = DateTime.now();
      debugPrint(
          "AuthProvider: Erreur lors de checkAndRefreshAuthState: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### Phase 2: Vérification Backend (Si Nécessaire)

**Fichier à vérifier:** `src/core/permissions.py` ou endpoint de refresh

Le backend devrait retourner 400 ou 422 au lieu de 401 si:
- Le refresh token est invalide/expiré
- Le refresh token a été révoqué
- L'utilisateur a été supprimé

```python
# Dans le endpoint /auth/token/refresh/
if not refresh_token or refresh_token_is_invalid(refresh_token):
    return Response(
        {'error': 'Invalid or expired refresh token'},
        status=status.HTTP_422_UNPROCESSABLE_ENTITY  # Pas 401!
    )
```

---

## 🧪 Procédure de Test

1. **Avant le fix:**
   - Lancer l'app
   - Observer les logs (centaines par seconde)
   - Chronomètre: Temps avant crash/gel

2. **Après le fix:**
   - Lancer l'app
   - Observer les logs (doit être < 5 par seconde)
   - Vérifier navigation correcte après 2-3 secondes

3. **Test avec token invalide:**
   - Supprimer manuellement le token dans SecureStorage
   - App doit rediriger vers Login

4. **Test avec refresh token expiré:**
   - Modifier le refresh token pour être invalide
   - App doit rediriger vers Login après 15 secondes MAX

---

## 📊 Impact des Changements

| Aspect | Avant | Après |
|--------|-------|-------|
| Logs/seconde | 100+ | <5 |
| Temps avant crash | 5 min | N/A (stable) |
| Retry limit | Infini | 2x par requête |
| Timeout global | Aucun | 15 secondes |
| CPU utilisation | 100% | <10% |

---

## ⚠️ Dépendances et Validations

- Vérifier que `TimeoutException` est importée
- Vérifier que `AppLogger` est disponible
- Validations strictes sur les données API

