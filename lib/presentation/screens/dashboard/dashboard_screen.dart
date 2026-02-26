import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/providers/auth_provider.dart';
import 'package:venturelink/data/providers/project_provider.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/data/providers/analytics_provider.dart';
import 'package:venturelink/core/config/app_config.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:venturelink/core/di/service_locator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = '30'; // Derniers 30 jours
  late final AnalyticsProvider _analyticsProvider;

  @override
  void initState() {
    super.initState();
    _analyticsProvider = serviceLocator<AnalyticsProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  void _loadDashboardData() {
    final projectProvider = context.read<ProjectProvider>();
    final subscriptionProvider = context.read<SubscriptionProvider>();

    projectProvider.loadUserProjects();
    subscriptionProvider.loadCurrentSubscription();

    // Charger les données d'analytics
    _analyticsProvider.setPeriod(_selectedPeriod);
    _analyticsProvider.loadAllAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer3<AuthProvider, ProjectProvider, SubscriptionProvider>(
        builder: (context, authProvider, projectProvider, subscriptionProvider,
            child) {
          if (projectProvider.isLoading || _analyticsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(authProvider.currentUser),
              SliverPadding(
                padding: const EdgeInsets.all(AppConfig.defaultPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWelcomeCard(authProvider, subscriptionProvider),
                    const SizedBox(height: 24),
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    _buildPeriodSelector(),
                    const SizedBox(height: 16),
                    _buildChartsSection(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                    const SizedBox(height: 24),
                    _buildActionCards(),
                    const SizedBox(height: 100), // Espace pour la bottom bar
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(user) {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Tableau de bord',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigation vers les notifications
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Navigation vers les paramètres
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(
      AuthProvider authProvider, SubscriptionProvider subscriptionProvider) {
    final user = authProvider.currentUser;
    final subscription = subscriptionProvider.currentSubscription;

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: subscriptionProvider.hasActiveSubscription
              ? const LinearGradient(
                  colors: [AppTheme.premiumGold, AppTheme.premiumOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: subscriptionProvider.hasActiveSubscription
                      ? Colors.white
                      : AppTheme.primaryColor,
                  child: Icon(
                    Icons.person,
                    color: subscriptionProvider.hasActiveSubscription
                        ? AppTheme.premiumGold
                        : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour ${user?.firstName ?? 'Utilisateur'} !',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: subscriptionProvider.hasActiveSubscription
                              ? Colors.white
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (subscriptionProvider.hasActiveSubscription) ...[
                            const Icon(Icons.star,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            subscriptionProvider.hasActiveSubscription
                                ? 'Membre Premium'
                                : user?.userType == 'ENTREPRENEUR'
                                    ? 'Entrepreneur'
                                    : 'Investisseur',
                            style: TextStyle(
                              color: subscriptionProvider.hasActiveSubscription
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (subscriptionProvider.hasActiveSubscription &&
                    subscription != null &&
                    subscription.daysRemaining > 0 &&
                    subscription.plan.trialDays > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Essai ${subscription.daysRemaining}j',
                      style: const TextStyle(
                        color: AppTheme.premiumOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getWelcomeMessage(
                  user?.userType, subscriptionProvider.hasActiveSubscription),
              style: TextStyle(
                color: subscriptionProvider.hasActiveSubscription
                    ? Colors.white
                    : Colors.grey[600],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = _analyticsProvider.dashboardStats;

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Vues totales',
          value: '${stats['total_views']}',
          icon: Icons.visibility,
          color: Colors.blue,
          change: stats['growth']['views'].toDouble(),
        ),
        _buildStatCard(
          title: 'Interactions',
          value: '${stats['total_interactions']}',
          icon: Icons.thumb_up_alt,
          color: Colors.green,
          change: stats['growth']['interactions'].toDouble(),
        ),
        _buildStatCard(
          title: 'Messages',
          value: '${stats['total_messages']}',
          icon: Icons.message,
          color: Colors.orange,
          change: stats['growth']['messages'].toDouble(),
        ),
        _buildStatCard(
          title: 'Investissements',
          value: '${stats['total_investments']}',
          icon: Icons.monetization_on,
          color: Colors.purple,
          change: stats['growth']['investments'].toDouble(),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double change,
  }) {
    final changeText = change >= 0
        ? '+${change.toStringAsFixed(1)}%'
        : '${change.toStringAsFixed(1)}%';
    final changeColor = change >= 0 ? Colors.green : Colors.red;
    final changeIcon = change >= 0 ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        changeIcon,
                        color: changeColor,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        changeText,
                        style: TextStyle(
                          color: changeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Text(
              'Période:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _periodChip('7', '7 jours'),
                    _periodChip('30', '30 jours'),
                    _periodChip('90', '90 jours'),
                    _periodChip('180', '6 mois'),
                    _periodChip('365', '1 an'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodChip(String value, String label) {
    final isSelected = _selectedPeriod == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedPeriod = value;
            });
            _analyticsProvider.setPeriod(value);
          }
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    final visitorStats = _analyticsProvider.visitorStats;
    final interactionStats = _analyticsProvider.interactionStats;

    if (visitorStats.isEmpty || interactionStats.isEmpty) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vues',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: _buildViewsChart(visitorStats),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: _buildInteractionsChart(interactionStats),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewsChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Préparer les données pour le graphique
    final spots = data.asMap().entries.map((entry) {
      final index = entry.key.toDouble();
      final item = entry.value;
      final views = (item['views'] as int).toDouble();
      return FlSpot(index, views);
    }).toList();

    // Calculer les valeurs min et max pour l'axe Y
    double maxY = 0;
    for (final spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = (maxY * 1.2).ceilToDouble(); // Ajouter 20% pour l'espace visuel

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                );
              },
              interval: maxY / 5,
              reservedSize: 30,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Afficher une date tous les N points selon la taille du dataset
                final interval = (data.length / 5).ceil();
                if (value.toInt() % interval != 0) {
                  return const SizedBox.shrink();
                }

                if (value.toInt() >= data.length) {
                  return const SizedBox.shrink();
                }

                final date = DateTime.parse(data[value.toInt()]['date']);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('dd/MM').format(date),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionsChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    // Calculer les totaux pour chaque type d'interaction
    int totalFavorites = 0;
    int totalShares = 0;
    int totalComments = 0;
    int totalInterests = 0;

    for (final item in data) {
      totalFavorites += item['favorites'] as int;
      totalShares += item['shares'] as int;
      totalComments += item['comments'] as int;
      totalInterests += item['interests'] as int;
    }

    final total = totalFavorites + totalShares + totalComments + totalInterests;

    if (total == 0) {
      return const Center(child: Text('Aucune interaction pour cette période'));
    }

    // Calculer les pourcentages
    final favoritesPercent = (totalFavorites / total * 100).round();
    final sharesPercent = (totalShares / total * 100).round();
    final commentsPercent = (totalComments / total * 100).round();
    final interestsPercent = (totalInterests / total * 100).round();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: totalFavorites.toDouble(),
                  title: '$favoritesPercent%',
                  color: Colors.amber,
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                PieChartSectionData(
                  value: totalShares.toDouble(),
                  title: '$sharesPercent%',
                  color: Colors.green,
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                PieChartSectionData(
                  value: totalComments.toDouble(),
                  title: '$commentsPercent%',
                  color: Colors.blue,
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                PieChartSectionData(
                  value: totalInterests.toDouble(),
                  title: '$interestsPercent%',
                  color: Colors.purple,
                  radius: 60,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: 180,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLegendItem('J\'aime', Colors.amber, totalFavorites),
            _buildLegendItem('Partages', Colors.green, totalShares),
            _buildLegendItem('Commentaires', Colors.blue, totalComments),
            _buildLegendItem('Intérêts', Colors.purple, totalInterests),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = _analyticsProvider.recentActivities;

    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activités récentes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(activity);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    // Déterminer l'icône et la couleur en fonction du type d'activité
    IconData icon;
    Color color;
    String actionText;

    switch (activity['type']) {
      case 'view':
        icon = Icons.visibility;
        color = Colors.blue;
        actionText = 'a vu';
        break;
      case 'interest':
        icon = Icons.favorite;
        color = Colors.red;
        actionText = 's\'intéresse à';
        break;
      case 'message':
        icon = Icons.message;
        color = Colors.green;
        actionText = 'a envoyé un message dans';
        break;
      case 'investment':
        icon = Icons.monetization_on;
        color = Colors.amber;
        actionText = 'a investi dans';
        break;
      case 'comment':
        icon = Icons.comment;
        color = Colors.orange;
        actionText = 'a commenté';
        break;
      case 'share':
        icon = Icons.share;
        color = Colors.purple;
        actionText = 'a partagé';
        break;
      case 'profile_view':
        icon = Icons.person;
        color = Colors.teal;
        actionText = 'a consulté';
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
        actionText = 'a interagi avec';
        break;
    }

    // Formater la date
    final date = DateTime.parse(activity['timestamp']);
    final now = DateTime.now();
    final difference = now.difference(date);

    String timeText;
    if (difference.inMinutes < 60) {
      timeText = 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      timeText = 'Il y a ${difference.inHours} h';
    } else {
      timeText = DateFormat('dd/MM à HH:mm').format(date);
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.2),
        child: Icon(
          icon,
          color: color,
          size: 18,
        ),
      ),
      title: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(
              text: activity['user_name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' $actionText '),
            TextSpan(
              text: activity['target_name'],
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      subtitle: Text(
        timeText,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: activity['amount'] != null
          ? Text(
              '${activity['amount']} €',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  String _getWelcomeMessage(String? userType, bool isPremium) {
    if (isPremium) {
      return 'Profitez de toutes les fonctionnalités Premium pour maximiser vos opportunités !';
    }

    switch (userType) {
      case 'ENTREPRENEUR':
        return 'Présentez vos projets et trouvez les investisseurs parfaits pour votre vision.';
      case 'INVESTOR':
        return 'Découvrez des opportunités d\'investissement prometteuses et diversifiez votre portefeuille.';
      default:
        return 'Explorez l\'écosystème entrepreneurial et créez des connexions précieuses.';
    }
  }

  Widget _buildActionCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              'Nouveau projet',
              Icons.add_business,
              AppTheme.primaryColor,
              () {
                // TODO: Navigation vers création de projet
              },
            ),
            _buildActionCard(
              'Rechercher',
              Icons.search,
              AppTheme.accentColor,
              () {
                // TODO: Navigation vers recherche
              },
            ),
            _buildActionCard(
              'Messages',
              Icons.message,
              AppTheme.secondaryColor,
              () {
                // TODO: Navigation vers messages
              },
            ),
            _buildActionCard(
              'Paramètres',
              Icons.settings,
              Colors.grey[700]!,
              () {
                // TODO: Navigation vers paramètres
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
