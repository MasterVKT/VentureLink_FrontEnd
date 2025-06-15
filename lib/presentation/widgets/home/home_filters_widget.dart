import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_model.dart';

/// Widget pour les filtres de la page d'accueil
class HomeFiltersWidget extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedStage;
  final String? selectedLocation;
  final List<CategoryModel> categories;
  final Function(String?) onCategoryChanged;
  final Function(String?) onStageChanged;
  final Function(String?) onLocationChanged;
  final VoidCallback onClearFilters;
  final VoidCallback? onAdvancedFilters;

  const HomeFiltersWidget({
    super.key,
    this.selectedCategory,
    this.selectedStage,
    this.selectedLocation,
    required this.categories,
    required this.onCategoryChanged,
    required this.onStageChanged,
    required this.onLocationChanged,
    required this.onClearFilters,
    this.onAdvancedFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filtres',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (_hasActiveFilters())
                TextButton(
                  onPressed: onClearFilters,
                  child: const Text('Effacer'),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Filtres horizontaux
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtre par catégorie
                _buildFilterChip(
                  context,
                  'Catégorie',
                  selectedCategory != null
                      ? _getCategoryName(selectedCategory!)
                      : null,
                  () => _showCategoryFilter(context),
                ),

                const SizedBox(width: 8),

                // Filtre par stade
                _buildFilterChip(
                  context,
                  'Stade',
                  selectedStage != null ? _getStageLabel(selectedStage!) : null,
                  () => _showStageFilter(context),
                ),

                const SizedBox(width: 8),

                // Filtre par localisation
                _buildFilterChip(
                  context,
                  'Localisation',
                  selectedLocation,
                  () => _showLocationFilter(context),
                ),

                const SizedBox(width: 8),

                // Autres filtres
                _buildFilterChip(
                  context,
                  'Plus de filtres',
                  null,
                  () => onAdvancedFilters?.call(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, String? value, VoidCallback onTap) {
    final isSelected = value != null;

    return FilterChip(
      label: Text(
        value ?? label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primary,
      checkmarkColor: Theme.of(context).colorScheme.onPrimary,
    );
  }

  void _showCategoryFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionner une catégorie',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Option "Toutes les catégories"
            ListTile(
              title: const Text('Toutes les catégories'),
              selected: selectedCategory == null,
              onTap: () {
                onCategoryChanged(null);
                Navigator.pop(context);
              },
            ),

            // Liste des catégories
            ...categories.map((category) => ListTile(
                  title: Text(category.getName('fr')),
                  selected: selectedCategory == category.id,
                  onTap: () {
                    onCategoryChanged(category.id);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showStageFilter(BuildContext context) {
    final stages = [
      {'value': 'IDEA', 'label': 'Idée'},
      {'value': 'PROTOTYPE', 'label': 'Prototype'},
      {'value': 'DEVELOPMENT', 'label': 'Développement'},
      {'value': 'GROWTH', 'label': 'Croissance'},
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sélectionner un stade',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Option "Tous les stades"
            ListTile(
              title: const Text('Tous les stades'),
              selected: selectedStage == null,
              onTap: () {
                onStageChanged(null);
                Navigator.pop(context);
              },
            ),

            // Liste des stades
            ...stages.map((stage) => ListTile(
                  title: Text(stage['label']!),
                  selected: selectedStage == stage['value'],
                  onTap: () {
                    onStageChanged(stage['value']);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLocationFilter(BuildContext context) {
    final controller = TextEditingController(text: selectedLocation ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer par localisation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Entrez une ville ou un pays',
            prefixIcon: Icon(Icons.location_on),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onLocationChanged(null);
              Navigator.pop(context);
            },
            child: const Text('Effacer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              onLocationChanged(
                  controller.text.isEmpty ? null : controller.text);
              Navigator.pop(context);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedCategory != null ||
        selectedStage != null ||
        selectedLocation != null;
  }

  String _getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => categories.first,
    );
    return category.getName('fr');
  }

  String _getStageLabel(String stage) {
    switch (stage) {
      case 'IDEA':
        return 'Idée';
      case 'PROTOTYPE':
        return 'Prototype';
      case 'DEVELOPMENT':
        return 'Développement';
      case 'GROWTH':
        return 'Croissance';
      default:
        return stage;
    }
  }
}
