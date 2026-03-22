// lib/presentation/project/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/presentation/widgets/project_card.dart';
import 'package:venturelink/presentation/widgets/states/empty_state_widget.dart';
import 'package:venturelink/presentation/widgets/states/loading_state_widget.dart';
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
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadFavoriteProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          // ── État chargement ──────────────────────────────────────────
          if (provider.isLoadingFavorites) {
            return const LoadingStateWidget(
              message: 'Chargement de vos favoris...',
            );
          }

          // ── État vide ────────────────────────────────────────────────
          if (provider.favoriteProjects.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.favorite_border,
              title: 'Aucun favori',
              subtitle:
                  'Les projets que vous marquerez comme favoris\napparaîtront ici',
              showIllustration: true,
              action: ElevatedButton.icon(
                onPressed: () => context.router.maybePop(),
                icon: const Icon(Icons.search),
                label: const Text('Découvrir des projets'),
              ),
            );
          }

          // ── État liste ───────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: () => provider.loadFavoriteProjects(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.favoriteProjects.length,
              itemBuilder: (context, index) {
                final project = provider.favoriteProjects[index];
                return ProjectCard(
                  project: project,
                  onTap: () => _navigateToDetail(project.id),
                  showStats: true,
                  onFavoriteToggle: () => _toggleFavorite(project.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ── WIDGETS ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          // Affiche le nombre de favoris dans le titre
          final count = provider.favoriteProjects.length;
          return Text(
            count > 0 ? 'Mes Favoris ($count)' : 'Mes Favoris',
          );
        },
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showInfoDialog,
          tooltip: 'À propos des favoris',
        ),
      ],
    );
  }

  // ── ACTIONS ────────────────────────────────────────────────────────────────

  void _navigateToDetail(String projectId) {
    context.router.push(ProjectDetailRoute(projectId: projectId));
  }

  Future<void> _toggleFavorite(String projectId) async {
    final provider = context.read<ProjectProvider>();
    await provider.removeFromFavorites(projectId);
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Favoris'),
        content: const Text(
          'Retrouvez ici tous les projets qui vous intéressent. '
          'Ajoutez ou retirez des projets de vos favoris en '
          'appuyant sur le cœur.',
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
