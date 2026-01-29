# 🤖 GitHub Copilot - Instructions Consolidées VentureLink
*Règles unifiées pour tous les agents AI travaillant sur le projet VentureLink*

**Dernière mise à jour:** 19 Janvier 2026  
**Version:** 2.1 (+ Règle Détection Boucles Infinies d'Auth)

---

## 📚 Table des Matières

1. [Contexte du Projet](#contexte-du-projet)
2. [Règles Fondamentales](#règles-fondamentales)
3. [Conventions et Normes Techniques](#conventions-et-normes-techniques)
4. [Architecture et Design](#architecture-et-design)
5. [Gestion d'État et Données](#gestion-détat-et-données)
6. [Processus de Développement](#processus-de-développement)
7. [Performance et Optimisation](#performance-et-optimisation)
8. [Sécurité et Authentification](#sécurité-et-authentification)
9. [Qualité du Code](#qualité-du-code)
10. [Documentation et Communication](#documentation-et-communication)

---

## 🎯 Contexte du Projet

### Qu'est-ce que VentureLink?
VentureLink est une **plateforme d'investissement participatif collaboratif** permettant:
- 👥 La création et la gestion de projets de financement
- 💰 L'investissement dans des projets innovants
- 🤖 Un matching IA intelligent entre investisseurs et porteurs de projets
- 💬 La messagerie directe et les échanges
- 📊 L'analyse et le suivi des investissements

### Stack Technologique Global

**Frontend:**
- Framework: Flutter 3.16.0+
- Langage: Dart 3.2.0+
- État: Provider 6.1.1+
- Réseau: Dio 5.3.2+ + Retrofit 4.0.3+
- Base de données locale: Shared Preferences + Hive
- Auth: Firebase Auth 4.15.3+
- Notifications: Firebase Messaging 14.7.9+
- Sécurité: Flutter Secure Storage 9.0.0+
- Internationalisation: i18n (fr/en)

**Backend:**
- Framework: Django REST Framework 3.14+
- Langage: Python 3.10+
- BD: PostgreSQL 13+
- Cache: Redis 7.0+
- Paiements: My-CoolPay API
- Authentification: JWT + Firebase
- Matching IA: Custom ML module

**Infrastructure:**
- Déploiement: Docker + Docker Compose
- CI/CD: GitHub Actions
- Monitoring: Sentry + ELK Stack

---

## ⚙️ Règles Fondamentales

### 1. Vérification de Conformité Pré-Actions
**TOUJOURS appliquer avant chaque réponse ou action:**

- ✅ La réponse/action suit l'ordre du **plan de développement** défini dans `doc_frontEnd/Plan_Dev_Frontend_VentureLink.txt`
- ✅ Conformité avec les **spécifications du projet** dans les fichiers de référence:
  - `doc_frontEnd/Architecture_FrontEnd_VentureLink.txt`
  - `doc_frontEnd/Charte_Graphique_VentureLink.txt`
  - `doc_frontEnd/Contrats_API_RESTFul_VentureLink.txt`
  - `doc_frontEnd/Conventions_et_Standards_VentureLink.txt`
  - `doc_frontEnd/doc_UI_VentureLink.txt`
  - `doc_frontEnd/Documentation_des_Services_Firebase_VentureLink.txt`
  - `doc_frontEnd/Flux_Intégration_VentureLink.txt`
  - `doc_frontEnd/Format_Données_Echangees_VentureLink.txt`
  - `contrat/GUIDE_HARMONISATION_FRONTEND_BACKEND_VENTURELINK_PHASE5_FINAL.md`
  - `contrat/MODELES_DONNEES_BACKEND_VENTURELINK_PHASE5_FINAL.md`

### 2. Vérification de Complétude Informationnelle
**Avant de répondre ou d'agir:**

- ✅ Disposez-vous de **toutes les informations** nécessaires pour une réponse/action pertinente et efficace?
- ⚠️ Si non, **posez les questions nécessaires** avant de procéder
- ✅ Vérifiez la disponibilité des références documentaires si besoin

### 3. Synthèse et Suivi de Progression
**Après chaque réponse ou action significative:**

- 📊 Fournissez une **synthèse claire** de ce qui a été fait
- 📋 Listez ce qui **reste à faire**
- ⚠️ Identifiez les **blocages potentiels**
- 🎯 Proposez les **prochaines étapes**

### 4. Réduction des Modifications Backend
**Prioriser une résolution frontend:**

- ✅ **Le meilleur cas:** Résolution sans modification backend
- ⚠️ Si des modifications backend sont nécessaires:
  - Présentez-les **de façon détaillée, précise et structurée**
  - Justifiez **chaque modification** proposée
  - Évaluez l'impact sur l'architecture globale

### 5. Multidevises et Localisation
**Pour tous les calculs financiers et affichages:**

- 💱 La devise affichée est **définie par les préférences/devise de l'utilisateur**
- 🌍 Support obligatoire des devises: EUR, XAF, USD
- 🗣️ Internationalisation **français (fr) et anglais (en)**
- 📍 Tous les textes doivent utiliser les clés i18n correspondantes

### 6. Environnement Virtual et Dépendances Python
**Pour les opérations backend/serveur:**

- 🐍 **TOUJOURS** travailler dans l'environnement virtuel Python du projet
- 🔐 Si PowerShell: Exécuter d'abord:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
  ```
- 📦 Installer les dépendances **dans le venv**, jamais globalement

### 7. Références Documentaires Spéciales

**My-CoolPay API:**
- 📄 Documentation: `doc_frontEnd/My-CoolPay API Docs.pdf`
- 🔑 Intégration obligatoire pour tous les paiements
- 💳 Support des plans: FREE, BASIC_MONTHLY, BASIC_YEARLY, PREMIUM_MONTHLY, PREMIUM_YEARLY

**Documents Critiques pour Harmonisation:**
- 📋 `API_CONTRACT.md` - Contrat API frontend-backend
- 🗂️ `DATA_MODELS.md` - Modèles de données partagés
- 🔌 `ENDPOINTS_REFERENCE.md` - Référence complète des endpoints
- 🔗 `FLUTTER_INTEGRATION_GUIDE.md` - Guide d'intégration Flutter
- 💰 `Implementation_Paiement_MyCoolPay.md` - Implémentation paiements

---

## 📋 Conventions et Normes Techniques

### 1. Nommage des Ressources API

**Endpoints REST:**
- Base URL: `/api/v1/`
- Format des routes: **Noms au pluriel en minuscules**
  - ✅ `/api/v1/projects`, `/api/v1/users`, `/api/v1/conversations`
  - ❌ `/api/v1/Project`, `/api/v1/user-profile`
- Paramètres de route: **kebab-case**
  - ✅ `/api/v1/user-ratings`, `/api/v1/investment-proposals`
- Query parameters: **snake_case**
  - ✅ `?sort_by=date&order_direction=desc&limit=20`
- Identifiants: **UUID obligatoires**
  - ✅ `/api/v1/projects/{uuid}/details`

### 2. Nommage Backend Django

**Modèles de données:**
- Classes modèles: **PascalCase** au singulier
  - ✅ `class User`, `class Project`, `class Investment`
- Champs de modèles: **snake_case**
  - ✅ `first_name`, `created_at`, `is_active`
- Relations: **snake_case avec noms explicites**
  - ✅ `project_owner`, `recipient_user`, `investor_user`
- Clés étrangères: **`<modele>_id`**
  - ✅ `user_id`, `project_id`, `conversation_id`

### 3. Nommage Frontend Flutter

**Widgets et Composants:**
- Classes: **PascalCase**
  - ✅ `ProjectCard`, `MessageListWidget`, `UserProfileScreen`
- Fichiers: **snake_case**
  - ✅ `project_card.dart`, `user_profile_screen.dart`

**Variables et Fonctions:**
- Noms de variables: **camelCase**
  - ✅ `projectsList`, `getUserProfile()`, `isLoading`
- Constantes globales: **UPPER_SNAKE_CASE**
  - ✅ `API_BASE_URL`, `DEFAULT_TIMEOUT`, `MAX_RETRIES`

**Assets:**
- Images: **snake_case avec préfixe descriptif**
  - ✅ `icon_home.png`, `img_profile_default.jpg`, `bg_splash.png`
- Polices: **snake_case**
  - ✅ `sf_pro_text_regular.ttf`, `roboto_medium.ttf`
- JSON: **snake_case**
  - ✅ `categories_list.json`, `countries_data.json`

### 4. Versionnement de l'API

**Stratégie:**
- **URL-based versioning**: `/api/v1/`, `/api/v2/`, etc.
- **Changements majeurs**: Nouvelle version (v2, v3)
- **Changements mineurs**: Compatibles avec version existante
- **Correctifs**: Déployés dans version existante

**Compatibilité:**
- Maintenir compatibilité pour **au moins 1 version majeure antérieure**
- **Jamais** supprimer un champ existant en version mineure
- Utiliser **dépreciation** avant suppression
  ```json
  {
    "id": "uuid-123",
    "name": "Nouveau",
    "title": "Ancien (déprécié, utiliser 'name')"
  }
  ```

### 5. Format des Erreurs API

**Structure standard normalisée:**
```json
{
  "error": {
    "status_code": 400,
    "error_code": "VALIDATION_ERROR",
    "message": "Les données fournies sont invalides.",
    "details": [
      {
        "field": "email",
        "message": "Adresse email déjà utilisée."
      }
    ]
  }
}
```

**Codes d'erreur normalisés:**

| Code | Description |
|------|-------------|
| `AUTHENTICATION_FAILED` | Échec d'authentification |
| `INVALID_CREDENTIALS` | Identifiants invalides |
| `TOKEN_EXPIRED` | Token expiré ou révoqué |
| `TOKEN_INVALID` | Token invalide ou malformé |
| `PERMISSION_DENIED` | Permission/autorisation insuffisante |
| `RESOURCE_NOT_FOUND` | Ressource inexistante |
| `VALIDATION_ERROR` | Erreur de validation des données |
| `RATE_LIMIT_EXCEEDED` | Limite de taux dépassée |
| `SUBSCRIPTION_REQUIRED` | Abonnement Premium requis |
| `LIMIT_REACHED` | Limite atteinte (projets, messages) |
| `RESOURCE_CONFLICT` | Conflit avec état actuel |
| `INTERNAL_SERVER_ERROR` | Erreur serveur interne |

**Codes HTTP appropriés:**

| Code | Cas d'usage |
|------|------------|
| 200 | Requête réussie |
| 201 | Ressource créée |
| 204 | Succès sans contenu (DELETE) |
| 400 | Erreur de validation |
| 401 | Authentification requise |
| 403 | Authentifié mais permission insuffisante |
| 404 | Ressource inexistante |
| 409 | Conflit de ressource |
| 422 | Données valides mais inutilisables |
| 429 | Trop de requêtes (rate limiting) |
| 500 | Erreur interne serveur |

---

## 🏗️ Architecture et Design

### 1. Architecture Frontend - MVVM

L'application Flutter suit une architecture **Model-View-ViewModel** stricte:

**Model Layer:**
- Représente les données
- Fichiers: `lib/data/models/*.dart`
- Utilise `@JsonSerializable()` pour sérialisation
- Inclut les méthodes `fromJson()`, `toJson()`, `fromMap()`

**Data Layer:**
- Accès aux données (API, BD locale, cache)
- Fichiers: `lib/data/services/`, `lib/data/providers/`
- Abstraction via repositories
- Gestion du cache et du stockage local

**Presentation Layer:**
- UI et logique d'affichage
- Fichiers: `lib/presentation/screens/`, `lib/presentation/widgets/`
- Utilise `Provider` pour state management
- Widgets réutilisables et composables

**ViewModel/Provider:**
- Logique métier et état
- Fichiers: `lib/data/providers/*.dart`
- Change notifier pour réactivité
- Pas de contexte Build direct

### 2. Séparation des Responsabilités (SoC)

**Principes stricts:**
- 🎯 Chaque classe/widget a **une seule responsabilité**
- 📦 Chaque dossier contient **un type de composant**
- 🔄 Flux unidirectionnel: Model → ViewModel → View
- ❌ Pas de logique métier dans les widgets
- ❌ Pas d'appels API directs dans UI

### 3. Testabilité et Dépendances

**Injection de dépendances:**
- Utiliser **GetIt** pour la registration des dépendances
- Fichier: `lib/core/injection/service_locator.dart`
- Enregistrer tous les services et repositories

**Exemple:**
```dart
void setupServiceLocator() {
  // Services
  getIt.registerSingleton<DioClient>(DioClient());
  getIt.registerSingleton<AuthService>(AuthService(getIt<DioClient>()));
  
  // Repositories
  getIt.registerSingleton<ProjectRepository>(
    ProjectRepository(getIt<DioClient>()),
  );
  
  // Providers
  getIt.registerSingleton<ProjectProvider>(
    ProjectProvider(getIt<ProjectRepository>()),
  );
}
```

### 4. Maintenabilité et Évolution

**Principes:**
- 📝 Code auto-documenté avec noms explicites
- 💬 Commentaires pour les logiques complexes
- 🔗 Structure modulaire pour évolution facile
- ⚠️ Gestion d'erreurs cohérente
- 🧪 Tests couvrant logic critique (>80%)

---

## 🗂️ Gestion d'État et Données

### 1. Pattern Provider Recommandé

**Structure d'un Provider:**
```dart
class ProjectProvider extends ChangeNotifier {
  final ProjectRepository _repository;
  
  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<ProjectModel> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  ProjectProvider(this._repository);
  
  // Actions
  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _projects = await _repository.getProjects();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 2. Modèles de Données

**Règles obligatoires:**
- ✅ Implémenter `@JsonSerializable()`
- ✅ `factory.fromJson()` pour désérialisation API
- ✅ `Map toJson()` pour sérialisation
- ✅ `factory.fromMap()` pour conversion interne
- ✅ Typage strict (pas de `dynamic`)
- ✅ Validation dans constructeur si nécessaire

**Exemple complet:**
```dart
import 'package:json_annotation/json_annotation.dart';

part 'project_model.g.dart';

@JsonSerializable()
class ProjectModel {
  final String id;
  final String title;
  final String? description;
  final double fundingGoal;
  final double fundingRaised;
  final ProjectStatus status;
  final DateTime createdAt;
  
  ProjectModel({
    required this.id,
    required this.title,
    this.description,
    required this.fundingGoal,
    required this.fundingRaised,
    required this.status,
    required this.createdAt,
  });
  
  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProjectModelToJson(this);
  
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      fundingGoal: (map['funding_goal'] as num).toDouble(),
      fundingRaised: (map['funding_raised'] as num).toDouble(),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.draft,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

enum ProjectStatus { draft, published, funded, archived }
```

### 3. Cache et Stockage Local

**Stratégies de cache:**

**Memory Cache (Temporaire):**
- Données chaudes utilisées fréquemment
- Durée: Session ou 15 minutes
- Exemple: Liste des projets actuels

**Shared Preferences (Persistant simple):**
- Petites données: Tokens, préférences utilisateur
- TTL: Jusqu'à révocation
- Exemple: Token JWT, devise préférée

**Hive (Persistant structuré):**
- Données complexes: Historique, caches
- TTL: Configurable
- Exemple: Cache de recherche, historique messages

**Redis (Backend):**
- Cache côté serveur pour données partagées
- TTL: 15 minutes par défaut
- Exemple: Listes de projets, statistiques

---

## 🔄 Processus de Développement

### 1. Workflow Recommandé

**Pour chaque feature:**

1. **Analyse** - Lire les spécifications et documents
2. **Planning** - Décomposer en tâches et identifier dépendances
3. **Design** - Esquisser l'architecture et les modèles
4. **Implémentation** - Code en suivant les conventions
5. **Test** - Tests unitaires, d'intégration, manuels
6. **Documentation** - Commentaires et mise à jour docs
7. **Review** - Auto-vérification contre les règles

### 2. Ordre de Développement

**Phase 1 - Fondations (Semaines 1-2):**
- ✅ Configuration Flutter complète
- ✅ Modèles de données pour authentification
- ✅ Service d'authentification Firebase
- ✅ Écran de login/register

**Phase 2 - Core Features (Semaines 3-4):**
- ✅ Gestion des projets (CRUD)
- ✅ Interface de découverte
- ✅ Système de matching IA

**Phase 3 - Paiements et Abonnements (Semaines 5-6):**
- ✅ Intégration My-CoolPay
- ✅ Gestion des plans d'abonnement
- ✅ Multi-devises

**Phase 4 - Polissage (Semaine 7+):**
- ✅ Optimisations performance
- ✅ Tests complets
- ✅ Documentation finale

### 3. Gestion des Versions

**Tags de version:**
```
v1.0.0-alpha.1    # Version alpha initiale
v1.0.0-beta.1     # Version beta pour testing
v1.0.0-rc.1       # Release candidate
v1.0.0             # Production release
```

**Branches:**
- `main` - Production, releases seulement
- `develop` - Développement principal
- `feature/*` - Features spécifiques
- `bugfix/*` - Corrections de bugs
- `release/*` - Branches de release

---

## ⚡ Performance et Optimisation

### 1. Optimisations Requises

**Lazy Loading:**
```dart
// Charger les données seulement quand nécessaire
@MaterialAutoRouter(
  routes: <AutoRoute>[
    AutoRoute(path: '/', page: SplashScreen, initial: true),
    AutoRoute(path: '/login', page: LoginScreen),
    AutoRoute(
      path: '/main',
      page: MainScreen,
      children: [
        AutoRoute(path: 'home', page: HomeScreen, initial: true),
        AutoRoute(path: 'discover', page: DiscoverScreen),
        // Lazy loading pour routes secondaires
        AutoRoute(path: '/project/:id', page: ProjectDetailScreen),
      ],
    ),
  ],
)
class $AppRouter {}
```

**Optimisation des Images:**
- Compression avant upload (max 85% qualité)
- Cache des images téléchargées (CachedNetworkImage)
- Dimensions limites: max 1080x1920 px
- Support WebP si possible

**Gestion des Requêtes:**
- Pagination obligatoire (20-50 items par page)
- Debouncing sur les recherches (300ms)
- Throttling sur scroll events
- Cancel requests quand écran fermé

**Build Optimizations:**
- Utiliser `const` constructors au maximum
- Réduire nombre de rebuilds avec `RepaintBoundary`
- Lazy initialization de providers complexes
- Profilage avec Dart DevTools

### 2. Cibles de Performance

- ⚡ **Temps de démarrage**: < 2 secondes
- 🎯 **Temps de chargement page**: < 1 seconde
- 📱 **Mémoire**: < 150 MB en usage normal
- 🔋 **Batterie**: Impact minimal sur durée

### 3. Monitoring et Debugging

- 📊 Firebase Analytics pour tracking usage
- 🐛 Sentry pour crash reporting
- ⏱️ Performance monitoring avec Dart DevTools
- 🔍 Network profiling avec Proxyman/Charles

---

## 🔒 Sécurité et Authentification

### 1. Authentification JWT

**Format du token:**
```
Authorization: Bearer <jwt_token>
```

**Durée de validité:**
- Access Token: 1 heure
- Refresh Token: 2 semaines
- Session: Jusqu'à logout

**Stockage:**
- ❌ **JAMAIS** en SharedPreferences plain text
- ✅ Flutter Secure Storage (encrypted)
- ✅ Secured par Keychain (iOS) / Keystore (Android)

### 2. Firebase Authentication

**Méthodes supportées:**
- Email/Password
- Google Sign-In
- Apple Sign-In (iOS)

**Configuration obligatoire:**
```dart
firebase_auth: ^4.15.3
firebase_core: ^2.24.0
google_sign_in: ^6.1.0
sign_in_with_apple: ^5.0.0  // iOS
```

### 3. CSRF Protection

**Pour requêtes modifiant les données:**

Header requis:
```
X-CSRFToken: <token>
```

**Workflow:**
1. Frontend demande token CSRF
2. Backend retourne token
3. Frontend inclut token dans headers POST/PUT/DELETE

### 4. Données Sensibles

**JAMAIS** retourner/stocker:
- ❌ Mots de passe en clair
- ❌ Tokens de sécurité complets
- ❌ Numéros de carte bancaire
- ❌ Clés API complètes

**Masquage sensible:**
```json
{
  "card_number": "****-****-****-1234",
  "email": "user***@email.com",
  "phone": "+33 6 ** ** ** **"
}
```

### 5. Validation et Sanitization

**Frontend:**
```dart
// Validation email
final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

// Validation password (min 8 chars, 1 upper, 1 digit, 1 special)
final passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

// Validation URL
final urlRegex = RegExp(r'^https?://');
```

**Backend:**
- Validation stricte sur tous les inputs
- Sanitization HTML/SQL
- Rate limiting par IP/user
- Logging des tentatives suspectes

---

## 📝 Qualité du Code

### 1. Style de Code

**Règles Dart/Flutter:**
- ✅ Suivre Dart Style Guide
- ✅ Utiliser `dart format` (100 chars max)
- ✅ Utiliser `dart analyze` avant commit
- ✅ Zéro avertissement ou erreur

**Code Analysis:**
```bash
# Formater le code
dart format lib/

# Analyser la qualité
dart analyze lib/

# Test de couverture
dart test --coverage=coverage
```

### 2. Commentaires et Documentation

**Niveaux de commentaires:**

```dart
/// Documentation publique pour une fonction (/// ou /** */)
/// 
/// Décrit le comportement, paramètres, et valeurs de retour
/// Visible dans IDE et documentation générée
/// 
/// Exemple:
/// ```dart
/// final projects = await repository.getProjects();
/// ```
Future<List<ProjectModel>> getProjects() async { }

// Commentaire simple pour une ligne de logique
if (isLoading) return Center(child: CircularProgressIndicator());

/* Commentaire multi-ligne pour expliquer
   une logique complexe ou des décisions
   architecturales */
var complexResult = calculateSomething();
```

### 3. Nommage Explicite

**Principes:**
- ✅ Noms descriptifs et compréhensibles
- ✅ Pas d'abréviations sauf si ultra-communes (API, HTTP)
- ✅ Longueur de nom proportionnelle à scope
- ✅ Verbes pour actions, noms pour données

**Exemples:**
```dart
// ✅ BON
Future<List<ProjectModel>> fetchActiveProjects() { }
bool isProjectOwner(String projectId, String userId) { }
class ProjectDetailViewModel { }

// ❌ MAUVAIS
Future<List<ProjectModel>> getProj() { }
bool chkOwn(String pid, String uid) { }
class PDVModel { }
```

### 4. Gestion des Erreurs

**Pattern try-catch robuste:**
```dart
try {
  final result = await repository.fetchData();
  // Process result
} on TimeoutException catch (e) {
  // Gestion timeout spécifique
  handleTimeoutError(e);
} on AuthenticationException catch (e) {
  // Gestion auth spécifique
  handleAuthError(e);
} on SocketException catch (e) {
  // Gestion réseau spécifique
  handleNetworkError(e);
} catch (e, stackTrace) {
  // Gestion générale + logging
  logError(e, stackTrace);
  rethrow;
}
```

### 5. Élimination de Code Mort

- ❌ Pas de code commenté (utiliser git history)
- ❌ Pas d'imports inutilisés (dart analyze détecte)
- ❌ Pas de variables non utilisées
- ❌ Pas de fonctions privées jamais appelées

---

## 📚 Documentation et Communication

### 1. Format de Documentation

**Dans les fichiers de code:**
```dart
/// Service pour gérer l'authentification avec Firebase
/// 
/// Responsabilités:
/// - Création de comptes utilisateur
/// - Connexion/déconnexion
/// - Gestion des tokens JWT
/// - Refresh des tokens expirés
/// 
/// Exceptions levées:
/// - [AuthenticationException] - Erreur d'authentification
/// - [FirebaseException] - Erreur Firebase
class AuthService {
  /// Authentifie un utilisateur avec email/password
  /// 
  /// Retourne un [AuthResponse] contenant:
  /// - [user] - Données utilisateur
  /// - [accessToken] - JWT pour requêtes API
  /// - [refreshToken] - Token pour renouvellement
  /// 
  /// Lève [AuthenticationException] si credentials invalides
  Future<AuthResponse> login(String email, String password) async { }
}
```

### 2. Changelog et Versioning

**Format du Changelog:**
```markdown
## v1.2.0 (2026-01-20)

### ✨ Nouvelles Fonctionnalités
- Ajout endpoint `/projects/{id}/analytics`
- Matching IA avec critères personnalisés
- Export de données en CSV

### 🔧 Modifications
- Amélioration performance recherche (x2 plus rapide)
- Meilleure gestion des erreurs réseau
- UI polish sur écran de profil

### 🐛 Corrections
- Correction bug date de création projets
- Correction affichage devises multiples
- Correction crash sur écran notifications

### 📦 Dépendances
- Mise à jour dio: 5.2.0 → 5.3.2
- Mise à jour provider: 6.0.0 → 6.1.1
- Ajout cached_network_image: 3.3.0
```

### 3. Format des Commits

**Convention Commits:**
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat:` Nouvelle feature
- `fix:` Correction bug
- `docs:` Changement documentation
- `style:` Formatage, conventions
- `refactor:` Refactoring code sans changement behavior
- `perf:` Amélioration performance
- `test:` Ajout/modification tests
- `chore:` Mise à jour dépendances, config

**Exemples:**
```
feat(auth): implement JWT token refresh

- Ajouter méthode refreshToken() dans AuthService
- Implémenter auto-refresh avant expiration
- Ajouter tests unitaires (95% couverture)

Closes #123
```

### 4. Synergies Frontend-Backend

**Documentation à maintenir à jour:**
- API Contract détaillant tous les endpoints
- Modèles de données partagés (JSON Schema)
- Erreurs API normalisées
- Changelogs synchronisés

**Réunions de synchronisation:**
- 🤝 Hebdomadaires pour nouvelles features
- 🔄 Bi-hebdomadaires pour breaking changes
- 📊 Mensuelles pour planification

---

## 🔥 Best Practices Spécifiques VentureLink

### 1. Authentification Multicanal

**Support obligatoire:**
- Email/Password (backend)
- Firebase Auth (Google, Apple)
- Fallback JWT si Firebase indisponible

**Flow recommandé:**
```
1. Tentative Firebase Auth
   ↓
2. Fallback vers JWT local
   ↓
3. Si JWT expiré → Refresh token
   ↓
4. Si refresh échoue → Re-login requis
```

### 2. Gestion des Plans d'Abonnement

**Plans existants:**
- `FREE` - Gratuit, limites par défaut
- `BASIC_MONTHLY` - 5 projets, mensuel
- `BASIC_YEARLY` - 5 projets, annuel
- `PREMIUM_MONTHLY` - Illimité, mensuel
- `PREMIUM_YEARLY` - Illimité, annuel

**Vérification permissions:**
```dart
// Avant chaque action nécessitant premium
if (!userProvider.subscription.isActive || 
    !userProvider.subscription.isPremium) {
  showPremiumRequiredDialog();
  return;
}
```

### 3. Matching IA

**Critères de matching:**
- Domaine d'expertise utilisateur
- Secteur projet (FINTECH, TECH, etc.)
- Montant d'investissement toléré
- Localisation géographique préférée
- Risque toléré (LOW, MEDIUM, HIGH)

**API Matching:**
```
GET /api/v1/matching/recommendations/
  - Retourne projets recommandés avec score 0.0-1.0
  - Top matching selon profil utilisateur
  
POST /api/v1/matching/feedback/
  - User feedback pour amélioration IA
  - Interaction signals (like, dislike, contact)
```

### 4. Système de Notifications

**Types de notifications:**
- 💬 Messages reçus
- 📢 Interactions sur projet
- 💰 Mises à jour investissements
- 📊 Alertes analytiques
- 🎯 Recommandations matching

**Push Notifications:**
- Firebase Messaging obligatoire
- Support offline (show when app opens)
- Categorization pour filtrer

### 5. Multi-Devises

**Conversion dynamique:**
```dart
// Service de conversion
class CurrencyService {
  /// Convertir montant d'une devise à une autre
  /// Support: EUR, XAF, USD
  Future<double> convert(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async { }
  
  /// Afficher montant avec devise appropriée
  String formatWithCurrency(double amount, String currency) {
    // Exemple: 1000 EUR → "1 000,00 €"
  }
}
```

**Taux de change:**
- ✅ Mis à jour toutes les heures
- ✅ Cache local pour offline
- ✅ Utiliser API My-CoolPay pour taux officiels

---

## 🚨 Checklist de Vérification Pré-Commit

**Avant chaque commit:**

- [ ] ✅ `dart format` appliqué
- [ ] ✅ `dart analyze` 0 erreur/warning
- [ ] ✅ Tests unitaires passent (>80% couverture)
- [ ] ✅ Pas d'imports inutilisés
- [ ] ✅ Pas de code commenté/mort
- [ ] ✅ Documentation (comments + docs)
- [ ] ✅ Conventions de nommage respectées
- [ ] ✅ Gestion d'erreurs complète
- [ ] ✅ Pas de secrets en dur (API keys, etc.)
- [ ] ✅ Compatible avec doc de harmonisation
- [ ] ✅ Pas de breaking changes non documentés
- [ ] ✅ Commit message suit convention

---

## 📞 Support et Escalade

**Pour questions/blocages:**

1. **Vérifiez d'abord:**
   - Documentation du projet
   - Commandes `dart analyze`
   - Logs et stack traces
   - Exemples de code existant

2. **Si blocage persiste:**
   - Documentez le problème précisément
   - Fournissez code minimal reproduisant
   - Mentionnez document de référence utilisé

3. **Escalade Backend si nécessaire:**
   - Proposez modification détaillée et justifiée
   - Analysez impact sur architecture
   - Mettez à jour documentation d'harmonisation

---

## 📞 Contact et Escalades

**Pour modifier ces règles:**
- 📧 Discuter des changements pertinents
- 🔄 Mettre à jour ce fichier centralisé
- 📢 Communiquer aux équipes

**Fichier source:** `.github/copilot-instructions.md`

---

**Version:** 2.0 (Consolidée)  
**Dernière mise à jour:** 17 Janvier 2026  
**Statut:** ✅ Actif et appliqué

*Ces règles s'appliquent à tous les agents AI (GitHub Copilot, Claude, etc.) travaillant sur le projet VentureLink. Elles sont obligatoires et doivent être respectées pour assurer la qualité et la cohérence du projet.*
