import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/investment_provider.dart';
import 'package:venturelink/data/models/investment_model.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/router/app_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

@RoutePage()
class InvestmentListScreen extends StatefulWidget {
  const InvestmentListScreen({super.key});

  @override
  State<InvestmentListScreen> createState() => _InvestmentListScreenState();
}

class _InvestmentListScreenState extends State<InvestmentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestmentProvider>().loadInvestments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Investissements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Voir les statistiques',
            onPressed: () {
              _showStatsDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<InvestmentProvider>(
            builder: (context, provider, child) {
              return TabBar(
                controller: _tabController,
                tabs: [
                  _buildTabWithBadge('Tous', provider.investments.length),
                  _buildTabWithBadge(
                      'En attente', provider.pendingInvestments.length),
                  _buildTabWithBadge(
                      'Approuvés', provider.approvedInvestments.length),
                  _buildTabWithBadge(
                      'Terminés', provider.completedInvestments.length),
                ],
              );
            },
          ),
          Expanded(
            child: Consumer<InvestmentProvider>(
              builder: (context, investmentProvider, child) {
                if (investmentProvider.isLoading &&
                    investmentProvider.investments.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (investmentProvider.error != null &&
                    investmentProvider.investments.isEmpty) {
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
                          investmentProvider.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            investmentProvider.loadInvestments();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInvestmentList(
                        investmentProvider.investments, 'Aucun investissement'),
                    _buildInvestmentList(investmentProvider.pendingInvestments,
                        'Aucun investissement en attente'),
                    _buildInvestmentList(investmentProvider.approvedInvestments,
                        'Aucun investissement approuvé'),
                    _buildInvestmentList(
                        investmentProvider.completedInvestments,
                        'Aucun investissement terminé'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String text, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvestmentList(
      List<InvestmentModel> investments, String emptyMessage) {
    if (investments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<InvestmentProvider>().loadInvestments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Actualisation terminée')),
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConfig.defaultPadding),
        itemCount: investments.length,
        itemBuilder: (context, index) {
          return _buildInvestmentCard(investments[index]);
        },
      ),
    );
  }

  Widget _buildInvestmentCard(InvestmentModel investment) {
    return Semantics(
      label: 'Investissement ${investment.project.title}, '
          'Montant: ${_formatCurrency(investment.amount, investment.currency)}, '
          'Statut: ${_getStatusLabel(investment.status)}',
      button: true,
      onTapHint: 'Appuyer pour voir les détails',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConfig.defaultSpacing),
        child: InkWell(
          onTap: () {
            context.router
                .push(InvestmentDetailRoute(investmentId: investment.id));
          },
          child: Padding(
            padding: const EdgeInsets.all(AppConfig.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec projet
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: investment.project.media?.isNotEmpty == true
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl:
                                    investment.project.media!.first.fileUrl ??
                                        '',
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildProjectAvatar(
                                        investment.project.title),
                              ),
                            )
                          : _buildProjectAvatar(investment.project.title),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investment.project.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Par ${investment.project.creator.fullName}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(investment.status),
                  ],
                ),

                const SizedBox(height: 16),

                // Montant et type
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
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    'Participation',
                    '${investment.equityPercentage!.toStringAsFixed(2)}%',
                    Icons.pie_chart_outline,
                  ),
                ],

                const SizedBox(height: 16),

                // Date et actions
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Créé le ${DateFormat('dd/MM/yyyy').format(investment.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const Spacer(),
                    _buildActionButtons(investment),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectAvatar(String projectTitle) {
    final initials = projectTitle
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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

  Widget _buildActionButtons(InvestmentModel investment) {
    if (investment.isPending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.cancel_outlined),
            onPressed: () => _showCancelDialog(investment),
            tooltip: 'Annuler',
          ),
        ],
      );
    } else if (investment.isApproved) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (investment.contractFile != null)
            IconButton(
              icon: const Icon(Icons.description_outlined),
              onPressed: () => _downloadContract(investment),
              tooltip: 'Voir le contrat',
            ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _viewHistory(investment),
            tooltip: 'Voir l\'historique',
          ),
        ],
      );
    } else if (investment.isCompleted) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.receipt_outlined),
            onPressed: () => _viewReceipt(investment),
            tooltip: 'Voir le reçu',
          ),
        ],
      );
    }
    return const SizedBox.shrink();
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

  void _showStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<InvestmentProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Statistiques d\'investissement'),
            content: _buildStatsContent(provider),
            actions: [
              if (provider.error != null && provider.stats == null)
                TextButton(
                  onPressed: () {
                    provider.loadStats();
                  },
                  child: const Text('Réessayer'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsContent(InvestmentProvider provider) {
    if (_isLoadingStats || (provider.isLoading && provider.stats == null)) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null && provider.stats == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Erreur lors du chargement des statistiques',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            provider.error!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    final stats = provider.stats;
    if (stats == null) {
      // Charger les stats si pas encore fait
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isLoadingStats) {
          setState(() {
            _isLoadingStats = true;
          });
          provider.loadStats().then((_) {
            if (mounted) {
              setState(() {
                _isLoadingStats = false;
              });
            }
          });
        }
      });

      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatRow(
              'Total investissements', stats.investmentsCount.toString()),
          _buildStatRow('Montant total investi',
              _formatCurrency(stats.totalInvested, 'EUR')),
          const Divider(),
          _buildStatRow('Capital', _formatCurrency(stats.totalEquity, 'EUR')),
          _buildStatRow('Prêts', _formatCurrency(stats.totalLoan, 'EUR')),
          _buildStatRow('Dons', _formatCurrency(stats.totalDonation, 'EUR')),
          _buildStatRow('Notes convertibles',
              _formatCurrency(stats.totalConvertibleNote, 'EUR')),
          const Divider(),
          _buildStatRow('En attente', stats.pendingCount.toString()),
          _buildStatRow('Approuvés', stats.approvedCount.toString()),
          _buildStatRow('Terminés', stats.completedCount.toString()),
          _buildStatRow('Rejetés', stats.rejectedCount.toString()),
          const Divider(),
          _buildStatRow('Projets distincts', stats.projectsCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
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
              Navigator.of(context).pop();
              final success = await context
                  .read<InvestmentProvider>()
                  .cancelInvestment(investment.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Investissement annulé')),
                );
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

  void _downloadContract(InvestmentModel investment) {
    // TODO: Implémenter le téléchargement du contrat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Téléchargement du contrat démarré')),
    );
  }

  void _viewHistory(InvestmentModel investment) {
    // TODO: Implémenter la vue de l'historique
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Historique non encore implémenté')),
    );
  }

  void _viewReceipt(InvestmentModel investment) {
    // TODO: Implémenter la vue du reçu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reçu non encore implémenté')),
    );
  }
}
