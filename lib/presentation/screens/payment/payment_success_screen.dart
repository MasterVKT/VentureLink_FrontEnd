import 'package:flutter/material.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/data/models/project_model.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final ProjectModel project;
  final double amount;
  final String currency;

  const PaymentSuccessScreen({
    super.key,
    required this.project,
    required this.amount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement réussi'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 56,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Merci pour votre investissement',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Votre paiement a été confirmé et le créateur du projet a été notifié.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant'),
                        Text(
                          _formatAmount(amount, currency),
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Continuer'),
            ),
          ],
        ),
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

