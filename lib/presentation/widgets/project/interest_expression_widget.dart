// lib/presentation/widgets/project/interest_expression_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/providers/project_provider.dart';

/// Helper pour afficher le bottom sheet d'expression d'intérêt
/// Utilisé dans ProjectDetailScreen via InterestExpressionHelper.show()
class InterestExpressionHelper {
  /// Affiche le bottom sheet et retourne quand l'utilisateur a terminé
  static Future<void> show(
    BuildContext context,
    ProjectModel project, {
    required VoidCallback onSuccess,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // S'adapte au clavier
      backgroundColor: Colors.transparent,
      builder: (context) => _InterestExpressionSheet(
        project: project,
        onSuccess: onSuccess,
      ),
    );
  }
}

/// Le bottom sheet d'expression d'intérêt
class _InterestExpressionSheet extends StatefulWidget {
  final ProjectModel project;
  final VoidCallback onSuccess;

  const _InterestExpressionSheet({
    required this.project,
    required this.onSuccess,
  });

  @override
  State<_InterestExpressionSheet> createState() =>
      _InterestExpressionSheetState();
}

class _InterestExpressionSheetState extends State<_InterestExpressionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _amountController = TextEditingController();

  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Padding pour éviter que le clavier cache le contenu
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMessageField(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildAnonymousToggle(),
            const SizedBox(height: 24),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS ───────────────────────────────────────────────────────────────

  /// Barre de "drag" en haut du bottom sheet
  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manifester mon intérêt',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pour "${widget.project.title}"',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Le créateur sera notifié de votre intérêt.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      maxLines: 3,
      maxLength: 300,
      decoration: InputDecoration(
        labelText: 'Message (optionnel)',
        hintText: 'Dites au créateur pourquoi ce projet vous intéresse...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Montant envisagé (optionnel)',
        hintText: 'Ex: 500000',
        suffixText: 'FCFA',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        helperText: 'Cela aide le créateur à estimer les investissements',
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final amount = double.tryParse(value);
          if (amount == null || amount <= 0) {
            return 'Veuillez entrer un montant valide';
          }
        }
        return null; // Champ optionnel
      },
    );
  }

  Widget _buildAnonymousToggle() {
    return Row(
      children: [
        Switch(
          value: _isAnonymous,
          onChanged: (value) {
            setState(() {
              _isAnonymous = value;
            });
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rester anonyme',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                'Le créateur ne verra pas votre nom',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      children: [
        // Bouton Annuler
        Expanded(
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Annuler'),
          ),
        ),

        const SizedBox(width: 12),

        // Bouton Confirmer
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Confirmer mon intérêt'),
          ),
        ),
      ],
    );
  }

  // ── LOGIQUE ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<ProjectProvider>();

      final success = await provider.expressInterest(
        widget.project.id,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        amount: _amountController.text.trim().isEmpty
            ? null
            : double.tryParse(_amountController.text.trim()),
        isAnonymous: _isAnonymous,
      );

      if (success && mounted) {
        // Fermer le bottom sheet
        Navigator.pop(context);

        // Appeler le callback de succès → met à jour _hasInterest dans DetailScreen
        widget.onSuccess();

        // Afficher le dialog de confirmation
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorSnackBar('Erreur lors de l\'envoi. Réessaie plus tard.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur de connexion.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text('Intérêt envoyé !'),
          ],
        ),
        content: Text(
          'Le créateur de "${widget.project.title}" a été notifié '
          'de votre intérêt. Il pourra vous contacter pour discuter '
          'des opportunités d\'investissement.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Super !'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }
}
