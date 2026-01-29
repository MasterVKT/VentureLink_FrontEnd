# 🤖 Règle GitHub Copilot - Détection Boucles Infinies d'Auth

**Document:** `.github/copilot-infinite-loop-detection-rule.md`  
**Date de Création:** 19 Janvier 2026  
**Applicable à:** Tous les projets Flutter/Dart avec authentification  
**Statut:** ✅ Actif et obligatoire

---

## 📋 Règle: Détection Automatique des Boucles Infinies de Refresh Token

### Quand Appliquer Cette Règle

**TOUJOURS** appliquer à chaque fois que:

1. ✅ Vous travaillez sur l'authentification JWT/Token
2. ✅ Vous travaillez sur les interceptors Dio
3. ✅ Vous travaillez sur les retry/error handling
4. ✅ L'utilisateur rapporte:
   - "Les logs se multiplient"
   - "L'app freeze/gel"
   - "Trop de requêtes réseau"
   - "Splash screen bloqué"
5. ✅ Vous voyez dans les logs des patterns comme:
   - Mêmes requêtes répétées 10+ fois par seconde
   - Erreurs 401/403 répétées
   - Erreurs de timeout/deadline exceeded
   - Logs exponentiellement croissants

### Checklist de Détection

Avant de faire TOUTE modification d'authentification, vérifiez:

- [ ] Y a-t-il un interceptor Dio qui retry sur 401?
- [ ] Le retry ajoute-t-il un délai croissant (exponential backoff)?
- [ ] Y a-t-il une limite MAX sur le nombre de retry?
- [ ] Y a-t-il une vérification pour éviter de retry le endpoint `/auth/token/refresh/` lui-même?
- [ ] Y a-t-il un timeout global sur les opérations auth?
- [ ] La logique de rafraîchissement supprime-t-elle les tokens EN CAS D'ERREUR?
- [ ] Y a-t-il une limite sur les tentatives d'auth consécutives échouées?

### Patterns Dangereux à Éviter

```dart
// ❌ DANGEREUX: Retry infini sans conditions
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    // Pas de vérification si c'est déjà un refresh token request!
    await refreshToken();
    final newRequest = await _dio.fetch(error.requestOptions);
    return handler.resolve(newRequest);
  }
}

// ❌ DANGEREUX: Pas de timeout
Future<bool> _refreshToken() async {
  final response = await _dio.post('/auth/token/refresh/', data: {...});
  // Si ce post lui-même échoue avec 401, boucle infinie!
}

// ❌ DANGEREUX: Pas de limite de retry
int retryCount = 0; // Jamais incrémenté!
onError: (error, handler) async {
  if (error.response?.statusCode == 401) {
    await refreshToken(); // Peut être appelé infiniment
  }
}

// ❌ DANGEREUX: Pas de vérification du token invalide
await _storage.write(key: tokenKey, value: newToken);
// Et si newToken est null? Stockage d'une valeur invalide!
```

### Patterns Sûrs à Adopter

```dart
// ✅ SÛRE: Retry limité avec vérification d'endpoint
int _refreshRetries = 0;
static const int _maxRefreshRetries = 2;

onError: (error, handler) async {
  // Éviter la boucle infinie sur le endpoint de refresh
  if (error.requestOptions.path.contains('/auth/token/refresh/')) {
    return handler.next(error);
  }
  
  if (error.response?.statusCode == 401 && _refreshRetries < _maxRefreshRetries) {
    _refreshRetries++;
    final refreshed = await _refreshAccessToken();
    if (refreshed) {
      _refreshRetries = 0;
      final clonedRequest = await _dio.fetch(error.requestOptions);
      return handler.resolve(clonedRequest);
    }
  }
  
  _refreshRetries = 0;
  handler.next(error);
}

// ✅ SÛRE: Timeout strict + validation
Future<bool> _refreshAccessToken() async {
  try {
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await clearAuthTokens();
      return false;
    }

    final response = await _dio
        .post(
          '/auth/token/refresh/',
          data: {'refresh': refreshToken},
          options: Options(headers: {_authHeader: null}),
        )
        .timeout(const Duration(seconds: 10));

    // Valider la réponse
    if (response.data == null || !response.data.containsKey('access')) {
      await clearAuthTokens();
      return false;
    }

    final newToken = response.data['access'];
    if (newToken == null || newToken.isEmpty) {
      await clearAuthTokens();
      return false;
    }

    await _storage.write(key: _accessTokenKey, value: newToken);
    return true;
  } on TimeoutException {
    await clearAuthTokens();
    return false;
  } catch (e) {
    await clearAuthTokens();
    return false;
  }
}

// ✅ SÛRE: Timeout global sur l'écran Splash
try {
  await authProvider.checkAndRefreshAuthState().timeout(
    const Duration(seconds: 15),
    onTimeout: () => throw TimeoutException('Auth check timeout'),
  );
} on TimeoutException {
  context.router.replace(const LoginRoute());
  return;
}
```

---

## 🔍 Diagnostic Rapide

### Symptômes vs Cause

| Symptôme | Cause Probable | Solution Rapide |
|----------|---|---|
| 100+ logs/sec identiques | Boucle retry | Ajouter limite max retries |
| Erreur 401 répétée | Token invalide | Ajouter timeout + validation token |
| App gel après 1-2 min | Boucle infinie | Ajouter timeout global 15s |
| Logs "401, 401, 401..." | Pas d'endpoint check | Vérifier `if (path.contains('refresh'))` |
| CPU 100% | Boucle serrée | Ajouter délai entre retries |

### Commandes Debug Utiles

```bash
# Voir le nombre de logs par seconde
adb logcat | grep "POST /auth" | wc -l

# Filtrer les logs d'auth
adb logcat | grep -E "\[API\].*auth|401|refresh"

# Voir la durée entre les logs
adb logcat | grep "POST /auth/token/refresh/" | \
  awk '{print $3}' | uniq -c
```

---

## 📝 Template de Comment pour Commits

Quand vous fixez une boucle infinie d'auth, utilisez ce template:

```
fix(auth): prevent infinite token refresh loop

**Problem:**
- [SYMPTOM] e.g., "100+ refresh attempts per second"
- [ROOT_CAUSE] e.g., "No max retry limit on 401 errors"
- [IMPACT] e.g., "App becomes unresponsive in 5 minutes"

**Solution:**
- [FIX_1] Add max retry limit (2x per request)
- [FIX_2] Add endpoint check to skip retrying /auth/token/refresh/
- [FIX_3] Add timeout on splash screen auth check (15s)
- [FIX_4] Add token validation before storage

**Validation:**
- [X] No 401 retry loops in logs
- [X] Auth completes in < 3s
- [X] Splash screen navigates correctly
- [X] CPU usage normal during auth

Fixes #[ISSUE_NUMBER]
Related: PROBLEME_BOUCLE_INFINITE_TOKEN_REFRESH.md
```

---

## 🛡️ Checklist Pré-Commit pour Auth Changes

**AVANT chaque commit de code auth, vérifier:**

- [ ] ✅ Y a-t-il un MAX_RETRIES défini?
- [ ] ✅ Y a-t-il un check pour `/auth/token/refresh/`?
- [ ] ✅ Y a-t-il un `.timeout()` sur les requêtes?
- [ ] ✅ Y a-t-il une validation des tokens avant stockage?
- [ ] ✅ Y a-t-il un clear de tokens en cas d'erreur?
- [ ] ✅ Y a-t-il un timeout global sur splash screen (15s)?
- [ ] ✅ Les logs ne montent pas de façon exponentielle?
- [ ] ✅ Test avec token invalide = redirection Login?

---

## 🎯 Application Systématique

### Lors de Code Review

Si vous voyez ce code:

```dart
onError: (error, handler) {
  if (error.response?.statusCode == 401) {
    refreshToken();
    // Retry request
  }
}
```

**COMMENTAIRE OBLIGATOIRE:**

```
❌ Cette implémentation peut créer une boucle infinie.

Ajouter:
1. Limite max retries: if (retries < 2)
2. Check endpoint: if (!path.contains('refresh'))
3. Timeout: .timeout(Duration(seconds: 10))
4. Validation token: if (newToken != null && newToken.isNotEmpty)

Voir: PROBLEME_BOUCLE_INFINITE_TOKEN_REFRESH.md
```

### Pour les Nouveaux Développeurs

Si vous êtes **assigné** à une issue d'authentification:

1. Lire d'abord: `PROBLEME_BOUCLE_INFINITE_TOKEN_REFRESH.md`
2. Vérifier: `lib/data/services/api_service.dart` (patterns sûrs)
3. Appliquer: Checklist pré-commit ci-dessus
4. Tester: Avec token invalide + invalid refresh token

---

## 🔗 Références et Ressources

- **Document Principal:** `PROBLEME_BOUCLE_INFINITE_TOKEN_REFRESH.md`
- **Code Exemple (Sûr):** `lib/data/services/api_service.dart` (après fix)
- **Tests:** `test/data/services/api_service_test.dart`
- **CI/CD Check:** `auth_loop_detection.sh`

---

## 📞 Escalade et Support

Si vous trouvez une **nouvelle boucle infinie** (pattern non couvert):

1. Créer une issue GitHub avec le tag `auth-loop-detection`
2. Ajouter les logs reproduisant le problème
3. Ajouter ce cas à la règle
4. Mettre à jour le document

---

**IMPORTANT:** Cette règle s'applique **sans exception** à tout code d'authentification. Les violations doivent être détectées en code review et forcées en PR before merge.

**Version:** 1.0  
**Applicabilité:** OBLIGATOIRE  
**Enforcement:** Automatique via CI/CD

