import 'package:flutter/material.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@RoutePage()
class ProjectCreateScreen extends StatefulWidget {
  const ProjectCreateScreen({super.key});

  @override
  State<ProjectCreateScreen> createState() => _ProjectCreateScreenState();
}

class _ProjectCreateScreenState extends State<ProjectCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _detailedDescriptionController =
      TextEditingController();
  final TextEditingController _fundingRangeController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  String _selectedSector = 'Technologie';
  String _selectedStage = 'Idée';
  final List<String> _selectedPartnerTypes = [];
  final List<String> _selectedSkills = [];
  bool _isLoading = false;
  int _currentIndex = 2; // L'index 2 correspond à l'onglet de création

  // Options pour les sélecteurs
  final List<String> _sectors = [
    'Technologie',
    'Santé',
    'Éducation',
    'Finance',
    'Environnement',
    'Agriculture',
    'Commerce',
    'Services',
    'Industrie',
    'Autre'
  ];

  final List<String> _stages = [
    'Idée',
    'Prototype',
    'Développement',
    'Croissance'
  ];

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
    // Vérifier si l'utilisateur a accès à la création de projet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPremiumAccess();
    });
  }

  Future<void> _checkPremiumAccess() async {
    final hasAccess = await PremiumUtils.checkPremiumAccess(
      context,
      PremiumFeature.projectCreation,
    );

    if (!hasAccess && mounted) {
      // Si l'utilisateur n'a pas accès et n'a pas souscrit à Premium, revenir en arrière
      context.router.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescriptionController.dispose();
    _detailedDescriptionController.dispose();
    _fundingRangeController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submitProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Vérifier à nouveau l'accès Premium avant de soumettre
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
      // Simuler une requête d'API
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet créé avec succès !'),
            backgroundColor: DesignConstants.successGreen,
          ),
        );

        Navigator.of(context).pushReplacementNamed(Routes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Erreur lors de la création du projet. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigation vers d'autres écrans selon l'index
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

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DesignConstants.lightGrey,
      appBar: VLAppBar(
        title: appLocalizations.create,
        automaticallyImplyLeading: true,
        showLanguageButton: true,
        onNotificationTap: () {
          context.router.push(const NotificationsRoute());
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignConstants.paddingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Introduction
              const Text(
                'Partagez votre projet avec la communauté',
                style: TextStyle(
                  fontSize: DesignConstants.titleSmall,
                  fontWeight: DesignConstants.semiBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complétez les informations ci-dessous pour présenter votre projet aux investisseurs et partenaires potentiels.',
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                  color: DesignConstants.darkGrey,
                ),
              ),
              const SizedBox(height: 24),

              // Informations de base
              VLCard(
                padding: const EdgeInsets.all(DesignConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de base',
                      style: TextStyle(
                        fontSize: DesignConstants.titleSmall,
                        fontWeight: DesignConstants.semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Titre du projet
                    VLTextField(
                      label: 'Titre du projet',
                      hintText:
                          'Ex: Application mobile de livraison de repas locaux',
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un titre pour votre projet';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description courte
                    VLTextField(
                      label: 'Description courte',
                      hintText: 'Résumez votre projet en quelques phrases',
                      controller: _shortDescriptionController,
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description courte';
                        }
                        if (value.length > 200) {
                          return 'La description courte ne doit pas dépasser 200 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Secteur d'activité
                    Text(
                      'Secteur d\'activité',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                        fontWeight: DesignConstants.medium,
                        color: DesignConstants.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: DesignConstants.white,
                        borderRadius:
                            BorderRadius.circular(DesignConstants.radiusSmall),
                        border: Border.all(color: DesignConstants.mediumGrey),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSector,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _sectors.map((String sector) {
                            return DropdownMenuItem<String>(
                              value: sector,
                              child: Text(sector),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedSector = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stade du projet
                    Text(
                      'Stade du projet',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                        fontWeight: DesignConstants.medium,
                        color: DesignConstants.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: DesignConstants.white,
                        borderRadius:
                            BorderRadius.circular(DesignConstants.radiusSmall),
                        border: Border.all(color: DesignConstants.mediumGrey),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStage,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down),
                          items: _stages.map((String stage) {
                            return DropdownMenuItem<String>(
                              value: stage,
                              child: Text(stage),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedStage = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Description détaillée
              VLCard(
                padding: const EdgeInsets.all(DesignConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description détaillée',
                      style: TextStyle(
                        fontSize: DesignConstants.titleSmall,
                        fontWeight: DesignConstants.semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    VLTextField(
                      label: 'Description complète du projet',
                      hintText:
                          'Décrivez en détail votre projet, son objectif, son marché cible, etc.',
                      controller: _detailedDescriptionController,
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une description détaillée';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Financement et partenaires
              VLCard(
                padding: const EdgeInsets.all(DesignConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financement et partenaires',
                      style: TextStyle(
                        fontSize: DesignConstants.titleSmall,
                        fontWeight: DesignConstants.semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fourchette de financement
                    VLTextField(
                      label: 'Fourchette de financement recherché',
                      hintText: 'Ex: 50K - 100K €',
                      controller: _fundingRangeController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une fourchette de financement';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Types de partenaires recherchés
                    Text(
                      'Types de partenaires recherchés',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
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
                          },
                          backgroundColor: DesignConstants.lightGrey,
                          selectedColor:
                              DesignConstants.primaryBlue.withOpacity(0.2),
                          checkmarkColor: DesignConstants.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? DesignConstants.primaryBlue
                                : DesignConstants.darkGrey,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Compétences recherchées
                    Text(
                      'Compétences recherchées',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
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
                          },
                          backgroundColor: DesignConstants.lightGrey,
                          selectedColor:
                              DesignConstants.primaryBlue.withOpacity(0.2),
                          checkmarkColor: DesignConstants.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? DesignConstants.primaryBlue
                                : DesignConstants.darkGrey,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tags et catégorisation
              VLCard(
                padding: const EdgeInsets.all(DesignConstants.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tags et catégorisation',
                      style: TextStyle(
                        fontSize: DesignConstants.titleSmall,
                        fontWeight: DesignConstants.semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    VLTextField(
                      label: 'Tags (séparés par des virgules)',
                      hintText: 'Ex: innovation, écologie, mobile',
                      controller: _tagsController,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons d'action
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VLButton(
                    text: appLocalizations.saveAsDraft,
                    onPressed: () {
                      // TODO: Implémenter la sauvegarde comme brouillon
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Projet enregistré comme brouillon'),
                          backgroundColor: DesignConstants.darkGrey,
                        ),
                      );
                    },
                    type: VLButtonType.secondary,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  VLButton(
                    text: appLocalizations.publishProject,
                    onPressed: _submitProject,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Note sur les projets premium
              Container(
                padding: const EdgeInsets.all(DesignConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(DesignConstants.radiusSmall),
                  border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.3)),
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
                      'Passez à Premium pour mettre en avant votre projet et accéder à plus de fonctionnalités !',
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                        color: DesignConstants.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: VLBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
