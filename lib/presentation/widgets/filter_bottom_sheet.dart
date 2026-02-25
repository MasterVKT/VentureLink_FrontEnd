
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

  @override
  void initState() {
    super.initState();
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