import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/project_provider.dart';
import '../../../data/providers/matching_provider.dart';
import '../../../data/models/project_model.dart';
import '../../widgets/project_card.dart';
import '../../common_widgets/vl_app_bar.dart';
import '../../common_widgets/vl_loading_indicator.dart';
import '../project/project_detail_screen.dart';

@RoutePage()
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);
      final matchingProvider =
          Provider.of<MatchingProvider>(context, listen: false);

      // Charger les recommandations IA
      matchingProvider.getRecommendations();

      // Charger les projets tendances
      projectProvider.loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.backgroundColor,
      appBar: VLAppBar(
        title: 'Découvrir',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchScreen(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterOptions(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets de navigation
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: context.appTheme.textSecondaryColor,
              indicatorColor: AppTheme.primaryColor,
              tabs: const [
                Tab(text: 'Pour Vous'),
                Tab(text: 'Tendances'),
                Tab(text: 'Récents'),
                Tab(text: 'Populaires'),
              ],
            ),
          ),

          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecommendationsTab(),
                _buildTrendingTab(),
                _buildRecentTab(),
                _buildPopularTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return Consumer<MatchingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: VLLoadingIndicator());
        }

        if (provider.recommendations.isEmpty) {
          return _buildEmptyState(
            icon: Icons.psychology,
            title: 'Aucune recommandation',
            subtitle:
                'Explorez des projets pour recevoir des suggestions personnalisées',
            action: () => _tabController.animateTo(1),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.getRecommendations();
          },
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Section des recommandations IA
              _buildSectionHeader(
                'Recommandé pour vous',
                'Basé sur votre profil et vos intérêts',
                icon: Icons.psychology,
              ),
              const SizedBox(height: 16),

              // Grille de projets recommandés
              _buildProjectGrid(provider.recommendations),

              const SizedBox(height: 24),

              // Section des suggestions de catégories
              _buildCategorySuggestions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendingTab() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        // Considérer les projets créés dans les 7 derniers jours comme tendance
        final trendingProjects = provider.projects
            .where((p) => DateTime.now().difference(p.createdAt).inDays <= 7)
            .toList();

        if (provider.isLoading && trendingProjects.isEmpty) {
          return const Center(child: VLLoadingIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadProjects(refresh: true);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(
                'Projets en tendance',
                'Les projets qui font le buzz cette semaine',
                icon: Icons.trending_up,
              ),
              const SizedBox(height: 16),
              if (trendingProjects.isNotEmpty) ...[
                // Projet vedette
                _buildFeaturedProject(trendingProjects.first),
                const SizedBox(height: 24),

                // Autres projets tendances
                _buildProjectGrid(trendingProjects.skip(1).toList()),
              ] else
                _buildEmptyState(
                  icon: Icons.trending_up,
                  title: 'Aucun projet en tendance',
                  subtitle: 'Revenez plus tard pour découvrir les nouveautés',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTab() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        final recentProjects = provider.projects
            .where((p) => DateTime.now().difference(p.createdAt).inDays <= 7)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (provider.isLoading && recentProjects.isEmpty) {
          return const Center(child: VLLoadingIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadProjects(refresh: true);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(
                'Nouveaux projets',
                'Découvrez les derniers projets ajoutés',
                icon: Icons.new_releases,
              ),
              const SizedBox(height: 16),
              if (recentProjects.isNotEmpty)
                _buildProjectList(recentProjects)
              else
                _buildEmptyState(
                  icon: Icons.new_releases,
                  title: 'Aucun nouveau projet',
                  subtitle:
                      'Soyez le premier à publier un projet cette semaine !',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularTab() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        final popularProjects = provider.projects.toList()
          ..sort((a, b) => (b.interestsCount + b.viewsCount)
              .compareTo(a.interestsCount + a.viewsCount));

        if (provider.isLoading && popularProjects.isEmpty) {
          return const Center(child: VLLoadingIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadProjects(refresh: true);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader(
                'Projets populaires',
                'Les projets qui attirent le plus d\'attention',
                icon: Icons.star,
              ),
              const SizedBox(height: 16),
              if (popularProjects.isNotEmpty)
                _buildProjectList(popularProjects)
              else
                _buildEmptyState(
                  icon: Icons.star,
                  title: 'Aucun projet populaire',
                  subtitle: 'Explorez les autres sections',
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.appTheme.textPrimaryColor,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProject(ProjectModel project) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToProject(project),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '🔥 TENDANCE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  project.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  project.shortDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatChip(
                      Icons.visibility,
                      '${project.viewsCount}',
                      Colors.white,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      Icons.favorite,
                      '${project.favoritesCount}',
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid(List<ProjectModel> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return ProjectCard(project: projects[index]);
      },
    );
  }

  Widget _buildProjectList(List<ProjectModel> projects) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ProjectCard(project: projects[index]),
        );
      },
    );
  }

  Widget _buildCategorySuggestions() {
    final categories = [
      {
        'name': 'Tech & Innovation',
        'icon': Icons.computer,
        'color': Colors.blue
      },
      {
        'name': 'Santé & Médecine',
        'icon': Icons.health_and_safety,
        'color': Colors.green
      },
      {'name': 'Éducation', 'icon': Icons.school, 'color': Colors.orange},
      {
        'name': 'E-commerce',
        'icon': Icons.shopping_cart,
        'color': Colors.purple
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Catégories populaires',
          'Explorez par domaine d\'activité',
          icon: Icons.category,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _filterByCategory(category['name'] as String),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (category['color'] as Color).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 32,
                            color: category['color'] as Color,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['name'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: category['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: context.appTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.appTheme.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: context.appTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: action,
                child: const Text('Explorer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToProject(ProjectModel project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(projectId: project.id),
      ),
    );
  }

  void _showSearchScreen() {
    // TODO: Implémenter la recherche
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recherche en cours de développement')),
    );
  }

  void _showFilterOptions() {
    // TODO: Implémenter les filtres
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtres en cours de développement')),
    );
  }

  void _filterByCategory(String category) {
    // TODO: Implémenter le filtrage par catégorie
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Filtrage par $category')),
    );
  }
}
