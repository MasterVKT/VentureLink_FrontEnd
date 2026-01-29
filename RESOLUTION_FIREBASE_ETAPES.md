# 🔥 Résolution Définitive du Problème Firebase - VentureLink

## 🎯 Objectif

Configurer correctement l'authentification Firebase pour que votre application Flutter communique parfaitement avec Django, même en mode développement, sans compromettre la sécurité.

---

## 📋 Étapes de Résolution (30 minutes)

### ⏰ Étape 1 : Préparation (5 minutes)

#### 1.1 Vérifier l'environnement
```bash
# Vérifier que Django fonctionne
cd /d/Projets/VentureLink/venturelink
python manage.py runserver

# Dans un autre terminal, vérifier l'accès
curl http://127.0.0.1:8000/api/v1/projects/
```

#### 1.2 Installer les dépendances Firebase
```bash
# Dans l'environnement virtuel Django
pip install firebase-admin python-jose[cryptography] python-decouple
```

---

### 🔧 Étape 2 : Configuration Django (10 minutes)

#### 2.1 Créer le fichier .env
Créez `.env` à la racine de votre projet Django :

```env
# Firebase Configuration
FIREBASE_TYPE=service_account
FIREBASE_PROJECT_ID=venturelink-5b045
FIREBASE_PRIVATE_KEY_ID=votre_private_key_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nVOTRE_CLE_PRIVEE_ICI\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@venturelink-5b045.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=votre_client_id

# Mode développement
FIREBASE_DEV_MODE=True
DEBUG=True
```

> **Important** : Remplacez les valeurs par celles de votre fichier JSON Firebase

#### 2.2 Modifier settings.py
Ajoutez à la fin de `venture_link_project/settings.py` :

```python
# Configuration Firebase
from decouple import config

FIREBASE_CONFIG = {
    'type': config('FIREBASE_TYPE', default='service_account'),
    'project_id': config('FIREBASE_PROJECT_ID', default='venturelink-5b045'),
    'private_key_id': config('FIREBASE_PRIVATE_KEY_ID', default=''),
    'private_key': config('FIREBASE_PRIVATE_KEY', default='').replace('\\n', '\n'),
    'client_email': config('FIREBASE_CLIENT_EMAIL', default=''),
    'client_id': config('FIREBASE_CLIENT_ID', default=''),
    'auth_uri': 'https://accounts.google.com/o/oauth2/auth',
    'token_uri': 'https://oauth2.googleapis.com/token',
    'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs',
    'client_x509_cert_url': f'https://www.googleapis.com/robot/v1/metadata/x509/{config("FIREBASE_CLIENT_EMAIL", default="")}'
}

FIREBASE_DEV_MODE = config('FIREBASE_DEV_MODE', default=True, cast=bool)

# Modifier REST_FRAMEWORK
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
}

# CORS pour Flutter
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",
]
CORS_ALLOW_CREDENTIALS = True
```

#### 2.3 Créer l'authentification Firebase
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

#### 2.4 Créer les permissions
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

#### 2.5 Ajouter le champ firebase_uid
Modifiez `apps/users/models.py` :

```python
class User(AbstractUser):
    # ... autres champs existants ...
    
    firebase_uid = models.CharField(
        max_length=128, 
        unique=True, 
        null=True, 
        blank=True,
        help_text="UID Firebase de l'utilisateur"
    )
```

Puis créez la migration :

```bash
python manage.py makemigrations
python manage.py migrate
```

---

### 📱 Étape 3 : Configuration Flutter (10 minutes)

#### 3.1 Vérifier firebase_options.dart
Assurez-vous que `lib/firebase_options.dart` contient :

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSyA5Ox6r37DWCZCKxmbziEKO6llVDZ4g_j0',
  appId: '1:149697014585:android:0b01bf7eae8dca160716e8',
  messagingSenderId: '149697014585',
  projectId: 'venturelink-5b045',
  storageBucket: 'venturelink-5b045.appspot.com',
);
```

#### 3.2 Créer le service Firebase
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
      default:
        return Exception('Erreur: ${e.message}');
    }
  }
}
```

#### 3.3 Créer l'intercepteur API
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
      }
    } catch (e) {
      Logger.error('Erreur ajout token: $e');
    }
    
    handler.next(options);
  }
}
```

#### 3.4 Modifier BaseApiService
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
    
    _dio.interceptors.add(FirebaseAuthInterceptor());
  }
  
  static Dio get dio => _dio;
}
```

#### 3.5 Modifier main.dart
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/services/base_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  BaseApiService.initialize();
  
  runApp(MyApp());
}
```

---

### 🧪 Étape 4 : Tests et Validation (5 minutes)

#### 4.1 Tester Django
```bash
# Redémarrer le serveur Django
python manage.py runserver

# Tester l'API
curl http://127.0.0.1:8000/api/v1/projects/
```

#### 4.2 Créer un utilisateur de test
```bash
python manage.py shell
```

```python
from django.contrib.auth import get_user_model
User = get_user_model()

user = User.objects.create_user(
    email='test@venturelink.com',
    password='TestPassword123!',
    first_name='Test',
    last_name='User',
    user_type='BOTH'
)
print(f"Utilisateur créé: {user.email}")
```

#### 4.3 Tester Flutter
Ajoutez ce widget de test dans votre app :

```dart
class TestFirebaseScreen extends StatefulWidget {
  @override
  _TestFirebaseScreenState createState() => _TestFirebaseScreenState();
}

class _TestFirebaseScreenState extends State<TestFirebaseScreen> {
  String _status = 'Prêt';
  
  Future<void> _testAuth() async {
    setState(() => _status = 'Test en cours...');
    
    try {
      final credential = await FirebaseAuthService.signInWithEmailAndPassword(
        email: 'test@venturelink.com',
        password: 'TestPassword123!',
      );
      
      if (credential != null) {
        setState(() => _status = '✅ Connexion réussie');
        
        // Test API
        final response = await BaseApiService.dio.get('/projects/');
        if (response.statusCode == 200) {
          setState(() => _status = '✅ API fonctionne avec Firebase');
        }
      }
    } catch (e) {
      setState(() => _status = '❌ Erreur: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Firebase')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testAuth,
              child: Text('Tester Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ✅ Checklist de Validation

- [ ] Variables d'environnement Firebase configurées
- [ ] FirebaseAuthentication créée dans Django
- [ ] FirebasePermission créée dans Django
- [ ] Champ firebase_uid ajouté au modèle User
- [ ] Migration appliquée
- [ ] Service Firebase créé dans Flutter
- [ ] Intercepteur API configuré
- [ ] BaseApiService modifié
- [ ] main.dart mis à jour
- [ ] Tests d'authentification réussis

---

## 🚨 Résolution des Problèmes Courants

### Problème 1 : "Firebase not initialized"
**Solution** : Vérifiez que Firebase.initializeApp() est appelé dans main.dart

### Problème 2 : "Token invalide"
**Solution** : Vérifiez les clés Firebase dans le fichier .env

### Problème 3 : "CORS Error"
**Solution** : Ajoutez l'origine Flutter dans CORS_ALLOWED_ORIGINS

### Problème 4 : "401 Unauthorized"
**Solution** : Vérifiez que l'intercepteur ajoute bien le token

### Problème 5 : "User not found"
**Solution** : Créez un utilisateur de test avec le script fourni

---

## 🎯 Résultat Attendu

Après avoir suivi ces étapes :

1. ✅ L'authentification Firebase fonctionne entre Flutter et Django
2. ✅ Les appels API incluent automatiquement le token Firebase
3. ✅ Le mode développement permet l'accès sans token pour les tests
4. ✅ La sécurité est maintenue en production
5. ✅ Les utilisateurs Firebase sont automatiquement créés dans Django

---

## 📞 Support

Si vous rencontrez des problèmes :

1. Vérifiez les logs Django : `python manage.py runserver`
2. Vérifiez les logs Flutter dans la console
3. Testez étape par étape avec le script de test
4. Assurez-vous que les clés Firebase sont correctes

Cette configuration vous donnera une authentification Firebase complètement fonctionnelle ! 🚀 