import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/providers/content_provider.dart';
import '../../../data/models/publication_model.dart';
import '../../../data/services/content_api_service.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/content/publication_card.dart';
import '../../widgets/content/publication_filter_sheet.dart';
import '../../widgets/content/publication_search_delegate.dart';

@RoutePage()
class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'all';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
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
      context.read<ContentProvider>().loadMorePublications();
    }
  }

  Future<void> _loadInitialData() async {
    final contentProvider = context.read<ContentProvider>();
    await Future.wait([
      contentProvider.loadPublications(refresh: true),
      contentProvider.loadFeaturedPublications(),
      contentProvider.loadPinnedPublications(),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadInitialData();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublicationFilterSheet(
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
          _applyFilter(filter);
        },
      ),
    );
  }

  void _applyFilter(String filter) {
    final contentProvider = context.read<ContentProvider>();

    switch (filter) {
      case 'featured':
        contentProvider.loadPublications(isFeatured: true, refresh: true);
        break;
      case 'sponsored':
        contentProvider.loadPublications(isSponsored: true, refresh: true);
        break;
      case 'tips':
        contentProvider.filterByType('TIPS');
        break;
      case 'educational':
        contentProvider.filterByType('EDUCATIONAL');
        break;
      case 'news':
        contentProvider.filterByType('NEWS');
        break;
      case 'entrepreneurship':
        contentProvider.filterByDomain('ENTREPRENEURSHIP');
        break;
      case 'finance':
        contentProvider.filterByDomain('FINANCE_INVESTMENT');
        break;
      case 'technology':
        contentProvider.filterByDomain('TECHNOLOGY');
        break;
      default:
        contentProvider.clearFilters();
    }
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: PublicationSearchDelegate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<ContentProvider>(
        builder: (context, contentProvider, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 0,
                title: Row(
                  children: [
                    // Logo de l'application
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'VentureLink',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: _showSearch,
                    icon: const Icon(Icons.search),
                    tooltip: 'Rechercher',
                  ),
                  IconButton(
                    onPressed: _showFilterSheet,
                    icon: Icon(
                      _selectedFilter == 'all'
                          ? Icons.filter_list_outlined
                          : Icons.filter_list,
                    ),
                    tooltip: 'Filtrer',
                  ),
                ],
              ),

              // Publications épinglées
              if (contentProvider.pinnedPublications.isNotEmpty)
                SliverToBoxAdapter(
                  child:
                      _buildPinnedSection(contentProvider.pinnedPublications),
                ),

              // Publications mises en avant
              if (contentProvider.featuredPublications.isNotEmpty)
                SliverToBoxAdapter(
                  child: _buildFeaturedSection(
                      contentProvider.featuredPublications),
                ),

              // Section principale des publications
              if (contentProvider.isLoading &&
                  contentProvider.publications.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (contentProvider.error != null &&
                  contentProvider.publications.isEmpty)
                SliverFillRemaining(
                  child: _buildErrorState(contentProvider.error!),
                )
              else if (contentProvider.publications.isEmpty)
                const SliverFillRemaining(
                  child: _EmptyState(),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index < contentProvider.publications.length) {
                        return PublicationCard(
                          publication: contentProvider.publications[index],
                          onLike: () =>
                              _handleLike(contentProvider.publications[index]),
                          onComment: () => _handleComment(
                              contentProvider.publications[index]),
                          onShare: () =>
                              _handleShare(contentProvider.publications[index]),
                          onTap: () =>
                              _handleTap(contentProvider.publications[index]),
                        );
                      } else if (contentProvider.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return null;
                    },
                    childCount: contentProvider.publications.length +
                        (contentProvider.isLoadingMore ? 1 : 0),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPinnedSection(List<Publication> pinnedPublications) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.push_pin,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Publications épinglées',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pinnedPublications.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildFeaturedCard(pinnedPublications[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(List<Publication> featuredPublications) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Publications mises en avant',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: featuredPublications.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  margin: const EdgeInsets.only(right: 12),
                  child: _buildFeaturedCard(featuredPublications[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCard(Publication publication) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(publication),
        child: Stack(
          children: [
            // Image de fond
            if (publication.primaryImageUrl != null)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: publication.primaryImageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Theme.of(context).colorScheme.surfaceVariant,
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
                      Colors.black.withOpacity(0.7),
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
                  // Type et domaine
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          publication.typeDisplayName,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          publication.domainDisplayName,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Titre
                  Text(
                    publication.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Statistiques
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${publication.viewsCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${publication.likesCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
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
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  // Gestionnaires d'événements
  Future<void> _handleLike(Publication publication) async {
    final contentProvider = context.read<ContentProvider>();
    await contentProvider.togglePublicationLike(publication.id);
  }

  void _handleComment(Publication publication) {
    context.router
        .pushNamed('/publication-detail/${publication.id}?tab=comments');
  }

  Future<void> _handleShare(Publication publication) async {
    final contentProvider = context.read<ContentProvider>();
    await contentProvider.sharePublication(publication.id);

    // Partager via le système
    await Share.share(
      'Découvrez cette publication sur VentureLink: ${publication.title}\n\n${publication.summary ?? ''}',
      subject: publication.title,
    );
  }

  void _handleTap(Publication publication) {
    context.router.pushNamed('/publication-detail/${publication.id}');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune publication',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les publications apparaîtront ici dès qu\'elles seront disponibles.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
