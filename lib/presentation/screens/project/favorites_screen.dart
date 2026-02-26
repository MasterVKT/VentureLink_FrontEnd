import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/presentation/widgets/project_card.dart';
import 'package:venturelink/presentation/widgets/states/empty_state_widget.dart';
import 'package:venturelink/presentation/widgets/states/loading_state_widget.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/core/router/app_router.dart';

/// Écran affichant la liste des projets favoris de l'utilisateur
@RoutePage()
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          // Filtrer les projets favoris
          // Note: Cette implémentation suppose que les projets ont un champ isFavorite
          // Dans une vraie implémentation, il faudrait charger les favoris depuis l'API
          final favoriteProjects = projectProvider.projects
              .where((project) => project.isFavorite)
              .toList();

          if (projectProvider.isLoading) {
            return const LoadingStateWidget(message: 'Chargement de vos favoris...');
          }

          if (favoriteProjects.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'Aucun favori',
              subtitle: 'Les projets que vous marquerez comme favoris\napparaîtront ici',
              showIllustration: true,
              action: ElevatedButton.icon(
                onPressed: () => context.router.pop(),
                icon: const Icon(Icons.search),
                label: const Text('Découvrir des projets'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await projectProvider.loadProjects(forceRefresh: true);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteProjects.length,
              itemBuilder: (context, index) {
                final project = favoriteProjects[index];
                return ProjectCard(
                  project: project,
                  onTap: () => _navigateToProjectDetail(project.id),
                  onFavoriteToggle: () => _toggleFavorite(project),
                  showStats: true,
                );
              },
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Mes Favoris'),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(),
          tooltip: 'À propos des favoris',
        ),
      ],
    );
  }

  void _navigateToProjectDetail(String projectId) {
    context.router.push(ProjectDetailRoute(projectId: projectId));
  }

  Future<void> _toggleFavorite(ProjectModel project) async {
    final projectProvider = context.read<ProjectProvider>();
    final success = await projectProvider.toggleFavorite(project.id);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            project.isFavorite
                ? 'Erreur lors du retrait des favoris'
                : 'Erreur lors de l\'ajout aux favoris',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Favoris'),
        content: const Text(
          'Retrouvez ici tous les projets qui vous intéressent. '
          'Ajoutez ou retirez des projets de vos favoris en appuyant sur le cœur.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
