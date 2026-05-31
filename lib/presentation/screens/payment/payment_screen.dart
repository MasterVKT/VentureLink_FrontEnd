import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/data/models/project_model.dart';
import 'package:venturelink/data/providers/payment_provider.dart';
import 'package:venturelink/presentation/screens/payment/payment_success_screen.dart';
import 'package:venturelink/presentation/screens/payment/payment_webview.dart';

class PaymentScreen extends StatefulWidget {
  final ProjectModel project;
  final double amount;
  final String currency;

  const PaymentScreen({
    super.key,
    required this.project,
    required this.amount,
    required this.currency,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'mobile_money';
  bool _isProcessing = false;
  late String _currency;

  @override
  void initState() {
    super.initState();
    _currency = widget.currency;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.amount * 1.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: _isProcessing
          ? _buildProcessingState()
          : ListView(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              children: [
                _buildProjectSummary(),
                const SizedBox(height: 20),
                _buildPaymentSummary(total),
                const SizedBox(height: 20),
                _buildPaymentMethodSelector(),
                const SizedBox(height: 20),
                _buildSecurityInfo(),
                const SizedBox(height: 28),
                _buildPayButton(total),
              ],
            ),
    );
  }

  Widget _buildProjectSummary() {
    final imageUrl =
        widget.project.primaryImageFullUrl ?? widget.project.primaryImageUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.lightbulb_outline),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.lightbulb_outline),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Investissement',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildPaymentSummary(double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé du paiement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
                'Montant', _formatAmount(widget.amount, _currency)),
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Frais (5%)',
              _formatAmount(total - widget.amount, _currency),
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              'Total',
              _formatAmount(total, _currency),
              isTotal: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 18),
                const SizedBox(width: 8),
                const Text('Devise :'),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _currency,
                  items: const [
                    DropdownMenuItem(value: 'XAF', child: Text('XAF')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _currency = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
              : Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mode de paiement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              title: 'Mobile Money',
              subtitle: 'MTN, Orange, etc.',
              icon: Icons.phone_android,
              value: 'mobile_money',
            ),
            const SizedBox(height: 12),
            _buildMethodTile(
              title: 'Carte bancaire',
              subtitle: 'Visa, Mastercard',
              icon: Icons.credit_card,
              value: 'card',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.security, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Paiement 100% sécurisé via My-CoolPay. Vos données bancaires ne sont jamais partagées.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[900],
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(double total) {
    return ElevatedButton(
      onPressed: _initiatePayment,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Text('Payer ${_formatAmount(total, _currency)}'),
    );
  }

  Widget _buildProcessingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Préparation du paiement...'),
        ],
      ),
    );
  }

  Future<void> _initiatePayment() async {
    setState(() {
      _isProcessing = true;
    });

    final provider = context.read<PaymentProvider>();

    try {
      final result = await provider.initiatePayment(
        projectId: widget.project.id,
        amount: widget.amount,
        currency: _currency,
        paymentMethod: _selectedPaymentMethod,
      );

      if (!result.success) {
        throw Exception(result.error ?? 'Erreur lors de l\'initiation');
      }

      final paymentUrl = (result.paymentUrl ?? '').toString();
      final transactionId = (result.transactionId ?? '').toString();

      if (paymentUrl.isEmpty || transactionId.isEmpty) {
        throw Exception('Informations de paiement incomplètes');
      }

      if (!mounted) return;
      final webViewResult = await Navigator.push<bool?>(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(
            url: paymentUrl,
            transactionId: transactionId,
          ),
        ),
      );

      if (!mounted) return;

      if (webViewResult == true) {
        await _checkPaymentStatus(transactionId);
      } else if (webViewResult == false) {
        _showErrorDialog('Le paiement a échoué');
      } else {
        _showInfoDialog('Paiement annulé');
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _checkPaymentStatus(String transactionId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final provider = context.read<PaymentProvider>();
      final result = await provider.checkPaymentStatus(transactionId);
      if (!mounted) return;

      Navigator.pop(context);

      final success = result['success'] == true;
      final status = (result['status'] ?? '').toString().toLowerCase();

      if (!success) {
        _showErrorDialog(result['error'] ?? 'Erreur lors de la vérification');
        return;
      }

      if (status.contains('completed') || status.contains('success')) {
        final didSucceed = await Navigator.push<bool?>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              project: widget.project,
              amount: widget.amount,
              currency: _currency,
            ),
          ),
        );

        if (!mounted) return;
        Navigator.pop(context, didSucceed == true);
      } else if (status.contains('failed') ||
          status.contains('cancel') ||
          status.contains('error')) {
        _showErrorDialog('Le paiement a échoué');
      } else {
        _showPendingDialog();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 12),
            Text('Erreur'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement en cours'),
        content: const Text(
          'Votre paiement est en cours de traitement. Vous recevrez une notification dès qu\'il sera confirmé.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '${amount.toStringAsFixed(2)} €';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'XAF':
        return '${amount.toStringAsFixed(0)} FCFA';
      default:
        return '${amount.toStringAsFixed(2)} $currency';
    }
  }
}
