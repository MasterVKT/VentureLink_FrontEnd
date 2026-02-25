import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/investment_provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:cached_network_image/cached_network_image.dart';

@RoutePage()
class InvestmentCreateScreen extends StatefulWidget {
  final String projectId;

  const InvestmentCreateScreen({
    super.key,
    required this.projectId,
  });

  @override
  State<InvestmentCreateScreen> createState() => _InvestmentCreateScreenState();
}

class _InvestmentCreateScreenState extends State<InvestmentCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _equityController = TextEditingController();
  final _interestController = TextEditingController();
  final _termController = TextEditingController();

  String _investmentType = 'EQUITY';
  String _currency = 'EUR';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Charger le projet si pas déjà fait
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProject(widget.projectId);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _equityController.dispose();
    _interestController.dispose();
    _termController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investir dans le projet'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitInvestment,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Investir'),
          ),
        ],
      ),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          final project = projectProvider.currentProject;

          if (projectProvider.isLoading || project == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (project.id != widget.projectId) {
            return const Center(
              child: Text('Projet non trouvé'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte du projet
                  _buildProjectCard(project),

                  const SizedBox(height: 24),

                  // Formulaire d'investissement
                  _buildInvestmentForm(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: project.media?.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: project.media!.first.fileUrl ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.lightbulb_outline,
                            ),
                          ),
                        )
                      : const Icon(Icons.lightbulb_outline),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Par ${project.creator.fullName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              project.shortDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 16),

            // Informations de financement
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financement recherché',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${project.fundingMin.toInt()}k - ${project.fundingMax.toInt()}k €',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stade',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          _getStageLabel(project.stage),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détails de l\'investissement',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 16),

        // Type d'investissement
        Text(
          'Type d\'investissement',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _investmentType,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Sélectionnez le type',
          ),
          items: const [
            DropdownMenuItem(value: 'EQUITY', child: Text('Capital (Equity)')),
            DropdownMenuItem(value: 'DEBT', child: Text('Dette (Loan)')),
            DropdownMenuItem(value: 'CONVERTIBLE', child: Text('Convertible')),
          ],
          onChanged: (value) {
            setState(() {
              _investmentType = value!;
            });
          },
        ),

        const SizedBox(height: 16),

        // Montant
        Text(
          'Montant de l\'investissement',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Montant',
                  prefixText: '€ ',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir un montant';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                ],
                onChanged: (value) {
                  setState(() {
                    _currency = value!;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Champs spécifiques au type d'investissement
        if (_investmentType == 'EQUITY') ...[
          Text(
            'Pourcentage d\'équité souhaité (%)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _equityController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ex: 15',
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final percentage = double.tryParse(value);
                if (percentage == null || percentage <= 0 || percentage > 100) {
                  return 'Pourcentage invalide (0-100)';
                }
              }
              return null;
            },
          ),
        ],

        if (_investmentType == 'DEBT') ...[
          Text(
            'Taux d\'intérêt souhaité (%)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _interestController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ex: 8',
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Durée (mois)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _termController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ex: 24',
              suffixText: 'mois',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Description
        Text(
          'Message ou conditions (optionnel)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Décrivez vos attentes, conditions ou motivations...',
          ),
          maxLines: 4,
          maxLength: 500,
        ),

        const SizedBox(height: 24),

        // Avertissement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber, color: Colors.amber[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Information importante',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cette demande d\'investissement sera envoyée au créateur du projet. Elle ne constitue pas un engagement légal jusqu\'à signature d\'un contrat.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
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

  Future<void> _submitInvestment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final equity = _equityController.text.isNotEmpty
          ? double.parse(_equityController.text)
          : null;
      final interest = _interestController.text.isNotEmpty
          ? double.parse(_interestController.text)
          : null;
      final term = _termController.text.isNotEmpty
          ? int.parse(_termController.text)
          : null;

      final success = await context.read<InvestmentProvider>().createInvestment(
            projectId: widget.projectId,
            amount: amount,
            currency: _currency,
            investmentType: _investmentType,
            equityPercentage: equity,
            interestRate: interest,
            termMonths: term,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande d\'investissement envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        context.router.maybePop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<InvestmentProvider>().error ??
                'Erreur lors de l\'envoi de la demande'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
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
}
