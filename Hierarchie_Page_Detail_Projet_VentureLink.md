# Hiérarchie et Dépendances - Page Détail Projet VentureLink

## Vue d'ensemble
La page de détail de projet (`ProjectDetailScreen`) est l'écran qui présente toutes les informations détaillées d'un projet spécifique. Elle est accessible depuis la page d'accueil et constitue le point central pour les actions d'investissement et d'engagement.

## Structure hiérarchique

### 1. **ProjectDetailScreen** (Écran Principal)
- **Fichier**: `lib/presentation/screens/project/project_detail_screen.dart`
- **Type**: StatefulWidget
- **Fonctionnalité**: Affichage détaillé d'un projet avec toutes ses informations et actions possibles

#### 1.1 **États de Chargement et d'Erreur**

##### 1.1.1 **État de Chargement**
- **Composant**: `CircularProgressIndicator` centré
- **Condition**: `projectProvider.isLoading || currentProject == null`

##### 1.1.2 **État d'Erreur**
- **Composants**:
  - **Icône d'erreur** (`Icons.error_outline`, taille 64)
  - **Titre**: "Erreur de chargement"
  - **Message d'erreur**: Texte de l'erreur
  - **Bouton "Réessayer"**: Relance le chargement
- **Condition**: `projectProvider.error != null`

#### 1.2 **SliverAppBar** (Barre de navigation avec image)
- **Hauteur expandue**: 250px
- **Type**: Épinglée (`pinned: true`)
- **Arrière-plan**: Image du projet ou dégradé par défaut

##### 1.2.1 **Image de Fond**
- **Widget**: `CachedNetworkImage`
- **Fallback**: Dégradé avec icône `lightbulb_outline`
- **Fit**: `BoxFit.cover`
- **États**:
  - **Placeholder**: Container avec `CircularProgressIndicator`
  - **Erreur**: Dégradé avec icône

##### 1.2.2 **Actions de l'AppBar**
- **Bouton Favori** (`Icons.favorite_border`)
  - **Action**: `toggleFavorite(project.id)`
  - **Navigation**: Aucune (état local)
- **Bouton Partage** (`Icons.share`)
  - **Action**: TODO - Non implémenté
  - **Navigation**: Aucune

#### 1.3 **Contenu Principal** (SliverToBoxAdapter)
- **Padding**: `AppConfig.defaultPadding` (uniforme)
- **Structure**: Colonne avec sections séparées par des `SizedBox(height: 24)`

##### 1.3.1 **En-tête du Projet** (`_buildProjectHeader`)
- **Composants**:
  - **Titre et Badge Premium** (Row)
    - Titre du projet (`headlineMedium`, `fontWeight.bold`)
    - Badge Premium conditionnel (fond ambre, texte blanc)
  - **Description courte** (`titleMedium`, couleur grise)
  - **Statistiques** (Row avec Spacer)
    - Vues, favoris, intérêts (chips avec icônes)
    - Date de publication (alignée à droite)

##### 1.3.2 **Boutons d'Action** (`_buildActionButtons` - Conditionnel)
- **Condition**: Affiché si utilisateur n'est pas propriétaire
- **Structure**: Row avec boutons étendus
- **Boutons**:
  - **"Manifester mon intérêt"** (ElevatedButton.icon)
    - **Icône**: `Icons.thumb_up_outlined`
    - **Action**: `toggleInterest(project.id)`
  - **"Contacter"** (ElevatedButton.icon)
    - **Icône**: `Icons.message_outlined`  
    - **Action**: TODO - Non implémenté
    - **Style**: Couleur secondaire

##### 1.3.3 **Section Description** (`_buildDescription`)
- **Titre**: "Description du projet"
- **Contenu**: Texte complet du projet (`bodyLarge`)

##### 1.3.4 **Informations du Projet** (`_buildProjectInfo`)
- **Container**: Arrière-plan `surfaceContainerHighest`, coins arrondis (12px)
- **Padding**: 16px uniforme
- **Structure**: Lignes d'information séparées par `Divider`
- **Widget**: `_buildInfoRow` pour chaque information
- **Données affichées**:
  - Catégorie
  - Stade de développement
  - Financement recherché (min-max + devise)
  - Localisation (conditionnelle)

##### 1.3.5 **Section Tags** (`_buildTags` - Conditionnel)
- **Condition**: `project.tags?.isNotEmpty == true`
- **Layout**: `Wrap` avec espacement (8px)
- **Style des tags**: Container avec fond `primaryContainer`, coins arrondis (16px)

##### 1.3.6 **Informations Créateur** (`_buildCreatorInfo`)
- **Container**: Arrière-plan `surfaceContainerHighest`, coins arrondis (12px)
- **Structure**: Row avec avatar et informations
- **Composants**:
  - **Avatar circulaire** (rayon 30px)
  - **Informations**: Nom, titre, bio courte

#### 1.4 **FloatingActionButton** "Investir" (Conditionnel)
- **Condition**: Projet non null ET utilisateur n'est pas propriétaire
- **Type**: `FloatingActionButton.extended`
- **Icône**: `Icons.account_balance_wallet`
- **Action**: Navigation vers `InvestmentCreateScreen`
- **Navigation**: → `InvestmentCreateScreen`

### 2. **Écrans de Navigation Accessibles**

#### 2.1 **InvestmentCreateScreen** (Création d'Investissement)
- **Fichier**: `lib/presentation/screens/investment/investment_create_screen.dart`
- **Navigation depuis**: FloatingActionButton "Investir"
- **Fonctionnalités**:
  - **AppBar** avec bouton "Investir" dans actions
  - **Carte résumé du projet**
  - **Formulaire d'investissement**:
    - Montant d'investissement
    - Type d'investissement (EQUITY, LOAN, etc.)
    - Devise
    - Conditions spécifiques selon le type
    - Description/message
  - **États de chargement** et validation

### 3. **Widgets Utilitaires**

#### 3.1 **_buildStatChip** (Puce de statistique)
- **Composants**: Row avec icône et texte
- **Style**: Icône 16px grise, texte 12px gris

#### 3.2 **_buildInfoRow** (Ligne d'information)
- **Structure**: Row avec label fixe (120px) et valeur étendue
- **Padding**: Vertical 8px
- **Alignement**: `CrossAxisAlignment.start`

#### 3.3 **_getStageLabel** (Traduction des stades)
- **Fonction**: Convertit les codes en français (IDEA → Idée, etc.)

### 4. **Gestion d'État et Navigation**

#### 4.1 **Providers Utilisés**
- **ProjectProvider**: Gestion du projet courant et actions
- **AuthProvider**: Vérification du propriétaire

#### 4.2 **Actions Disponibles**
- **toggleFavorite**: Ajouter/retirer des favoris
- **toggleInterest**: Manifester son intérêt
- **Navigation vers investissement**: Bouton d'investissement principal

## 🚨 PROBLÈMES ERGONOMIQUES IDENTIFIÉS

### 1. **Problèmes de Layout et Espacement**

#### 1.1 **Incohérence dans les espacements**
- **Problème**: Espacement fixe de 24px entre toutes les sections, sans hiérarchie visuelle
- **Impact**: Difficulté à distinguer les groupes d'informations logiques
- **Suggestion**: Utiliser des espacements variables (16px pour les sous-sections, 32px pour les sections principales)

#### 1.2 **Largeur fixe dans `_buildInfoRow`**
- **Problème**: Label fixé à 120px peut être trop court pour certaines langues
- **Code problématique**: 
```dart
SizedBox(
  width: 120, // Trop rigide
  child: Text(label, ...)
),
```
- **Impact**: Troncature possible du texte, surtout en français
- **Suggestion**: Utiliser `Flexible` ou calculer dynamiquement

#### 1.3 **Problème d'alignement des statistiques**
- **Problème**: Les statistiques et la date utilisent `Spacer()` mais peuvent créer des layouts étranges sur petits écrans
- **Impact**: Éléments trop écartés ou chevauchement possible
- **Suggestion**: Utiliser `MainAxisAlignment.spaceBetween` avec contraintes minimales

### 2. **Problèmes d'Accessibilité**

#### 2.1 **Contraste insuffisant**
- **Problème**: Utilisation de `Colors.grey[600]` sans vérification du contraste avec l'arrière-plan
- **Impact**: Lisibilité réduite, non-conformité WCAG
- **Suggestion**: Utiliser les couleurs du thème (`onSurface.withOpacity(0.6)`)

#### 2.2 **Taille des boutons d'action**
- **Problème**: Boutons "Contacter" et "Manifester intérêt" sans largeur minimum garantie
- **Impact**: Difficile à toucher sur petits écrans
- **Suggestion**: Assurer une hauteur minimum de 48px et largeur proportionnelle

#### 2.3 **Absence de labels d'accessibilité**
- **Problème**: Icônes sans `semanticLabel`
- **Impact**: Inaccessible aux lecteurs d'écran
- **Suggestion**: Ajouter des labels appropriés

### 3. **Problèmes d'Expérience Utilisateur**

#### 3.1 **Actions non implémentées visibles**
- **Problème**: Bouton "Partage" et "Contacter" présents mais non fonctionnels
- **Impact**: Frustration utilisateur, promesses non tenues
- **Suggestion**: Masquer ou désactiver visuellement avec tooltip explicatif

#### 3.2 **Feedback visuel insuffisant**
- **Problème**: Pas de feedback immédiat sur `toggleFavorite` et `toggleInterest`
- **Impact**: Utilisateur ne sait pas si l'action a réussi
- **Suggestion**: Animations, changements d'icônes, snackbars

#### 3.3 **Gestion d'erreur des images**
- **Problème**: Widget d'erreur identique au placeholder
- **Impact**: Utilisateur ne sait pas si l'image charge ou a échoué
- **Suggestion**: Différencier visuellement les états (icône d'erreur, possibilité de retry)

### 4. **Problèmes de Performance**

#### 4.1 **Chargement de projet non optimisé**
- **Problème**: Rechargement du projet à chaque ouverture même s'il est déjà en cache
- **Impact**: Temps de chargement inutile, consommation réseau
- **Suggestion**: Vérifier la cache avant de recharger

#### 4.2 **Image non lazy-loaded**
- **Problème**: SliverAppBar charge l'image immédiatement même si pas visible
- **Impact**: Consommation mémoire et réseau
- **Suggestion**: Implémenter un lazy loading intelligent

### 5. **Problèmes de Responsivité**

#### 5.1 **Hauteur fixe du SliverAppBar**
- **Problème**: 250px fixe peut être inapproprié sur petits écrans
- **Impact**: Perte d'espace utile sur mobiles
- **Suggestion**: Hauteur responsive basée sur la taille d'écran

#### 5.2 **Padding uniforme non adaptatif**
- **Problème**: `AppConfig.defaultPadding` identique sur tous les écrans
- **Impact**: Gaspillage d'espace sur tablettes, manque d'air sur mobiles
- **Suggestion**: Padding adaptatif selon la taille d'écran

### 6. **Problèmes de Cohérence**

#### 6.1 **Styles de conteneurs incohérents**
- **Problème**: Certains conteneurs avec `surfaceContainerHighest`, d'autres sans
- **Impact**: Hiérarchie visuelle confuse
- **Suggestion**: Définir une hiérarchie claire et cohérente

#### 6.2 **Gestion des états vides/nulls**
- **Problème**: Certaines propriétés optionnelles gérées, d'autres non
- **Impact**: Crashes potentiels ou affichages vides
- **Suggestion**: Gestion systématique des états nulls

## Flux de Données et États

### 1. **Chargement Initial**
1. `initState()` → `loadProject(projectId)`
2. Affichage de l'état de chargement
3. Mise à jour via `Consumer<ProjectProvider>`

### 2. **Actions Utilisateur**
1. **Favoris**: `toggleFavorite()` → Mise à jour état
2. **Intérêt**: `toggleInterest()` → Mise à jour état  
3. **Investir**: Navigation vers formulaire d'investissement

### 3. **Navigation Sortante**
- **Vers InvestmentCreateScreen**: Via FloatingActionButton
- **Retour**: Via bouton natif ou AppBar

## Améliorations Prioritaires Recommandées

### 1. **Corrections Critiques**
1. Implémenter les actions manquantes ou les masquer
2. Corriger les problèmes d'accessibilité (contraste, labels)
3. Améliorer la gestion des erreurs et états de chargement

### 2. **Améliorations UX**
1. Ajouter des feedbacks visuels pour toutes les actions
2. Optimiser la performance de chargement
3. Améliorer la responsivité

### 3. **Cohérence Design**
1. Standardiser les espacements et styles
2. Créer un système de design cohérent
3. Améliorer la hiérarchie visuelle des informations 