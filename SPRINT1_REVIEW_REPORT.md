# 🔍 CODE REVIEW — SPRINT 1
## VentureLink FrontEnd — Analyse par rapport aux User Stories

**Date :** 24 Février 2026  
**Reviewer :** Kilo Code (Expert Flutter Senior)  
**Statut global :** ⚠️ **PARTIELLEMENT CONFORME** — Fondations solides, mais plusieurs critères d'acceptation non remplis

---

## 📊 TABLEAU DE BORD GLOBAL

| User Story | Titre | Statut | Complétude |
|------------|-------|--------|------------|
| **US1.1** | Liste des projets fonctionnelle | ⚠️ Partiel | ~55% |
| **US1.2** | Recherche et filtres | ❌ Incomplet | ~30% |
| **US1.3** | Upload médias projets | ✅ Bon | ~80% |
| **US1.4** | Système de favoris UI | ⚠️ Partiel | ~60% |
| **US1.5** | Optimisation backend projets | ✅ Bon | ~75% |
| **US1.6** | Tests et corrections | ⚠️ Partiel | ~65% |

---

## 📋 US1.1 — Liste des Projets Fonctionnelle

### ✅ Ce qui est fait

#### Tâche 1.1.1 — Widget `ProjectCard` (`lib/presentation/widgets/project_card.dart`)
- ✅ Widget `ProjectCard` créé et fonctionnel
- ✅ `CachedNetworkImage` utilisé pour le cache des images
- ✅ Placeholder avec icône si pas d'image
- ✅ Corner radius 12px en haut seulement (`BorderRadius.vertical`)
- ✅ Titre sur 1 ligne avec `overflow: TextOverflow.ellipsis`
- ✅ Description sur 2 lignes max avec ellipsis
- ✅ Barre de progression (`LinearProgressIndicator`)
- ✅ Chips catégorie + localisation
- ✅ `InkWell` avec `borderRadius` pour le ripple effect
- ✅ Badge "Vérifié" (remplace le bouton favoris dans cette implémentation)

#### Tâche 1.1.3 — Skeleton Loaders (`lib/presentation/widgets/skeleton/project_card_skeleton.dart`)
- ✅ `ProjectCardSkeleton` créé avec `shimmer`
- ✅ Un seul `Shimmer.fromColors` englobant (meilleure approche — effet synchronisé)
- ✅ `_SkeletonBox` réutilisable
- ✅ `FractionallySizedBox` pour la ligne 70% (corrige le bug `double.infinity * 0.7`)
- ✅ `ProjectCardSkeletonList` avec `count` configurable
- ✅ Mimique bien la structure du `ProjectCard`

#### Tâche 1.1.5 — États et Erreurs
- ✅ `ErrorStateWidget` créé (`lib/presentation/widgets/states/error_state_widget.dart`)
- ✅ `EmptyStateWidget` créé (`lib/presentation/widgets/states/empty_state_widget.dart`)
- ✅ `LoadingStateWidget` créé (`lib/presentation/widgets/states/loading_state_widget.dart`)
- ✅ Messages d'erreur en français
- ✅ Bouton "Réessayer" avec `FilledButton.icon`
- ✅ `errorBuilder` dans `EmptyStateWidget` si l'image asset est manquante
- ✅ Helpers `_getErrorMessage()` et `_getErrorIcon()` dans `ProjectListScreen`

#### Tâche 1.1.4 — API Backend (`lib/data/services/project_api_service.dart`)
- ✅ `getProjects()` avec paramètres `page`, `page_size`, `search`, `category`, `stage`, `location`, `funding_min`, `funding_max`
- ✅ Gestion des erreurs Dio avec extraction du message d'erreur
- ✅ Cas spécial 404 sur page > 1 (fin de pagination)
- ✅ `ProjectProvider` avec `loadProjects()`, `loadProject()`, `toggleFavorite()`

---

### ❌ Ce qui manque / est incorrect

#### Tâche 1.1.1 — `ProjectCard` — Problèmes critiques

**1. Bouton favoris absent dans `ProjectCard`**
```dart
// ❌ MANQUANT dans lib/presentation/widgets/project_card.dart
// Le sprint demande :
final VoidCallback? onFavoriteToggle;  // ← paramètre absent
// Et dans _buildTitleRow() : icône cœur rouge/vide selon état favori
```
Le `ProjectCard` n'a pas de paramètre `onFavoriteToggle` ni d'icône cœur. Il affiche un badge "Vérifié" à la place, ce qui ne correspond pas aux specs.

**2. Montants hardcodés à `0€`**
```dart
// ❌ lib/presentation/widgets/project_card.dart:222-228
const Text(
  '0€', // TODO: Implémenter la propriété fundingRaised
  ...
),
// Et ligne 245-247 :
const Text(
  '0%', // TODO: Calculer avec les vraies valeurs
  ...
),
```
Le modèle `ProjectModel` a pourtant un getter `fundingRaised` (ligne 489-490 de `project_model.dart`). Ces TODO doivent être résolus.

**3. Devise hardcodée en `€` au lieu de XAF**
```dart
// ❌ lib/presentation/widgets/project_card.dart:323-330
String _formatAmount(double amount) {
  return '${(amount / 1000000).toStringAsFixed(1)}M€'; // ← € hardcodé
}
```
Le sprint spécifie le format `"X XAF collecté sur Y XAF"`. La devise doit être dynamique (EUR, XAF, USD selon préférences utilisateur).

**4. Hauteur image 180px au lieu de 200px**
```dart
// ⚠️ lib/presentation/widgets/project_card.dart:33-35
SizedBox(
  height: 180, // ← Sprint demande 200px
  ...
),
```

#### Tâche 1.1.2 — Pagination infinie — **NON IMPLÉMENTÉE**

```dart
// ❌ lib/presentation/screens/project/project_list_screen.dart
// Le sprint demande infinite_scroll_pagination avec PagingController
// L'implémentation actuelle utilise un simple ListView.builder
// sans pagination automatique au scroll
```

**Problèmes majeurs :**
- ❌ `PagingController` absent — le package `infinite_scroll_pagination` est dans `pubspec.yaml` mais **non utilisé** dans `ProjectListScreen`
- ❌ `PagedListView` absent — utilise `ListView.builder` simple
- ❌ Pas de chargement automatique au scroll (infinite scroll)
- ❌ `ProjectListScreen` est un `StatelessWidget` — doit être `StatefulWidget` pour gérer `PagingController`
- ❌ Pull-to-refresh présent mais ne réinitialise pas la pagination
- ❌ Pas de loader "page suivante" en bas de liste
- ❌ `ProjectCard` non utilisé dans `ProjectListScreen` — utilise `ListTile` à la place !

```dart
// ❌ lib/presentation/screens/project/project_list_screen.dart:59-65
itemBuilder: (context, index) {
  final project = projectProvider.projects[index];
  return ListTile(  // ← Devrait être ProjectCard !
    title: Text(project.title),
    subtitle: Text(project.shortDescription),
    ...
  );
},
```

**Critères d'acceptation non remplis :**
- ❌ La liste n'affiche pas 20 projets par page (pas de pagination)
- ❌ Pagination infinie non fonctionnelle
- ❌ `ProjectCard` non utilisé dans la liste
- ❌ Performance non optimisée (pas de `const` constructors)

---

## 📋 US1.2 — Recherche et Filtres

### ✅ Ce qui est fait

- ✅ `AdvancedSearchScreen` existe (`lib/presentation/screens/search/advanced_search_screen.dart`) avec filtres catégorie, stage, localisation, budget
- ✅ `ProjectApiService.getProjects()` accepte les paramètres de recherche et filtres
- ✅ `VentureSearchField` widget commun disponible

### ❌ Ce qui manque

**Tâche 1.2.1 — Barre de recherche dans `ProjectListScreen`**
```dart
// ❌ ABSENT dans lib/presentation/screens/project/project_list_screen.dart
// Pas de barre de recherche dans l'AppBar
// Pas d'icône search/close
// Pas de debounce 300ms
// Pas de TextField dans l'AppBar
```

**Tâche 1.2.2 — `FilterBottomSheet`**
```dart
// ❌ FICHIER ABSENT
// lib/presentation/widgets/filter_bottom_sheet.dart n'existe pas
// lib/data/models/project_filters.dart n'existe pas
```
Le modèle `ProjectFilters` et le widget `FilterBottomSheet` sont **entièrement absents**. L'`AdvancedSearchScreen` existe mais n'est pas intégré dans `ProjectListScreen`.

**Tâche 1.2.3 — Chips filtres actifs**
```dart
// ❌ ABSENT dans ProjectListScreen
// Pas de chips pour les filtres actifs
// Pas de compteur de résultats
// Pas de bouton "Effacer tout"
```

**Tâche 1.2.4 — Intégration filtres dans API call**
```dart
// ❌ ABSENT dans ProjectProvider
// fetchProjects() ne prend pas de ProjectFilters en paramètre
// Les méthodes searchProjects() et filterByCategory() 
// appellent juste loadProjects(forceRefresh: true) sans passer les paramètres !
```

```dart
// ❌ lib/data/providers/project_provider.dart:359-366
Future<void> searchProjects(String query) async {
  await loadProjects(forceRefresh: true); // ← query ignorée !
}

Future<void> filterByCategory(String categoryId) async {
  await loadProjects(forceRefresh: true); // ← categoryId ignorée !
}
```

**Critères d'acceptation non remplis :**
- ❌ Barre de recherche absente dans `ProjectListScreen`
- ❌ Recherche en temps réel avec debounce 300ms absente
- ❌ Bottom sheet de filtres absent
- ❌ Chips filtres actifs absents
- ❌ Compteur de résultats absent
- ❌ Bouton "Effacer tous les filtres" absent

---

## 📋 US1.3 — Upload Médias Projets

### ✅ Ce qui est fait

**Tâche 1.3.1 — `MediaUploader` (`lib/presentation/widgets/media_uploader.dart`)**
- ✅ Widget `MediaUploader` complet et bien structuré
- ✅ Sélection multiple d'images depuis galerie
- ✅ Prise de photo depuis caméra
- ✅ Sélection de vidéos
- ✅ Aperçu immédiat (images locales + URLs distantes)
- ✅ Drag & drop natif Flutter (`LongPressDraggable` + `DragTarget`) — bonne décision d'éviter `reorderable_grid_view`
- ✅ Badge "Couverture" sur le premier média
- ✅ Bouton supprimer sur chaque média
- ✅ Overlay de progression upload
- ✅ Compression images avec `flutter_image_compress` (qualité 85%)
- ✅ Vérification taille : 5 MB images, 50 MB vidéos
- ✅ Limite configurable `maxMedia` (défaut 10)
- ✅ `MediaFile` modèle complet avec `copyWith()`
- ✅ Utilisation de `withValues(alpha:)` au lieu de `withOpacity()` déprécié
- ✅ Gestion `mounted` avant setState

### ❌ Ce qui manque

**1. `MediaUploader` non intégré dans `ProjectCreateScreenEnhanced`**
```dart
// ❌ lib/presentation/screens/project/project_create_screen_enhanced.dart
// Le widget MediaUploader existe mais n'est PAS utilisé dans le formulaire de création
// Aucun import de media_uploader.dart dans project_create_screen_enhanced.dart
// Le formulaire ne permet pas d'ajouter des images/vidéos
```

**2. Pas de barre de progression upload réelle**
```dart
// ⚠️ lib/presentation/widgets/media_uploader.dart
// L'overlay de progression existe mais uploadProgress est toujours 0.0
// Il n'y a pas de service d'upload qui met à jour uploadProgress
// L'upload réel vers le backend n'est pas implémenté dans ce widget
```

**3. Miniature vidéo non générée**
```dart
// ⚠️ lib/presentation/widgets/media_uploader.dart:476-487
Future<void> _addVideoFile(File file) async {
  // ← Pas de génération de miniature (video_thumbnail absent)
  // Fallback icône play correct, mais miniature manquante
}
```

**Critères d'acceptation :**
- ✅ Bouton "Ajouter des médias" fonctionnel
- ✅ Support images (JPEG, PNG) et vidéos (MP4)
- ✅ Upload multiple (jusqu'à 10 médias)
- ✅ Aperçu immédiat après sélection
- ❌ Barre de progression upload non connectée au vrai upload
- ✅ Drag & drop pour réorganiser
- ✅ Suppression fonctionne
- ✅ Compression automatique des images
- ✅ Limites de taille respectées
- ❌ **Non intégré dans la création de projet**

---

## 📋 US1.4 — Système de Favoris UI

### ✅ Ce qui est fait

- ✅ `toggleFavorite()` dans `ProjectProvider` et `ProjectApiService`
- ✅ Icône cœur dans `ProjectDetailScreen` avec animation scale
- ✅ État `_isFavorited` local dans `ProjectDetailScreen`
- ✅ Feedback SnackBar "Projet ajouté/retiré des favoris"
- ✅ Endpoint API `/projects/{id}/toggle_favorite/` appelé
- ✅ `favoritesCount` dans `ProjectModel`

### ❌ Ce qui manque

**1. Bouton favoris absent dans `ProjectCard`**
```dart
// ❌ lib/presentation/widgets/project_card.dart
// Pas de paramètre onFavoriteToggle
// Pas d'icône cœur dans la carte
// L'utilisateur ne peut pas marquer un favori depuis la liste
```

**2. État favori non persisté dans le modèle**
```dart
// ❌ lib/data/providers/project_provider.dart:279-281
if (index != -1) {
  // Note: Il faudrait ajouter un champ isFavorite au modèle
  notifyListeners(); // ← L'UI ne reflète pas le changement d'état
}
```
Le modèle `ProjectModel` n'a pas de champ `isFavorite`. Après `toggleFavorite()`, l'icône ne change pas dans la liste.

**3. `_isFavorited` initialisé à `false` sans vérification backend**
```dart
// ⚠️ lib/presentation/screens/project/project_detail_screen.dart:31
bool _isFavorited = false; // ← Toujours false au chargement
// Devrait être initialisé depuis project.isFavorite
```

**Critères d'acceptation :**
- ❌ Bouton favoris absent dans la liste de projets
- ✅ Bouton favoris présent dans la page de détails
- ❌ État favori non synchronisé avec le backend au chargement
- ✅ Feedback visuel (animation + SnackBar)

---

## 📋 US1.5 — Optimisation Backend Projets

### ✅ Ce qui est fait

- ✅ `ProjectApiService` complet avec tous les endpoints
- ✅ Gestion pagination côté service (`page`, `page_size`)
- ✅ Gestion des erreurs Dio avec messages détaillés
- ✅ Endpoints spéciaux : `getFeaturedProjects()`, `getTrendingProjects()`, `getRecommendedProjects()`
- ✅ `ProjectListResult` avec `isSuccess`, `projects`, `totalCount`, `hasNext`
- ✅ `diagnoseApiIssues()` en mode debug
- ✅ Timeout géré par `ApiService` (Dio)

### ⚠️ Points d'amélioration

**1. `loadProjects()` fait 4 appels API en séquence**
```dart
// ⚠️ lib/data/providers/project_provider.dart:63-131
// 4 appels séquentiels : recommended + featured + trending + all
// Devrait utiliser Future.wait() pour paralléliser
```

**2. `_isLoading` et `_isLoadingProjects` — deux flags redondants**
```dart
// ⚠️ lib/data/providers/project_provider.dart:16-19
bool _isLoading = false;       // ← utilisé par loadProject(), createProject()...
bool _isLoadingProjects = false; // ← utilisé par loadProjects()
// Confusion possible, le ProjectListScreen utilise isLoading mais loadProjects
// utilise _isLoadingProjects sans mettre à jour _isLoading
```

**3. `fundingRaised` calculé de façon incorrecte**
```dart
// ❌ lib/data/models/project_model.dart:489-490
double get fundingRaised =>
    fundingMax * (interestsCount / 100.0).clamp(0.0, 1.0);
// ← Calcul arbitraire basé sur interestsCount, pas sur les vrais investissements
// Devrait venir du backend (champ dédié)
```

---

## 📋 US1.6 — Tests et Corrections

### ✅ Ce qui est fait

- ✅ 70/74 tests passent (94.6%)
- ✅ Tests unitaires pour modèles, services, providers
- ✅ Architecture MVVM respectée
- ✅ 0 erreur `dart analyze`

### ❌ Ce qui manque

- ❌ 4 tests échoués (voir `SPRINT1_TEST_REPORT.md` pour les corrections)
- ❌ Aucun test pour `ProjectCard`, `ProjectListScreen`, `MediaUploader`
- ❌ Aucun test pour `ProjectProvider.loadProjects()`
- ❌ Coverage ~65% (cible 80%)
- ❌ 119 usages de `.withOpacity()` déprécié (sauf dans `media_uploader.dart` qui utilise correctement `.withValues()`)

---

## 🎯 OBJECTIFS DE FIN DE SPRINT — VÉRIFICATION

| Objectif | Statut | Détail |
|----------|--------|--------|
| Voir une belle liste de projets | ❌ | `ListTile` au lieu de `ProjectCard` |
| Chercher "tech" et voir les résultats | ❌ | Barre de recherche absente dans `ProjectListScreen` |
| Filtrer par catégorie | ❌ | `FilterBottomSheet` absent |
| Cliquer sur un projet → détails | ✅ | Navigation fonctionnelle |
| Créer un projet et ajouter des images | ❌ | `MediaUploader` non intégré dans le formulaire |
| Marquer un projet en favori | ⚠️ | Seulement depuis la page détails, pas depuis la liste |

---

## 🔴 BLOCANTS CRITIQUES (à corriger en priorité)

### B01 — `ProjectListScreen` utilise `ListTile` au lieu de `ProjectCard`
**Fichier :** `lib/presentation/screens/project/project_list_screen.dart:59`  
**Impact :** L'UI de la liste est basique et ne respecte pas les specs  
**Correction :** Remplacer `ListTile` par `ProjectCard` avec `onTap` et `onFavoriteToggle`

### B02 — Pagination infinie non implémentée
**Fichier :** `lib/presentation/screens/project/project_list_screen.dart`  
**Impact :** Pas de chargement automatique au scroll, pas de 20 projets par page  
**Correction :** Convertir en `StatefulWidget`, ajouter `PagingController`, utiliser `PagedListView`

### B03 — `MediaUploader` non intégré dans la création de projet
**Fichier :** `lib/presentation/screens/project/project_create_screen_enhanced.dart`  
**Impact :** Impossible d'ajouter des images/vidéos lors de la création  
**Correction :** Importer et utiliser `MediaUploader` dans `_buildBasicInfoCard()` ou une section dédiée

### B04 — `FilterBottomSheet` et `ProjectFilters` absents
**Fichiers manquants :**
- `lib/presentation/widgets/filter_bottom_sheet.dart`
- `lib/data/models/project_filters.dart`  
**Impact :** Filtres non fonctionnels dans `ProjectListScreen`

### B05 — Barre de recherche absente dans `ProjectListScreen`
**Fichier :** `lib/presentation/screens/project/project_list_screen.dart`  
**Impact :** Impossible de chercher depuis la liste principale  
**Correction :** Ajouter `_isSearching`, `_searchController`, `_debounce` dans l'AppBar

---

## 🟡 PROBLÈMES MOYENS (recommandés)

### M01 — Montants hardcodés `0€` dans `ProjectCard`
**Fichier :** `lib/presentation/widgets/project_card.dart:222-247`  
**Correction :** Utiliser `project.fundingRaised` et `project.fundingCurrency`

### M02 — Devise `€` hardcodée au lieu de XAF/EUR/USD
**Fichier :** `lib/presentation/widgets/project_card.dart:323-330`  
**Correction :** Utiliser `project.fundingCurrency` et formater selon les préférences utilisateur

### M03 — `isFavorite` absent du modèle `ProjectModel`
**Fichier :** `lib/data/models/project_model.dart`  
**Correction :** Ajouter `final bool isFavorite;` et le parser depuis le JSON

### M04 — `searchProjects()` et `filterByCategory()` ignorent leurs paramètres
**Fichier :** `lib/data/providers/project_provider.dart:359-376`  
**Correction :** Passer les paramètres à `loadProjects()` via `ProjectFilters`

### M05 — `loadProjects()` fait 4 appels séquentiels
**Fichier :** `lib/data/providers/project_provider.dart:63-131`  
**Correction :** Utiliser `Future.wait([...])` pour paralléliser

---

## ✅ POINTS FORTS À CONSERVER

1. **`ProjectCardSkeleton`** — Implémentation exemplaire avec un seul `Shimmer` englobant et `FractionallySizedBox` pour corriger le bug `double.infinity * 0.7`
2. **`MediaUploader`** — Code propre, drag & drop natif Flutter, gestion des erreurs, compression, limites de taille
3. **`ErrorStateWidget` / `EmptyStateWidget`** — Widgets bien conçus, responsives, avec `errorBuilder` pour les assets manquants
4. **`ProjectApiService`** — Service complet avec gestion d'erreurs Dio robuste
5. **`ProjectModel`** — Modèle riche avec getters de compatibilité et parsing défensif
6. **Utilisation de `.withValues(alpha:)`** dans `media_uploader.dart` — bonne pratique Flutter 3.32+

---

## 📋 PLAN D'ACTION RECOMMANDÉ

### Jour 1 (Urgent — Blocants)
```
1. Convertir ProjectListScreen en StatefulWidget + PagingController
2. Remplacer ListTile par ProjectCard dans ProjectListScreen
3. Ajouter onFavoriteToggle à ProjectCard
4. Intégrer MediaUploader dans ProjectCreateScreenEnhanced
```

### Jour 2 (Critique — Recherche)
```
5. Créer lib/data/models/project_filters.dart
6. Créer lib/presentation/widgets/filter_bottom_sheet.dart
7. Ajouter barre de recherche dans ProjectListScreen AppBar (debounce 300ms)
8. Ajouter chips filtres actifs dans ProjectListScreen
```

### Jour 3 (Important — Corrections)
```
9. Corriger montants hardcodés dans ProjectCard (fundingRaised, devise)
10. Ajouter isFavorite dans ProjectModel
11. Corriger searchProjects() et filterByCategory() dans ProjectProvider
12. Corriger les 4 tests échoués
```

### Jour 4 (Qualité)
```
13. Écrire tests pour ProjectCard, ProjectListScreen
14. Remplacer withOpacity() par withValues() (119 occurrences)
15. Paralléliser les 4 appels API dans loadProjects()
```

---

## 📊 SCORE FINAL PAR TÂCHE

| Tâche | Description | Score | Statut |
|-------|-------------|-------|--------|
| 1.1.1 | Widget ProjectCard | 7/10 | ⚠️ Favoris manquants, montants hardcodés |
| 1.1.2 | Pagination infinie | 1/10 | ❌ Non implémentée |
| 1.1.3 | Skeleton Loaders | 10/10 | ✅ Excellent |
| 1.1.4 | Connexion API | 8/10 | ✅ Bon |
| 1.1.5 | États et Erreurs | 9/10 | ✅ Très bon |
| 1.2.1 | Barre de recherche | 0/10 | ❌ Absente dans ProjectListScreen |
| 1.2.2 | FilterBottomSheet | 0/10 | ❌ Fichier absent |
| 1.2.3 | Chips filtres actifs | 0/10 | ❌ Absent |
| 1.2.4 | Filtres dans API | 3/10 | ❌ Paramètres ignorés |
| 1.3.1 | MediaUploader | 8/10 | ✅ Bon mais non intégré |
| 1.4 | Favoris UI | 5/10 | ⚠️ Seulement dans détails |
| 1.5 | Optimisation backend | 7/10 | ✅ Bon |
| 1.6 | Tests | 6/10 | ⚠️ 4 échecs, coverage insuffisant |

**Score global Sprint 1 : 64/130 = ~49%**

---

*Rapport généré le 24 Février 2026 — Kilo Code Review*
