import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/theme/app_theme.dart';

/// Bottom sheet pour les filtres de recherche de projets
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

  final List<Map<String, String>> _stages = [
    {'id': 'IDEA', 'label': 'Idée'},
    {'id': 'PROTOTYPE', 'label': 'Prototype'},
    {'id': 'MVP', 'label': 'MVP'},
    {'id': 'GROWTH', 'label': 'Croissance'},
    {'id': 'SCALE', 'label': 'Expansion'},
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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  _buildStageFilter(),
                  const SizedBox(height: 16),
                  _buildBudgetFilter(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Filtres',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
        _buildSectionTitle('Catégorie'),
        const SizedBox(height: 8),
        Wrap(
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
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStageFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Stade de développement'),
        const SizedBox(height: 8),
        Wrap(
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
        _buildSectionTitle('Budget'),
        const SizedBox(height: 8),
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
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatAmount(_fundingRange.start)),
            Text(_formatAmount(_fundingRange.end)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _selectedStage = null;
                _fundingRange = const RangeValues(0, 1000000);
              });
            },
            child: const Text('Réinitialiser'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              final updatedFilters = _filters.copyWith(
                categoryId: _selectedCategory,
                stage: _selectedStage,
                fundingMin: _fundingRange.start > 0 ? _fundingRange.start : null,
                fundingMax: _fundingRange.end < 1000000 ? _fundingRange.end : null,
              );
              
              widget.onFiltersApplied?.call(updatedFilters);
              Navigator.pop(context, updatedFilters);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
            ),
            child: const Text('Appliquer'),
          ),
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
      return amount.toStringAsFixed(0);
    }
  }
}
