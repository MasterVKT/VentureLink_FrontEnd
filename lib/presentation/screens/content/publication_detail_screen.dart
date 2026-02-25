import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/providers/content_provider.dart';
import '../../../data/models/publication_model.dart';
import '../../widgets/content/comment_widget.dart';
import '../../widgets/content/comment_input_widget.dart';
import '../../widgets/content/publication_media_widget.dart';

@RoutePage()
class PublicationDetailScreen extends StatefulWidget {
  final String publicationId;
  final String? tab;

  const PublicationDetailScreen({
    super.key,
    required this.publicationId,
    this.tab,
  });

  @override
  State<PublicationDetailScreen> createState() =>
      _PublicationDetailScreenState();
}

class _PublicationDetailScreenState extends State<PublicationDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  Publication? _publication;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Naviguer vers l'onglet commentaires si spécifié
    if (widget.tab == 'comments') {
      _tabController.index = 1;
    }

    _loadPublication();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPublication() async {
    final contentProvider = context.read<ContentProvider>();

    try {
      final publication =
          await contentProvider.getPublicationById(widget.publicationId);
      if (publication != null) {
        setState(() {
          _publication = publication;
          _isLoading = false;
        });

        // Charger les commentaires
        await contentProvider.loadPublicationComments(widget.publicationId);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_publication == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Publication')),
        body: const Center(
          child: Text('Publication non trouvée'),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildSliverAppBar(),
            _buildSliverTabBar(),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildContentTab(),
            _buildCommentsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderContent(),
      ),
      actions: [
        IconButton(
          onPressed: _handleShare,
          icon: const Icon(Icons.share),
        ),
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Row(
                children: [
                  Icon(Icons.flag),
                  SizedBox(width: 8),
                  Text('Signaler'),
                ],
              ),
              onTap: () => _handleReport(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderContent() {
    return Stack(
      children: [
        // Image de fond
        if (_publication!.primaryImageFullUrl != null)
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: _publication!.primaryImageFullUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),

        // Overlay gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
        ),

        // Contenu
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badges
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _publication!.typeDisplayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _publication!.domainDisplayName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Titre
              Text(
                _publication!.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),

              // Informations
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'VentureLink',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _publication!.formattedPublishedDate,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverTabBarDelegate(
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Article'),
            Tab(text: 'Commentaires'),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé
          if (_publication!.summary != null &&
              _publication!.summary!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _publication!.summary!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Contenu principal
          if (_publication!.content != null &&
              _publication!.content!.isNotEmpty) ...[
            Text(
              _publication!.content!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
            ),
            const SizedBox(height: 24),
          ],

          // Médias
          if (_publication!.hasMedia) ...[
            _buildMediaSection(),
            const SizedBox(height: 24),
          ],

          // Tags
          if (_publication!.tagsList.isNotEmpty) ...[
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _publication!.tagsList.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Information de sponsoring
          if (_publication!.isSponsored &&
              _publication!.sponsorName != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.tertiary,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.campaign,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Contenu sponsorisé',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ce contenu est sponsorisé par ${_publication!.sponsorName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                  ),
                  if (_publication!.sponsorUrl != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _launchUrl(_publication!.sponsorUrl!),
                      child: const Text('En savoir plus'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Statistiques et actions
          _buildStatsAndActions(),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Médias',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        PublicationMediaList(
          mediaList: _publication!.media ?? [],
          showDescriptions: true,
        ),
      ],
    );
  }

  Widget _buildStatsAndActions() {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Statistiques
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.visibility,
                    _publication!.viewsCount.toString(),
                    'Vues',
                  ),
                  _buildStatItem(
                    Icons.favorite,
                    _publication!.likesCount.toString(),
                    'J\'aime',
                  ),
                  _buildStatItem(
                    Icons.comment,
                    _publication!.commentsCount.toString(),
                    'Commentaires',
                  ),
                  _buildStatItem(
                    Icons.share,
                    (_publication!.sharesCount ?? 0).toString(),
                    'Partages',
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: _publication!.userHasLiked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    label: 'J\'aime',
                    isActive: _publication!.userHasLiked,
                    onTap: _handleLike,
                  ),
                  _buildActionButton(
                    icon: Icons.comment_outlined,
                    label: 'Commenter',
                    onTap: () => _tabController.animateTo(1),
                  ),
                  _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Partager',
                    onTap: _handleShare,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsTab() {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        final comments =
            contentProvider.getCommentsForPublication(widget.publicationId);
        final isLoadingComments =
            contentProvider.isLoadingComments(widget.publicationId);

        return Column(
          children: [
            // Zone de saisie de commentaire
            CommentInputWidget(
              onSubmit: (content) => _handleCreateComment(content),
            ),

            const Divider(height: 1),

            // Liste des commentaires
            Expanded(
              child: isLoadingComments
                  ? const Center(child: CircularProgressIndicator())
                  : comments.isEmpty
                      ? _buildEmptyComments()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            return CommentWidget(
                              comment: comments[index],
                              publicationId: widget.publicationId,
                              onReply: (parentId, content) =>
                                  _handleCreateComment(content,
                                      parentId: parentId),
                              onLike: (commentId) =>
                                  _handleCommentLike(commentId),
                              onDelete: (commentId) =>
                                  _handleDeleteComment(commentId),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyComments() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.comment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun commentaire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Soyez le premier à commenter cette publication',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Gestionnaires d'événements
  Future<void> _handleLike() async {
    final contentProvider = context.read<ContentProvider>();
    final liked =
        await contentProvider.togglePublicationLike(widget.publicationId);

    // Mettre à jour la publication locale
    if (liked != _publication!.userHasLiked) {
      setState(() {
        _publication = Publication(
          id: _publication!.id,
          title: _publication!.title,
          summary: _publication!.summary,
          content: _publication!.content,
          publicationType: _publication!.publicationType,
          domain: _publication!.domain,
          tags: _publication!.tags,
          tagsList: _publication!.tagsList,
          author: _publication!.author,
          status: _publication!.status,
          publishedAt: _publication!.publishedAt,
          scheduledFor: _publication!.scheduledFor,
          viewsCount: _publication!.viewsCount,
          likesCount: liked
              ? _publication!.likesCount + 1
              : _publication!.likesCount - 1,
          commentsCount: _publication!.commentsCount,
          sharesCount: _publication!.sharesCount,
          isFeatured: _publication!.isFeatured,
          isPinned: _publication!.isPinned,
          allowComments: _publication!.allowComments,
          isSponsored: _publication!.isSponsored,
          sponsorName: _publication!.sponsorName,
          sponsorUrl: _publication!.sponsorUrl,
          metaDescription: _publication!.metaDescription,
          slug: _publication!.slug,
          media: _publication!.media,
          likes: _publication!.likes,
          userHasLiked: liked,
          canBeCommented: _publication!.canBeCommented,
          isPublished: _publication!.isPublished,
          featuredMedia: _publication!.featuredMedia,
          createdAt: _publication!.createdAt,
          updatedAt: _publication!.updatedAt,
        );
      });
    }
  }

  Future<void> _handleShare() async {
    final contentProvider = context.read<ContentProvider>();
    await contentProvider.sharePublication(widget.publicationId);

    await Share.share(
      'Découvrez cette publication sur VentureLink: ${_publication!.title}\n\n${_publication!.summary ?? ''}',
      subject: _publication!.title,
    );
  }

  Future<void> _handleCreateComment(String content, {String? parentId}) async {
    final contentProvider = context.read<ContentProvider>();
    final success = await contentProvider.createComment(
      publicationId: widget.publicationId,
      content: content,
      parentId: parentId,
    );

    if (success) {
      // Mettre à jour le compteur de commentaires
      setState(() {
        _publication = Publication(
          id: _publication!.id,
          title: _publication!.title,
          summary: _publication!.summary,
          content: _publication!.content,
          publicationType: _publication!.publicationType,
          domain: _publication!.domain,
          tags: _publication!.tags,
          tagsList: _publication!.tagsList,
          author: _publication!.author,
          status: _publication!.status,
          publishedAt: _publication!.publishedAt,
          scheduledFor: _publication!.scheduledFor,
          viewsCount: _publication!.viewsCount,
          likesCount: _publication!.likesCount,
          commentsCount: _publication!.commentsCount + 1,
          sharesCount: _publication!.sharesCount,
          isFeatured: _publication!.isFeatured,
          isPinned: _publication!.isPinned,
          allowComments: _publication!.allowComments,
          isSponsored: _publication!.isSponsored,
          sponsorName: _publication!.sponsorName,
          sponsorUrl: _publication!.sponsorUrl,
          metaDescription: _publication!.metaDescription,
          slug: _publication!.slug,
          media: _publication!.media,
          likes: _publication!.likes,
          userHasLiked: _publication!.userHasLiked,
          canBeCommented: _publication!.canBeCommented,
          isPublished: _publication!.isPublished,
          featuredMedia: _publication!.featuredMedia,
          createdAt: _publication!.createdAt,
          updatedAt: _publication!.updatedAt,
        );
      });
    }
  }

  Future<void> _handleCommentLike(String commentId) async {
    final contentProvider = context.read<ContentProvider>();
    await contentProvider.toggleCommentLike(widget.publicationId, commentId);
  }

  Future<void> _handleDeleteComment(String commentId) async {
    final contentProvider = context.read<ContentProvider>();
    final success =
        await contentProvider.deleteComment(widget.publicationId, commentId);

    if (success) {
      // Mettre à jour le compteur de commentaires
      setState(() {
        _publication = Publication(
          id: _publication!.id,
          title: _publication!.title,
          summary: _publication!.summary,
          content: _publication!.content,
          publicationType: _publication!.publicationType,
          domain: _publication!.domain,
          tags: _publication!.tags,
          tagsList: _publication!.tagsList,
          author: _publication!.author,
          status: _publication!.status,
          publishedAt: _publication!.publishedAt,
          scheduledFor: _publication!.scheduledFor,
          viewsCount: _publication!.viewsCount,
          likesCount: _publication!.likesCount,
          commentsCount: _publication!.commentsCount - 1,
          sharesCount: _publication!.sharesCount,
          isFeatured: _publication!.isFeatured,
          isPinned: _publication!.isPinned,
          allowComments: _publication!.allowComments,
          isSponsored: _publication!.isSponsored,
          sponsorName: _publication!.sponsorName,
          sponsorUrl: _publication!.sponsorUrl,
          metaDescription: _publication!.metaDescription,
          slug: _publication!.slug,
          media: _publication!.media,
          likes: _publication!.likes,
          userHasLiked: _publication!.userHasLiked,
          canBeCommented: _publication!.canBeCommented,
          isPublished: _publication!.isPublished,
          featuredMedia: _publication!.featuredMedia,
          createdAt: _publication!.createdAt,
          updatedAt: _publication!.updatedAt,
        );
      });
    }
  }

  void _handleReport() {
    // Implémenter le signalement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Publication signalée')),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
