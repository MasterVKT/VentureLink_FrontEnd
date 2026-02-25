import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/theme/app_theme.dart';

/// Bottom sheet pour les filtres de recherche de projets
/// Affiche les options de filtrage: catégorie, stage, localisation, budget
class FilterBottomSheet extends StatefulWidget {
  final ProjectFilters currentFilters;
  final List<CategoryModel> categories;
  final Function(ProjectFilters filters)? onFiltersApplied;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.categories,
    this.onFiltersApplied,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();

  /// Affiche le bottom sheet et retourne les filtres mis à jour
  static Future<ProjectFilters?> show(
    BuildContext context, {
    required ProjectFilters currentFilters,
    required List<CategoryModel> categories,
  }) {
    return showModalBottomSheet<ProjectFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: currentFilters,
        categories: categories,
      ),
    );
  }
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ProjectFilters _filters;
  String? _selectedCategory;
  String? _selectedStage;
  RangeValues _fundingRange = const RangeValues(0, 1000000);

  // Options de stage
  final List<Map<String, String>> _stages = [
    {'id': 'IDEA', 'label': 'Idée'},
    {'id': 'PROTOTYPE', 'label': 'Prototype'},
    {'id': 'MVP', 'label': 'MVP'},
    {'id': 'LAUNCHED', 'label': 'Lancé'},
    {'id': 'GROWTH', 'label': 'Croissance'},
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _selectedCategory = widget.currentFilters.categoryId;
    _selectedStage = widget.currentFilters.stage;
    _fundingRange = RangeValues(
      widget.currentFilters.fundingMin ?? 0,
      widget.currentFilters.fundingMax ?? 1000000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const Spacer(),
                if (_filters.hasActiveFilters)
                  TextButton(
                    onPressed: _resetFilters,
                    child: const Text('Réinitialiser'),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Contenu scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre: Catégorie
                  _buildSectionTitle('Catégorie'),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(),
                  const SizedBox(height: 24),

                  // Filtre: Stage
                  _buildSectionTitle('Stade de développement'),
                  const SizedBox(height: 12),
                  _buildStageFilter(),
                  const SizedBox(height: 24),

                  // Filtre: Budget
                  _buildSectionTitle('Budget recherché'),
                  const SizedBox(height: 12),
                  _buildBudgetFilter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Bouton d'application
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _applyFilters,
                icon: const Icon(Icons.filter_alt),
                label: Text(
                  'Appliquer les filtres${_filters.hasActiveFilters ? ' (${_filters.activeFiltersCount})' : ''}',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.categories.map((category) {
        final isSelected = _selectedCategory == category.id;
        return FilterChip(
          label: Text(category.nameFr),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? category.id : null;
              _filters = _filters.copyWith(
                categoryId: selected ? category.id : null,
              );
            });
          },
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStageFilter() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _stages.map((stage) {
        final isSelected = _selectedStage == stage['id'];
        return FilterChip(
          label: Text(stage['label']!),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedStage = selected ? stage['id'] : null;
              _filters = _filters.copyWith(
                stage: selected ? stage['id'] : null,
              );
            });
          },
          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
          checkmarkColor: AppTheme.primaryColor,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _fundingRange,
          min: 0,
          max: 1000000,
          divisions: 100,
          labels: RangeLabels(
            _formatAmount(_fundingRange.start),
            _formatAmount(_fundingRange.end),
          ),
          onChanged: (values) {
            setState(() {
              _fundingRange = values;
              _filters = _filters.copyWith(
                fundingMin: values.start > 0 ? values.start : null,
                fundingMax: values.end < 1000000 ? values.end : null,
              );
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Min: ${_formatAmount(_fundingRange.start)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Max: ${_formatAmount(_fundingRange.end)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
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

  void _resetFilters() {
    setState(() {
      _filters = const ProjectFilters();
      _selectedCategory = null;
      _selectedStage = null;
      _fundingRange = const RangeValues(0, 1000000);
    });
  }

  void _applyFilters() {
    if (widget.onFiltersApplied != null) {
      widget.onFiltersApplied!(_filters);
    }
    Navigator.of(context).pop(_filters);
  }
}
