import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:venturelink/presentation/widgets/project_card.dart';

@RoutePage()
class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  bool _showFilters = false;
  String _selectedCategory = '';
  String _selectedStage = '';
  String _selectedFundingType = '';
  RangeValues _fundingRange = const RangeValues(0, 1000000);
  DateTime? _createdAfter;
  DateTime? _createdBefore;
  bool _isVerifiedOnly = false;
  bool _isActiveOnly = true;

  List<ProjectModel> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _categories = [
    'Tous',
    'Technologie',
    'Santé',
    'Finance',
    'E-commerce',
    'Éducation',
    'Environnement',
    'Immobilier',
    'Autre',
  ];

  final List<String> _stages = [
    'Tous',
    'Idée',
    'Prototype',
    'MVP',
    'Croissance',
    'Expansion',
  ];

  final List<String> _fundingTypes = [
    'Tous',
    'Love Money',
    'Business Angels',
    'Venture Capital',
    'Crowdfunding',
    'Prêt bancaire',
    'Subvention',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche avancée'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<SubscriptionProvider>(
            builder: (context, subscriptionProvider, child) {
              if (subscriptionProvider.hasActiveSubscription) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.bookmark_outline),
                  onSelected: _handleSavedSearchAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          Icon(Icons.save),
                          SizedBox(width: 8),
                          Text('Sauvegarder cette recherche'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.list),
                          SizedBox(width: 8),
                          Text('Mes recherches sauvegardées'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche principale
          Container(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher des projets...',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                      icon: Icon(
                        _showFilters
                            ? Icons.filter_list_off
                            : Icons.filter_list,
                        color: Colors.white,
                      ),
                      tooltip: 'Filtres',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _performSearch,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.search),
                        label: const Text('Rechercher'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Panneau de filtres
          if (_showFilters) _buildFiltersPanel(),

          // Résultats de recherche
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      color: Colors.grey[50],
      child: ExpansionTile(
        title: const Text(
          'Filtres avancés',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Catégorie et Secteur
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdownField(
                        'Catégorie',
                        _selectedCategory,
                        _categories,
                        (value) => setState(() => _selectedCategory = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdownField(
                        'Stade',
                        _selectedStage,
                        _stages,
                        (value) => setState(() => _selectedStage = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Type de financement
                _buildDropdownField(
                  'Type de financement',
                  _selectedFundingType,
                  _fundingTypes,
                  (value) => setState(() => _selectedFundingType = value!),
                ),
                const SizedBox(height: 16),

                // Localisation
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Localisation',
                    hintText: 'Ville, région, pays...',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Plage de financement
                Text(
                  'Montant recherché',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _fundingRange,
                  min: 0,
                  max: 2000000,
                  divisions: 40,
                  labels: RangeLabels(
                    '${(_fundingRange.start / 1000).round()}K€',
                    '${(_fundingRange.end / 1000).round()}K€',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _fundingRange = values;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        'Créé après',
                        _createdAfter,
                        (date) => setState(() => _createdAfter = date),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField(
                        'Créé avant',
                        _createdBefore,
                        (date) => setState(() => _createdBefore = date),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Options
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Projets vérifiés uniquement'),
                        value: _isVerifiedOnly,
                        onChanged: (value) {
                          setState(() {
                            _isVerifiedOnly = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Projets actifs uniquement'),
                        value: _isActiveOnly,
                        onChanged: (value) {
                          setState(() {
                            _isActiveOnly = value!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value.isEmpty ? null : value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item == 'Tous' ? '' : item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        onChanged(pickedDate);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Sélectionner une date',
          style: TextStyle(
            color: date != null ? null : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Utilisez les filtres ci-dessus pour rechercher des projets',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun projet trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header avec nombre de résultats
        Container(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} projet(s) trouvé(s)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Trier par'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'date', child: Text('Date de création')),
                  const PopupMenuItem(
                      value: 'funding', child: Text('Montant recherché')),
                  const PopupMenuItem(
                      value: 'views', child: Text('Popularité')),
                  const PopupMenuItem(
                      value: 'relevance', child: Text('Pertinence')),
                ],
                onSelected: (value) {
                  // TODO: Implémenter le tri
                },
              ),
            ],
          ),
        ),

        // Liste des résultats
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProjectCard(project: _searchResults[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simuler une recherche API
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Remplacer par un vrai appel API
    if (!mounted) return;
    final projectProvider = context.read<ProjectProvider>();
    final allProjects = projectProvider.projects;

    List<ProjectModel> results = allProjects.where((project) {
      // Filtre par texte de recherche
      if (_searchController.text.isNotEmpty) {
        final searchLower = _searchController.text.toLowerCase();
        if (!project.title.toLowerCase().contains(searchLower) &&
            !project.description.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Filtre par catégorie
      if (_selectedCategory.isNotEmpty &&
          project.category.toString() != _selectedCategory) {
        return false;
      }

      // Filtre par stade
      if (_selectedStage.isNotEmpty && project.stage != _selectedStage) {
        return false;
      }

      // Filtre par montant
      if (project.fundingGoal < _fundingRange.start ||
          project.fundingGoal > _fundingRange.end) {
        return false;
      }

      // Filtre par statut actif
      if (_isActiveOnly && project.status != 'ACTIVE') {
        return false;
      }

      // Filtre par vérification
      if (_isVerifiedOnly && !project.isVerified) {
        return false;
      }

      return true;
    }).toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _locationController.clear();
      _minAmountController.clear();
      _maxAmountController.clear();
      _selectedCategory = '';
      _selectedStage = '';
      _selectedFundingType = '';
      _fundingRange = const RangeValues(0, 1000000);
      _createdAfter = null;
      _createdBefore = null;
      _isVerifiedOnly = false;
      _isActiveOnly = true;
      _searchResults = [];
      _hasSearched = false;
    });
  }

  void _handleSavedSearchAction(String action) {
    switch (action) {
      case 'save':
        _showSaveSearchDialog();
        break;
      case 'view':
        _showSavedSearches();
        break;
    }
  }

  void _showSaveSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        return AlertDialog(
          title: const Text('Sauvegarder la recherche'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nom de la recherche',
              hintText: 'Ex: Startups tech Paris',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // TODO: Sauvegarder la recherche
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Recherche sauvegardée !'),
                  ),
                );
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _showSavedSearches() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppConfig.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mes recherches sauvegardées',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    // TODO: Afficher les vraies recherches sauvegardées
                    ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: const Text('Startups tech Paris'),
                      subtitle: const Text('Créée il y a 2 jours'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Charger cette recherche
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: const Text('E-commerce < 50K€'),
                      subtitle: const Text('Créée il y a 1 semaine'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Charger cette recherche
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
