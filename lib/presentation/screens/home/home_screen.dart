import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venturelink/core/config/config_service.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';

import 'package:venturelink/presentation/widgets/project/universal_media_carousel_widget.dart';
import 'package:venturelink/presentation/screens/debug/media_debug_screen.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Charger les projets au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('[HomeScreen] Initialisation - début chargement des projets');
      final projectProvider = context.read<ProjectProvider>();
      debugPrint(
          '[HomeScreen] ProjectProvider trouvé, nbr projets actuels: ${projectProvider.projects.length}');
      debugPrint(
          '[HomeScreen] État initial - isLoading: ${projectProvider.isLoading}, error: ${projectProvider.error}');

      projectProvider.loadProjects(refresh: true).then((_) {
        debugPrint(
            '[HomeScreen] Chargement terminé - nbr projets: ${projectProvider.projects.length}');
        debugPrint(
            '[HomeScreen] État final - isLoading: ${projectProvider.isLoading}, error: ${projectProvider.error}');
      }).catchError((error) {
        debugPrint('[HomeScreen] Erreur lors du chargement: $error');
      });
    });
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour ${user?.firstName ?? 'Utilisateur'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Restaurer après génération des routes
              // context.router.push(const SearchRoute());
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Restaurer après génération des routes
              // context.router.push(const NotificationsRoute());
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
          await context.read<ProjectProvider>().loadProjects(refresh: true);
        },
        child: Consumer<ProjectProvider>(
          builder: (context, projectProvider, child) {
            if (projectProvider.isLoading && projectProvider.projects.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (projectProvider.error != null &&
                projectProvider.projects.isEmpty) {
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
                      projectProvider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        projectProvider.loadProjects(refresh: true);
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (projectProvider.projects.isEmpty) {
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

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Section des projets mis en avant
                if (projectProvider.projects.any((p) => p.isFeatured))
                  SliverToBoxAdapter(
                    child: _buildFeaturedSection(context, projectProvider),
                  ),

                // Section des projets récents
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(ConfigService.defaultPadding),
                    child: Text(
                      'Projets récents',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),

                // Liste des projets
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < projectProvider.projects.length) {
                        return _buildProjectCard(
                            context, projectProvider.projects[index]);
                      } else if (projectProvider.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                    childCount: projectProvider.projects.length +
                        (projectProvider.hasMore ? 1 : 0),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Restaurer après génération des routes
          // context.router.push(const ProjectCreateRoute());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFeaturedSection(
      BuildContext context, ProjectProvider projectProvider) {
    final featuredProjects =
        projectProvider.projects.where((p) => p.isFeatured).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(ConfigService.defaultPadding),
          child: Text(
            'Projets mis en avant',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 245,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: ConfigService.defaultPadding),
            itemCount: featuredProjects.length,
            itemBuilder: (context, index) {
              return _buildFeaturedProjectCard(
                  context, featuredProjects[index]);
            },
          ),
        ),
        const SizedBox(height: ConfigService.defaultPadding),
      ],
    );
  }

  Widget _buildFeaturedProjectCard(BuildContext context, ProjectModel project) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(
        right: ConfigService.defaultSpacing,
        bottom: 4,
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // TODO: Restaurer après génération des routes
            // context.router.push(ProjectDetailRoute(projectId: project.id));
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image du projet avec carrousel de médias
              Stack(
                children: [
                  Container(
                    height: 115,
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

                  // Badge de comptage de médias (coin supérieur droit)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: MediaCountBadge(project: project),
                  ),

                  // Badge Premium (coin supérieur gauche)
                  if (project.isPremium)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
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
                    Row(
                      children: [
                        Icon(
                          Icons.euro,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${_formatAmount(project.fundingMin)} - ${_formatAmount(project.fundingMax)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: ConfigService.defaultPadding,
        vertical: ConfigService.defaultSpacing / 2,
      ),
      child: InkWell(
        onTap: () {
          // TODO: Restaurer après génération des routes
          // context.router.push(ProjectDetailRoute(projectId: project.id));
        },
        child: Padding(
          padding: const EdgeInsets.all(ConfigService.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec créateur
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        project.creator.profile?.profilePicture != null
                            ? CachedNetworkImageProvider(
                                project.creator.profile!.profilePicture!)
                            : null,
                    child: project.creator.profile?.profilePicture == null
                        ? Text(project.creator.firstName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.creator.fullName,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          project.creator.profile?.title ?? 'Entrepreneur',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (project.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Titre et description
              Text(
                project.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                project.shortDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Carrousel de médias du projet (si disponible)
              if (project.hasAnyMedia)
                Stack(
                  children: [
                    FeedUniversalMediaCarouselWidget(
                      mediaList: project.allMedia,
                      debugContext: 'Feed-${project.title}',
                    ),

                    // Badge de comptage de médias (coin supérieur droit)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: MediaCountBadge(project: project),
                    ),
                  ],
                ),

              // Tags
              if (project.tags?.isNotEmpty == true)
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: project.tags!.take(2).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag.getName('fr'), // TODO: Utiliser la locale actuelle
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),

              // Informations du projet
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildInfoChip(
                      context,
                      Icons.category_outlined,
                      project.category
                          .getName('fr'), // TODO: Utiliser la locale actuelle
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      Icons.timeline,
                      _getStageLabel(project.stage),
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      Icons.euro,
                      '${_formatAmount(project.fundingMin)} - ${_formatAmount(project.fundingMax)}',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Actions et statistiques
              Row(
                children: [
                  _buildStatChip(
                      Icons.visibility, project.viewsCount.toString()),
                  const SizedBox(width: 8),
                  _buildStatChip(
                      Icons.favorite_border, project.favoritesCount.toString()),
                  const SizedBox(width: 8),
                  _buildStatChip(Icons.thumb_up_outlined,
                      project.interestsCount.toString()),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      context
                          .read<ProjectProvider>()
                          .toggleFavorite(project.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.thumb_up_outlined),
                    onPressed: () {
                      context
                          .read<ProjectProvider>()
                          .toggleInterest(project.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getStageLabel(String stage) {
    switch (stage) {
      case 'IDEA':
        return 'Idée';
      case 'PROTOTYPE':
        return 'Prototype';
      case 'MVP':
        return 'MVP';
      case 'GROWTH':
        return 'Croissance';
      case 'EXPANSION':
        return 'Expansion';
      default:
        return stage;
    }
  }

  // Formater un montant financier pour un affichage plus lisible
  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }
}

/// Widget pour afficher le nombre de médias d'un projet
class MediaCountBadge extends StatelessWidget {
  final ProjectModel project;

  const MediaCountBadge({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    if (!project.hasAnyMedia) {
      return const SizedBox.shrink();
    }

    final mediaCount = project.allMedia.length;
    if (mediaCount <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.collections,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            mediaCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
