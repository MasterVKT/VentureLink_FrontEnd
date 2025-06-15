# Hiérarchie et Dépendances - Page Profil Utilisateur VentureLink

## Vue d'ensemble
La page de profil utilisateur (`ProfileScreen`) est l'écran personnel de l'utilisateur qui présente ses informations, statistiques et actions disponibles. Elle constitue le centre de gestion du compte utilisateur et le point d'accès aux fonctionnalités personnelles de l'application.

## Structure hiérarchique

### 1. **ProfileScreen** (Écran Principal)
- **Fichier**: `lib/presentation/screens/profile/profile_screen.dart`
- **Type**: StatefulWidget
- **Fonctionnalité**: Affichage et gestion du profil utilisateur avec actions rapides et statistiques

#### 1.1 **AppBar** (Barre de navigation supérieure)
- **Titre**: Localisé (`appLocalizations.profile`)
- **AutomaticallyImplyLeading**: `false` (pas de bouton retour)
- **Actions**:
  - **Bouton Paramètres** (`Icons.settings`)
    - **Action**: Navigation vers `SettingsScreen`
    - **Navigation**: → `SettingsRoute()`
  - **Bouton Notifications** (`Icons.notifications_outlined`)
    - **Action**: Navigation vers `NotificationsScreen`
    - **Navigation**: → `NotificationsRoute()`

#### 1.2 **Corps Principal** (Consumer2<AuthProvider, SubscriptionProvider>)
- **Gestion d'état**: Réactif aux changements des deux providers
- **RefreshIndicator**: Pull-to-refresh pour actualiser les données
- **SingleChildScrollView**: Défilement vertical avec padding par défaut

##### 1.2.1 **État Utilisateur Non Connecté**
- **Composant**: Texte centré "Utilisateur non connecté"
- **Condition**: `user == null`

##### 1.2.2 **Contenu Principal** (Column)
- **Espacement**: Sections séparées par `SizedBox(height: 24)`
- **Structure**: 5 sections principales

### 2. **Section En-tête du Profil** (`_buildProfileHeader`)
- **Widget**: Card avec padding par défaut
- **Fonctionnalité**: Informations principales et photo de profil

#### 2.1 **Photo de Profil** (Stack)
- **Container principal**: Ombre portée avec couleur primaire
- **CircleAvatar**: Rayon 50px
- **États**:
  - **Avec photo**: `CachedNetworkImageProvider`
  - **Sans photo**: Initiale du prénom (taille 32, bold)
- **Bouton d'édition** (Positioned)
  - **Position**: En bas à droite
  - **Style**: Cercle bleu avec icône caméra blanche
  - **Action**: `_changeProfilePicture()` → BottomSheet de sélection

#### 2.2 **Informations Utilisateur**
- **Nom complet**: `headlineSmall`, bold
- **Badges conditionnels**:
  - **Vérifié**: Icône `verified` bleue dans cercle
  - **Premium**: Badge ambre "PREMIUM" (10px, bold)
- **Email**: `bodyMedium` en gris
- **Type d'utilisateur**: Badge avec `primaryContainer`
- **Titre professionnel**: Optionnel, couleur primaire
- **Bio courte**: Optionnelle, centrée

### 3. **Section Actions Rapides** (`_buildQuickActions`)
- **Widget**: Card avec titre "Actions rapides"
- **Layout**: Grille 2x3 de boutons d'action

#### 3.1 **Actions Disponibles** (6 boutons)
- **Ligne 1**:
  - **"Modifier le profil"** (`Icons.edit`)
    - **Action**: `_editProfile()` → `ProfileEditRoute()`
  - **"Créer un projet"** (`Icons.add_box_outlined`)
    - **Action**: `_createProject()` → `ProjectCreateRoute()`
- **Ligne 2**:
  - **"Mes investissements"** (`Icons.account_balance_wallet_outlined`)
    - **Action**: `_goToInvestments()` → Navigation vers onglet investissements
  - **"Abonnements"** (`Icons.workspace_premium`)
    - **Action**: `_goToSubscriptions()` → `SimpleSubscriptionRoute()`
- **Ligne 3**:
  - **"Partager profil"** (`Icons.share`)
    - **Action**: `_shareProfile()` → TODO (SnackBar temporaire)
  - **"Devenir Premium"** (`Icons.star`)
    - **Action**: `_goToPremium()` → `PremiumRoute()`

#### 3.2 **Style des Boutons** (`_buildActionButton`)
- **Container**: Fond `surfaceContainerHighest`, coins arrondis 12px
- **Padding**: 16px uniforme
- **Structure**: Colonne avec icône (24px) et texte
- **Interaction**: `InkWell` avec `borderRadius`

### 4. **Section Informations du Profil** (`_buildProfileInfo`)
- **Condition**: Affiché si `user.profile != null`
- **Widget**: Card avec titre "Informations du profil"

#### 4.1 **Informations Affichées** (Conditionnelles)
- **À propos**: `bioShort` si disponible
- **Site web**: `website` si disponible
- **LinkedIn**: `socialLinkedin` si disponible
- **Twitter**: `socialTwitter` si disponible
- **Note moyenne**: `avgRating` + `ratingCount` si disponibles
- **Niveau de vérification**: Toujours affiché, traduit

#### 4.2 **Style des Lignes** (`_buildInfoRow`)
- **Structure**: Row avec label fixe (100px) et valeur étendue
- **Label**: `bodyMedium` semi-bold
- **Valeur**: `bodyMedium` normal

### 5. **Section Statistiques** (`_buildStatistics`)
- **Widget**: Card avec titre "Statistiques"
- **Layout**: Grille 2x2 de cartes statistiques

#### 5.1 **Statistiques Affichées** (Données statiques)
- **Ligne 1**:
  - **"Projets créés"**: "3" (codé en dur)
  - **"Investissements"**: "7" (codé en dur)
- **Ligne 2**:
  - **"Connexions"**: "24" (codé en dur)
  - **"Note moyenne"**: "4.8⭐" (codé en dur)

#### 5.2 **Style des Cartes** (`_buildStatCard`)
- **Container**: Fond `surfaceContainerHighest`, coins arrondis 12px
- **Padding**: 16px uniforme
- **Structure**: Valeur (`headlineSmall`, bold, couleur primaire) + Label

### 6. **Section Actions du Compte** (`_buildAccountActions`)
- **Widget**: Card avec titre "Compte"
- **Structure**: Liste de `ListTile`

#### 6.1 **Actions Disponibles**
- **"Paramètres"** (`Icons.settings`)
  - **Action**: `SettingsRoute()`
  - **Trailing**: `Icons.chevron_right`
- **"Confidentialité"** (`Icons.privacy_tip_outlined`)
  - **Action**: `_goToPrivacy()` → TODO (SnackBar temporaire)
  - **Trailing**: `Icons.chevron_right`
- **"Aide & Support"** (`Icons.help_outline`)
  - **Action**: `_goToSupport()` → TODO (SnackBar temporaire)
  - **Trailing**: `Icons.chevron_right`
- **Divider**
- **"Déconnexion"** (`Icons.logout`, rouge)
  - **Action**: `_logout()` → Dialog de confirmation

### 7. **Modales et Dialogues**

#### 7.1 **BottomSheet Changement Photo** (`_changeProfilePicture`)
- **Type**: `ModalBottomSheet` avec coins arrondis
- **Poignée**: Container gris 40x4px
- **Actions disponibles**:
  - **"Prendre une photo"** (`Icons.photo_camera`)
    - **Action**: `_takePicture()` → `ImageUtils.takePhotoWithCamera()`
  - **"Choisir dans la galerie"** (`Icons.photo_library`)
    - **Action**: `_pickFromGallery()` → `ImageUtils.pickImageFromGallery()`
  - **"Supprimer la photo"** (conditionnel, rouge)
    - **Condition**: Photo de profil existante
    - **Action**: `_removeProfilePicture()`

#### 7.2 **Dialog Déconnexion** (`_logout`)
- **Type**: `AlertDialog`
- **Titre**: "Déconnexion"
- **Contenu**: "Êtes-vous sûr de vouloir vous déconnecter ?"
- **Actions**:
  - **"Annuler"**: `TextButton` → Ferme le dialog
  - **"Déconnexion"**: `ElevatedButton` rouge → Déconnexion + navigation vers `LoginRoute()`

### 8. **Écrans de Navigation Accessibles**

#### 8.1 **ProfileEditScreen** (Édition de Profil)
- **Fichier**: `lib/presentation/screens/profile/profile_edit_screen.dart`
- **Navigation depuis**: Bouton "Modifier le profil"
- **Fonctionnalités**:
  - **AppBar** avec bouton "Enregistrer"
  - **Formulaire complet** avec validation
  - **Sections**: Infos personnelles, Profil professionnel, Bio, Réseaux sociaux
  - **Photo de profil éditable**

#### 8.2 **SettingsScreen** (Paramètres)
- **Navigation depuis**: AppBar et section Compte
- **Fonctionnalité**: Configuration de l'application

#### 8.3 **Autres Navigations**
- **NotificationsScreen**: Via AppBar
- **ProjectCreateScreen**: Via actions rapides
- **SimpleSubscriptionScreen**: Via actions rapides et abonnements
- **PremiumScreen**: Via actions rapides
- **InvestmentListScreen**: Via actions rapides (onglet principal)

### 9. **Fonctionnalités Utilitaires**

#### 9.1 **Gestion des Images**
- **Upload**: `ProfileProvider.uploadProfilePicture(File)`
- **Suppression**: `ProfileProvider.removeProfilePicture()`
- **Feedback**: SnackBar vert (succès) ou rouge (erreur)

#### 9.2 **Traductions des Labels**
- **`_getUserTypeLabel`**: ENTREPRENEUR → "Entrepreneur", etc.
- **`_getVerificationLevel`**: BASIC → "Basique", etc.

## 🚨 PROBLÈMES ERGONOMIQUES IDENTIFIÉS

### 1. **Problèmes de Layout et Espacement**

#### 1.1 **Espacement uniforme trop rigide**
- **Problème**: `SizedBox(height: 24)` identique entre toutes les sections
- **Impact**: Manque de hiérarchie visuelle, sections trop espacées
- **Suggestion**: Espacements variables selon l'importance (16px, 24px, 32px)

#### 1.2 **Largeur fixe dans `_buildInfoRow`**
- **Problème**: Label fixé à 100px peut être insuffisant
- **Code problématique**:
```dart
SizedBox(
  width: 100, // Trop court pour certains labels
  child: Text(label, ...)
)
```
- **Impact**: Troncature possible, surtout en français
- **Suggestion**: Utiliser `Flexible` ou largeur dynamique

#### 1.3 **Grille d'actions rigide**
- **Problème**: Grille 2x3 non responsive, boutons trop petits sur petits écrans
- **Impact**: Difficile à utiliser, texte tronqué possible
- **Suggestion**: Grille adaptative ou liste sur petits écrans

### 2. **Problèmes d'Accessibilité**

#### 2.1 **Zone de touch insuffisante pour la photo**
- **Problème**: Bouton caméra trop petit (20px d'icône)
- **Impact**: Difficile à toucher, problème d'accessibilité
- **Suggestion**: Augmenter la zone de touch à 48x48px minimum

#### 2.2 **Contraste insuffisant pour l'email**
- **Problème**: `Colors.grey[600]` sans vérification du contraste
- **Impact**: Lisibilité réduite, non-conformité WCAG
- **Suggestion**: Utiliser `theme.colorScheme.onSurface.withOpacity(0.7)`

#### 2.3 **Manque de labels d'accessibilité**
- **Problème**: Icônes sans `semanticLabel`
- **Impact**: Inaccessible aux lecteurs d'écran
- **Suggestion**: Ajouter des labels appropriés

### 3. **Problèmes d'Expérience Utilisateur**

#### 3.1 **Fonctionnalités non implémentées visibles**
- **Problème**: Boutons "Partager profil", "Confidentialité", "Aide & Support" visibles mais non fonctionnels
- **Impact**: Frustration utilisateur, promesses non tenues
- **Suggestion**: Masquer ou implémenter les fonctionnalités manquantes

#### 3.2 **Données statistiques statiques**
- **Problème**: Toutes les statistiques sont codées en dur ("3", "7", "24", "4.8⭐")
- **Impact**: Informations fausses, perte de crédibilité
- **Suggestion**: Connecter aux vraies données utilisateur

#### 3.3 **Feedback visuel insuffisant sur upload**
- **Problème**: Pas d'indicateur de progression lors de l'upload de photo
- **Impact**: Utilisateur ne sait pas si l'action est en cours
- **Suggestion**: Ajouter un loader/progress indicator

### 4. **Problèmes de Performance**

#### 4.1 **Refresh non optimisé**
- **Problème**: RefreshIndicator recharge tout sans indication de ce qui est mis à jour
- **Impact**: Utilisateur ne sait pas ce qui change
- **Suggestion**: Feedback spécifique sur les données mises à jour

#### 4.2 **Images non optimisées**
- **Problème**: `CachedNetworkImage` sans gestion des erreurs de réseau
- **Impact**: Expérience dégradée en cas de connexion lente
- **Suggestion**: Ajouter placeholder et retry pour les erreurs

#### 4.3 **Navigation investissements défaillante**
- **Problème**: `_goToInvestments()` utilise `pushAndPopUntil` avec TODO
- **Impact**: Navigation cassée
- **Suggestion**: Implémenter correctement la navigation

### 5. **Problèmes de Responsivité**

#### 5.1 **Avatar de taille fixe**
- **Problème**: Rayon 50px peut être trop grand sur petits écrans
- **Impact**: Occupation excessive de l'espace
- **Suggestion**: Taille responsive (40-60px selon l'écran)

#### 5.2 **Boutons d'action non adaptatifs**
- **Problème**: Padding fixe 16px peut être inapproprié
- **Impact**: Boutons trop serrés ou trop espacés
- **Suggestion**: Padding adaptatif selon la taille d'écran

#### 5.3 **Texte non scalable**
- **Problème**: Tailles de police fixes sans adaptation aux préférences système
- **Impact**: Problème d'accessibilité pour malvoyants
- **Suggestion**: Respecter les préférences de taille de texte

### 6. **Problèmes de Cohérence**

#### 6.1 **Styles de conteneurs incohérents**
- **Problème**: Mélange entre `surfaceContainerHighest` et `primaryContainer`
- **Impact**: Hiérarchie visuelle confuse
- **Suggestion**: Système de couleurs cohérent

#### 6.2 **Couleurs codées en dur**
- **Problème**: `Colors.red` pour déconnexion au lieu des couleurs du thème
- **Code problématique**:
```dart
color: Colors.red // Devrait utiliser theme.colorScheme.error
```
- **Impact**: Incohérence avec le thème
- **Suggestion**: Utiliser systématiquement les couleurs du thème

#### 6.3 **Gestion d'erreur incohérente**
- **Problème**: Certaines actions montrent des SnackBar, d'autres non
- **Impact**: Feedback utilisateur imprévisible
- **Suggestion**: Standardiser la gestion des erreurs

### 7. **Problèmes de Sécurité et Confidentialité**

#### 7.1 **Upload d'images sans validation**
- **Problème**: Pas de validation de taille/type de fichier visible
- **Impact**: Risque d'upload de fichiers inappropriés
- **Suggestion**: Ajouter validation côté client

#### 7.2 **Affichage d'email en clair**
- **Problème**: Email affiché sans possibilité de le masquer
- **Impact**: Problème de confidentialité
- **Suggestion**: Option pour masquer les informations sensibles

## Flux de Données et États

### 1. **Chargement Initial**
1. Vérification utilisateur connecté
2. Chargement des données via `AuthProvider` et `SubscriptionProvider`
3. Affichage des informations

### 2. **Refresh des Données**
1. Pull-to-refresh déclenché
2. `authProvider.refreshUser()`
3. `subscriptionProvider.loadCurrentSubscription()`
4. Mise à jour de l'interface

### 3. **Gestion des Photos**
1. Tap sur bouton caméra → BottomSheet
2. Sélection source (caméra/galerie) → `ImageUtils`
3. Upload via `ProfileProvider` → Feedback utilisateur

### 4. **Navigation Sortante**
- **Vers ProfileEditScreen**: Modification du profil
- **Vers SettingsScreen**: Configuration
- **Vers écrans métier**: Projets, investissements, abonnements
- **Vers LoginScreen**: Après déconnexion

## Améliorations Prioritaires Recommandées

### 1. **Corrections Critiques**
1. Implémenter les fonctionnalités manquantes ou les masquer
2. Connecter les statistiques aux vraies données
3. Corriger la navigation vers les investissements

### 2. **Améliorations UX**
1. Ajouter feedback visuel pour toutes les actions
2. Optimiser les tailles et espacements pour la responsivité
3. Améliorer la gestion des états de chargement

### 3. **Cohérence Design**
1. Standardiser les couleurs et styles
2. Créer un système d'espacement cohérent
3. Améliorer la hiérarchie visuelle

### 4. **Accessibilité**
1. Corriger les contrastes et zones de touch
2. Ajouter les labels d'accessibilité
3. Respecter les préférences système

### 5. **Fonctionnalités Manquantes**
1. **Vraies statistiques** connectées aux données utilisateur
2. **Partage de profil** fonctionnel
3. **Paramètres de confidentialité** complets
4. **Section aide** avec support
5. **Validation d'upload** d'images
6. **Mode hors ligne** pour consultation du profil 