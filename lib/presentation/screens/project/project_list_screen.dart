import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/presentation/widgets/project_card.dart';
import 'package:venturelink/presentation/widgets/skeleton/project_card_skeleton.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  final ScrollController _scrollController = ScrollController();
  
  // Search
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  // Filtres
  ProjectFilters _currentFilters = ProjectFilters();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Charger les projets au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects(forceRefresh: true);
    });
  }

  void _onScroll() {
    // Charger plus de projets quand on arrive en bas de la liste
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      final provider = context.read<ProjectProvider>();
      if (provider.hasMore && !provider.isLoadingMore) {
        _isLoadingMore = true;
        provider.loadMoreProjects().then((_) {
          setState(() {
            _isLoadingMore = false;
          });
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    // Debounce : attendre 300ms après la dernière frappe
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _currentFilters.search = query.isEmpty ? null : query;
      });
      context.read<ProjectProvider>().searchProjects(query);
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          return _FilterBottomSheet(
            currentFilters: _currentFilters,
            categories: provider.categories,
            onApply: (filters) {
              setState(() {
                _currentFilters = filters;
              });
              provider.applyFilters(filters);
              Navigator.pop(context);
            },
            onClear: () {
              setState(() {
                _currentFilters = ProjectFilters();
              });
              provider.clearFilters();
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  void _navigateToDetails(ProjectModel project) {
    context.router.push(ProjectDetailRoute(projectId: project.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildActiveFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  Widget _buildActiveFilters() {
    if (!_currentFilters.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Text(
              'Filtres actifs :',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildFilterChips(),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentFilters = ProjectFilters();
                  _searchController.clear();
                  _isSearching = false;
                });
                context.read<ProjectProvider>().clearFilters();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'Tout effacer',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterChips() {
    final chips = <Widget>[];

    if (_currentFilters.search != null) {
      chips.add(_buildFilterChip(
        label: '🔍 ${_currentFilters.search!}',
        onRemove: () {
          setState(() {
            _currentFilters.search = null;
            _searchController.clear();
          });
          context.read<ProjectProvider>().searchProjects('');
        },
      ));
    }

    if (_currentFilters.category != null) {
      final category = context
          .read<ProjectProvider>()
          .categories
          .firstWhere(
            (c) => c.id == _currentFilters.category,
            orElse: () => CategoryModel(id: '', nameFr: 'Catégorie', nameEn: 'Category'),
          );
      chips.add(_buildFilterChip(
        label: '📁 ${category.nameFr}',
        onRemove: () {
          setState(() {
            _currentFilters.category = null;
          });
          context.read<ProjectProvider>().filterByCategory(null);
        },
      ));
    }

    if (_currentFilters.stage != null) {
      chips.add(_buildFilterChip(
        label: '🚀 ${_currentFilters.stage!}',
        onRemove: () {
          setState(() {
            _currentFilters.stage = null;
          });
          context.read<ProjectProvider>().filterByStage(null);
        },
      ));
    }

    if (_currentFilters.location != null) {
      chips.add(_buildFilterChip(
        label: '📍 ${_currentFilters.location!}',
        onRemove: () {
          setState(() {
            _currentFilters.location = null;
          });
          context.read<ProjectProvider>().filterByLocation(null);
        },
      ));
    }

    if (_currentFilters.fundingMin != null || _currentFilters.fundingMax != null) {
      final min = _currentFilters.fundingMin != null
          ? '€${_currentFilters.fundingMin!.toStringAsFixed(0)}'
          : '0';
      final max = _currentFilters.fundingMax != null
          ? '€${_currentFilters.fundingMax!.toStringAsFixed(0)}'
          : '∞';
      chips.add(_buildFilterChip(
        label: '💰 $min - $max',
        onRemove: () {
          setState(() {
            _currentFilters.fundingMin = null;
            _currentFilters.fundingMax = null;
          });
          context.read<ProjectProvider>().filterByBudget(null, null);
        },
      ));
    }

    return chips;
  }

  Widget _buildFilterChip({required String label, required VoidCallback onRemove}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: Colors.blue[50],
        deleteIconColor: Colors.grey[700],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.projects.isEmpty) {
          return _buildSkeletonLoader();
        }

        if (provider.error != null) {
          return _buildErrorIndicator(provider.error!);
        }

        if (provider.projects.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadProjects(forceRefresh: true),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: provider.projects.length + 1,
            itemBuilder: (context, index) {
              if (index == provider.projects.length) {
                // Indicateur de chargement pour la pagination infinie
                return _buildLoadingIndicator();
              }
              final project = provider.projects[index];
              return ProjectCard(
                project: project,
                onTap: () => _navigateToDetails(project),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => const ProjectCardSkeleton(),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!_isLoadingMore) {
      return const SizedBox.shrink();
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorIndicator(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<ProjectProvider>().loadProjects(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_state.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.inbox, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun projet trouvé',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilters.hasActiveFilters
                  ? 'Aucun projet ne correspond à vos filtres.\nEssayez de modifier votre recherche.'
                  : 'Il n\'y a pas encore de projets disponibles.\nRevenez plus tard !',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            if (_currentFilters.hasActiveFilters) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentFilters = ProjectFilters();
                    _searchController.clear();
                    _isSearching = false;
                  });
                  context.read<ProjectProvider>().clearFilters();
                },
                child: const Text('Effacer les filtres'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// WIDGET DE FILTRES (BOTTOM SHEET)
// ---------------------------------------------------------------------------

class _FilterBottomSheet extends StatefulWidget {
  final ProjectFilters currentFilters;
  final List<CategoryModel> categories;
  final Function(ProjectFilters) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.currentFilters,
    required this.categories,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ProjectFilters _filters;
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  String? _selectedCategory;
  String? _selectedStage;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters.copyWith();
    _selectedCategory = _filters.category;
    _selectedStage = _filters.stage;
    _selectedLocation = _filters.location;
    if (_filters.fundingMin != null) {
      _minBudgetController.text = _filters.fundingMin!.toString();
    }
    if (_filters.fundingMax != null) {
      _maxBudgetController.text = _filters.fundingMax!.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: 16),

          // Filtres scrollables
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  _buildStageFilter(),
                  const SizedBox(height: 16),
                  _buildLocationFilter(),
                  const SizedBox(height: 16),
                  _buildBudgetFilter(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Boutons d'action
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Filtres',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (_hasActiveFilters())
          TextButton(
            onPressed: widget.onClear,
            child: const Text('Tout effacer'),
          ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: widget.categories.map((category) {
            final isSelected = _selectedCategory == category.id;
            return FilterChip(
              label: Text(category.nameFr),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category.id : null;
                  _filters.category = _selectedCategory;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStageFilter() {
    final stages = [
      {'id': 'IDEA', 'label': 'Idée'},
      {'id': 'STARTED', 'label': 'Démarré'},
      {'id': 'LAUNCHED', 'label': 'Lancé'},
      {'id': 'GROWING', 'label': 'En croissance'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Stade de développement',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: stages.map((stage) {
            final isSelected = _selectedStage == stage['id'];
            return FilterChip(
              label: Text(stage['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStage = selected ? stage['id'] as String : null;
                  _filters.stage = _selectedStage;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    final locations = ['Douala', 'Yaoundé', 'Bafoussam', 'Bamenda', 'Autre'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Localisation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: locations.map((location) {
            final isSelected = _selectedLocation == location;
            return FilterChip(
              label: Text(location),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedLocation = selected ? location : null;
                  _filters.location = _selectedLocation;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget (en €)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minBudgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Min',
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                onChanged: (value) {
                  _filters.fundingMin =
                      double.tryParse(value);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _maxBudgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max',
                  border: OutlineInputBorder(),
                  prefixText: '€ ',
                ),
                onChanged: (value) {
                  _filters.fundingMax =
                      double.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClear,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Réinitialiser'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => widget.onApply(_filters),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Appliquer'),
          ),
        ),
      ],
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategory != null ||
        _selectedStage != null ||
        _selectedLocation != null ||
        _filters.fundingMin != null ||
        _filters.fundingMax != null;
  }

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }
}
