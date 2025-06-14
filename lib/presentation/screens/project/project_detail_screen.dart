import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ProjectDetailScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProject(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          if (projectProvider.isLoading ||
              projectProvider.currentProject == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (projectProvider.error != null) {
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
                      projectProvider.loadProject(widget.projectId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final project = projectProvider.currentProject!;
          final currentUser = context.watch<AuthProvider>().currentUser;
          final isOwner = currentUser?.id == project.creator.id;

          return CustomScrollView(
            slivers: [
              // App Bar avec image
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: project.media?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: project.media!.first.fileUrl ?? '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: const Center(
                                child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {
                      projectProvider.toggleFavorite(project.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // TODO: Implémenter le partage
                    },
                  ),
                ],
              ),

              // Contenu principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête du projet
                      _buildProjectHeader(project),

                      const SizedBox(height: 24),

                      // Actions principales
                      if (!isOwner) _buildActionButtons(project),

                      const SizedBox(height: 24),

                      // Description
                      _buildDescription(project),

                      const SizedBox(height: 24),

                      // Informations du projet
                      _buildProjectInfo(project),

                      const SizedBox(height: 24),

                      // Tags
                      if (project.tags?.isNotEmpty == true) _buildTags(project),

                      const SizedBox(height: 24),

                      // Créateur
                      _buildCreatorInfo(project),

                      const SizedBox(
                          height: 100), // Espace pour le bouton flottant
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          final project = projectProvider.currentProject;
          final currentUser = context.watch<AuthProvider>().currentUser;

          if (project == null || currentUser?.id == project.creator.id) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              context.router.push(InvestmentCreateRoute(projectId: project.id));
            },
            icon: const Icon(Icons.account_balance_wallet),
            label: const Text('Investir'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }

  Widget _buildProjectHeader(ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre et badges
        Row(
          children: [
            Expanded(
              child: Text(
                project.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            if (project.isPremium)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'PREMIUM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          project.shortDescription,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),

        const SizedBox(height: 16),

        // Statistiques
        Row(
          children: [
            _buildStatChip(Icons.visibility, project.viewsCount.toString()),
            const SizedBox(width: 12),
            _buildStatChip(
                Icons.favorite_border, project.favoritesCount.toString()),
            const SizedBox(width: 12),
            _buildStatChip(
                Icons.thumb_up_outlined, project.interestsCount.toString()),
            const Spacer(),
            Text(
              'Publié le ${DateFormat('dd/MM/yyyy').format(project.publishedAt ?? project.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(ProjectModel project) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<ProjectProvider>().toggleInterest(project.id);
            },
            icon: const Icon(Icons.thumb_up_outlined),
            label: const Text('Manifester mon intérêt'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {
            // TODO: Implémenter la messagerie
          },
          icon: const Icon(Icons.message_outlined),
          label: const Text('Contacter'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description du projet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          project.fullDescription,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildProjectInfo(ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations du projet',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow('Catégorie', project.category.getName('fr')),
              const Divider(),
              _buildInfoRow('Stade', _getStageLabel(project.stage)),
              const Divider(),
              _buildInfoRow('Financement recherché',
                  '${project.fundingMin.toInt()}k - ${project.fundingMax.toInt()}k ${project.fundingCurrency}'),
              if (project.locationCity != null ||
                  project.locationCountry != null) ...[
                const Divider(),
                _buildInfoRow('Localisation',
                    '${project.locationCity ?? ''} ${project.locationCountry ?? ''}'),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: project.tags!.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag.getName('fr'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCreatorInfo(ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À propos du créateur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: project.creator.profile?.profilePicture != null
                    ? CachedNetworkImageProvider(
                        project.creator.profile!.profilePicture!)
                    : null,
                child: project.creator.profile?.profilePicture == null
                    ? Text(
                        project.creator.firstName[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.creator.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (project.creator.profile?.title != null)
                      Text(
                        project.creator.profile!.title!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    if (project.creator.profile?.bioShort != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.creator.profile!.bioShort!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
      case 'DEVELOPMENT':
        return 'Développement';
      case 'GROWTH':
        return 'Croissance';
      default:
        return stage;
    }
  }
}
