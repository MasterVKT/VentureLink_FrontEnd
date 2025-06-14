import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/investment_provider.dart';
import 'package:venturelink/data/models/investment_model.dart';
import 'package:venturelink/core/config/app_config.dart';
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tous'),
            Tab(text: 'En attente'),
            Tab(text: 'Approuvés'),
            Tab(text: 'Terminés'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              _showStatsDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<InvestmentProvider>(
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
              _buildInvestmentList(investmentProvider.investments),
              _buildInvestmentList(investmentProvider.pendingInvestments),
              _buildInvestmentList(investmentProvider.approvedInvestments),
              _buildInvestmentList(investmentProvider.completedInvestments),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInvestmentList(List<InvestmentModel> investments) {
    if (investments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun investissement',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<InvestmentProvider>().loadInvestments();
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppConfig.defaultSpacing),
      child: InkWell(
        onTap: () {
          // TODO: Naviguer vers les détails de l'investissement
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
                                  investment.project.media!.first.fileUrl ?? '',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investment.project.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                    NumberFormat.currency(
                            locale: 'fr_FR', symbol: investment.currency)
                        .format(investment.amount),
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
    Color color;
    String label;

    switch (status) {
      case 'PENDING':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'APPROVED':
        color = Colors.green;
        label = 'Approuvé';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Rejeté';
        break;
      case 'COMPLETED':
        color = Colors.blue;
        label = 'Terminé';
        break;
      case 'CANCELLED':
        color = Colors.grey;
        label = 'Annulé';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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

  void _showStatsDialog(BuildContext context) {
    final stats = context.read<InvestmentProvider>().stats;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques d\'investissement'),
        content: stats != null
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatRow('Total investissements',
                        stats.investmentsCount.toString()),
                    _buildStatRow(
                        'Montant total investi',
                        NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                            .format(stats.totalInvested)),
                    const Divider(),
                    _buildStatRow(
                        'Capital (Equity)',
                        NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                            .format(stats.totalEquity)),
                    _buildStatRow(
                        'Prêts',
                        NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                            .format(stats.totalLoan)),
                    _buildStatRow(
                        'Dons',
                        NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                            .format(stats.totalDonation)),
                    _buildStatRow(
                        'Notes convertibles',
                        NumberFormat.currency(locale: 'fr_FR', symbol: '€')
                            .format(stats.totalConvertibleNote)),
                    const Divider(),
                    _buildStatRow('En attente', stats.pendingCount.toString()),
                    _buildStatRow('Approuvés', stats.approvedCount.toString()),
                    _buildStatRow('Terminés', stats.completedCount.toString()),
                    _buildStatRow('Rejetés', stats.rejectedCount.toString()),
                    const Divider(),
                    _buildStatRow(
                        'Projets distincts', stats.projectsCount.toString()),
                  ],
                ),
              )
            : const Text('Aucune statistique disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
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
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}
