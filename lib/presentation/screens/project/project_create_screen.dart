import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/config/routes.dart';
import 'package:venturelink/constants/design_constants.dart';
import 'package:venturelink/presentation/common_widgets/vl_app_bar.dart';
import 'package:venturelink/presentation/common_widgets/vl_button.dart';
import 'package:venturelink/presentation/common_widgets/vl_card.dart';
import 'package:venturelink/presentation/common_widgets/vl_text_field.dart';
import 'package:venturelink/presentation/common_widgets/vl_bottom_nav_bar.dart';
import 'package:auto_route/auto_route.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:venturelink/core/utils/premium_utils.dart';
import 'package:venturelink/core/utils/validation_utils.dart';
import 'package:venturelink/core/services/auto_save_service.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:async';

@RoutePage()
class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen>
    with AutoSaveMixin {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Contrôleurs de formulaire
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _detailedDescriptionController =
      TextEditingController();
  final TextEditingController _fundingRangeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _videoUrlController = TextEditingController();

  // FocusNodes pour la navigation clavier
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // État du formulaire
  String? _selectedCategoryId;
  String _selectedStage = 'IDEA';
  final List<String> _selectedPartnerTypes = [];
  final List<String> _selectedSkills = [];
  bool _isLoading = false;
  bool _isDraftLoading = false;
  int _currentIndex = 2;
  String? _currentDraftId;
  bool _hasUnsavedChanges = false;
  Timer? _validationTimer;

  // Données des dropdowns
  List<CategoryModel> _categories = [];
  List<TagModel> _availableTags = [];
  bool _categoriesLoaded = false;

  // Options statiques (en attendant l'API)
  final List<String> _stages = ['IDEA', 'PROTOTYPE', 'DEVELOPMENT', 'GROWTH'];

  final List<String> _partnerTypes = ['Investisseur', 'Associé', 'Mentor'];

  final List<String> _skills = [
    'Développement web',
    'Développement mobile',
    'Design UI/UX',
    'Marketing digital',
    'Vente',
    'Finance',
    'Juridique',
    'Gestion de projet',
    'Ressources humaines',
    'Communication'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });

    // Écouter les changements pour détecter les modifications non sauvegardées
    _titleController.addListener(_onFormChanged);
    _shortDescriptionController.addListener(_onFormChanged);
    _detailedDescriptionController.addListener(_onFormChanged);
    _fundingRangeController.addListener(_onFormChanged);
    _tagsController.addListener(_onFormChanged);
    _videoUrlController.addListener(_onFormChanged);
  }

  Future<void> _initializeScreen() async {
    // Vérifier l'accès Premium
    await _checkPremiumAccess();

    // Charger les catégories et tags
    await _loadFormData();

    // Vérifier s'il y a des données sauvegardées
    await _checkForSavedData();

    // Démarrer la sauvegarde automatique
    _startAutoSave();
  }

  Future<void> _checkPremiumAccess() async {
    final hasAccess = await PremiumUtils.checkPremiumAccess(
      context,
      PremiumFeature.projectCreation,
    );

    if (!hasAccess && mounted) {
      context.router.pop();
    }
  }

  Future<void> _loadFormData() async {
    final projectProvider =
        Provider.of<ProjectProvider>(context, listen: false);

    try {
      await Future.wait([
        projectProvider.loadCategories(),
        projectProvider.loadTags(),
      ]);

      if (mounted) {
        setState(() {
          _categories = projectProvider.categories;
          _availableTags = projectProvider.tags;
          _categoriesLoaded = true;

          // Sélectionner la première catégorie par défaut
          if (_categories.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des données: $e');
      if (mounted) {
        _showErrorSnackBar(
            'Erreur lors du chargement des données du formulaire');
      }
    }
  }

  Future<void> _checkForSavedData() async {
    final hasSaved = await hasSavedData('project_create');

    if (hasSaved && mounted) {
      final shouldRestore = await _showRestoreDialog();
      if (shouldRestore == true) {
        await _restoreSavedData();
      } else {
        await clearSavedData('project_create');
      }
    }
  }

  Future<bool?> _showRestoreDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Données sauvegardées trouvées'),
        content: const Text(
            'Nous avons trouvé des données de projet sauvegardées automatiquement. '
            'Souhaitez-vous les restaurer ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreSavedData() async {
    final savedData = await getSavedData('project_create');
    if (savedData != null) {
      setState(() {
        _titleController.text = savedData['title'] ?? '';
        _shortDescriptionController.text = savedData['short_description'] ?? '';
        _detailedDescriptionController.text =
            savedData['detailed_description'] ?? '';
        _fundingRangeController.text = savedData['funding_range'] ?? '';
        _tagsController.text = savedData['tags'] ?? '';
        _videoUrlController.text = savedData['video_url'] ?? '';
        _selectedCategoryId = savedData['category_id'];
        _selectedStage = savedData['stage'] ?? 'IDEA';
        _selectedPartnerTypes.clear();
        _selectedPartnerTypes.addAll(
            (savedData['partner_types'] as List<dynamic>?)?.cast<String>() ??
                []);
        _selectedSkills.clear();
        _selectedSkills.addAll(
            (savedData['skills'] as List<dynamic>?)?.cast<String>() ?? []);
        _currentDraftId = savedData['draft_id'];
      });

      _showSuccessSnackBar('Données restaurées avec succès');
    }
  }

  void _startAutoSave() {
    startAutoSave(
      formKey: 'project_create',
      getFormData: _getFormData,
      interval: const Duration(minutes: 2),
      onSaved: () {
        if (mounted) {
          setState(() {
            _hasUnsavedChanges = false;
          });
        }
      },
    );
  }

  Map<String, dynamic> _getFormData() {
    return {
      'title': _titleController.text,
      'short_description': _shortDescriptionController.text,
      'detailed_description': _detailedDescriptionController.text,
      'funding_range': _fundingRangeController.text,
      'tags': _tagsController.text,
      'video_url': _videoUrlController.text,
      'category_id': _selectedCategoryId,
      'stage': _selectedStage,
      'partner_types': _selectedPartnerTypes,
      'skills': _selectedSkills,
      'draft_id': _currentDraftId,
    };
  }

  void _onFormChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }

    // Validation en temps réel avec debounce
    _validationTimer?.cancel();
    _validationTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _formKey.currentState?.validate();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _shortDescriptionController.dispose();
    _detailedDescriptionController.dispose();
    _fundingRangeController.dispose();
    _tagsController.dispose();
    _videoUrlController.dispose();

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    _validationTimer?.cancel();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Veuillez corriger les erreurs avant de sauvegarder');
      return;
    }

    setState(() {
      _isDraftLoading = true;
    });

    try {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);

      final success = await projectProvider.saveDraft(
        title: _titleController.text,
        shortDescription: _shortDescriptionController.text,
        fullDescription: _detailedDescriptionController.text,
        categoryId: _selectedCategoryId!,
        stage: _selectedStage,
        fundingMin: _extractMinFunding(),
        fundingMax: _extractMaxFunding(),
        fundingCurrency: 'EUR',
        videoUrl: _videoUrlController.text.isNotEmpty
            ? _videoUrlController.text
            : null,
        tagIds: _getSelectedTagIds(),
      );

      if (success && mounted) {
        _currentDraftId = projectProvider.currentProject?.id;
        await clearSavedData('project_create');
        setState(() {
          _hasUnsavedChanges = false;
        });
        _showSuccessSnackBar('Brouillon sauvegardé avec succès');
      } else {
        _showErrorSnackBar(projectProvider.error ??
            'Erreur lors de la sauvegarde du brouillon');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la sauvegarde du brouillon');
    } finally {
      if (mounted) {
        setState(() {
          _isDraftLoading = false;
        });
      }
    }
  }

  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Veuillez corriger les erreurs avant de publier');
      return;
    }

    // Vérifier à nouveau l'accès Premium
    final hasAccess = await PremiumUtils.checkPremiumAccess(
      context,
      PremiumFeature.projectCreation,
    );

    if (!hasAccess) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final projectProvider =
          Provider.of<ProjectProvider>(context, listen: false);

      final success = await projectProvider.createProject(
        title: _titleController.text,
        shortDescription: _shortDescriptionController.text,
        fullDescription: _detailedDescriptionController.text,
        categoryId: _selectedCategoryId!,
        stage: _selectedStage,
        fundingMin: _extractMinFunding(),
        fundingMax: _extractMaxFunding(),
        fundingCurrency: 'EUR',
        videoUrl: _videoUrlController.text.isNotEmpty
            ? _videoUrlController.text
            : null,
        tagIds: _getSelectedTagIds(),
      );

      if (success && mounted) {
        await clearSavedData('project_create');
        _showSuccessSnackBar('Projet créé avec succès !');

        // Navigation vers la page d'accueil
        context.router.pushAndPopUntil(
          const HomeRoute(),
          predicate: (route) => false,
        );
      } else {
        _showErrorSnackBar(
            projectProvider.error ?? 'Erreur lors de la création du projet');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors de la création du projet');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _extractMinFunding() {
    try {
      final text = _fundingRangeController.text.trim();
      if (text.isEmpty) return 0.0;

      // Extraire les montants de la fourchette
      final parts = text.split('-');
      if (parts.length >= 1) {
        final minText = parts[0].trim().replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(minText) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  double _extractMaxFunding() {
    try {
      final text = _fundingRangeController.text.trim();
      if (text.isEmpty) return 0.0;

      // Extraire les montants de la fourchette
      final parts = text.split('-');
      if (parts.length >= 2) {
        final maxText = parts[1].trim().replaceAll(RegExp(r'[^\d.]'), '');
        return double.tryParse(maxText) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  List<String> _getSelectedTagIds() {
    final tagNames = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    return _availableTags
        .where((tag) =>
            tagNames.contains(tag.nameFr) || tagNames.contains(tag.nameEn))
        .map((tag) => tag.id)
        .toList();
  }

  void _onNavBarTap(int index) {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog(() => _navigateToIndex(index));
    } else {
      _navigateToIndex(index);
    }
  }

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.router.push(const HomeRoute());
        break;
      case 1:
        context.router.push(const SearchRoute());
        break;
      case 2:
        // Déjà sur l'écran de création
        break;
      case 3:
        context.router.push(const NotificationsRoute());
        break;
      case 4:
        context.router.push(const ProfileRoute());
        break;
    }
  }

  Future<void> _showUnsavedChangesDialog(VoidCallback onConfirm) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non sauvegardées'),
        content: const Text('Vous avez des modifications non sauvegardées. '
            'Souhaitez-vous les sauvegarder avant de quitter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              onConfirm();
            },
            child: const Text('Quitter sans sauvegarder'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              await _saveDraft();
              onConfirm();
            },
            child: const Text('Sauvegarder et quitter'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: DesignConstants.successGreen,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: () {
              // Logique de retry si nécessaire
            },
          ),
        ),
      );
    }
  }

  TextInputAction _getNextTextInputAction(int index) {
    return index < _focusNodes.length - 1
        ? TextInputAction.next
        : TextInputAction.done;
  }

  void _focusNext(int currentIndex) {
    if (currentIndex < _focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[currentIndex + 1]);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) {
        if (!didPop && _hasUnsavedChanges) {
          _showUnsavedChangesDialog(() => Navigator.of(context).pop());
        }
      },
      child: Scaffold(
        backgroundColor: DesignConstants.lightGrey,
        appBar: VLAppBar(
          title: appLocalizations.create,
          automaticallyImplyLeading: true,
          showLanguageButton: true,
          onNotificationTap: () {
            context.router.push(const NotificationsRoute());
          },
          actions: [
            if (_hasUnsavedChanges)
              IconButton(
                icon: const Icon(Icons.save_outlined),
                onPressed: _saveDraft,
                tooltip: 'Sauvegarder le brouillon',
              ),
          ],
        ),
        body: _categoriesLoaded
            ? _buildForm(appLocalizations, isTablet)
            : const Center(child: CircularProgressIndicator()),
        bottomNavigationBar: VLBottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onNavBarTap,
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations appLocalizations, bool isTablet) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroduction(appLocalizations),
            SizedBox(height: isTablet ? 32 : 24),
            _buildBasicInfoCard(appLocalizations, isTablet),
            SizedBox(height: isTablet ? 24 : 16),
            _buildDetailedDescriptionCard(appLocalizations, isTablet),
            SizedBox(height: isTablet ? 24 : 16),
            _buildFundingCard(appLocalizations, isTablet),
            SizedBox(height: isTablet ? 24 : 16),
            _buildTagsCard(appLocalizations, isTablet),
            SizedBox(height: isTablet ? 32 : 24),
            _buildActionButtons(appLocalizations),
            SizedBox(height: isTablet ? 24 : 16),
            _buildPremiumNote(appLocalizations),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction(AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.shareYourProject ??
              'Partagez votre projet avec la communauté',
          style: const TextStyle(
            fontSize: DesignConstants.titleSmall,
            fontWeight: DesignConstants.semiBold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          appLocalizations.projectCreationDescription ??
              'Complétez les informations ci-dessous pour présenter votre projet aux investisseurs et partenaires potentiels.',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
            color: DesignConstants.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(AppLocalizations appLocalizations, bool isTablet) {
    return VLCard(
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.basicInformation ?? 'Informations de base',
            style: const TextStyle(
              fontSize: DesignConstants.titleSmall,
              fontWeight: DesignConstants.semiBold,
            ),
          ),
          const SizedBox(height: 16),

          // Titre du projet
          VLTextField(
            label: appLocalizations.projectTitle ?? 'Titre du projet',
            hintText: appLocalizations.projectTitleHint ??
                'Ex: Application mobile de livraison de repas locaux',
            controller: _titleController,
            focusNode: _focusNodes[0],
            textInputAction: _getNextTextInputAction(0),
            onSubmitted: (_) => _focusNext(0),
            validator: ValidationUtils.validateProjectTitle,
            semanticsLabel: 'Titre du projet, champ obligatoire',
          ),
          const SizedBox(height: 16),

          // Description courte
          VLTextField(
            label: appLocalizations.shortDescription ?? 'Description courte',
            hintText: appLocalizations.shortDescriptionHint ??
                'Résumez votre projet en quelques phrases',
            controller: _shortDescriptionController,
            focusNode: _focusNodes[1],
            textInputAction: _getNextTextInputAction(1),
            onSubmitted: (_) => _focusNext(1),
            maxLines: isTablet ? 3 : 2,
            validator: ValidationUtils.validateShortDescription,
            semanticsLabel:
                'Description courte du projet, maximum 200 caractères',
          ),
          const SizedBox(height: 16),

          // Catégorie
          _buildCategoryDropdown(appLocalizations),
          const SizedBox(height: 16),

          // Stade du projet
          _buildStageDropdown(appLocalizations),

          // URL vidéo (optionnelle)
          const SizedBox(height: 16),
          VLTextField(
            label: appLocalizations.videoUrl ?? 'URL vidéo (optionnelle)',
            hintText: 'https://youtube.com/watch?v=...',
            controller: _videoUrlController,
            focusNode: _focusNodes[5],
            textInputAction: TextInputAction.done,
            validator: ValidationUtils.validateVideoUrl,
            semanticsLabel: 'URL vidéo optionnelle pour présenter votre projet',
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.sector ?? 'Secteur d\'activité',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            fontWeight: DesignConstants.medium,
            color: DesignConstants.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: DesignConstants.white,
            borderRadius: BorderRadius.circular(DesignConstants.radiusSmall),
            border: Border.all(color: DesignConstants.mediumGrey),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategoryId,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              hint: Text(appLocalizations.selectCategory ??
                  'Sélectionner une catégorie'),
              semanticLabel:
                  'Sélectionner le secteur d\'activité de votre projet',
              items: _categories.map((CategoryModel category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.nameFr),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategoryId = newValue;
                  });
                  _onFormChanged();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStageDropdown(AppLocalizations appLocalizations) {
    final stageLabels = {
      'IDEA': appLocalizations.stageIdea ?? 'Idée',
      'PROTOTYPE': appLocalizations.stagePrototype ?? 'Prototype',
      'DEVELOPMENT': appLocalizations.stageDevelopment ?? 'Développement',
      'GROWTH': appLocalizations.stageGrowth ?? 'Croissance',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.projectStage ?? 'Stade du projet',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            fontWeight: DesignConstants.medium,
            color: DesignConstants.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: DesignConstants.white,
            borderRadius: BorderRadius.circular(DesignConstants.radiusSmall),
            border: Border.all(color: DesignConstants.mediumGrey),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStage,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              semanticLabel:
                  'Sélectionner le stade de développement de votre projet',
              items: _stages.map((String stage) {
                return DropdownMenuItem<String>(
                  value: stage,
                  child: Text(stageLabels[stage] ?? stage),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedStage = newValue;
                  });
                  _onFormChanged();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedDescriptionCard(
      AppLocalizations appLocalizations, bool isTablet) {
    return VLCard(
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.detailedDescription ?? 'Description détaillée',
            style: const TextStyle(
              fontSize: DesignConstants.titleSmall,
              fontWeight: DesignConstants.semiBold,
            ),
          ),
          const SizedBox(height: 16),
          VLTextField(
            label: appLocalizations.fullProjectDescription ??
                'Description complète du projet',
            hintText: appLocalizations.fullProjectDescriptionHint ??
                'Décrivez en détail votre projet, son objectif, son marché cible, etc.',
            controller: _detailedDescriptionController,
            focusNode: _focusNodes[2],
            textInputAction: _getNextTextInputAction(2),
            onSubmitted: (_) => _focusNext(2),
            maxLines: isTablet ? 10 : 8,
            validator: ValidationUtils.validateFullDescription,
            semanticsLabel:
                'Description détaillée du projet, minimum 50 caractères',
          ),
        ],
      ),
    );
  }

  Widget _buildFundingCard(AppLocalizations appLocalizations, bool isTablet) {
    return VLCard(
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.fundingAndPartners ?? 'Financement et partenaires',
            style: const TextStyle(
              fontSize: DesignConstants.titleSmall,
              fontWeight: DesignConstants.semiBold,
            ),
          ),
          const SizedBox(height: 16),

          // Fourchette de financement
          VLTextField(
            label: appLocalizations.fundingRange ??
                'Fourchette de financement recherché',
            hintText: appLocalizations.fundingRangeHint ?? 'Ex: 50K - 100K €',
            controller: _fundingRangeController,
            focusNode: _focusNodes[3],
            textInputAction: _getNextTextInputAction(3),
            onSubmitted: (_) => _focusNext(3),
            validator: ValidationUtils.validateFundingRange,
            semanticsLabel:
                'Fourchette de financement, format: montant minimum - montant maximum',
          ),
          const SizedBox(height: 16),

          // Types de partenaires recherchés
          _buildPartnerTypesSection(appLocalizations, isTablet),
          const SizedBox(height: 16),

          // Compétences recherchées
          _buildSkillsSection(appLocalizations, isTablet),
        ],
      ),
    );
  }

  Widget _buildPartnerTypesSection(
      AppLocalizations appLocalizations, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.partnerTypes ?? 'Types de partenaires recherchés',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            fontWeight: DesignConstants.medium,
            color: DesignConstants.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _partnerTypes.map((type) {
            final isSelected = _selectedPartnerTypes.contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedPartnerTypes.add(type);
                  } else {
                    _selectedPartnerTypes.remove(type);
                  }
                });
                _onFormChanged();

                // Feedback haptique
                HapticFeedback.selectionClick();
              },
              backgroundColor: DesignConstants.lightGrey,
              selectedColor: DesignConstants.primaryBlue.withOpacity(0.2),
              checkmarkColor: DesignConstants.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected
                    ? DesignConstants.primaryBlue
                    : DesignConstants.darkGrey,
              ),
              semanticsLabel:
                  'Type de partenaire: $type, ${isSelected ? "sélectionné" : "appuyer pour sélectionner"}',
              materialTapTargetSize: MaterialTapTargetSize.padded,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(AppLocalizations appLocalizations, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appLocalizations.skillsNeeded ?? 'Compétences recherchées',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
            fontWeight: DesignConstants.medium,
            color: DesignConstants.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) {
            final isSelected = _selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSkills.add(skill);
                  } else {
                    _selectedSkills.remove(skill);
                  }
                });
                _onFormChanged();

                // Feedback haptique
                HapticFeedback.selectionClick();
              },
              backgroundColor: DesignConstants.lightGrey,
              selectedColor: DesignConstants.primaryBlue.withOpacity(0.2),
              checkmarkColor: DesignConstants.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected
                    ? DesignConstants.primaryBlue
                    : DesignConstants.darkGrey,
              ),
              semanticsLabel:
                  'Compétence: $skill, ${isSelected ? "sélectionnée" : "appuyer pour sélectionner"}',
              materialTapTargetSize: MaterialTapTargetSize.padded,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTagsCard(AppLocalizations appLocalizations, bool isTablet) {
    return VLCard(
      padding: EdgeInsets.all(isTablet ? 24.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appLocalizations.tagsAndCategorization ?? 'Tags et catégorisation',
            style: const TextStyle(
              fontSize: DesignConstants.titleSmall,
              fontWeight: DesignConstants.semiBold,
            ),
          ),
          const SizedBox(height: 16),
          VLTextField(
            label: appLocalizations.tags ?? 'Tags (séparés par des virgules)',
            hintText:
                appLocalizations.tagsHint ?? 'Ex: innovation, écologie, mobile',
            controller: _tagsController,
            focusNode: _focusNodes[4],
            textInputAction: _getNextTextInputAction(4),
            onSubmitted: (_) => _focusNext(4),
            validator: ValidationUtils.validateTags,
            semanticsLabel:
                'Tags du projet, séparés par des virgules, maximum 10 tags',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations appLocalizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VLButton(
          text: appLocalizations.saveAsDraft,
          onPressed: _isDraftLoading ? null : _saveDraft,
          type: VLButtonType.secondary,
          isFullWidth: true,
          isLoading: _isDraftLoading,
          semanticsLabel: 'Sauvegarder le projet comme brouillon',
        ),
        const SizedBox(height: 12),
        VLButton(
          text: appLocalizations.publishProject,
          onPressed: (_isLoading || _selectedCategoryId == null)
              ? null
              : _submitProject,
          isLoading: _isLoading,
          isFullWidth: true,
          semanticsLabel: 'Publier le projet sur la plateforme',
        ),
      ],
    );
  }

  Widget _buildPremiumNote(AppLocalizations appLocalizations) {
    return Container(
      padding: const EdgeInsets.all(DesignConstants.paddingMedium),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignConstants.radiusSmall),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.star,
                color: Color(0xFFFFD700),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Premium',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            appLocalizations.premiumNote ??
                'Passez à Premium pour mettre en avant votre projet et accéder à plus de fonctionnalités !',
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
              color: DesignConstants.black,
            ),
          ),
        ],
      ),
    );
  }
}
