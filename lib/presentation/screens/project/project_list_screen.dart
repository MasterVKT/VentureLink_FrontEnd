
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