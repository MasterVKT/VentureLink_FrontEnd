import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/data/providers/payment_provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPaymentHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des paiements'),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.historyError != null) {
            return Padding(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Erreur de chargement',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.historyError!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.loadPaymentHistory,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.paymentHistory.isEmpty) {
            return const Center(
              child: Text('Aucune transaction pour le moment'),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadPaymentHistory,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppConfig.defaultPadding),
              itemCount: provider.paymentHistory.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = provider.paymentHistory[index];
                return Card(
                  child: ListTile(
                    leading: _buildStatusIcon(item.status),
                    title: Text(item.formattedAmount),
                    subtitle: Text(item.description),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatStatus(item.status),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(item.createdAt),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('success') || s.contains('completed')) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    if (s.contains('pending') || s.contains('processing')) {
      return const Icon(Icons.hourglass_top, color: Colors.orange);
    }
    if (s.contains('cancel')) {
      return const Icon(Icons.cancel, color: Colors.grey);
    }
    return const Icon(Icons.error, color: Colors.red);
  }

  String _formatStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('success') || s.contains('completed')) return 'Réussi';
    if (s.contains('pending')) return 'En attente';
    if (s.contains('processing')) return 'En cours';
    if (s.contains('cancel')) return 'Annulé';
    return 'Échoué';
  }

  String _formatDate(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
