import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/presentation/widgets/project/universal_media_carousel_widget.dart';

/// Widget pour afficher un projet dans le style des réseaux sociaux (Facebook)
class SocialProjectCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onLike;
  final VoidCallback? onInterest;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onProfileTap;
  final VoidCallback? onMenuTap;

  const SocialProjectCard({
    super.key,
    required this.project,
    this.onLike,
    this.onInterest,
    this.onComment,
    this.onShare,
    this.onProfileTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du post avec info du créateur
          _buildPostHeader(context),

          // Contenu du projet
          _buildProjectContent(context),

          // Médias du projet
          if (project.hasAnyMedia) _buildProjectMedia(context),

          // Informations détaillées du projet
          _buildProjectDetails(context),

          // Stats et actions
          _buildStatsAndActions(context),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Photo de profil du créateur
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 24,
              backgroundImage: project.creator.profile?.profilePicture != null
                  ? CachedNetworkImageProvider(
                      project.creator.profile!.profilePicture!)
                  : null,
              child: project.creator.profile?.profilePicture == null
                  ? Text(
                      project.creator.firstName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

          // Infos du créateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom du créateur uniquement
                Text(
                  project.creator.fullName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                // Badges organisés horizontalement avec espacement
                Row(
                  children: [
                    // Badge vérifié
                    if (project.isVerified) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Vérifié',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],

                    // Badge Premium
                    if (project.isPremium) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),

                const SizedBox(height: 2),

                // Qualité et temps sur une ligne séparée
                Row(
                  children: [
                    // Qualité/titre du créateur
                    if (project.creator.profile?.title != null) ...[
                      Expanded(
                        child: Text(
                          project.creator.profile!.title!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(' • ',
                          style: TextStyle(color: Colors.grey, fontSize: 11)),
                    ],

                    // Temps écoulé depuis publication
                    Text(
                      _getTimeAgo(project.publishedAt ?? project.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu options
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onMenuTap,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(ProjectDetailRoute(projectId: project.id));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre du projet
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              project.shortDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectMedia(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.router.push(ProjectDetailRoute(projectId: project.id));
      },
      child: FeedUniversalMediaCarouselWidget(
        mediaList: project.allMedia,
        debugContext: 'SocialCard-${project.title}',
      ),
    );
  }

  Widget _buildProjectDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          if (project.tags?.isNotEmpty == true) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.tags!.take(3).map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${tag.getName('fr')}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Informations détaillées en grille
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.category_outlined,
                        'Catégorie',
                        project.category.getName('fr'),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.timeline,
                        'Stade',
                        _getStageLabel(project.stage),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.location_on_outlined,
                        'Localisation',
                        '${project.locationCity ?? ''} ${project.locationCountry ?? ''}',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        Icons.euro,
                        'Financement',
                        '${_formatAmount(project.fundingMin)} - ${_formatAmount(project.fundingMax)}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Barre de progression du financement (style ancienne page Découvrir)
                const SizedBox(height: 8),
                _buildFundingProgress(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsAndActions(BuildContext context) {
    return Column(
      children: [
        // Stats (version plus compacte)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildStatItem(
                      Icons.visibility, project.viewsCount.toString()),
                  const SizedBox(width: 12),
                  _buildStatItem(
                      Icons.favorite_border, project.favoritesCount.toString()),
                  const SizedBox(width: 12),
                  _buildStatItem(Icons.thumb_up_outlined,
                      project.interestsCount.toString()),
                  const SizedBox(width: 12),
                  _buildStatItem(Icons.comment_outlined,
                      '0'), // TODO: Récupérer depuis l'API
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Il y a ${_getTimeAgo(project.publishedAt ?? project.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 16),

        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  Icons.thumb_up_outlined,
                  'J\'aime',
                  onLike ?? () {},
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  context,
                  Icons.favorite_outline,
                  'Intéressé',
                  onInterest ?? () {},
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  context,
                  Icons.comment_outlined,
                  'Commenter',
                  onComment ?? () {},
                ),
              ),
              Expanded(
                child: _buildActionButton(
                  context,
                  Icons.share_outlined,
                  'Partager',
                  onShare ?? () {},
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFundingProgress(BuildContext context) {
    // Simulation du pourcentage de progression (en attendant les vraies données)
    final targetAmount =
        project.fundingMax > 0 ? project.fundingMax : project.fundingMin;
    final collectedAmount = targetAmount * 0.35; // Simulation 35% collecté
    final progressPercent = targetAmount > 0
        ? (collectedAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Montants collecté / objectif (plus compact)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Collecté: ${_formatAmount(collectedAmount)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 10,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(
              child: Text(
                'Objectif: ${_formatAmount(targetAmount)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Barre de progression ORANGE (style ancienne page Découvrir)
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progressPercent,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Pourcentage en ORANGE
        Text(
          '${(progressPercent * 100).toInt()}% de l\'objectif atteint',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M€';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k€';
    }
    return '${amount.toStringAsFixed(0)}€';
  }
}
