# Hiérarchie et Dépendances - Page Notifications VentureLink

## Vue d'ensemble
La page des notifications (`NotificationsScreen`) est l'écran qui présente toutes les notifications utilisateur sous forme de liste interactive. Elle est accessible depuis la page d'accueil et autres écrans via l'icône de notification, et constitue le centre de communication pour les alertes et mises à jour importantes.

## Structure hiérarchique

### 1. **NotificationsScreen** (Écran Principal)
- **Fichier**: `lib/presentation/screens/notifications/notifications_screen.dart`
- **Type**: StatefulWidget
- **Fonctionnalité**: Affichage et gestion des notifications utilisateur avec recherche et actions

#### 1.1 **AppBar** (Barre de navigation supérieure)
- **Titre dynamique**: "Notifications" ou barre de recherche selon le mode
- **Élévation**: 0 (design plat)
- **Arrière-plan**: `theme.colorScheme.surface`

##### 1.1.1 **Mode Normal - Titre statique**
- **Texte**: Localisé (`l10n.notifications`)

##### 1.1.2 **Mode Recherche - Barre de recherche** (`_buildSearchBar`)
- **Widget**: `TextField` avec focus automatique
- **Décoration**: Sans bordure (`InputBorder.none`)
- **Placeholder**: Localisé (`l10n.searchNotifications`)
- **Action**: `onChanged` → `searchNotifications(value)`

##### 1.1.3 **Actions de l'AppBar**
- **Bouton Search/Close** (`Icons.search`/`Icons.close`)
  - **Action**: Toggle entre modes normal et recherche
  - **Navigation**: Aucune (état local)
- **Menu PopupMenuButton** (`Icons.more_vert`)
  - **Option 1**: "Marquer tout comme lu" (`Icons.mark_email_read`)
    - **Action**: `markAllAsRead()`
  - **Option 2**: "Paramètres de notification" (`Icons.settings`)
    - **Action**: Ouvre dialog de paramètres
    - **Navigation**: Modal (AlertDialog)
  - **Option 3**: "Actualiser" (`Icons.refresh`)
    - **Action**: `loadNotifications()`

#### 1.2 **Corps Principal** (Consumer<NotificationProvider>)
- **Gestion d'état**: Réactif aux changements du `NotificationProvider`

##### 1.2.1 **État de Chargement**
- **Composant**: `CircularProgressIndicator` centré
- **Condition**: `provider.isLoading`

##### 1.2.2 **État d'Erreur** (`_buildErrorWidget`)
- **Composants**:
  - **Icône d'erreur** (`Icons.error_outline`, taille 64)
  - **Titre**: Localisé (`l10n.errorLoadingNotifications`)
  - **Bouton "Réessayer"** avec icône refresh
- **Padding**: 32px uniforme
- **Condition**: `provider.error != null`

##### 1.2.3 **État Vide** (`_buildEmptyWidget`)
- **Icônes dynamiques**:
  - Mode normal: `Icons.notifications_none` (taille 80)
  - Mode recherche: `Icons.search_off` (taille 80)
- **Texte dynamique**:
  - Mode normal: Localisé (`l10n.noNotifications`)
  - Mode recherche: "Aucun résultat"
- **Style**: Opacité 0.3 pour l'icône, 0.7 pour le texte

##### 1.2.4 **Liste des Notifications**
- **Widget**: `RefreshIndicator` contenant `ListView.builder`
- **Padding**: Vertical 8px
- **Fonction Pull-to-refresh**: `loadNotifications()`
- **Source de données**: 
  - Mode normal: `provider.notifications`
  - Mode recherche: `provider.searchResults`

### 2. **NotificationCard** (Composant Principal - `_buildNotificationCard`)
- **Type**: Container avec InkWell
- **Margin**: Horizontal 16px, vertical 4px
- **Coins arrondis**: 12px
- **Tap**: Navigation contextuelle selon catégorie

#### 2.1 **Apparence Visuelle**
- **États visuels différenciés**:
  - **Non lue**: Arrière-plan `primaryContainer.withOpacity(0.1)`, bordure `primary.withOpacity(0.2)`
  - **Lue**: Arrière-plan `surface`, bordure `outline.withOpacity(0.2)`

#### 2.2 **Structure Interne** (Row principal)
- **Padding**: 16px uniforme
- **Alignement**: `CrossAxisAlignment.start`

##### 2.2.1 **Section Icône** (Stack)
- **Container circulaire**: 48x48px
- **Arrière-plan**: `categoryColor.withOpacity(0.1)`
- **Icône**: Dynamique selon catégorie, taille 24px
- **Indicateur non lu**: Point rouge 12x12px (positionné en haut-droite)

##### 2.2.2 **Section Contenu** (Expanded Column)
- **Espacement avec icône**: 12px
- **Composants** :
  - **Titre** (`titleMedium`)
    - **Style dynamique**: Bold si non lu, normal si lu
    - **Troncature**: 2 lignes max avec ellipsis
  - **Contenu** (`bodyMedium`)
    - **Opacité**: 0.8 si non lu, 0.6 si lu
    - **Troncature**: 3 lignes max avec ellipsis
  - **Métadonnées** (Row)
    - **Temps relatif**: Format intelligent (minutes/heures/jours)
    - **Séparateur**: Point gris 4x4px
    - **Catégorie**: Libellé coloré selon type

##### 2.2.3 **Menu Actions** (PopupMenuButton)
- **Icône**: `Icons.more_vert` (taille 20px, opacité 0.6)
- **Actions conditionnelles**:
  - **"Marquer comme lu"** (si non lu)
    - **Icône**: `Icons.mark_email_read`
    - **Action**: `markAsRead(notification.id)`
  - **"Archiver"** (toujours présent)
    - **Icône**: `Icons.archive_outlined`
    - **Action**: `archiveNotification(notification.id)`
  - **"Supprimer"** (toujours présent)
    - **Icône**: `Icons.delete_outline` (rouge)
    - **Action**: `deleteNotification(notification.id)`
    - **Style**: Texte rouge

### 3. **Dialogues et Modales**

#### 3.1 **Dialogue Paramètres de Notification** (`_showNotificationSettings`)
- **Type**: `AlertDialog`
- **Titre**: Localisé (`l10n.notificationSettings`)
- **Contenu**: `SingleChildScrollView` avec `SwitchListTile`
- **Options disponibles**:
  - **Notifications push** (`enable_push`)
    - **Action**: `updateNotificationPreferences({'enable_push': value})`
  - **Notifications email** (`enable_email`)
    - **Action**: `updateNotificationPreferences({'enable_email': value})`
- **Bouton**: "Fermer" pour dismissal

### 4. **Navigation Contextuelle** (`_handleNotificationTap`)

#### 4.1 **Navigation par Catégorie**
- **PROJECT**: → `ProjectDetailScreen` (avec `objectId`)
- **INVESTMENT**: → `InvestmentListScreen`
- **MESSAGE**: → `MessagingScreen`
- **Défaut**: → `HomeScreen`

#### 4.2 **Marquage Automatique**
- **Action préalable**: Marquer comme lu si non lu

### 5. **Modèle de Données** (NotificationModel)

#### 5.1 **Propriétés Principales**
- `id`, `recipient`, `title`, `content`
- `category`, `priority`, `status`
- `readAt`, `createdAt`, `updatedAt`
- `objectId`, `actionUrl`, `icon`

#### 5.2 **Getters Utilitaires**
- **États**: `isUnread`, `isRead`, `isArchived`
- **Priorités**: `isHighPriority`, `isUrgent`, `isLowPriority`
- **Catégories**: `isProjectCategory`, `isInvestmentCategory`, etc.

#### 5.3 **Propriétés Visuelles**
- **`categoryIcon`**: Icône selon catégorie
- **`categoryColor`**: Couleur selon catégorie
- **`priorityColor`**: Couleur selon priorité

### 6. **Fonctionnalités Utilitaires**

#### 6.1 **Formatage du Temps** (`_formatNotificationTime`)
- **< 1 minute**: "À l'instant"
- **< 1 heure**: "Il y a X minutes"
- **< 24 heures**: "Il y a X heures"
- **< 7 jours**: "Il y a X jours"
- **> 7 jours**: Format date (dd/MM/yyyy)

#### 6.2 **Libellés de Catégorie** (`_getCategoryLabel`)
- **Traduction**: Codes techniques → Libellés localisés
- **Fallback**: "Général" pour catégories inconnues

## 🚨 PROBLÈMES ERGONOMIQUES IDENTIFIÉS

### 1. **Problèmes de Layout et Espacement**

#### 1.1 **Espacement inconsistant dans les cartes**
- **Problème**: Margin vertical de 4px entre les cartes trop serré
- **Impact**: Cartes collées, difficulté à distinguer les éléments
- **Suggestion**: Augmenter à 8px minimum pour plus de respiration

#### 1.2 **Taille fixe de l'icône de catégorie**
- **Problème**: Container 48x48px fixe peut sembler disproportionné sur certains écrans
- **Code problématique**:
```dart
Container(
  width: 48,
  height: 48, // Trop rigide
  decoration: BoxDecoration(...)
)
```
- **Impact**: Occupation excessive de l'espace sur petits écrans
- **Suggestion**: Taille responsive ou réduction à 40x40px

#### 1.3 **Alignement du menu actions**
- **Problème**: Menu PopupMenuButton aligné en haut sans padding approprié
- **Impact**: Difficile à toucher, pas aligné avec le contenu
- **Suggestion**: Centrer verticalement ou ajouter padding

### 2. **Problèmes d'Accessibilité**

#### 2.1 **Contraste insuffisant pour les métadonnées**
- **Problème**: `onSurface.withOpacity(0.5)` peut être trop clair
- **Impact**: Difficulté de lecture, non-conformité WCAG
- **Suggestion**: Minimum 0.6 d'opacité ou utiliser couleurs du thème

#### 2.2 **Zone de touch trop petite pour le menu**
- **Problème**: Icône du menu seulement 20px, zone de touch insuffisante
- **Impact**: Difficulté d'utilisation, surtout pour accessibilité
- **Suggestion**: Augmenter la zone de touch à 48x48px minimum

#### 2.3 **Manque de feedback visuel sur les actions**
- **Problème**: Aucune indication visuelle lors des actions (archiver, supprimer)
- **Impact**: Utilisateur ne sait pas si l'action a réussi
- **Suggestion**: Animations, SnackBar, ou changements d'état visuels

### 3. **Problèmes d'Expérience Utilisateur**

#### 3.1 **Gestion de la recherche peu intuitive**
- **Problème**: Toggle search cache le titre sans indication claire du mode
- **Impact**: Utilisateur peut être perdu sur l'état actuel
- **Suggestion**: Breadcrumb ou indicateur visuel du mode actif

#### 3.2 **Actions destructives sans confirmation**
- **Problème**: Suppression directe sans dialogue de confirmation
- **Impact**: Risque de suppression accidentelle
- **Suggestion**: Dialog de confirmation pour les actions irréversibles

#### 3.3 **Pas de tri ou filtrage avancé**
- **Problème**: Seule la recherche textuelle est disponible
- **Impact**: Difficile de naviguer dans de nombreuses notifications
- **Suggestion**: Filtres par catégorie, priorité, statut

### 4. **Problèmes de Performance**

#### 4.1 **Rechargement complet à chaque refresh**
- **Problème**: Pull-to-refresh recharge toutes les notifications
- **Impact**: Perte de position de scroll, consommation réseau
- **Suggestion**: Chargement incrémental ou cache intelligent

#### 4.2 **Pas de pagination**
- **Problème**: Toutes les notifications chargées d'un coup
- **Impact**: Performance dégradée avec beaucoup de notifications
- **Suggestion**: Pagination lazy-loading

#### 4.3 **Recherche sans debounce**
- **Problème**: Recherche déclenchée à chaque caractère tapé
- **Impact**: Surcharge de requêtes, performance dégradée
- **Suggestion**: Debounce de 300-500ms

### 5. **Problèmes de Responsivité**

#### 5.1 **Texte non responsive**
- **Problème**: Troncature fixe (2-3 lignes) sans adaptation à l'écran
- **Impact**: Perte d'information sur grands écrans, encombrement sur petits
- **Suggestion**: Adaptation dynamique selon la taille d'écran

#### 5.2 **Padding uniforme non adaptatif**
- **Problème**: Padding de 16px identique sur tous les écrans
- **Impact**: Gaspillage d'espace sur tablettes
- **Suggestion**: Padding responsive

### 6. **Problèmes de Cohérence**

#### 6.1 **États vides inconsistants**
- **Problème**: État de recherche vide différent de l'état général vide
- **Impact**: Incohérence dans l'expérience utilisateur
- **Suggestion**: Design système unifié pour tous les états vides

#### 6.2 **Couleurs codées en dur**
- **Problème**: `Colors.red` pour suppression au lieu des couleurs du thème
- **Code problématique**:
```dart
color: Colors.red // Devrait utiliser theme.colorScheme.error
```
- **Impact**: Incohérence avec le thème, problèmes d'accessibilité
- **Suggestion**: Utiliser systématiquement les couleurs du thème

#### 6.3 **Messages d'erreur non localisés**
- **Problème**: Certains textes ("Aucun résultat", "Archiver") non localisés
- **Impact**: Expérience utilisateur incohérente dans différentes langues
- **Suggestion**: Localisation complète de tous les textes

## Flux de Données et États

### 1. **Chargement Initial**
1. `initState()` → `loadNotifications()`
2. Affichage de l'état de chargement
3. Mise à jour via `Consumer<NotificationProvider>`

### 2. **Recherche**
1. Toggle mode recherche → `_toggleSearch()`
2. Saisie utilisateur → `searchNotifications(value)`
3. Affichage des résultats filtrés

### 3. **Actions sur Notifications**
1. **Tap**: Marquage + navigation contextuelle
2. **Menu**: Actions spécifiques (marquer, archiver, supprimer)
3. **Bulk**: Actions globales (marquer tout)

### 4. **Navigation Sortante**
- **Vers ProjectDetailScreen**: Notifications projet
- **Vers InvestmentListScreen**: Notifications investissement
- **Vers MessagingScreen**: Notifications message
- **Vers HomeScreen**: Autres catégories

## Améliorations Prioritaires Recommandées

### 1. **Corrections Critiques**
1. Corriger les problèmes d'accessibilité (contraste, zones de touch)
2. Ajouter confirmations pour actions destructives
3. Implémenter feedback visuel pour toutes les actions

### 2. **Améliorations UX**
1. Ajouter pagination et lazy loading
2. Implémenter filtres avancés (catégorie, priorité, statut)
3. Améliorer la gestion de la recherche avec debounce

### 3. **Cohérence Design**
1. Standardiser tous les espacements et couleurs
2. Localiser tous les textes manquants
3. Créer un système d'états vides cohérent

### 4. **Performance**
1. Optimiser le chargement avec cache intelligent
2. Implémenter le debounce pour la recherche
3. Ajouter la pagination lazy-loading

### 5. **Fonctionnalités Manquantes**
1. **Tri des notifications** (date, priorité, catégorie)
2. **Filtres visuels** avec chips
3. **Actions en lot** (sélection multiple)
4. **Aperçu riche** pour certains types de notifications
5. **Notifications groupées** par catégorie ou projet 