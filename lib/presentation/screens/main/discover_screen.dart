import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:venturelink/core/config/config_service.dart';

@RoutePage()
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  final List<String> _categories = [
    'Tous',
    'Technologie',
    'Finance',
    'Santé',
    'Éducation',
    'Environnement',
    'Social',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Découvrir'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(ConfigService.defaultPadding),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: ConfigService.defaultSpacing),
                _buildCategoryFilter(),
              ],
            ),
          ),
          Expanded(
            child: _buildProjectGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Rechercher un projet...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ConfigService.defaultBorderRadius),
        ),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: ConfigService.defaultSpacing),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectGrid() {
    // État vide en attendant l'implémentation de l'API
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: ConfigService.defaultSpacing),
          Text(
            'Aucun projet à découvrir',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: ConfigService.defaultSpacing / 2),
          Text(
            'Les projets apparaîtront ici une fois l\'API connectée',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
