# Instructions pour résoudre l'authentification Django - VentureLink

## 🎯 Problème identifié

L'application Flutter ne peut pas charger les données car les endpoints Django retournent des erreurs 401 (Unauthorized) :
- ❌ `/api/v1/projects/` → 401
- ❌ `/api/v1/content/publications/` → 401
- ✅ `/api/v1/projects/categories/` → 200 (fonctionne)
- ✅ `/api/v1/projects/tags/` → 200 (fonctionne)

## 🔧 Solution rapide (5 minutes)

### Étape 1 : Localiser le fichier settings.py
Dans votre projet Django backend, trouvez le fichier `settings.py` (probablement dans `venture_link_project/settings.py`)

### Étape 2 : Modifier la configuration REST_FRAMEWORK
Remplacez la section `REST_FRAMEWORK` par :

```python
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Temporaire pour développement
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}
```

### Étape 3 : Redémarrer le serveur Django
```bash
# Arrêtez le serveur (Ctrl+C)
# Puis redémarrez
python manage.py runserver
```

### Étape 4 : Tester la correction
```bash
python test_simple.py
```

Vous devriez voir :
```
Projects: 200
Publications: 200
```

### Étape 5 : Tester l'application Flutter
Relancez l'application Flutter. La page d'accueil devrait maintenant charger les données.

## 🔍 Vérification

Si les tests montrent encore des erreurs 401, ajoutez également dans vos ViewSets Django :

**Dans `apps/projects/views.py` :**
```python
from rest_framework.permissions import AllowAny

class ProjectViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]  # Ajouter cette ligne
    # ... reste du code
```

**Dans `apps/content/views.py` :**
```python
from rest_framework.permissions import AllowAny

class PublicationViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]  # Ajouter cette ligne
    # ... reste du code
```

## ⚠️ Important

Cette solution est **temporaire pour le développement**. En production, vous devrez :
1. Réactiver l'authentification Firebase
2. Configurer correctement les clés Firebase
3. Utiliser `IsAuthenticated` au lieu de `AllowAny`

## 📞 Support

Si le problème persiste :
1. Vérifiez que le serveur Django fonctionne sur `http://127.0.0.1:8000`
2. Consultez les logs Django pour des erreurs spécifiques
3. Assurez-vous que les migrations sont appliquées : `python manage.py migrate`

---
**Temps estimé** : 5-10 minutes  
**Difficulté** : Facile  
**Impact** : Résout immédiatement le problème de chargement des données 