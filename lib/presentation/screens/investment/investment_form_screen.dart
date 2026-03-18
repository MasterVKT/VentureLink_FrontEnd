import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Écran de formulaire d'investissement (Sprint 2 - Tâche 2.4.1)
/// Formulaire de montant d'investissement avec validation et résumé
@RoutePage()
class InvestmentFormScreen extends StatefulWidget {
  final ProjectModel project;

  const InvestmentFormScreen({
    super.key,
    required this.project,
  });

  @override
  State<InvestmentFormScreen> createState() => _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends State<InvestmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  double _amount = 0;
  String _selectedCurrency = 'XAF';
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _selectedCurrency = widget.project.fundingCurrency;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investir'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProjectSummary(),
            const SizedBox(height: 24),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildCurrencySelector(),
            const SizedBox(height: 24),
            _buildInvestmentSummary(),
            const SizedBox(height: 24),
            _buildTermsCheckbox(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
            // Padding pour le scroll
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // BUILD METHODS
  // ───────────────────────────────────────────────────────────────────────────

  /// Résumé du projet
  Widget _buildProjectSummary() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image du projet
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.project.primaryImageFullUrl ??
                    widget.project.primaryImageUrl ??
                    '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.business_center, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Infos projet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Par ${widget.project.creatorName ?? 'Créateur'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

  /// Champ de montant
  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: 'Montant de l\'investissement',
        hintText: 'Entrez le montant',
        prefixIcon: const Icon(Icons.attach_money, color: AppTheme.primaryColor),
        suffixText: _selectedCurrency,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un montant';
        }
        final amount = double.tryParse(value);
        if (amount == null) {
          return 'Montant invalide';
        }
        // Minimum 10 000 XAF ou équivalent
        final minAmount = _selectedCurrency == 'XAF' ? 10000.0 : 10.0;
        if (amount < minAmount) {
          return 'Montant minimum : ${_formatAmount(minAmount)}';
        }
        // Maximum : reste à financer
        final remaining = widget.project.fundingMax - widget.project.fundingRaised;
        if (amount > remaining) {
          return 'Montant maximum : ${_formatAmount(remaining)}';
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _amount = double.tryParse(value) ?? 0;
        });
      },
    );
  }

  /// Sélecteur de devise
  Widget _buildCurrencySelector() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCurrency,
      decoration: InputDecoration(
        labelText: 'Devise',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
      items: ['XAF', 'EUR', 'USD'].map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text(currency, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCurrency = value!;
          _amount = 0;
          _amountController.clear();
        });
      },
    );
  }

  /// Résumé de l'investissement
  Widget _buildInvestmentSummary() {
    final fees = _amount * 0.05; // 5% de frais de plateforme
    final total = _amount + fees;

    return Card(
      color: AppTheme.primaryColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Montant', _formatAmount(_amount)),
            const SizedBox(height: 8),
            _buildSummaryRow('Frais de plateforme (5%)', _formatAmount(fees)),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              _formatAmount(total),
              isBold: true,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Ligne de résumé
  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isLarge ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppTheme.primaryColor : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  /// Checkbox des conditions
  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      value: _acceptedTerms,
      onChanged: (value) {
        setState(() {
          _acceptedTerms = value ?? false;
        });
      },
      title: const Text(
        'J\'accepte les conditions générales d\'investissement',
        style: TextStyle(fontSize: 14),
      ),
      subtitle: TextButton(
        onPressed: () {
          // TODO: Naviguer vers les CGU
          debugPrint('Voir les conditions générales');
        },
        child: const Text('Voir les conditions'),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Bouton de soumission
  Widget _buildSubmitButton() {
    final canSubmit = _formKey.currentState?.validate() == true && _acceptedTerms && _amount > 0;

    return ElevatedButton(
      onPressed: canSubmit ? _submitInvestment : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Continuer vers le paiement',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ───────────────────────────────────────────────────────────────────────────

  /// Soumettre l'investissement
  Future<void> _submitInvestment() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) return;

    // Redirection vers l'écran de paiement (Sprint 3)
    // Pour l'instant, afficher un message de succès
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Investissement prêt'),
            ],
          ),
          content: Text(
            'Vous êtes prêt à investir ${_formatAmount(_amount)} dans ${widget.project.title}.\n\n'
            'L\'intégration du paiement sera disponible dans le Sprint 3.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Compris'),
            ),
          ],
        ),
      );
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // UTILITAIRES
  // ───────────────────────────────────────────────────────────────────────────

  /// Formater le montant avec la devise
  String _formatAmount(double amount) {
    final symbol = _getCurrencySymbol(_selectedCurrency);

    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M$symbol';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K$symbol';
    } else {
      return '${amount.toStringAsFixed(0)}$symbol';
    }
  }

  /// Obtenir le symbole de la devise
  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'EUR':
        return ' €';
      case 'USD':
        return ' \$';
      case 'XAF':
        return ' FCFA';
      case 'GBP':
        return ' £';
      default:
        return ' $currencyCode';
    }
  }
}
