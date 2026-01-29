# 🔥 Configuration Firebase Complète - VentureLink

## Vue d'ensemble

Ce guide vous explique comment configurer correctement l'authentification Firebase pour que votre application Flutter communique parfaitement avec votre backend Django, même en mode développement.

## 📋 Prérequis

- Projet Firebase créé : `venturelink-5b045`
- Application Flutter configurée
- Backend Django fonctionnel
- Clés Firebase disponibles

---

## 🚀 Étape 1 : Configuration Firebase Console

### 1.1 Vérifier la configuration du projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionnez votre projet `venturelink-5b045`
3. Vérifiez que l'authentification est activée :
   - **Authentication** > **Sign-in method**
   - Activez : Email/Password, Google
4. Ajoutez vos domaines autorisés :
   - `localhost`
   - `127.0.0.1`
   - `10.0.2.2` (pour émulateur Android)

### 1.2 Générer la clé de service (Service Account)

1. **Project Settings** > **Service accounts**
2. Cliquez sur **Generate new private key**
3. Téléchargez le fichier JSON
4. Gardez ce fichier en sécurité !

---

## 🔧 Étape 2 : Configuration Django Backend

### 2.1 Installation des dépendances

```bash
# Dans votre environnement virtuel Django
pip install firebase-admin
pip install python-jose[cryptography]
pip install python-decouple
```

### 2.2 Configuration des variables d'environnement

Créez un fichier `.env` dans votre projet Django :

```env
# Firebase Configuration
FIREBASE_TYPE=service_account
FIREBASE_PROJECT_ID=venturelink-5b045
FIREBASE_PRIVATE_KEY_ID=your_private_key_id_from_json
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_HERE\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@venturelink-5b045.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your_client_id_from_json
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token

# Mode développement
FIREBASE_DEV_MODE=True
DEBUG=True
```

### 2.3 Mise à jour de settings.py

```python
# settings.py
import os
from decouple import config

# Configuration Firebase
FIREBASE_CONFIG = {
    'type': config('FIREBASE_TYPE', default='service_account'),
    'project_id': config('FIREBASE_PROJECT_ID', default='venturelink-5b045'),
    'private_key_id': config('FIREBASE_PRIVATE_KEY_ID', default=''),
    'private_key': config('FIREBASE_PRIVATE_KEY', default='').replace('\\n', '\n'),
    'client_email': config('FIREBASE_CLIENT_EMAIL', default=''),
    'client_id': config('FIREBASE_CLIENT_ID', default=''),
    'auth_uri': config('FIREBASE_AUTH_URI', default='https://accounts.google.com/o/oauth2/auth'),
    'token_uri': config('FIREBASE_TOKEN_URI', default='https://oauth2.googleapis.com/token'),
    'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
    'client_x509_cert_url': f'https://www.googleapis.com/robot/v1/metadata/x509/{config("FIREBASE_CLIENT_EMAIL", default="")}'
}

# Mode développement Firebase
FIREBASE_DEV_MODE = config('FIREBASE_DEV_MODE', default=True, cast=bool)

# REST Framework avec Firebase
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'apps.core.authentication.FirebaseAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'apps.core.permissions.FirebasePermission',
    ],
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': 20,
    'EXCEPTION_HANDLER': 'apps.core.exceptions.custom_exception_handler',
}

# CORS pour Flutter
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",
    "http://localhost:8080",
]

CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = FIREBASE_DEV_MODE  # Seulement en dev
```

### 2.4 Créer l'authentification Firebase personnalisée

Créez `apps/core/authentication.py` :

```python
import firebase_admin
from firebase_admin import auth, credentials
from rest_framework import authentication, exceptions
from django.contrib.auth import get_user_model
from django.conf import settings
import logging

logger = logging.getLogger(__name__)
User = get_user_model()

class FirebaseAuthentication(authentication.BaseAuthentication):
    def __init__(self):
        if not firebase_admin._apps:
            try:
                if hasattr(settings, 'FIREBASE_CONFIG') and settings.FIREBASE_CONFIG.get('private_key'):
                    cred = credentials.Certificate(settings.FIREBASE_CONFIG)
                    firebase_admin.initialize_app(cred)
                    logger.info("Firebase Admin SDK initialisé")
                else:
                    logger.warning("Configuration Firebase manquante")
            except Exception as e:
                logger.error(f"Erreur Firebase: {e}")
    
    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        
        if not auth_header:
            if getattr(settings, 'FIREBASE_DEV_MODE', False):
                return self._create_dev_user()
            return None
        
        try:
            if auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]
            else:
                return None
            
            decoded_token = auth.verify_id_token(token)
            user = self._get_or_create_user(decoded_token)
            return (user, decoded_token)
            
        except Exception as e:
            logger.error(f"Erreur authentification: {e}")
            if getattr(settings, 'FIREBASE_DEV_MODE', False):
                return self._create_dev_user()
            raise exceptions.AuthenticationFailed('Token invalide')
    
    def _get_or_create_user(self, decoded_token):
        firebase_uid = decoded_token['uid']
        email = decoded_token.get('email', '')
        name = decoded_token.get('name', '')
        
        try:
            if email:
                user = User.objects.get(email=email)
            else:
                user = User.objects.get(firebase_uid=firebase_uid)
        except User.DoesNotExist:
            first_name = name.split(' ')[0] if name else 'User'
            last_name = ' '.join(name.split(' ')[1:]) if len(name.split(' ')) > 1 else 'Firebase'
            
            user = User.objects.create(
                email=email or f"{firebase_uid}@firebase.local",
                first_name=first_name,
                last_name=last_name,
                firebase_uid=firebase_uid,
                is_active=True,
                user_type='BOTH'
            )
        
        if not hasattr(user, 'firebase_uid') or not user.firebase_uid:
            user.firebase_uid = firebase_uid
            user.save()
        
        return user
    
    def _create_dev_user(self):
        user, created = User.objects.get_or_create(
            email='dev@venturelink.local',
            defaults={
                'first_name': 'Dev',
                'last_name': 'User',
                'user_type': 'BOTH',
                'is_active': True,
                'firebase_uid': 'dev-user-uid'
            }
        )
        return (user, {'uid': 'dev-user-uid'})
```

### 2.5 Créer les permissions personnalisées

Créez `apps/core/permissions.py` :

```python
from rest_framework import permissions
from django.conf import settings

class FirebasePermission(permissions.BasePermission):
    def has_permission(self, request, view):
        if getattr(settings, 'FIREBASE_DEV_MODE', False):
            if request.method in permissions.SAFE_METHODS:
                return True
            return request.user and request.user.is_authenticated
        
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        if getattr(settings, 'FIREBASE_DEV_MODE', False) and request.method in permissions.SAFE_METHODS:
            return True
        
        if hasattr(obj, 'creator'):
            return obj.creator == request.user or request.user.is_staff
        elif hasattr(obj, 'user'):
            return obj.user == request.user or request.user.is_staff
        
        return request.user.is_staff
```

### 2.6 Ajouter le champ firebase_uid au modèle User

```python
# apps/users/models.py
class User(AbstractUser):
    # ... autres champs ...
    
    firebase_uid = models.CharField(
        max_length=128, 
        unique=True, 
        null=True, 
        blank=True,
        help_text="UID Firebase de l'utilisateur"
    )
```

Puis créez et appliquez la migration :

```bash
python manage.py makemigrations
python manage.py migrate
```

---

## 📱 Étape 3 : Configuration Flutter

### 3.1 Vérifier firebase_options.dart

Assurez-vous que votre `lib/firebase_options.dart` contient les bonnes clés :

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyA5Ox6r37DWCZCKxmbziEKO6llVDZ4g_j0',
  appId: '1:149697014585:android:0b01bf7eae8dca160716e8',
  messagingSenderId: '149697014585',
  projectId: 'venturelink-5b045',
  storageBucket: 'venturelink-5b045.appspot.com',
);
```

### 3.2 Créer le service d'authentification Firebase

Créez `lib/core/services/firebase_auth_service.dart` :

```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static User? get currentUser => _auth.currentUser;
  static bool get isSignedIn => currentUser != null;
  
  static Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = currentUser;
      if (user != null) {
        final token = await user.getIdToken(forceRefresh);
        Logger.info('Token Firebase obtenu');
        return token;
      }
      return null;
    } catch (e) {
      Logger.error('Erreur token Firebase: $e');
      return null;
    }
  }
  
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Logger.info('Connexion réussie: $email');
      return credential;
    } on FirebaseAuthException catch (e) {
      Logger.error('Erreur connexion: ${e.code}');
      throw _handleFirebaseAuthException(e);
    }
  }
  
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      Logger.info('Déconnexion réussie');
    } catch (e) {
      Logger.error('Erreur déconnexion: $e');
      rethrow;
    }
  }
  
  static Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Utilisateur non trouvé');
      case 'wrong-password':
        return Exception('Mot de passe incorrect');
      case 'email-already-in-use':
        return Exception('Email déjà utilisé');
      case 'weak-password':
        return Exception('Mot de passe trop faible');
      case 'invalid-email':
        return Exception('Email invalide');
      default:
        return Exception('Erreur: ${e.message}');
    }
  }
}
```

### 3.3 Créer l'intercepteur API avec Firebase

Créez `lib/core/services/api_interceptor.dart` :

```dart
import 'package:dio/dio.dart';
import 'firebase_auth_service.dart';
import '../utils/logger.dart';

class FirebaseAuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await FirebaseAuthService.getIdToken();
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        Logger.debug('Token ajouté: ${options.path}');
      } else {
        Logger.warning('Pas de token pour: ${options.path}');
      }
    } catch (e) {
      Logger.error('Erreur ajout token: $e');
    }
    
    handler.next(options);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        Logger.info('Token expiré, rafraîchissement...');
        
        final newToken = await FirebaseAuthService.getIdToken(forceRefresh: true);
        
        if (newToken != null) {
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          
          final dio = Dio();
          final response = await dio.fetch(requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        Logger.error('Erreur rafraîchissement: $e');
      }
    }
    
    handler.next(err);
  }
}
```

### 3.4 Mettre à jour votre BaseApiService

Modifiez `lib/data/services/base_api_service.dart` :

```dart
import 'package:dio/dio.dart';
import '../../core/services/api_interceptor.dart';

class BaseApiService {
  static late Dio _dio;
  
  static void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1',
      connectTimeout: Duration(milliseconds: 30000),
      receiveTimeout: Duration(milliseconds: 30000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Ajouter l'intercepteur Firebase
    _dio.interceptors.add(FirebaseAuthInterceptor());
    
    // Intercepteur de logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  static Dio get dio => _dio;
}
```

### 3.5 Initialiser dans main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/services/base_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialiser l'API avec Firebase
  BaseApiService.initialize();
  
  runApp(MyApp());
}
```

---

## 🧪 Étape 4 : Tests et Validation

### 4.1 Test de l'authentification

Créez un utilisateur de test :

```bash
# Dans Django
python manage.py shell
```

```python
from django.contrib.auth import get_user_model
User = get_user_model()

# Créer un utilisateur de test
user = User.objects.create_user(
    email='test@venturelink.com',
    password='TestPassword123!',
    first_name='Test',
    last_name='User',
    user_type='BOTH'
)
print(f"Utilisateur créé: {user.email}")
```

### 4.2 Test côté Flutter

Créez un écran de test simple :

```dart
// lib/screens/test_auth_screen.dart
class TestAuthScreen extends StatefulWidget {
  @override
  _TestAuthScreenState createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final _emailController = TextEditingController(text: 'test@venturelink.com');
  final _passwordController = TextEditingController(text: 'TestPassword123!');
  
  Future<void> _testLogin() async {
    try {
      final credential = await FirebaseAuthService.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (credential != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion réussie!')),
        );
        
        // Test d'appel API
        final token = await FirebaseAuthService.getIdToken();
        print('Token obtenu: ${token?.substring(0, 50)}...');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Firebase Auth')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testLogin,
              child: Text('Test Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔍 Étape 5 : Débogage et Résolution de problèmes

### 5.1 Vérifications côté Django

```bash
# Vérifier les logs Django
python manage.py runserver

# Dans une autre console, tester l'API
curl -H "Authorization: Bearer YOUR_FIREBASE_TOKEN" \
     http://127.0.0.1:8000/api/v1/projects/
```

### 5.2 Vérifications côté Flutter

```dart
// Ajouter des logs détaillés
Logger.debug('Firebase User: ${FirebaseAuth.instance.currentUser?.uid}');
Logger.debug('Token: ${await FirebaseAuthService.getIdToken()}');
```

### 5.3 Problèmes courants et solutions

| Problème | Solution |
|----------|----------|
| Token invalide | Vérifier la configuration Firebase dans Django |
| 401 Unauthorized | S'assurer que le token est bien envoyé dans l'en-tête |
| CORS Error | Ajouter l'origine Flutter dans CORS_ALLOWED_ORIGINS |
| Firebase not initialized | Vérifier l'initialisation dans main.dart |

---

## 🚀 Étape 6 : Passage en production

### 6.1 Configuration production Django

```python
# settings.py (production)
FIREBASE_DEV_MODE = False
DEBUG = False

# Permissions plus strictes
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
}
```

### 6.2 Configuration production Flutter

```dart
// Utiliser les vraies URLs de production
static const String baseUrl = 'https://api.venturelink.com/api/v1';
```

---

## ✅ Checklist finale

- [ ] Firebase projet configuré
- [ ] Service Account key téléchargée
- [ ] Variables d'environnement Django configurées
- [ ] Authentification Firebase Django créée
- [ ] Permissions personnalisées créées
- [ ] Champ firebase_uid ajouté au modèle User
- [ ] Service Firebase Flutter créé
- [ ] Intercepteur API configuré
- [ ] Tests d'authentification réussis
- [ ] API calls avec token fonctionnels

---

## 📞 Support

Si vous rencontrez des problèmes :

1. Vérifiez les logs Django et Flutter
2. Testez l'authentification étape par étape
3. Vérifiez la configuration Firebase Console
4. Assurez-vous que les clés sont correctes

Cette configuration vous permettra d'avoir une authentification Firebase complètement fonctionnelle entre Flutter et Django, avec un mode développement permissif et une sécurité renforcée en production. 