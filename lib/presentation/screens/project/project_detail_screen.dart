import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/messaging_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/presentation/widgets/project/interest_expression_widget.dart';
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

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorited = false;
  bool _hasInterest = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProject();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProject() async {
    final projectProvider = context.read<ProjectProvider>();

    // Optimisation : vérifier si le projet est déjà en cache
    if (projectProvider.currentProject?.id == widget.projectId) {
      // Synchroniser l'état favori depuis le modèle
      if (mounted) {
        setState(() {
          _isFavorited = projectProvider.currentProject!.isFavorite;
        });
      }
      return;
    }

    await projectProvider.loadProject(widget.projectId);

    // Initialiser l'état favori depuis le modèle chargé
    if (mounted && projectProvider.currentProject != null) {
      setState(() {
        _isFavorited = projectProvider.currentProject!.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Hauteur responsive du SliverAppBar
    final expandedHeight =
        isTablet ? 300.0 : (screenHeight * 0.35).clamp(200.0, 280.0);

    // Padding adaptatif
    final horizontalPadding =
        isTablet ? AppConfig.defaultPadding * 2 : AppConfig.defaultPadding;

    return Scaffold(
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          // État de chargement amélioré
          if (projectProvider.isLoading ||
              projectProvider.currentProject == null) {
            return _buildLoadingState();
          }

          // État d'erreur amélioré
          if (projectProvider.error != null) {
            return _buildErrorState(projectProvider.error!);
          }

          final project = projectProvider.currentProject!;
          final currentUser = context.watch<AuthProvider>().currentUser;
          final isOwner = currentUser?.id == project.creator.id;

          return CustomScrollView(
            slivers: [
              // App Bar avec image améliorée
              _buildSliverAppBar(project, expandedHeight),

              // Contenu principal avec padding adaptatif
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: AppConfig.defaultPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête du projet avec animations
                      _buildProjectHeader(project),

                      _buildSpacer(isTablet ? 32 : 24),

                      // Actions principales avec feedback visuel
                      if (!isOwner) _buildActionButtons(project),

                      _buildSpacer(isTablet ? 32 : 24),

                      // Description
                      _buildDescription(project),

                      _buildSpacer(isTablet ? 32 : 24),

                      // Informations du projet améliorées
                      _buildProjectInfo(project, isTablet),

                      _buildSpacer(isTablet ? 32 : 24),

                      // Tags améliorés
                      if (project.tags?.isNotEmpty == true) _buildTags(project),

                      _buildSpacer(isTablet ? 32 : 24),

                      // Créateur avec accessibilité améliorée
                      _buildCreatorInfo(project),

                      _buildSpacer(120), // Espace pour le bouton flottant
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildInvestmentButton(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement du projet...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
              semanticLabel: 'Erreur',
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProject,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ProjectModel project, double expandedHeight) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildProjectImage(project),
      ),
      actions: [
        // Bouton favori avec animation
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isFavorited ? _scaleAnimation.value : 1.0,
              child: IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : null,
                  semanticLabel: _isFavorited
                      ? 'Retirer des favoris'
                      : 'Ajouter aux favoris',
                ),
                onPressed: () => _handleToggleFavorite(project),
              ),
            );
          },
        ),
        // Bouton partage fonctionnel
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () => _handleShare(project),
          tooltip: 'Partager ce projet',
        ),
      ],
    );
  }

  Widget _buildProjectImage(ProjectModel project) {
    // Utilisation du nouveau système de médias
    final imageUrl = project.hasAnyMedia ? project.allMedia.first.url : null;

    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildImageError(),
      );
    }

    return _buildDefaultBackground();
  }

  Widget _buildImageError() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.errorContainer,
            Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 48,
            semanticLabel: 'Image non disponible',
          ),
          const SizedBox(height: 8),
          Text(
            'Image non disponible',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
      ),
      child: Icon(
        Icons.lightbulb_outline,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 64,
        semanticLabel: 'Icône de projet',
      ),
    );
  }

  Widget _buildSpacer(double height) {
    return SizedBox(height: height);
  }

  Widget _buildProjectHeader(ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre et badges
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                project.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            if (project.isPremium) _buildPremiumBadge(),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          project.shortDescription,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
        ),

        const SizedBox(height: 20),

        // Statistiques avec meilleur alignement
        _buildStatsRow(project),
      ],
    );
  }

  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'PREMIUM',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsRow(ProjectModel project) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildStatChip(
          Icons.visibility,
          project.viewsCount.toString(),
          'Vues',
        ),
        _buildStatChip(
          Icons.favorite_border,
          project.favoritesCount.toString(),
          'Favoris',
        ),
        _buildStatChip(
          Icons.thumb_up_outlined,
          project.interestsCount.toString(),
          'Intérêts',
        ),
        Text(
          'Publié le ${DateFormat('dd/MM/yyyy').format(project.publishedAt ?? project.createdAt ?? DateTime.now())}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ProjectModel project) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleToggleInterest(project),
                icon: Icon(
                  _hasInterest ? Icons.thumb_up : Icons.thumb_up_outlined,
                  semanticLabel:
                      _hasInterest ? 'Retirer intérêt' : 'Manifester intérêt',
                ),
                label: Text(_hasInterest
                    ? 'Intérêt manifesté'
                    : 'Manifester mon intérêt'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(0, 48), // Accessibilité
                  backgroundColor: _hasInterest
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleContact(project),
                icon: const Icon(
                  Icons.message_outlined,
                  semanticLabel: 'Contacter le créateur',
                ),
                label: const Text('Contacter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(0, 48), // Accessibilité
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ],
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
        const SizedBox(height: 16),
        Text(
          project.fullDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6, // Meilleure lisibilité
              ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo(ProjectModel project, bool isTablet) {
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
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow('Catégorie', project.category.getName('fr')),
              const Divider(height: 24),
              _buildInfoRow('Stade', _getStageLabel(project.stage)),
              const Divider(height: 24),
              _buildInfoRow('Financement recherché',
                  '${_formatAmount(project.fundingMin)} - ${_formatAmount(project.fundingMax)} ${project.fundingCurrency}'),
              if (project.locationCity != null ||
                  project.locationCountry != null) ...[
                const Divider(height: 24),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
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
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: project.tags!.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                tag.getName('fr'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
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
        InkWell(
          onTap: () {
            context.router.push(
              PublicProfileRoute(user: project.creator),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage:
                      project.creator.profile?.profilePicture != null
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
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (project.creator.profile?.title != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          project.creator.profile!.title!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ],
                      if (project.creator.profile?.bioShort != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          project.creator.profile!.bioShort!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height: 1.4,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentButton() {
    return Consumer<ProjectProvider>(
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
          icon: const Icon(
            Icons.account_balance_wallet,
            semanticLabel: 'Investir dans ce projet',
          ),
          label: const Text('Investir'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }

  Widget _buildStatChip(IconData icon, String count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          semanticLabel: label,
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w500,
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

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k';
    }
    return amount.toStringAsFixed(0);
  }

  // Actions avec feedback visuel et haptique
  Future<void> _handleToggleFavorite(ProjectModel project) async {
    // Feedback haptique
    HapticFeedback.lightImpact();

    // Animation
    if (!_isFavorited) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
    }

    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      final success =
          await context.read<ProjectProvider>().toggleFavorite(project.id);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isFavorited
                  ? 'Projet ajouté aux favoris'
                  : 'Projet retiré des favoris'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Annuler le changement en cas d'échec
        setState(() {
          _isFavorited = !_isFavorited;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la mise à jour des favoris'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      // Annuler le changement en cas d'erreur
      setState(() {
        _isFavorited = !_isFavorited;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleToggleInterest(ProjectModel project) async {
    // Feedback haptique
    HapticFeedback.selectionClick();

    if (_hasInterest) {
      // Si l'utilisateur a déjà manifesté son intérêt, le retirer directement
      setState(() {
        _hasInterest = false;
      });

      try {
        final success =
            await context.read<ProjectProvider>().toggleInterest(project.id);

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Intérêt retiré'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          // Annuler le changement en cas d'échec
          setState(() {
            _hasInterest = true;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de la suppression de l\'intérêt'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        // Annuler le changement en cas d'erreur
        setState(() {
          _hasInterest = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur de connexion'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      // Utiliser le widget avancé pour manifester l'intérêt
      await InterestExpressionHelper.show(
        context,
        project,
        onSuccess: () {
          setState(() {
            _hasInterest = true;
          });
        },
      );
    }
  }

  Future<void> _handleShare(ProjectModel project) async {
    // Feedback haptique
    HapticFeedback.selectionClick();

    try {
      final shareUrl = 'https://venturelink.com/projects/${project.id}';
      final shareText = 'Découvrez ce projet innovant sur VentureLink !\n\n'
          '📋 ${project.title}\n'
          '💡 ${project.shortDescription}\n\n'
          '🔗 $shareUrl';

      await Share.share(
        shareText,
        subject: 'Projet VentureLink: ${project.title}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du partage'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleContact(ProjectModel project) async {
    // Feedback haptique
    HapticFeedback.selectionClick();

    try {
      final messagingProvider = context.read<MessagingProvider>();

      // Créer ou récupérer la conversation directe avec message initial
      final conversation = await messagingProvider.createConversation(
        project.creator.id,
        'Bonjour, je suis intéressé par votre projet "${project.title}". Pourrions-nous en discuter ?',
      );

      if (mounted && conversation != null) {
        // Naviguer vers la conversation
        context.router.push(const MessagingRoute());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Conversation ouverte avec ${project.creator.fullName}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'ouverture de la conversation'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur de connexion'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
