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

import 'package:flutter/material.dart';
import 'package:venturelink/data/models/project_filters.dart';
import 'package:venturelink/data/models/project_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final ProjectFilters currentFilters;
  final Function(ProjectFilters) onApply;
  final List<CategoryModel> categories;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onApply,
    required this.categories,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
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
    // Créer une copie des filtres actuels
    _filters = ProjectFilters(
      category: widget.currentFilters.category,
      location: widget.currentFilters.location,
      minBudget: widget.currentFilters.minBudget,
      maxBudget: widget.currentFilters.maxBudget,
      status: widget.currentFilters.status,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: 16),

          // Filtres (avec scroll si beaucoup de contenu)
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  _buildLocationFilter(),
                  const SizedBox(height: 16),
                  _buildBudgetFilter(),
                  const SizedBox(height: 16),
                  _buildStatusFilter(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Boutons
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
          runSpacing: 8,
          children: widget.categories.map((category) {
            final isSelected = _filters.category == category.id;
            return FilterChip(
              label: Text(category.nameFr),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters.category = selected ? category.id : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationFilter() {
    final countries = [
      'Cameroun',
      'Sénégal',
      'Côte d\'Ivoire',
      'Bénin',
      'Togo',
      'Mali',
      'Niger',
      'Burkina Faso',
    ];

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
        DropdownButtonFormField<String>(
          value: _filters.location,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: const Text('Sélectionner un pays'),
          items: countries.map((country) {
            return DropdownMenuItem(
              value: country,
              child: Text(country),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _filters.location = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBudgetFilter() {
    return Column(
      children: [
        RangeSlider(
          values: _fundingRange,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Budget',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(
            _filters.minBudget ?? 0,
            _filters.maxBudget ?? 1000000,
          ),
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
            _formatCurrency(_filters.minBudget ?? 0),
            _formatCurrency(_filters.maxBudget ?? 1000000),
          ),
          onChanged: (values) {
            setState(() {
              _filters.minBudget = values.start;
              _filters.maxBudget = values.end;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatCurrency(_filters.minBudget ?? 0)),
            Text(_formatCurrency(_filters.maxBudget ?? 1000000)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'value': 'ACTIVE', 'label': 'Actif'},
      {'value': 'FUNDED', 'label': 'Financé'},
      {'value': 'CLOSED', 'label': 'Fermé'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statut',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: statuses.map((status) {
            final isSelected = _filters.status == status['value'];
            return FilterChip(
              label: Text(status['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filters.status = selected ? status['value'] : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _filters.clear();
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
              widget.onApply(_filters);
              Navigator.pop(context);
            },
            child: const Text('Appliquer'),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M €';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K €';
    }
    return '${amount.toStringAsFixed(0)} €';
  }
}
