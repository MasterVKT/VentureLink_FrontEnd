import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/discover_provider.dart';
import 'package:venturelink/presentation/widgets/discover/carousel_section_skeleton.dart';
import 'package:venturelink/presentation/widgets/discover/project_carousel_section.dart';
import 'package:venturelink/presentation/widgets/states/error_state_widget.dart';

/// Écran de découverte (Discover)
/// Affiche les projets recommandés, tendance, nouveaux et presque financés
@RoutePage()
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  late DiscoverProvider _discoverProvider;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _discoverProvider = Provider.of<DiscoverProvider>(context, listen: false);
    _loadDiscoverData();
  }

  Future<void> _loadDiscoverData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _discoverProvider.loadDiscoverData();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Découverte'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: _navigateToNotifications,
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_error != null) {
      return ErrorStateWidget(
        message: 'Erreur de chargement',
        subtitle: _error,
        onRetry: _loadDiscoverData,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDiscoverData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildRecommendedSection(),
            const SizedBox(height: 24),
            _buildTrendingSection(),
            const SizedBox(height: 24),
            _buildNewProjectsSection(),
            const SizedBox(height: 24),
            _buildAlmostFundedSection(),
            const SizedBox(height: 24),
            // Padding pour le scroll
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour ${user?.firstName ?? 'Investisseur'} 👋',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Découvrez des projets qui pourraient vous intéresser',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecommendedSection() {
    return Consumer<DiscoverProvider>(
      builder: (context, provider, child) {
        if (provider.recommendedProjects.isEmpty) {
          return const SizedBox.shrink();
        }

        return ProjectCarouselSection(
          title: 'Recommandés pour vous',
          subtitle: 'Basé sur vos préférences',
          projects: provider.recommendedProjects,
          onSeeAll: () => _navigateToProjectList(filter: 'recommended'),
        );
      },
    );
  }

  Widget _buildTrendingSection() {
    return Consumer<DiscoverProvider>(
      builder: (context, provider, child) {
        if (provider.trendingProjects.isEmpty) {
          return const SizedBox.shrink();
        }

        return ProjectCarouselSection(
          title: 'Projets tendance 🔥',
          subtitle: 'Les plus populaires cette semaine',
          projects: provider.trendingProjects,
          onSeeAll: () => _navigateToProjectList(filter: 'trending'),
        );
      },
    );
  }

  Widget _buildNewProjectsSection() {
    return Consumer<DiscoverProvider>(
      builder: (context, provider, child) {
        if (provider.newProjects.isEmpty) {
          return const SizedBox.shrink();
        }

        return ProjectCarouselSection(
          title: 'Nouveaux projets ✨',
          subtitle: 'Récemment publiés',
          projects: provider.newProjects,
          onSeeAll: () => _navigateToProjectList(filter: 'new'),
        );
      },
    );
  }

  Widget _buildAlmostFundedSection() {
    return Consumer<DiscoverProvider>(
      builder: (context, provider, child) {
        if (provider.almostFundedProjects.isEmpty) {
          return const SizedBox.shrink();
        }

        return ProjectCarouselSection(
          title: 'Bientôt financés 🎯',
          subtitle: 'Ils ont presque atteint leur objectif',
          projects: provider.almostFundedProjects,
          onSeeAll: () => _navigateToProjectList(filter: 'almost_funded'),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: index == 0
                ? Column(
                    children: [
                      _buildWelcomeHeader(),
                      const SizedBox(height: 24),
                      const CarouselSectionSkeleton(),
                    ],
                  )
                : const CarouselSectionSkeleton(),
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // NAVIGATION
  // ───────────────────────────────────────────────────────────────────────────

  void _navigateToNotifications() {
    context.router.push(const NotificationsRoute());
  }

  void _navigateToProjectList({required String filter}) {
    // Navigation vers la liste de projets filtrée
    // À implémenter selon les besoins
    debugPrint('Navigation vers liste de projets: $filter');
  }
}
