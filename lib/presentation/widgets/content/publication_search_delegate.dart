import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/content_provider.dart';
import '../../../data/models/publication_model.dart';
import 'publication_card.dart';

class PublicationSearchDelegate extends SearchDelegate<Publication?> {
  @override
  String get searchFieldLabel => 'Rechercher des publications...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState(context, 'Saisissez un terme de recherche');
    }

    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        // Déclencher la recherche
        WidgetsBinding.instance.addPostFrameCallback((_) {
          contentProvider.searchPublications(query);
        });

        if (contentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (contentProvider.error != null) {
          return _buildErrorState(context, contentProvider.error!);
        }

        final results = contentProvider.publications;

        if (results.isEmpty) {
          return _buildEmptyState(
              context, 'Aucune publication trouvée pour "$query"');
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            return PublicationCard(
              publication: results[index],
              onLike: () => _handleLike(context, results[index]),
              onComment: () => _handleComment(context, results[index]),
              onShare: () => _handleShare(context, results[index]),
              onTap: () => _handleTap(context, results[index]),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildSuggestionsEmpty(context);
    }

    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        // Filtrer les publications existantes pour les suggestions
        final suggestions = contentProvider.publications
            .where((publication) =>
                publication.title.toLowerCase().contains(query.toLowerCase()) ||
                publication.summary
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ==
                    true ||
                publication.tagsList.any(
                    (tag) => tag.toLowerCase().contains(query.toLowerCase())))
            .take(5)
            .toList();

        if (suggestions.isEmpty) {
          return _buildNoSuggestions(context);
        }

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final publication = suggestions[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.article,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              title: Text(
                publication.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                publication.typeDisplayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              trailing: Icon(
                Icons.north_west,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onTap: () {
                query = publication.title;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestionsEmpty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Rechercher des publications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trouvez des articles, conseils, actualités et tutoriels',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Suggestions de recherche populaires
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Recherches populaires',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'entrepreneuriat',
              'investissement',
              'startup',
              'business plan',
              'marketing',
              'leadership',
            ].map((term) => _buildSuggestionChip(context, term)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String term) {
    return ActionChip(
      label: Text(term),
      onPressed: () {
        query = term;
        showResults(context);
      },
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }

  Widget _buildNoSuggestions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune suggestion',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur Entrée pour rechercher "$query"',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun résultat',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
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

  Widget _buildErrorState(BuildContext context, String error) {
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
              'Erreur de recherche',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
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

  // Gestionnaires d'événements
  Future<void> _handleLike(
      BuildContext context, Publication publication) async {
    final contentProvider = context.read<ContentProvider>();
    await contentProvider.togglePublicationLike(publication.id);
  }

  void _handleComment(BuildContext context, Publication publication) {
    close(context, publication);
    // Navigation vers les commentaires sera gérée par l'écran parent
  }

  Future<void> _handleShare(
      BuildContext context, Publication publication) async {
    final contentProvider = context.read<ContentProvider>();
    await contentProvider.sharePublication(publication.id);
  }

  void _handleTap(BuildContext context, Publication publication) {
    close(context, publication);
    // Navigation vers le détail sera gérée par l'écran parent
  }
}
