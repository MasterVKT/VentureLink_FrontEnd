import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/models/project_model.dart';

class InterestExpressionWidget extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback? onSuccess;

  const InterestExpressionWidget({
    super.key,
    required this.project,
    this.onSuccess,
  });

  @override
  State<InterestExpressionWidget> createState() =>
      _InterestExpressionWidgetState();
}

class _InterestExpressionWidgetState extends State<InterestExpressionWidget> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isAnonymous = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Poignée
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titre
              Text(
                'Manifester votre intérêt',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                'Exprimez votre intérêt pour "${widget.project.title}"',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Message
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message au créateur',
                  helperText: 'Expliquez votre intérêt pour ce projet',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message_outlined),
                ),
                maxLines: 4,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir un message';
                  }
                  if (value.trim().length < 10) {
                    return 'Le message doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Montant d'investissement potentiel
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant d\'investissement potentiel',
                  helperText:
                      'Montant que vous seriez prêt à investir (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.euro),
                  suffixText: 'EUR',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final amount = int.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Veuillez saisir un montant valide';
                    }
                    if (amount < 100) {
                      return 'Le montant minimum est de 100 EUR';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Option anonyme
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Exprimer mon intérêt de manière anonyme',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Manifester mon intérêt'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Feedback haptique
    HapticFeedback.selectionClick();

    setState(() {
      _isLoading = true;
    });

    try {
      final projectProvider = context.read<ProjectProvider>();
      final authProvider = context.read<AuthProvider>();

      if (authProvider.currentUser == null) {
        throw Exception(
            'Vous devez être connecté pour manifester votre intérêt');
      }

      final amount = _amountController.text.isNotEmpty
          ? double.tryParse(_amountController.text)
          : null;

      final success = await projectProvider.expressInterest(
        widget.project.id,
        message: _messageController.text.trim(),
        amount: amount,
        isAnonymous: _isAnonymous,
      );

      if (success && mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAnonymous
                ? 'Intérêt manifesté de manière anonyme'
                : 'Intérêt manifesté avec succès'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Voir',
              onPressed: () {
                // Optionnel: naviguer vers les intérêts
              },
            ),
          ),
        );

        widget.onSuccess?.call();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'expression d\'intérêt'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
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

// Helper pour afficher le bottom sheet
class InterestExpressionHelper {
  static Future<void> show(
    BuildContext context,
    ProjectModel project, {
    VoidCallback? onSuccess,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InterestExpressionWidget(
        project: project,
        onSuccess: onSuccess,
      ),
    );
  }
}
