import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/models/user_model.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/content_provider.dart';

import 'package:venturelink/presentation/widgets/project/universal_media_carousel_widget.dart';
import 'package:venturelink/presentation/widgets/project/social_project_card.dart';
import 'package:venturelink/presentation/widgets/home/home_filters_widget.dart';
import 'package:venturelink/presentation/screens/debug/media_debug_screen.dart';
import 'package:venturelink/core/router/app_router.dart';

@RoutePage()
class HomeScreenEnhanced extends StatefulWidget {
  const HomeScreenEnhanced({super.key});

  @override
  State<HomeScreenEnhanced> createState() => _HomeScreenEnhancedState();
}

class _HomeScreenEnhancedState extends State<HomeScreenEnhanced> {
  final ScrollController _scrollController = ScrollController();
  bool _showFilters = false;

  // Filtres
  String? _selectedCategory;
  String? _selectedStage;
  String? _selectedLocation;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Charger les projets au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('[HomeScreen] Initialisation - début chargement des projets');

      // Authentification automatique pour les tests
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        await authProvider.autoLoginForTesting();
      }

      if (mounted) {
        final projectProvider = context.read<ProjectProvider>();

        projectProvider.loadProjects().then((_) {
          debugPrint(
              '[HomeScreen] Chargement terminé - nbr projets: ${projectProvider.projects.length}');

          // Charger aussi les projets spécialisés
          _loadSpecializedProjects();
        }).catchError((error) {
          debugPrint('[HomeScreen] Erreur lors du chargement: $error');
        });
      }
    });
  }

  Future<void> _loadSpecializedProjects() async {
    final projectProvider = context.read<ProjectProvider>();
    final contentProvider = context.read<ContentProvider>();

    try {
      // Charger les projets et publications en parallèle
      await Future.wait([
        projectProvider.loadTrendingProjects().catchError((e) {
          debugPrint('[HomeScreen] Erreur chargement projets tendance: $e');
        }),
        projectProvider.loadFeaturedProjects().catchError((e) {
          debugPrint('[HomeScreen] Erreur chargement projets mis en avant: $e');
        }),
        contentProvider.loadFeaturedPublications().catchError((e) {
          debugPrint(
              '[HomeScreen] Erreur chargement publications mises en avant: $e');
        }),
        contentProvider.loadPublications().catchError((e) {
          debugPrint('[HomeScreen] Erreur chargement publications: $e');
        }),
        if (context.read<AuthProvider>().isAuthenticated)
          projectProvider.loadRecommendedProjects().catchError((e) {
            debugPrint(
                '[HomeScreen] Erreur chargement projets recommandés: $e');
          }),
      ]);
      debugPrint(
          '[HomeScreen] Chargement des projets et publications spécialisés terminé');
    } catch (e) {
      debugPrint('[HomeScreen] Erreur générale lors du chargement: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Charger plus de projets quand on approche de la fin
      context.read<ProjectProvider>().loadMoreProjects();
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final projectProvider = context.read<ProjectProvider>();
    projectProvider.loadProjects(
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStage = null;
      _selectedLocation = null;
      _searchQuery = null;
    });
    context.read<ProjectProvider>().loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('Bonjour ${user?.firstName ?? 'Utilisateur'}'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          // Bouton de recherche/filtres
          IconButton(
            icon:
                Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.router.push(const NotificationsRoute());
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.orange),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MediaDebugScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<ProjectProvider>().loadProjects();
          await _loadSpecializedProjects();
        },
        child: Consumer<ProjectProvider>(
          builder: (context, projectProvider, child) {
            if (projectProvider.isLoading && projectProvider.projects.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (projectProvider.error != null &&
                projectProvider.projects.isEmpty) {
              return _buildErrorState(projectProvider.error!);
            }

            if (projectProvider.projects.isEmpty) {
              return _buildEmptyState();
            }

            // Organiser les projets en sections
            final featuredProjects = projectProvider.featuredProjects;
            final trendingProjects = projectProvider.trendingProjects;
            final recentProjects = _getRecentProjects(projectProvider.projects);
            final recommendedProjects = projectProvider.recommendedProjects;

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Filtres (si affichés)
                if (_showFilters)
                  SliverToBoxAdapter(
                    child: HomeFiltersWidget(
                      selectedCategory: _selectedCategory,
                      selectedStage: _selectedStage,
                      selectedLocation: _selectedLocation,
                      categories: projectProvider.categories,
                      onCategoryChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _applyFilters();
                      },
                      onStageChanged: (stage) {
                        setState(() {
                          _selectedStage = stage;
                        });
                        _applyFilters();
                      },
                      onLocationChanged: (location) {
                        setState(() {
                          _selectedLocation = location;
                        });
                        _applyFilters();
                      },
                      onClearFilters: _clearFilters,
                      onAdvancedFilters: _showAdvancedFilters,
                    ),
                  ),

                // Section "Projets mis en avant" (carousel horizontal)
                if (featuredProjects.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildFeaturedSection(featuredProjects),
                  ),

                // Section "Pour vous" (si utilisateur connecté)
                if (user != null && recommendedProjects.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                        'Pour vous', 'Projets recommandés pour votre profil'),
                  ),
                if (user != null && recommendedProjects.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SocialProjectCard(
                          project: recommendedProjects[index],
                          onLike: () => _handleLike(recommendedProjects[index]),
                          onInterest: () =>
                              _handleInterest(recommendedProjects[index]),
                          onComment: () =>
                              _handleComment(recommendedProjects[index]),
                          onShare: () =>
                              _handleShare(recommendedProjects[index]),
                          onProfileTap: () => _handleProfileTap(
                              recommendedProjects[index].creator),
                          onMenuTap: () =>
                              _handleMenuTap(recommendedProjects[index]),
                        ),
                      ),
                      childCount:
                          recommendedProjects.length.clamp(0, 3), // Limiter à 3
                    ),
                  ),

                // Section "Tendances"
                if (trendingProjects.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                        'Tendances', 'Projets qui font le buzz cette semaine'),
                  ),
                if (trendingProjects.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SocialProjectCard(
                          project: trendingProjects[index],
                          onLike: () => _handleLike(trendingProjects[index]),
                          onInterest: () =>
                              _handleInterest(trendingProjects[index]),
                          onComment: () =>
                              _handleComment(trendingProjects[index]),
                          onShare: () => _handleShare(trendingProjects[index]),
                          onProfileTap: () => _handleProfileTap(
                              trendingProjects[index].creator),
                          onMenuTap: () =>
                              _handleMenuTap(trendingProjects[index]),
                        ),
                      ),
                      childCount:
                          trendingProjects.length.clamp(0, 5), // Limiter à 5
                    ),
                  ),

                // Section "Récents"
                SliverToBoxAdapter(
                  child: _buildSectionHeader(
                      'Récents', 'Derniers projets publiés'),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < recentProjects.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SocialProjectCard(
                            project: recentProjects[index],
                            onLike: () => _handleLike(recentProjects[index]),
                            onInterest: () =>
                                _handleInterest(recentProjects[index]),
                            onComment: () =>
                                _handleComment(recentProjects[index]),
                            onShare: () => _handleShare(recentProjects[index]),
                            onProfileTap: () => _handleProfileTap(
                                recentProjects[index].creator),
                            onMenuTap: () =>
                                _handleMenuTap(recentProjects[index]),
                          ),
                        );
                      } else if (projectProvider.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: recentProjects.length +
                        (projectProvider.hasMore ? 1 : 0),
                  ),
                ),

                // Espace pour le FAB
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(const ProjectCreateRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(List<ProjectModel> featuredProjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
            'Mis en avant', 'Projets sélectionnés par notre équipe'),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredProjects.length,
            itemBuilder: (context, index) {
              return _buildFeaturedProjectCard(featuredProjects[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProjectCard(ProjectModel project) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            context.router.push(ProjectDetailRoute(projectId: project.id));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec overlay
              Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: project.hasAnyMedia
                        ? CompactUniversalMediaCarouselWidget(
                            mediaList: project.allMedia,
                            debugContext: 'Featured-${project.title}',
                          )
                        : const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                  ),

                  // Overlay avec info du créateur
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _handleProfileTap(project.creator),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundImage: project
                                          .creator.profile?.profilePicture !=
                                      null
                                  ? CachedNetworkImageProvider(
                                      project.creator.profile!.profilePicture!)
                                  : null,
                              child: project.creator.profile?.profilePicture ==
                                      null
                                  ? Text(
                                      project.creator.firstName[0]
                                          .toUpperCase(),
                                      style: const TextStyle(fontSize: 12),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              project.creator.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Badges
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (project.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (project.isVerified) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'VÉRIFIÉ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              // Contenu
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project.shortDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Stats
                    Row(
                      children: [
                        Icon(Icons.visibility,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          project.viewsCount.toString(),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.favorite_border,
                            size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          project.interestsCount.toString(),
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatAmount(project.fundingMin)} - ${_formatAmount(project.fundingMax)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<ProjectProvider>().loadProjects();
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucun projet trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Soyez le premier à créer un projet !',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _searchQuery ?? '');
        return AlertDialog(
          title: const Text('Rechercher des projets'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Entrez votre recherche...',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
            onSubmitted: (value) {
              _onSearch(value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _onSearch('');
                Navigator.pop(context);
              },
              child: const Text('Effacer'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _onSearch(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Rechercher'),
            ),
          ],
        );
      },
    );
  }

  // Algorithmes de répartition des projets
  List<ProjectModel> _getRecentProjects(List<ProjectModel> projects) {
    // Tous les projets triés par date de publication
    return projects.toList()
      ..sort((a, b) => (b.publishedAt ?? b.createdAt ?? DateTime.now())
          .compareTo(a.publishedAt ?? a.createdAt ?? DateTime.now()));
  }

  // Actions améliorées sur les projets
  void _handleLike(ProjectModel project) {
    context.read<ProjectProvider>().toggleFavorite(project.id);

    // Feedback haptique
    HapticFeedback.lightImpact();

    // Afficher un snackbar de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Action effectuée avec succès'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleInterest(ProjectModel project) {
    // Afficher un bottom sheet pour exprimer l'intérêt
    _showInterestBottomSheet(project);
  }

  void _handleComment(ProjectModel project) {
    // Naviguer vers l'écran de détail du projet
    context.router.push(ProjectDetailRoute(projectId: project.id));
  }

  void _handleShare(ProjectModel project) {
    final shareUrl = 'https://venturelink.com/projects/${project.id}';
    final shareText =
        'Découvrez ce projet: ${project.title}\n\n${project.shortDescription}\n\n$shareUrl';

    Share.share(
      shareText,
      subject: 'Projet VentureLink: ${project.title}',
    );
  }

  void _handleProfileTap(UserModel creator) {
    // TODO: Implémenter navigation vers profil
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profil de ${creator.fullName}')),
    );
  }

  void _handleMenuTap(ProjectModel project) {
    _showProjectMenu(project);
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildAdvancedFiltersSheet(),
    );
  }

  void _showInterestBottomSheet(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildInterestBottomSheet(project),
    );
  }

  void _showProjectMenu(ProjectModel project) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildProjectMenuSheet(project),
    );
  }

  Widget _buildAdvancedFiltersSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres avancés',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Filtres de financement
          Text(
            'Financement recherché',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Montant minimum',
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Montant maximum',
                    prefixText: '€ ',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Filtres par tags
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          // TODO: Implémenter sélection de tags

          const Spacer(),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Appliquer les filtres avancés
                    Navigator.pop(context);
                  },
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestBottomSheet(ProjectModel project) {
    final messageController = TextEditingController();
    final amountController = TextEditingController();
    bool isAnonymous = false;

    return StatefulBuilder(
      builder: (context, setState) => Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exprimer votre intérêt',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour: ${project.title}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message (optionnel)',
                hintText: 'Expliquez votre intérêt pour ce projet...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Montant d\'investissement envisagé',
                prefixText: '€ ',
                hintText: '50000',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isAnonymous,
                  onChanged: (value) {
                    setState(() {
                      isAnonymous = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    'Exprimer cet intérêt de manière anonyme',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Appeler l'API pour exprimer l'intérêt
                      context.read<ProjectProvider>().expressInterest(
                            project.id,
                            message: messageController.text,
                            amount: double.tryParse(amountController.text),
                            isAnonymous: isAnonymous,
                          );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Intérêt exprimé avec succès!'),
                        ),
                      );
                    },
                    child: const Text('Exprimer l\'intérêt'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectMenuSheet(ProjectModel project) {
    final currentUser = context.read<AuthProvider>().currentUser;
    final isOwner = currentUser?.id == project.creator.id;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOwner) ...[
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Signaler ce projet'),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(project);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off_outlined),
              title: const Text('Masquer ce projet'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter masquage
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Ajouter aux favoris'),
              onTap: () {
                Navigator.pop(context);
                _handleLike(project);
              },
            ),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Modifier le projet'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la route d'édition
                // context.router.push(ProjectEditRoute(projectId: project.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Voir les statistiques'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implémenter la route d'analytics
                // context.router.push(ProjectAnalyticsRoute(projectId: project.id));
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.close),
            title: const Text('Fermer'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Signaler ce projet'),
        content: const Text('Pourquoi souhaitez-vous signaler ce projet ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter signalement
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Signalement envoyé. Merci pour votre vigilance.'),
                ),
              );
            },
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M€';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k€';
    }
    return '${amount.toStringAsFixed(0)}€';
  }
}
