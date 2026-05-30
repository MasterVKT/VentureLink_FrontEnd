import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_route/auto_route.dart';

import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/presentation/widgets/project_card.dart';
import 'package:venturelink/presentation/widgets/states/empty_state_widget.dart';
import 'package:venturelink/presentation/widgets/states/loading_state_widget.dart';
import 'package:venturelink/presentation/widgets/filter_bottom_sheet.dart';
import 'package:venturelink/core/router/app_router.dart';

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
  ProjectFilters _currentFilters = const ProjectFilters();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects(forceRefresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore) {
      final provider = context.read<ProjectProvider>();
      if (provider.hasMore) {
        setState(() => _isLoadingMore = true);
        provider.loadMoreProjects();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<ProjectProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingProjects && provider.projects.isEmpty) {
            return const LoadingStateWidget(
                message: 'Chargement des projets...');
          }

          if (provider.projects.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.folder_open,
              title: 'Aucun projet',
              subtitle: 'Soyez le premier à créer un projet !',
              action: ElevatedButton.icon(
                onPressed: () =>
                    context.router.push(const ProjectCreateRoute()),
                icon: const Icon(Icons.add),
                label: const Text('Créer un projet'),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadProjects(forceRefresh: true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.projects.length + 1,
              itemBuilder: (context, index) {
                if (index == provider.projects.length) {
                  return _isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }

                final project = provider.projects[index];
                return ProjectCard(
                  project: project,
                  onTap: () => _navigateToProjectDetail(project.id),
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _currentFilters =
            _currentFilters.copyWith(searchQuery: query.isEmpty ? null : query);
      });
      context.read<ProjectProvider>().searchProjects(query);
    });
  }

  void _showFilterBottomSheet() {
    FilterBottomSheet.show(
      context,
      currentFilters: _currentFilters,
      categories: context.read<ProjectProvider>().categories,
    ).then((filters) {
      if (filters != null) {
        setState(() {
          _currentFilters = filters;
        });
        context.read<ProjectProvider>().applyFilters(filters);
      }
    });
  }

  void _navigateToProjectDetail(String projectId) {
    context.router.push(ProjectDetailRoute(projectId: projectId));
  }
}
