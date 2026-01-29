import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/investment_provider.dart';
import 'package:venturelink/data/models/investment_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

@RoutePage()
class InvestmentDetailScreen extends StatefulWidget {
  final String investmentId;

  const InvestmentDetailScreen({
    super.key,
    required this.investmentId,
  });

  @override
  State<InvestmentDetailScreen> createState() => _InvestmentDetailScreenState();
}

class _InvestmentDetailScreenState extends State<InvestmentDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestmentProvider>().loadInvestment(widget.investmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'investissement'),
        actions: [
          Consumer<InvestmentProvider>(
            builder: (context, provider, child) {
              final investment = provider.currentInvestment;
              if (investment != null) {
                return PopupMenuButton<String>(
                  onSelected: (value) => _handleMenuAction(value, investment),
                  itemBuilder: (context) => [
                    if (investment.contractFile != null)
                      const PopupMenuItem(
                        value: 'contract',
                        child: Row(
                          children: [
                            Icon(Icons.description),
                            SizedBox(width: 8),
                            Text('Voir le contrat'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history),
                          SizedBox(width: 8),
                          Text('Voir l\'historique'),
                        ],
                      ),
                    ),
                    if (investment.isPending)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Annuler',
                                style: TextStyle(color: Colors.red)),
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
      body: Consumer<InvestmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.loadInvestment(widget.investmentId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final investment = provider.currentInvestment;
          if (investment == null) {
            return const Center(
              child: Text('Investissement non trouvé'),
            );
          }

          return _buildInvestmentDetails(investment);
        },
      ),
    );
  }

  Widget _buildInvestmentDetails(InvestmentModel investment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du projet
          _buildProjectHeader(investment),

          const SizedBox(height: 24),

          // Informations de l'investissement
          _buildInvestmentInfo(investment),

          const SizedBox(height: 24),

          // Détails financiers
          _buildFinancialDetails(investment),

          if (investment.description?.isNotEmpty == true) ...[
            const SizedBox(height: 24),
            _buildDescription(investment),
          ],

          const SizedBox(height: 24),

          // Statut et dates
          _buildStatusAndDates(investment),

          const SizedBox(height: 24),

          // Actions
          _buildActionButtons(investment),
        ],
      ),
    );
  }

  Widget _buildProjectHeader(InvestmentModel investment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: investment.project.media?.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: investment.project.media!.first.fileUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.lightbulb_outline,
                          size: 32,
                        ),
                      ),
                    )
                  : const Icon(Icons.lightbulb_outline, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    investment.project.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Par ${investment.project.creator.fullName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusChip(investment.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentInfo(InvestmentModel investment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de l\'investissement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoTile(
                  'Montant',
                  _formatCurrency(investment.amount, investment.currency),
                  Icons.euro,
                ),
                const SizedBox(width: 16),
                _buildInfoTile(
                  'Type',
                  _getInvestmentTypeLabel(investment.investmentType),
                  Icons.category_outlined,
                ),
              ],
            ),
            if (investment.equityPercentage != null) ...[
              const SizedBox(height: 16),
              _buildInfoTile(
                'Participation',
                '${investment.equityPercentage!.toStringAsFixed(2)}%',
                Icons.pie_chart_outline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDetails(InvestmentModel investment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails financiers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            if (investment.interestRate != null)
              _buildDetailRow(
                'Taux d\'intérêt',
                '${investment.interestRate!.toStringAsFixed(2)}%',
              ),
            if (investment.termMonths != null)
              _buildDetailRow(
                'Durée',
                '${investment.termMonths} mois',
              ),
            _buildDetailRow(
              'Devise',
              investment.currency,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(InvestmentModel investment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              investment.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusAndDates(InvestmentModel investment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut et dates',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Statut',
              _getStatusLabel(investment.status),
            ),
            _buildDetailRow(
              'Créé le',
              DateFormat('dd/MM/yyyy HH:mm').format(investment.createdAt),
            ),
            if (investment.approvedAt != null)
              _buildDetailRow(
                'Approuvé le',
                DateFormat('dd/MM/yyyy HH:mm').format(investment.approvedAt!),
              ),
            if (investment.completedAt != null)
              _buildDetailRow(
                'Finalisé le',
                DateFormat('dd/MM/yyyy HH:mm').format(investment.completedAt!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(InvestmentModel investment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (investment.contractFile != null)
                  ElevatedButton.icon(
                    onPressed: () => _downloadContract(investment),
                    icon: const Icon(Icons.download),
                    label: const Text('Télécharger le contrat'),
                  ),
                ElevatedButton.icon(
                  onPressed: () => _viewHistory(investment),
                  icon: const Icon(Icons.history),
                  label: const Text('Voir l\'historique'),
                ),
                if (investment.isPending)
                  ElevatedButton.icon(
                    onPressed: () => _showCancelDialog(investment),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Annuler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Semantics(
      label: 'Statut: ${_getStatusLabel(status)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(status).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
        ),
        child: Text(
          _getStatusLabel(status),
          style: TextStyle(
            color: _getStatusColor(status),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return theme.colorScheme.error;
      case 'COMPLETED':
        return theme.colorScheme.primary;
      case 'CANCELLED':
        return theme.colorScheme.outline;
      default:
        return theme.colorScheme.outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'APPROVED':
        return 'Approuvé';
      case 'REJECTED':
        return 'Rejeté';
      case 'COMPLETED':
        return 'Terminé';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }

  String _getInvestmentTypeLabel(String type) {
    switch (type) {
      case 'EQUITY':
        return 'Capital';
      case 'DEBT':
      case 'LOAN':
        return 'Prêt';
      case 'DONATION':
        return 'Don';
      case 'CONVERTIBLE':
      case 'CONVERTIBLE_NOTE':
        return 'Note convertible';
      default:
        return type;
    }
  }

  String _formatCurrency(double amount, String currency) {
    final locale = _getCurrencyLocale(currency);
    return NumberFormat.currency(
      locale: locale,
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    ).format(amount);
  }

  String _getCurrencyLocale(String currency) {
    switch (currency) {
      case 'EUR':
        return 'fr_FR';
      case 'USD':
        return 'en_US';
      case 'GBP':
        return 'en_GB';
      default:
        return 'fr_FR';
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  void _handleMenuAction(String action, InvestmentModel investment) {
    switch (action) {
      case 'contract':
        _downloadContract(investment);
        break;
      case 'history':
        _viewHistory(investment);
        break;
      case 'cancel':
        _showCancelDialog(investment);
        break;
    }
  }

  void _downloadContract(InvestmentModel investment) {
    // TODO: Implémenter le téléchargement du contrat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Téléchargement du contrat démarré'),
      ),
    );
  }

  void _viewHistory(InvestmentModel investment) {
    // TODO: Implémenter la vue de l'historique
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Historique non encore implémenté'),
      ),
    );
  }

  void _showCancelDialog(InvestmentModel investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler l\'investissement'),
        content:
            const Text('Êtes-vous sûr de vouloir annuler cet investissement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final router = context.router;

              navigator.pop();
              final success = await context
                  .read<InvestmentProvider>()
                  .cancelInvestment(investment.id);

              if (success && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(content: Text('Investissement annulé')),
                );
                router.maybePop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
