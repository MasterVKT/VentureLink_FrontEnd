import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';

import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/presentation/widgets/project_card.dart';
import 'package:venturelink/presentation/widgets/skeleton/project_card_skeleton.dart';
import 'package:venturelink/presentation/widgets/states/error_state_widget.dart';
import 'package:venturelink/presentation/widgets/states/empty_state_widget.dart';
import 'package:venturelink/presentation/widgets/filter_bottom_sheet.dart';
import 'package:venturelink/core/theme/app_theme.dart';


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/presentation/widgets/project_card.dart';
import 'package:venturelink/presentation/widgets/filter_bottom_sheet.dart';
import 'package:venturelink/core/router/app_router.dart';

@RoutePage()
class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  // ───────────────────────────────────────────────────────────────────────────
  // SEARCH & FILTERS
  // ───────────────────────────────────────────────────────────────────────────
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  ProjectFilters _filters = const ProjectFilters();

  // Pagination
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;
  final ScrollController _scrollController = ScrollController();

  // ───────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Charger les projets au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILD
  // ───────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar avec recherche
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher un projet...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _clearSearch();
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  ),
                ),
                onChanged: (value) => _onSearchChanged(value),
              )
            : const Text('Projets'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: Badge(
              isLabelVisible: _filters.hasActiveFilters,
              label: Text('${_filters.activeFiltersCount}'),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilters,
          ),
        ],
        bottom: _filters.hasActiveFilters || _filters.hasSearchQuery
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: _buildActiveFiltersBar(),
              )
            : null,
      ),

      // Corps avec liste
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          // État de chargement initial
          if (projectProvider.isLoading && projectProvider.projects.isEmpty) {
            return const ProjectCardSkeletonList();
          }

          // Erreur
          if (projectProvider.error != null) {
            return ErrorStateWidget(
              message: _getErrorMessage(projectProvider.error),
              onRetry: () {
                projectProvider.clearError();
                _loadProjects();
              },
              icon: _getErrorIcon(projectProvider.error),
            );
          }

          // Liste vide
          if (projectProvider.projects.isEmpty) {
            return EmptyStateWidget(
              title: _filters.hasActiveFilters || _filters.hasSearchQuery
                  ? 'Aucun résultat'
                  : 'Aucun projet trouvé',
              message: _filters.hasActiveFilters || _filters.hasSearchQuery
                  ? 'Essayez de modifier vos filtres ou votre recherche.'
                  : 'Il n\'y a pas encore de projets disponibles. Revenez plus tard !',
              onAction: _filters.hasActiveFilters
                  ? () {
                      _clearAllFilters();
                      _loadProjects();
                    }
                  : null,
              actionLabel: _filters.hasActiveFilters ? 'Effacer les filtres' : null,
            );
          }

          // Liste avec pagination infinie
          return RefreshIndicator(
            onRefresh: () => _loadProjects(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: projectProvider.projects.length + 1,
              itemBuilder: (context, index) {
                if (index == projectProvider.projects.length) {
                  // Indicateur de chargement pour la pagination
                  if (_isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final project = projectProvider.projects[index];
                return ProjectCard(
                  project: project,
                  onTap: () => _navigateToProjectDetail(project.id),
                  onFavoriteToggle: () => _toggleFavorite(project.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // WIDGETS
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildActiveFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Chips filtres actifs
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Chip recherche
                  if (_filters.hasSearchQuery)
                    _buildFilterChip(
                      label: '🔍 "${_filters.searchQuery}"',
                      onDismissed: _clearSearch,
                    ),

                  // Chip catégorie
                  if (_filters.categoryId != null)
                    _buildFilterChip(
                      label: '📁 ${_getCategoryName(_filters.categoryId!)}',
                      onDismissed: _clearCategoryFilter,
                    ),

                  // Chip stage
                  if (_filters.stage != null)
                    _buildFilterChip(
                      label: '🚀 ${_getStageLabel(_filters.stage!)}',
                      onDismissed: _clearStageFilter,
                    ),

                  // Chip budget
                  if (_filters.fundingMin != null || _filters.fundingMax != null)
                    _buildFilterChip(
                      label: '💰 ${_formatBudgetRange()}',
                      onDismissed: _clearBudgetFilter,
                    ),
                ],
              ),
            ),
          ),

          // Bouton effacer tout
          if (_filters.hasActiveFilters || _filters.hasSearchQuery)
            TextButton(
              onPressed: () {
                _clearAllFilters();
                _loadProjects();
              },
              child: const Text('Tout effacer'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required VoidCallback onDismissed}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        onDeleted: onDismissed,
        onSelected: (selected) {},
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // PAGINATION
  // ───────────────────────────────────────────────────────────────────────────

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMorePages) {
      _loadMoreProjects();
    }
  }

  Future<void> _loadProjects() async {
    final projectProvider = context.read<ProjectProvider>();
    await projectProvider.loadProjectsWithFilters(_filters);
    setState(() {
      _currentPage = 1;
      _hasMorePages = true;
      _isLoadingMore = false;
    });
  }

  Future<void> _loadMoreProjects() async {
    if (_isLoadingMore || !_hasMorePages) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      final projectProvider = context.read<ProjectProvider>();
      final result = await projectProvider.getApiService().getProjects(
            page: _currentPage,
            pageSize: 20,
            filters: _filters,
          );

      if (result.projects != null && result.projects!.isNotEmpty) {
        projectProvider.appendProjects(result.projects!);
      }

      _hasMorePages = result.hasNext ?? false;
    } catch (e) {
      debugPrint('Erreur chargement page suivante: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // SEARCH
  // ───────────────────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _filters = _filters.copyWith(searchQuery: value.isNotEmpty ? value : null);
      });
      _loadProjects();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filters = _filters.clearSearch();
    });
    _loadProjects();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // FILTERS
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _showFilters() async {
    final projectProvider = context.read<ProjectProvider>();
    final categories = projectProvider.categories;

    final result = await FilterBottomSheet.show(
      context,
      currentFilters: _filters,
      categories: categories,
    );

    if (result != null && result != _filters) {
      setState(() {
        _filters = result;
      });
      _loadProjects();
    }
  }

  void _clearCategoryFilter() {
    setState(() {
      _filters = _filters.copyWith(categoryId: null);
    });
    _loadProjects();
  }

  void _clearStageFilter() {
    setState(() {
      _filters = _filters.copyWith(stage: null);
    });
    _loadProjects();
  }

  void _clearBudgetFilter() {
    setState(() {
      _filters = _filters.copyWith(fundingMin: null, fundingMax: null);
    });
    _loadProjects();
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _filters = const ProjectFilters();
      _isSearching = false;
    });
    _loadProjects();
  }

  String _getCategoryName(String categoryId) {
    final projectProvider = context.read<ProjectProvider>();
    final category = projectProvider.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(
        id: categoryId,
        nameFr: 'Catégorie',
        nameEn: 'Category',
      ),
    );
    return category.nameFr;
  }

  String _getStageLabel(String stage) {
    switch (stage) {
      case 'IDEA':
        return 'Idée';
      case 'PROTOTYPE':
        return 'Prototype';
      case 'MVP':
        return 'MVP';
      case 'LAUNCHED':
        return 'Lancé';
      case 'GROWTH':
        return 'Croissance';
      default:
        return stage;
    }
  }

  String _formatBudgetRange() {
    final min = _filters.fundingMin;
    final max = _filters.fundingMax;

    if (min != null && max != null) {
      return '${_formatAmount(min)} - ${_formatAmount(max)}';
    } else if (min != null) {
      return '> ${_formatAmount(min)}';
    } else if (max != null) {
      return '< ${_formatAmount(max)}';
    }
    return '';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return '${amount.toStringAsFixed(0)}';
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  void _navigateToProjectDetail(String projectId) {
    context.router.push(ProjectDetailRoute(projectId: projectId));
  }

  Future<void> _toggleFavorite(String projectId) async {
    final projectProvider = context.read<ProjectProvider>();
    final success = await projectProvider.toggleFavorite(projectId);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Projet ajouté aux favoris ❤️' : 'Erreur lors de l\'ajout aux favoris',
  // ============================================
  // 📌 Variables
  // ============================================
  
  final PagingController<int, ProjectModel> _pagingController =
      PagingController(firstPageKey: 1);

  late ProjectProvider _projectProvider;
  static const int _pageSize = 20;

  // Recherche
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _currentSearch = '';

  // Filtres
  ProjectFilters _filters = ProjectFilters();

  // ============================================
  // 🔧 Initialisation
  // ============================================
  
  @override
  void initState() {
    super.initState();
    _projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  // ============================================
  // 📥 Récupérer les projets avec recherche et filtres
  // ============================================
  
  Future<void> _fetchPage(int pageKey) async {
    try {
      await _projectProvider.loadProjects(forceRefresh: pageKey == 1);
      var allProjects = _projectProvider.projects;
      
      // Appliquer la recherche
      if (_currentSearch.isNotEmpty) {
        allProjects = allProjects.where((project) {
          final titleMatch = project.title
              .toLowerCase()
              .contains(_currentSearch.toLowerCase());
          final descriptionMatch = project.shortDescription
              .toLowerCase()
              .contains(_currentSearch.toLowerCase());
          return titleMatch || descriptionMatch;
        }).toList();
      }

      // Appliquer les filtres
      if (_filters.hasActiveFilters) {
        allProjects = allProjects.where((project) {
          bool matches = true;

          if (_filters.category != null) {
            matches = matches && project.category.id == _filters.category;
          }

          if (_filters.location != null) {
            matches = matches && 
                project.location.toLowerCase().contains(
                  _filters.location!.toLowerCase()
                );
          }

          if (_filters.minBudget != null) {
            matches = matches && project.fundingMax >= _filters.minBudget!;
          }

          if (_filters.maxBudget != null) {
            matches = matches && project.fundingMax <= _filters.maxBudget!;
          }

          if (_filters.status != null) {
            matches = matches && project.status == _filters.status;
          }

          return matches;
        }).toList();
      }
      
      final startIndex = (pageKey - 1) * _pageSize;
      final endIndex = startIndex + _pageSize;
      final isLastPage = endIndex >= allProjects.length;

      if (isLastPage) {
        final pageProjects = allProjects.sublist(
          startIndex,
          allProjects.length,
        );
        _pagingController.appendLastPage(pageProjects);
      } else {
        final pageProjects = allProjects.sublist(startIndex, endIndex);
        _pagingController.appendPage(pageProjects, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // ============================================
  // 🎨 Interface utilisateur
  // ============================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Chips des filtres actifs
          if (_filters.hasActiveFilters || _currentSearch.isNotEmpty)
            _buildActiveFiltersChips(),

          // Liste des projets
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() => _pagingController.refresh()),
              child: PagedListView<int, ProjectModel>(
                pagingController: _pagingController,
                padding: const EdgeInsets.all(16),
                builderDelegate: PagedChildBuilderDelegate<ProjectModel>(
                  itemBuilder: (context, project, index) => ProjectCard(
                    project: project,
                    onTap: () => _navigateToDetails(project),
                    onFavoriteToggle: () => _toggleFavorite(project),
                  ),
                  firstPageErrorIndicatorBuilder: (context) => _buildErrorState(),
                  firstPageProgressIndicatorBuilder: (context) => _buildSkeleton(),
                  noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🔨 AppBar avec recherche
  // ============================================
  
  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Rechercher des projets...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: _onSearchChanged,
            )
          : const Text('Projets'),
      actions: [
        // Bouton Recherche
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                _onSearchChanged('');
              }
            });
          },
        ),
        
        // Bouton Filtres avec badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterBottomSheet,
            ),
            if (_filters.activeFilterCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${_filters.activeFilterCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // 🏷️ Chips des filtres actifs
  // ============================================
  
  Widget _buildActiveFiltersChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getResultsText(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Effacer tout'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildFilterChipsList(),
          ),
        ],
      ),
    );
  }

  String _getResultsText() {
    // Note: itemList peut être null pendant le chargement
    final count = _pagingController.itemList?.length ?? 0;
    return '$count résultat${count > 1 ? 's' : ''}';
  }

  List<Widget> _buildFilterChipsList() {
    final chips = <Widget>[];

    // Chip de recherche
    if (_currentSearch.isNotEmpty) {
      chips.add(_buildChip(
        label: 'Recherche: "$_currentSearch"',
        onDelete: () {
          _searchController.clear();
          _onSearchChanged('');
        },
      ));
    }

    // Chip catégorie
    if (_filters.category != null) {
      final category = _projectProvider.categories
          .where((c) => c.id == _filters.category)
          .firstOrNull;
      chips.add(_buildChip(
        label: category?.nameFr ?? 'Catégorie',
        onDelete: () {
          setState(() {
            _filters.category = null;
          });
          _pagingController.refresh();
        },
      ));
    }

    // Chip localisation
    if (_filters.location != null) {
      chips.add(_buildChip(
        label: _filters.location!,
        onDelete: () {
          setState(() {
            _filters.location = null;
          });
          _pagingController.refresh();
        },
      ));
    }

    // Chip budget
    if (_filters.minBudget != null || _filters.maxBudget != null) {
      chips.add(_buildChip(
        label: 'Budget filtré',
        onDelete: () {
          setState(() {
            _filters.minBudget = null;
            _filters.maxBudget = null;
          });
          _pagingController.refresh();
        },
      ));
    }

    // Chip statut
    if (_filters.status != null) {
      chips.add(_buildChip(
        label: _filters.status!,
        onDelete: () {
          setState(() {
            _filters.status = null;
          });
          _pagingController.refresh();
        },
      ));
    }

    return chips;
  }

  Widget _buildChip({required String label, required VoidCallback onDelete}) {
    return Chip(
      label: Text(label),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: onDelete,
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
    );
  }

  // ============================================
  // 🔍 Gestion de la recherche
  // ============================================
  
  void _onSearchChanged(String query) {
    // Debounce : attendre 300ms après la dernière frappe
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _currentSearch = query;
      });
      _pagingController.refresh();
    });
  }

  // ============================================
  // 🎛️ Gestion des filtres
  // ============================================
  
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        currentFilters: _filters,
        categories: _projectProvider.categories,
        onApply: (newFilters) {
          setState(() {
            _filters = newFilters;
          });
          _pagingController.refresh();
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _currentSearch = '';
      _searchController.clear();
      _isSearching = false;
    });
    _pagingController.refresh();
  }

  // ============================================
  // 🔨 Widgets Helper (skeleton, erreur, vide)
  // ============================================
  
  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 24, width: double.infinity, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Container(height: 16, width: double.infinity, color: Colors.grey[300]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Erreur : ${_pagingController.error}'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _pagingController.refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text(
            'Aucun projet trouvé',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _filters.hasActiveFilters || _currentSearch.isNotEmpty
                ? 'Essayez de modifier vos critères de recherche'
                : 'Il n\'y a pas encore de projets disponibles',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🎯 Actions
  // ============================================
  
  void _navigateToDetails(ProjectModel project) {
    context.router.push(ProjectDetailRoute(projectId: project.id));
  }

  Future<void> _toggleFavorite(ProjectModel project) async {
    final success = await _projectProvider.toggleFavorite(project.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            project.isFavorite ? '❤️ Retiré des favoris' : '❤️ Ajouté aux favoris',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ───────────────────────────────────────────────────────────────────────────

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('socket') || errorStr.contains('connect')) {
      return 'Pas de connexion internet.\nVérifiez votre connexion et réessayez.';
    } else if (errorStr.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre.\nRéessayez dans quelques instants.';
    } else if (errorStr.contains('http')) {
      return 'Erreur du serveur.\nNous travaillons à résoudre le problème.';
    } else {
      return 'Une erreur s\'est produite.\nVeuillez réessayer.';
    }
  }

  IconData _getErrorIcon(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('socket') || errorStr.contains('connect')) {
      return Icons.wifi_off;
    } else if (errorStr.contains('timeout')) {
      return Icons.timer_off;
    } else {
      return Icons.error_outline;
    }
  }
}
  // ============================================
  // 🧹 Nettoyage
  // ============================================
  
  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
