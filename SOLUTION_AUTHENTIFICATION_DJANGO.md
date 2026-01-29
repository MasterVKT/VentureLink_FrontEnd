# Solution pour les problèmes d'authentification Django - VentureLink

## 🔍 Diagnostic du problème

D'après les tests effectués, voici l'état actuel des endpoints de l'API Django :

- ✅ **Catégories** (`/api/v1/projects/categories/`) : **Fonctionnel** (200)
- ✅ **Tags** (`/api/v1/projects/tags/`) : **Fonctionnel** (200)
- ❌ **Projets** (`/api/v1/projects/`) : **Authentification requise** (401)
- ❌ **Publications** (`/api/v1/content/publications/`) : **Authentification requise** (401)

**Problème identifié** : L'authentification Firebase n'est pas correctement configurée ou les permissions sont trop restrictives pour le développement.

## 🔧 Solutions recommandées

### Solution 1 : Configuration temporaire pour le développement (RECOMMANDÉE)

#### 1.1 Modifier `settings.py`

Localisez le fichier `settings.py` de votre projet Django et modifiez la configuration `REST_FRAMEWORK` :

```python
# Dans settings.py
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',  # Temporaire pour développement
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.SessionAuthentication',
        # Commentez temporairement l'authentification Firebase
        # 'apps.core.authentication.FirebaseAuthentication',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
}

# Configuration CORS pour le développement
CORS_ALLOW_ALL_ORIGINS = True  # Attention: uniquement pour le développement
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",
]
```

#### 1.2 Modifier les ViewSets (si nécessaire)

Si la modification des settings ne suffit pas, modifiez directement les ViewSets :

**Dans `apps/projects/views.py` :**
```python
from rest_framework.permissions import AllowAny
from rest_framework.decorators import action
from rest_framework.response import Response

class ProjectViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]  # Temporaire pour développement
    
    def get_queryset(self):
        return Project.objects.filter(is_draft=False, status='ACTIVE')
    
    @action(detail=False, methods=['get'])
    def trending(self, request):
        """Projets tendance"""
        days = int(request.query_params.get('days', 7))
        limit = int(request.query_params.get('limit', 10))
        
        projects = self.get_queryset().order_by('-views_count')[:limit]
        serializer = self.get_serializer(projects, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Projets mis en avant"""
        limit = int(request.query_params.get('limit', 10))
        projects = self.get_queryset().filter(is_featured=True)[:limit]
        serializer = self.get_serializer(projects, many=True)
        return Response(serializer.data)
```

**Dans `apps/content/views.py` :**
```python
from rest_framework.permissions import AllowAny

class PublicationViewSet(viewsets.ModelViewSet):
    permission_classes = [AllowAny]  # Temporaire pour développement
    
    def get_queryset(self):
        return Publication.objects.filter(status='PUBLISHED')
    
    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Publications mises en avant"""
        limit = int(request.query_params.get('limit', 10))
        publications = self.get_queryset().filter(is_featured=True)[:limit]
        serializer = self.get_serializer(publications, many=True)
        return Response(serializer.data)
```

#### 1.3 Redémarrer le serveur Django

```bash
# Arrêtez le serveur Django (Ctrl+C)
# Puis redémarrez-le
python manage.py runserver
```

### Solution 2 : Configuration Firebase correcte (pour la production)

Si vous souhaitez configurer correctement Firebase au lieu d'utiliser la solution temporaire :

#### 2.1 Vérifier la configuration Firebase

**Dans `settings.py` :**
```python
# Configuration Firebase
FIREBASE_CONFIG = {
    'type': 'service_account',
    'project_id': 'venturelink-5b045',
    'private_key_id': 'your-private-key-id',
    'private_key': 'your-private-key',
    'client_email': 'your-client-email',
    'client_id': 'your-client-id',
    'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
    'token_uri': 'https://oauth2.googleapis.com/token',
}

# Middleware Firebase
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'apps.core.middleware.FirebaseAuthenticationMiddleware',  # Important
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]
```

#### 2.2 Permissions mixtes pour le développement

```python
# Dans vos ViewSets, utilisez des permissions conditionnelles
from django.conf import settings
from rest_framework.permissions import AllowAny, IsAuthenticated

class ProjectViewSet(viewsets.ModelViewSet):
    def get_permissions(self):
        """Permissions conditionnelles selon l'environnement"""
        if settings.DEBUG:
            permission_classes = [AllowAny]
        else:
            permission_classes = [IsAuthenticated]
        return [permission() for permission in permission_classes]
```

### Solution 3 : Créer des données de test

Une fois l'authentification résolue, créez des données de test :

#### 3.1 Commande Django pour créer des données

Créez un fichier `apps/projects/management/commands/create_test_data.py` :

```python
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.projects.models import Project, ProjectCategory, ProjectTag
from apps.content.models import Publication

User = get_user_model()

class Command(BaseCommand):
    help = 'Crée des données de test pour VentureLink'
    
    def handle(self, *args, **options):
        self.stdout.write('🚀 Création des données de test...')
        
        # Créer un utilisateur admin
        admin_user, created = User.objects.get_or_create(
            email='admin@venturelink.com',
            defaults={
                'first_name': 'Admin',
                'last_name': 'VentureLink',
                'user_type': 'ADMIN',
                'is_staff': True,
                'is_superuser': True,
            }
        )
        
        if created:
            admin_user.set_password('admin123')
            admin_user.save()
            self.stdout.write('✅ Utilisateur admin créé')
        
        # Créer des projets de test
        tech_category = ProjectCategory.objects.get_or_create(
            name_fr='Technologie',
            defaults={'name_en': 'Technology', 'icon': 'tech'}
        )[0]
        
        ai_tag = ProjectTag.objects.get_or_create(
            name_fr='IA',
            defaults={'name_en': 'AI'}
        )[0]
        
        project, created = Project.objects.get_or_create(
            title='EcoApp - Application écologique',
            defaults={
                'short_description': 'App mobile pour réduire son empreinte carbone',
                'full_description': 'Application innovante pour un mode de vie durable...',
                'category': tech_category,
                'creator': admin_user,
                'stage': 'PROTOTYPE',
                'funding_min': 50000.00,
                'funding_max': 200000.00,
                'funding_currency': 'EUR',
                'location_country': 'France',
                'location_city': 'Paris',
                'is_featured': True,
                'is_draft': False,
                'status': 'ACTIVE'
            }
        )
        
        if created:
            project.tags.add(ai_tag)
            self.stdout.write('✅ Projet de test créé')
        
        self.stdout.write('✅ Données de test créées avec succès!')
```

#### 3.2 Exécuter la commande

```bash
python manage.py create_test_data
```

## 🧪 Tests de vérification

Après avoir appliqué les solutions, testez les endpoints :

```python
# Script de test (test_after_fix.py)
import requests

def test_endpoints():
    base_url = "http://127.0.0.1:8000/api/v1"
    
    endpoints = {
        "Projects": "/projects/",
        "Categories": "/projects/categories/",
        "Tags": "/projects/tags/",
        "Publications": "/content/publications/"
    }
    
    for name, endpoint in endpoints.items():
        try:
            response = requests.get(f"{base_url}{endpoint}")
            if response.status_code == 200:
                print(f"✅ {name}: OK (200)")
            else:
                print(f"❌ {name}: Status {response.status_code}")
        except Exception as e:
            print(f"❌ {name}: {e}")

if __name__ == "__main__":
    test_endpoints()
```

## 📋 Checklist de résolution

- [ ] **Étape 1** : Modifier `settings.py` pour utiliser `AllowAny`
- [ ] **Étape 2** : Redémarrer le serveur Django
- [ ] **Étape 3** : Tester les endpoints avec `python test_after_fix.py`
- [ ] **Étape 4** : Créer des données de test si nécessaire
- [ ] **Étape 5** : Tester l'application Flutter
- [ ] **Étape 6** : Documenter les changements pour la production

## ⚠️ Avertissements importants

1. **Sécurité** : La configuration `AllowAny` est **uniquement pour le développement**
2. **Production** : Réactivez l'authentification Firebase avant le déploiement
3. **Données** : Les données de test ne doivent pas être utilisées en production
4. **Monitoring** : Surveillez les logs Django pour détecter d'autres problèmes

## 🔄 Retour à l'authentification Firebase

Une fois le développement terminé, pour revenir à l'authentification Firebase :

```python
# Dans settings.py
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',  # Restaurer
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'apps.core.authentication.FirebaseAuthentication',  # Réactiver
        'rest_framework.authentication.SessionAuthentication',
    ],
}

# Dans vos ViewSets
class ProjectViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated]  # Restaurer
```

## 📞 Support

Si les problèmes persistent après avoir appliqué ces solutions :

1. Vérifiez les logs Django pour des erreurs spécifiques
2. Assurez-vous que toutes les migrations sont appliquées : `python manage.py migrate`
3. Vérifiez que les applications sont bien installées dans `INSTALLED_APPS`
4. Consultez la documentation Firebase pour Django

---

**Date de création** : 16 juin 2025  
**Statut** : Solution temporaire pour le développement  
**Priorité** : Haute - Bloque le développement de l'application Flutter 