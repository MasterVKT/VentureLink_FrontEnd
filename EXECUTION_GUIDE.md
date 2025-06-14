# Guide d'Exécution Pratique
## Instructions Détaillées pour l'Implémentation

### 📋 **Prérequis et Préparation**

#### **Setup initial requis :**
```bash
# 1. Sauvegarde base de données
cd /d/Projets/VentureLink/env/venture_link_project
python manage.py dumpdata > backup_$(date +%Y%m%d).json

# 2. Installation Redis
# Windows : Télécharger Redis for Windows
# Ou utiliser Docker
docker run -d --name redis -p 6379:6379 redis:alpine

# 3. Dépendances Python additionnelles
pip install redis celery elasticsearch-dsl django-redis
pip install pillow imageio-ffmpeg  # Pour traitement médias

# 4. Dépendances Flutter additionnelles
cd ../venturelink
flutter pub add cached_network_image image_picker
flutter pub add file_picker carousel_slider
flutter pub add pull_to_refresh infinite_scroll_pagination
```

---

## 🎯 **PHASE 1 - EXÉCUTION DÉTAILLÉE**

### **1.1 Écran Liste Projets (Semaine 1)**

#### **Jour 1-2 : Backend Optimisations**

##### **Étape 1 : Configuration Redis**
```python
# venture_link_project/settings.py - Ajouter
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# Cache timeout
CACHE_TTL = 60 * 15  # 15 minutes
```

##### **Étape 2 : Optimiser ProjectViewSet**
**Fichier : `apps/projects/views/project_views.py`**
```python
# Ajouter méthodes de cache et filtrage avancé
from django.core.cache import cache
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import filters

class ProjectViewSet(viewsets.ModelViewSet):
    filter_backends = [
        DjangoFilterBackend, 
        filters.SearchFilter,
        filters.OrderingFilter
    ]
    filterset_fields = [
        'category', 'stage', 'location_country', 
        'location_city', 'status'
    ]
    search_fields = [
        'title', 'short_description', 'full_description',
        'tags__name'
    ]
    ordering_fields = [
        'created_at', 'funding_min', 'funding_max', 
        'view_count', 'favorite_count'
    ]
    
    def get_queryset(self):
        cache_key = f"projects_list_{self.request.user.id}"
        queryset = cache.get(cache_key)
        
        if not queryset:
            queryset = Project.objects.select_related(
                'creator', 'category'
            ).prefetch_related('tags', 'media')
            cache.set(cache_key, queryset, 900)  # 15 min
            
        return queryset
```

##### **Étape 3 : Nouveaux endpoints de filtrage**
**Fichier : `apps/projects/urls/api_urls.py`**
```python
# Ajouter routes
urlpatterns = [
    # ... existing routes ...
    path('search/', ProjectSearchView.as_view(), name='project-search'),
    path('trending/', TrendingProjectsView.as_view(), name='trending'),
    path('categories/', CategoryListView.as_view(), name='categories'),
]
```

#### **Jour 3-5 : Frontend Interface**

##### **Étape 1 : Remplacer ProjectListScreen**
**Fichier : `lib/presentation/screens/project/project_list_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProjectListScreen extends StatefulWidget {
  @override
  _ProjectListScreenState createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final PagingController<int, ProjectModel> _pagingController =
      PagingController(firstPageKey: 1);
  final RefreshController _refreshController = RefreshController();
  
  String? _searchQuery;
  Map<String, dynamic> _filters = {};

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener(_fetchPage);
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final provider = Provider.of<ProjectProvider>(context, listen: false);
      final result = await provider.getProjects(
        page: pageKey,
        search: _searchQuery,
        filters: _filters,
      );

      if (result.hasNext) {
        _pagingController.appendPage(result.projects, pageKey + 1);
      } else {
        _pagingController.appendLastPage(result.projects);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projets'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFiltersSheet,
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        child: PagedListView<int, ProjectModel>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<ProjectModel>(
            itemBuilder: (context, project, index) =>
                ProjectCard(project: project),
            firstPageErrorIndicatorBuilder: (context) =>
                ErrorIndicator(
                  error: _pagingController.error,
                  onTryAgain: () => _pagingController.refresh(),
                ),
            noItemsFoundIndicatorBuilder: (context) =>
                EmptyStateWidget(
                  message: 'Aucun projet trouvé',
                  onRefresh: () => _pagingController.refresh(),
                ),
          ),
        ),
      ),
    );
  }
}
```

##### **Étape 2 : Composant ProjectCard**
**Fichier : `lib/presentation/widgets/project_card.dart`**
```dart
class ProjectCard extends StatelessWidget {
  final ProjectModel project;

  const ProjectCard({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 4,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context, 
          '/project-detail',
          arguments: project.id,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            Container(
              height: 200,
              width: double.infinity,
              child: project.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: project.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => 
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Icon(Icons.image, size: 50),
                    ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.title,
                          style: Theme.of(context).textTheme.headline6,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Chip(
                        label: Text(project.category.name),
                        backgroundColor: Colors.blue[100],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Description
                  Text(
                    project.shortDescription,
                    style: Theme.of(context).textTheme.bodyText2,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Funding info
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 16),
                      Text(
                        '${project.fundingMin.toStringAsFixed(0)}€ - ${project.fundingMax.toStringAsFixed(0)}€',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Icon(Icons.location_on, size: 16),
                      Text(project.locationCity ?? 'Non spécifiée'),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  // Actions
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          project.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: project.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () => _toggleFavorite(context),
                      ),
                      IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () {},
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () => _expressInterest(context),
                        child: Text('Intéressé'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### **1.2 Upload Médias (Semaine 2)**

#### **Jour 1 : Backend optimisations**

##### **Service de traitement médias**
**Fichier : `apps/projects/services/media_service.py`**
```python
from PIL import Image
import imageio
from django.core.files.base import ContentFile
from django.conf import settings
import uuid
import os

class MediaProcessingService:
    @staticmethod
    def process_image(image_file, max_size=(1920, 1080), quality=85):
        """Compresse et redimensionne une image"""
        img = Image.open(image_file)
        
        # Redimensionner si nécessaire
        if img.size[0] > max_size[0] or img.size[1] > max_size[1]:
            img.thumbnail(max_size, Image.Resampling.LANCZOS)
        
        # Sauvegarder avec compression
        output = BytesIO()
        format = 'JPEG' if img.mode == 'RGB' else 'PNG'
        img.save(output, format=format, quality=quality, optimize=True)
        
        return ContentFile(
            output.getvalue(),
            name=f"{uuid.uuid4()}.{format.lower()}"
        )
    
    @staticmethod
    def generate_thumbnail(image_file, size=(300, 200)):
        """Génère une miniature"""
        img = Image.open(image_file)
        img.thumbnail(size, Image.Resampling.LANCZOS)
        
        output = BytesIO()
        img.save(output, format='JPEG', quality=70)
        
        return ContentFile(
            output.getvalue(),
            name=f"thumb_{uuid.uuid4()}.jpg"
        )
```

#### **Jour 2-4 : Frontend interface**

##### **Composant MediaUploader**
**Fichier : `lib/presentation/widgets/media_uploader.dart`**
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MediaUploader extends StatefulWidget {
  final List<ProjectMediaModel> initialMedia;
  final Function(List<File>) onMediaChanged;
  final int maxImages;
  final int maxVideos;

  const MediaUploader({
    Key? key,
    this.initialMedia = const [],
    required this.onMediaChanged,
    this.maxImages = 10,
    this.maxVideos = 3,
  }) : super(key: key);

  @override
  _MediaUploaderState createState() => _MediaUploaderState();
}

class _MediaUploaderState extends State<MediaUploader> {
  List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Médias du projet',
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 16),
        
        // Grid de médias sélectionnés
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _selectedFiles.length + 1,
          itemBuilder: (context, index) {
            if (index == _selectedFiles.length) {
              return _buildAddMediaButton();
            }
            return _buildMediaItem(_selectedFiles[index], index);
          },
        ),
        
        SizedBox(height: 16),
        
        // Instructions
        Text(
          'Formats acceptés : JPG, PNG, MP4, MOV\n'
          'Taille max : 50MB par fichier\n'
          'Maximum ${widget.maxImages} images et ${widget.maxVideos} vidéos',
          style: Theme.of(context).textTheme.caption,
        ),
      ],
    );
  }

  Widget _buildAddMediaButton() {
    return GestureDetector(
      onTap: _showMediaOptions,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 40, color: Colors.grey[600]),
            Text('Ajouter', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaItem(File file, int index) {
    bool isVideo = file.path.toLowerCase().contains(RegExp(r'\.(mp4|mov|avi)$'));
    
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: !isVideo ? DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ) : null,
          ),
          child: isVideo ? Center(
            child: Icon(Icons.play_circle_filled, size: 40, color: Colors.white),
          ) : null,
        ),
        
        // Bouton supprimer
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeMedia(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Prendre une photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galerie photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Prendre une vidéo'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('Galerie vidéo'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      _addMedia(File(image.path));
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final XFile? video = await _picker.pickVideo(source: source);
    if (video != null) {
      _addMedia(File(video.path));
    }
  }

  void _addMedia(File file) {
    setState(() {
      _selectedFiles.add(file);
    });
    widget.onMediaChanged(_selectedFiles);
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onMediaChanged(_selectedFiles);
  }
}
```

---

### **1.3 Système Favoris/Intérêts (Semaine 3)**

#### **Frontend uniquement - APIs backend existantes**

##### **Service d'intérêts**
**Fichier : `lib/data/services/interest_service.dart`**
```dart
import 'package:venturelink/domain/services/i_api_service.dart';

class InterestService {
  final IApiService _apiService;

  InterestService(this._apiService);

  Future<bool> toggleFavorite(String projectId) async {
    try {
      await _apiService.post('/projects/$projectId/toggle_favorite/');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> expressInterest(String projectId) async {
    try {
      await _apiService.post('/projects/$projectId/toggle_interest/');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ProjectModel>> getFavoriteProjects() async {
    try {
      final response = await _apiService.get('/projects/favorites/');
      return (response.data['results'] as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<ProjectModel>> getInterestedProjects() async {
    try {
      final response = await _apiService.get('/projects/interests/');
      return (response.data['results'] as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
```

##### **Écrans favoris et intérêts**
**Fichier : `lib/presentation/screens/project/favorites_screen.dart`**
```dart
class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes intérêts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Favoris'),
            Tab(text: 'Intérêts exprimés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FavoriteProjectsList(),
          InterestedProjectsList(),
        ],
      ),
    );
  }
}
```

---

## 🚀 **PHASE 2 - MATCHING ET DÉCOUVERTE**

### **2.1 Algorithme Backend (Semaines 4-5)**

#### **Création app matching**
```bash
cd /d/Projets/VentureLink/env/venture_link_project
python manage.py startapp matching
mkdir -p apps/matching/services
mkdir -p apps/matching/serializers
```

##### **Modèles de matching**
**Fichier : `apps/matching/models.py`**
```python
from django.db import models
from django.contrib.auth import get_user_model
from apps.projects.models import Project

User = get_user_model()

class UserPreferences(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    preferred_categories = models.ManyToManyField('projects.Category')
    preferred_locations = models.JSONField(default=list)
    budget_min = models.DecimalField(max_digits=12, decimal_places=2, null=True)
    budget_max = models.DecimalField(max_digits=12, decimal_places=2, null=True)
    risk_tolerance = models.CharField(max_length=20, choices=[
        ('low', 'Faible'),
        ('medium', 'Moyen'),
        ('high', 'Élevé'),
    ], default='medium')
    preferred_stages = models.JSONField(default=list)
    
class MatchScore(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    project = models.ForeignKey(Project, on_delete=models.CASCADE)
    score = models.FloatField()
    factors = models.JSONField()  # Détail des facteurs de score
    calculated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        unique_together = ['user', 'project']
        
class UserInteraction(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    project = models.ForeignKey(Project, on_delete=models.CASCADE)
    interaction_type = models.CharField(max_length=20, choices=[
        ('view', 'Vue'),
        ('favorite', 'Favori'),
        ('interest', 'Intérêt'),
        ('message', 'Message'),
        ('investment', 'Investissement'),
    ])
    weight = models.FloatField(default=1.0)
    created_at = models.DateTimeField(auto_now_add=True)
```

##### **Algorithme de matching**
**Fichier : `apps/matching/services/matching_algorithm.py`**
```python
import numpy as np
from django.db.models import Q, Count, Avg
from typing import List, Dict, Tuple
from apps.projects.models import Project
from apps.matching.models import UserPreferences, MatchScore, UserInteraction

class MatchingAlgorithm:
    def __init__(self, user):
        self.user = user
        self.preferences = self._get_or_create_preferences()
        
    def calculate_project_scores(self, projects: List[Project]) -> List[Tuple[Project, float]]:
        """Calcule les scores de matching pour une liste de projets"""
        scored_projects = []
        
        for project in projects:
            score = self._calculate_single_score(project)
            scored_projects.append((project, score))
            
        return sorted(scored_projects, key=lambda x: x[1], reverse=True)
    
    def _calculate_single_score(self, project: Project) -> float:
        """Calcule le score pour un projet donné"""
        factors = {}
        
        # 1. Correspondance catégorie (poids: 30%)
        category_score = self._calculate_category_score(project)
        factors['category'] = category_score
        
        # 2. Correspondance géographique (poids: 20%)
        location_score = self._calculate_location_score(project)
        factors['location'] = location_score
        
        # 3. Correspondance budget (poids: 25%)
        budget_score = self._calculate_budget_score(project)
        factors['budget'] = budget_score
        
        # 4. Correspondance stage (poids: 15%)
        stage_score = self._calculate_stage_score(project)
        factors['stage'] = stage_score
        
        # 5. Historique interactions (poids: 10%)
        interaction_score = self._calculate_interaction_score(project)
        factors['interaction'] = interaction_score
        
        # Score final pondéré
        final_score = (
            category_score * 0.30 +
            location_score * 0.20 +
            budget_score * 0.25 +
            stage_score * 0.15 +
            interaction_score * 0.10
        )
        
        # Sauvegarder le score
        MatchScore.objects.update_or_create(
            user=self.user,
            project=project,
            defaults={
                'score': final_score,
                'factors': factors
            }
        )
        
        return final_score
    
    def _calculate_category_score(self, project: Project) -> float:
        """Score basé sur les catégories préférées"""
        if not self.preferences.preferred_categories.exists():
            return 0.5  # Score neutre si pas de préférences
            
        if project.category in self.preferences.preferred_categories.all():
            return 1.0
        return 0.0
    
    def _calculate_location_score(self, project: Project) -> float:
        """Score basé sur la localisation"""
        if not self.preferences.preferred_locations:
            return 0.5
            
        project_location = f"{project.location_country}_{project.location_city}"
        if project_location in self.preferences.preferred_locations:
            return 1.0
        elif project.location_country in [loc.split('_')[0] for loc in self.preferences.preferred_locations]:
            return 0.7  # Même pays
        return 0.3
    
    def _calculate_budget_score(self, project: Project) -> float:
        """Score basé sur l'adéquation budget"""
        if not self.preferences.budget_min or not self.preferences.budget_max:
            return 0.5
            
        # Vérifier si les budgets se chevauchent
        overlap_start = max(project.funding_min, float(self.preferences.budget_min))
        overlap_end = min(project.funding_max, float(self.preferences.budget_max))
        
        if overlap_start <= overlap_end:
            # Calculer le pourcentage de chevauchement
            project_range = project.funding_max - project.funding_min
            pref_range = float(self.preferences.budget_max - self.preferences.budget_min)
            overlap_range = overlap_end - overlap_start
            
            overlap_ratio = overlap_range / min(project_range, pref_range)
            return min(overlap_ratio, 1.0)
        
        return 0.0
    
    def _calculate_stage_score(self, project: Project) -> float:
        """Score basé sur le stage du projet"""
        if not self.preferences.preferred_stages:
            return 0.5
            
        if project.stage in self.preferences.preferred_stages:
            return 1.0
        return 0.0
    
    def _calculate_interaction_score(self, project: Project) -> float:
        """Score basé sur l'historique d'interactions"""
        # Interactions similaires de l'utilisateur
        similar_interactions = UserInteraction.objects.filter(
            user=self.user,
            interaction_type__in=['favorite', 'interest', 'investment']
        ).values_list('project__category', flat=True)
        
        if project.category.id in similar_interactions:
            return 0.8
            
        # Interactions sur des projets similaires
        similar_projects = Project.objects.filter(
            category=project.category,
            userinteraction__user=self.user
        ).count()
        
        if similar_projects > 0:
            return 0.6
            
        return 0.2
```

---

### **2.2 Interface Découverte (Semaine 6)**

##### **Service API matching**
**Fichier : `lib/data/services/matching_api_service.dart`**
```dart
class MatchingApiService {
  final IApiService _apiService;

  MatchingApiService(this._apiService);

  Future<List<ProjectModel>> getRecommendations({
    int limit = 20,
    String? category,
  }) async {
    try {
      final response = await _apiService.get(
        '/matching/recommendations/',
        queryParameters: {
          'limit': limit,
          if (category != null) 'category': category,
        },
      );
      
      return (response.data['results'] as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<UserModel>> getMatchingInvestors(String projectId) async {
    try {
      final response = await _apiService.get('/matching/investors/$projectId/');
      return (response.data['results'] as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<double> getMatchingScore(String projectId) async {
    try {
      final response = await _apiService.get('/matching/score/$projectId/');
      return response.data['score'].toDouble();
    } catch (e) {
      return 0.0;
    }
  }
}
```

##### **Interface swipable découverte**
**Fichier : `lib/presentation/screens/discover/discover_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ProjectModel> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Découvrir'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Recommandés'),
            Tab(text: 'Tendances'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendationsTab(),
          _buildTrendingTab(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_recommendations.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Header avec stats
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Projets', '${_recommendations.length}'),
              _buildStatCard('Matches', '87%'),
              _buildStatCard('Nouveaux', '12'),
            ],
          ),
        ),
        
        // Cards swipables
        Expanded(
          child: Swiper(
            itemBuilder: (context, index) {
              return SwipeableProjectCard(
                project: _recommendations[index],
                onSwipeLeft: () => _onReject(_recommendations[index]),
                onSwipeRight: () => _onInterest(_recommendations[index]),
                onTap: () => _openProjectDetail(_recommendations[index]),
              );
            },
            itemCount: _recommendations.length,
            pagination: SwiperPagination(),
            control: SwiperControl(),
            loop: false,
          ),
        ),
        
        // Boutons d'action
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.red,
            heroTag: "reject",
            child: Icon(Icons.close),
            onPressed: () => _onReject(_recommendations.first),
          ),
          FloatingActionButton(
            backgroundColor: Colors.blue,
            heroTag: "info",
            child: Icon(Icons.info),
            onPressed: () => _openProjectDetail(_recommendations.first),
          ),
          FloatingActionButton(
            backgroundColor: Colors.green,
            heroTag: "like",
            child: Icon(Icons.favorite),
            onPressed: () => _onInterest(_recommendations.first),
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 **CHECKLIST DE VALIDATION**

### **Phase 1 - Validation :**
- [ ] Liste projets charge en <2 secondes
- [ ] Filtres fonctionnent correctement
- [ ] Upload médias fonctionne (images + vidéos)
- [ ] Système favoris/intérêts opérationnel
- [ ] Interface responsive sur mobile/tablet

### **Phase 2 - Validation :**
- [ ] Algorithme matching génère scores cohérents
- [ ] Recommandations personnalisées affichées
- [ ] Interface découverte fluide et engageante
- [ ] APIs matching <500ms de réponse

### **Phase 3 - Validation :**
- [ ] Commentaires threaded fonctionnels
- [ ] Recherche full-text performante
- [ ] Filtres avancés précis

### **Phase 4 - Validation :**
- [ ] Dashboards analytics informatifs
- [ ] Paiements sécurisés (si implémenté)
- [ ] Performance globale optimisée

Ce guide fournit toutes les instructions nécessaires pour exécuter le plan d'implémentation de manière méthodique et progressive. 