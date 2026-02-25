import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:venturelink/core/config/config_service.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implémenter la recherche
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Naviguer vers les notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Rafraîchir les données
        },
        child: ListView(
          padding: const EdgeInsets.all(ConfigService.defaultPadding),
          children: [
            _buildSectionTitle(context, 'Projets mis en avant'),
            const SizedBox(height: ConfigService.defaultSpacing),
            _buildFeaturedProjects(context),
            const SizedBox(height: ConfigService.defaultPadding),
            _buildSectionTitle(context, 'Projets récents'),
            const SizedBox(height: ConfigService.defaultSpacing),
            _buildRecentProjects(context),
            const SizedBox(height: ConfigService.defaultPadding),
            _buildSectionTitle(context, 'Catégories populaires'),
            const SizedBox(height: ConfigService.defaultSpacing),
            _buildPopularCategories(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Naviguer vers la création de projet
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildFeaturedProjects(BuildContext context) {
    // État vide en attendant l'implémentation de l'API
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ConfigService.defaultBorderRadius),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: ConfigService.defaultSpacing),
            Text(
              'Aucun projet mis en avant',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProjects(BuildContext context) {
    // État vide en attendant l'implémentation de l'API
    return Container(
      padding: const EdgeInsets.all(ConfigService.defaultPadding),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: ConfigService.defaultSpacing),
            Text(
              'Aucun projet récent',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    return Wrap(
      spacing: ConfigService.defaultSpacing,
      runSpacing: ConfigService.defaultSpacing,
      children: [
        'Technologie',
        'Finance',
        'Santé',
        'Éducation',
        'Environnement',
        'Social',
      ].map((category) {
        return ActionChip(
          label: Text(category),
          onPressed: () {
            // TODO: Filtrer les projets par catégorie
          },
        );
      }).toList(),
    );
  }
}
