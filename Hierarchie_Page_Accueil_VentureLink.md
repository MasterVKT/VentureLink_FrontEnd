# Hiérarchie et Dépendances - Page d'Accueil VentureLink

## Vue d'ensemble
La page d'accueil (`HomeScreen`) est l'écran principal de l'application VentureLink qui présente les projets sous forme de feed social. Elle constitue le point d'entrée principal pour découvrir et interagir avec les projets.

## Structure hiérarchique

### 1. **HomeScreen** (Écran Principal)
- **Fichier**: `lib/presentation/screens/home/home_screen.dart`
- **Type**: StatefulWidget
- **Fonctionnalité**: Affichage du feed principal des projets avec sections organisées

#### 1.1 **AppBar** (Barre de navigation supérieure)
- **Composants**:
  - **Titre de salutation**: "Bonjour [Prénom utilisateur]"
  - **Bouton Filtres** (`Icons.filter_list`)
    - **Action**: Toggle l'affichage des filtres
    - **Navigation**: Aucune (état local)
  - **Bouton Recherche** (`Icons.search`)
    - **Action**: Ouvre une boîte de dialogue de recherche
    - **Navigation**: Aucune (modal)
  - **Bouton Notifications** (`Icons.notifications_outlined`)
    - **Action**: Navigation vers l'écran des notifications
    - **Navigation**: → `NotificationsScreen`
  - **Bouton Debug** (`Icons.bug_report`)
    - **Action**: Navigation vers l'écran de debug média
    - **Navigation**: → `MediaDebugScreen`

#### 1.2 **HomeFiltersWidget** (Section Filtres - Conditionnelle)
- **Fichier**: `lib/presentation/widgets/home/home_filters_widget.dart`
- **Visibilité**: Affiché uniquement si `_showFilters = true`
- **Fonctionnalités**:
  - **Filtre par Catégorie**
    - **Action**: Ouvre un BottomSheet avec liste des catégories
    - **Navigation**: Modal (BottomSheet)
  - **Filtre par Stade**
    - **Action**: Ouvre un BottomSheet avec les stades de projet
    - **Navigation**: Modal (BottomSheet)
  - **Filtre par Localisation**
    - **Action**: Ouvre un BottomSheet pour sélectionner la localisation
    - **Navigation**: Modal (BottomSheet)
  - **Bouton "Plus de filtres"**
    - **Action**: Ouvre les filtres avancés
    - **Navigation**: Modal (BottomSheet)
  - **Bouton "Effacer"**
    - **Action**: Remet à zéro tous les filtres actifs

#### 1.3 **Section "Projets mis en avant"** (Carousel horizontal)
- **Condition**: Affiché si `featuredProjects.isNotEmpty`
- **Composants**:
  - **En-tête de section**: "Mis en avant" avec sous-titre
  - **Carousel horizontal** de cartes de projets
    - **Widget**: `_buildFeaturedProjectCard`
    - **Dimensions**: 300px de largeur, 280px de hauteur
    - **Navigation par carte**: → `ProjectDetailScreen`

##### 1.3.1 **FeaturedProjectCard** (Carte projet en vedette)
- **Fonctionnalités**:
  - **Image du projet**: Avec `CompactUniversalMediaCarouselWidget`
  - **Overlay créateur**: Photo de profil et nom
  - **Titre et description** du projet
  - **Indicateurs de statut**: Badges Premium, Vérifié
  - **Action principale**: Tap → Navigation vers `ProjectDetailScreen`

#### 1.4 **Section "Pour vous"** (Projets recommandés)
- **Condition**: Affiché si utilisateur connecté ET `recommendedProjects.isNotEmpty`
- **Limite**: Maximum 3 projets
- **Widget utilisé**: `SocialProjectCard`

#### 1.5 **Section "Tendances"** (Projets populaires)
- **Condition**: Affiché si `trendingProjects.isNotEmpty`
- **Limite**: Maximum 5 projets
- **Widget utilisé**: `SocialProjectCard`

#### 1.6 **Section "Récents"** (Derniers projets)
- **Affichage**: Toujours présent
- **Fonctionnalité**: Chargement infini (pagination)
- **Widget utilisé**: `SocialProjectCard`
- **Indicateur de chargement**: Affiché en bas si `hasMore = true`

### 2. **SocialProjectCard** (Composant Principal des Projets)
- **Fichier**: `lib/presentation/widgets/project/social_project_card.dart`
- **Type**: StatelessWidget
- **Style**: Card similaire aux réseaux sociaux (Facebook)

#### 2.1 **En-tête du Post**
- **Composants**:
  - **Photo de profil du créateur**
    - **Action**: Tap → Navigation vers profil créateur (TODO)
  - **Informations créateur**:
    - Nom complet
    - Badges (Vérifié, Premium)
    - Titre/qualité professionnelle
    - Temps écoulé depuis publication
  - **Menu options** (`Icons.more_vert`)
    - **Action**: Affiche menu contextuel (TODO)

#### 2.2 **Contenu du Projet**
- **Action**: Tap → Navigation vers `ProjectDetailScreen`
- **Composants**:
  - Titre du projet
  - Description (extrait)
  - Catégorie et localisation

#### 2.3 **Médias du Projet** (Conditionnel)
- **Widget**: `UniversalMediaCarouselWidget`
- **Condition**: Affiché si `project.hasAnyMedia`
- **Action**: Tap → Navigation vers `ProjectDetailScreen`

#### 2.4 **Détails du Projet**
- **Informations affichées**:
  - Stade de développement
  - Budget recherché
  - Pourcentage de financement
  - Date de fin de campagne
  - Nombre d'investisseurs

#### 2.5 **Stats et Actions Sociales**
- **Statistiques**:
  - Nombre de likes
  - Nombre de commentaires
  - Nombre de partages
- **Actions**:
  - **Bouton Like** (`Icons.favorite`)
    - **Action**: Toggle like/unlike
    - **Callback**: `onLike()`
  - **Bouton Intérêt** (`Icons.bookmark`)
    - **Action**: Marquer comme intéressant
    - **Callback**: `onInterest()`
  - **Bouton Commentaire** (`Icons.comment`)
    - **Action**: Ouvrir section commentaires
    - **Callback**: `onComment()`
  - **Bouton Partage** (`Icons.share`)
    - **Action**: Partager le projet
    - **Callback**: `onShare()`

### 3. **Écrans de Navigation Accessibles**

#### 3.1 **ProjectDetailScreen** (Page de Détail du Projet)
- **Fichier**: `lib/presentation/screens/project/project_detail_screen.dart`
- **Navigation depuis**: Tap sur carte projet, image, titre
- **Fonctionnalités**:
  - **SliverAppBar** avec image en plein écran
  - **Actions AppBar**:
    - Bouton favori
    - Bouton partage
    - Bouton retour
  - **Contenu détaillé**:
    - En-tête complet du projet
    - Description complète
    - Informations détaillées
    - Tags
    - Informations sur le créateur
  - **FloatingActionButton**: "Investir" (si pas propriétaire)
    - **Navigation**: → `InvestmentCreateScreen`

#### 3.2 **NotificationsScreen** (Page des Notifications)
- **Navigation depuis**: Bouton notifications de l'AppBar
- **Fonctionnalité**: Affichage des notifications utilisateur

#### 3.3 **ProjectCreateScreen** (Création de Projet)
- **Navigation depuis**: FloatingActionButton principal
- **Fonctionnalité**: Formulaire de création de nouveau projet

### 4. **Widgets Utilitaires**

#### 4.1 **UniversalMediaCarouselWidget**
- **Fichier**: `lib/presentation/widgets/project/universal_media_carousel_widget.dart`
- **Fonctionnalité**: Affichage des médias (images/vidéos) en carousel

#### 4.2 **CompactUniversalMediaCarouselWidget**
- **Usage**: Version compacte pour les cartes en vedette
- **Fonctionnalité**: Carousel optimisé pour petits espaces

### 5. **Fonctionnalités Transversales**

#### 5.1 **Gestion d'État**
- **ProjectProvider**: Gestion des projets et des filtres
- **AuthProvider**: Gestion de l'utilisateur connecté

#### 5.2 **Navigation**
- **RefreshIndicator**: Pull-to-refresh pour actualiser le feed
- **Scroll infini**: Chargement automatique des projets suivants
- **ScrollController**: Détection de fin de scroll pour pagination

#### 5.3 **Gestion des Erreurs**
- **État de chargement**: CircularProgressIndicator
- **État d'erreur**: Message d'erreur avec bouton retry
- **État vide**: Message "Aucun projet trouvé"

### 6. **Flux de Données**

#### 6.1 **Chargement Initial**
1. `initState()` → `loadProjects(refresh: true)`
2. Chargement depuis l'API via `ProjectProvider`
3. Mise à jour de l'interface via `Consumer<ProjectProvider>`

#### 6.2 **Filtrage**
1. Sélection de filtres dans `HomeFiltersWidget`
2. Appel de `_applyFilters()`
3. Rechargement des projets avec paramètres de filtre

#### 6.3 **Actions Sociales**
1. Tap sur bouton d'action (like, intérêt, etc.)
2. Appel API via le provider correspondant
3. Mise à jour locale et synchronisation

## Dépendances Clés

### Modèles de Données
- `ProjectModel`: Modèle principal des projets
- `CategoryModel`: Modèle des catégories
- `UserModel`: Modèle des utilisateurs/créateurs

### Services
- `ProjectProvider`: Gestion d'état et API des projets
- `AuthProvider`: Gestion de l'authentification
- `ApiService`: Services API backend

### Navigation
- `AppRouter`: Configuration des routes
- `AutoRoute`: Système de navigation déclarative

## Améliorations Identifiées

### Fonctionnalités Manquantes
1. **Navigation vers profil créateur** (TODO dans SocialProjectCard)
2. **Menu contextuel des projets** (TODO dans en-tête)
3. **Système de commentaires** (callback défini mais pas implémenté)
4. **Partage de projets** (callback défini mais pas implémenté)
5. **Filtres avancés** (bouton présent mais pas implémenté)

### Optimisations Possibles
1. **Cache des images** avec lazy loading
2. **Pré-chargement** des projets suivants
3. **Gestion offline** pour la consultation
4. **Analytics** sur les interactions utilisateur 