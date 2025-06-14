import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/subscription_provider.dart';
import '../../../data/models/subscription_plan_model.dart';
// import '../../../data/models/payment_method_model.dart'; // Inutilisé
import '../../../data/services/user_preferences_service.dart';
import '../../../core/di/service_locator.dart';
import '../../common_widgets/vl_app_bar.dart';
import '../../common_widgets/vl_loading_indicator.dart';
import '../../common_widgets/vl_button.dart';
import 'payment_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedCurrency = 'XAF'; // Devise par défaut
  final List<String> _supportedCurrencies = ['XAF', 'EUR', 'USD'];
  late UserPreferencesService _userPrefsService;

  @override
  void initState() {
    super.initState();
    _userPrefsService = serviceLocator<UserPreferencesService>();
    _loadUserPreferences();
    _loadData();
  }

  void _loadUserPreferences() async {
    // Charger la devise préférée de l'utilisateur
    final preferredCurrency = _userPrefsService.getPreferredCurrency();
    setState(() {
      _selectedCurrency = preferredCurrency;
    });
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).loadPlans();
      Provider.of<SubscriptionProvider>(context, listen: false)
          .loadCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: VLAppBar(
        title: 'Abonnements',
        actions: [
          // Sélecteur de devise
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange,
                color: AppTheme.primaryColor),
            onSelected: (currency) {
              setState(() {
                _selectedCurrency = currency;
              });
              _userPrefsService.setPreferredCurrency(currency);
            },
            itemBuilder: (context) => _supportedCurrencies
                .map((currency) => PopupMenuItem(
                      value: currency,
                      child: Row(
                        children: [
                          if (currency == _selectedCurrency)
                            const Icon(Icons.check, size: 16),
                          const SizedBox(width: 8),
                          Text(currency),
                          const SizedBox(width: 8),
                          Text(
                            _getCurrencySymbol(currency),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPlans || provider.isLoadingSubscription) {
            return const Center(child: VLLoadingIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadPlans();
              await provider.loadCurrentSubscription();
            },
            child: CustomScrollView(
              slivers: [
                // En-tête avec abonnement actuel
                SliverToBoxAdapter(
                  child: _buildCurrentSubscriptionHeader(provider),
                ),

                // Liste des plans disponibles
                SliverToBoxAdapter(
                  child: _buildPlansSection(provider),
                ),

                // Avantages de l'abonnement
                SliverToBoxAdapter(
                  child: _buildBenefitsSection(),
                ),

                // FAQ
                SliverToBoxAdapter(
                  child: _buildFAQSection(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'XAF':
        return 'FCFA';
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return currency;
    }
  }

  Widget _buildCurrentSubscriptionHeader(SubscriptionProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                provider.hasActiveSubscription
                    ? Icons.star
                    : Icons.star_outline,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.hasActiveSubscription
                      ? 'Abonnement Actif'
                      : 'Choisissez votre Plan',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.hasActiveSubscription &&
              provider.currentSubscription != null) ...[
            Text(
              'Plan ${provider.currentSubscription!.plan.name}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (provider.currentSubscription!.endDate != null)
              Text(
                'Expire le ${provider.currentSubscription!.endDate.toString().substring(0, 10)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            const SizedBox(height: 8),
            // Statut de l'abonnement
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(provider.currentSubscription!.status),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                provider.currentSubscription!.statusDisplay,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: VLButton(
                    text: 'Gérer l\'abonnement',
                    onPressed: () => _showManageSubscriptionOptions(provider),
                    type: VLButtonType.secondary,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Débloquez toutes les fonctionnalités premium de VentureLink',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip('✨ Matching IA illimité'),
                _buildFeatureChip('📊 Analytics avancées'),
                _buildFeatureChip('🚀 Support prioritaire'),
                _buildFeatureChip('💰 Projets illimités'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        feature,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPlansSection(SubscriptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Plans d\'abonnement',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: context.appTheme.textPrimaryColor,
                ),
              ),
              const Spacer(),
              Text(
                'Prix en $_selectedCurrency',
                style: TextStyle(
                  fontSize: 14,
                  color: context.appTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez le plan qui correspond à vos besoins',
            style: TextStyle(
              fontSize: 14,
              color: context.appTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 20),

          // Grille des plans
          ...provider.plans.map((plan) => _buildPlanCard(plan, provider)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
      SubscriptionPlanModel plan, SubscriptionProvider provider) {
    final isPopular = plan.isPopular;
    final isCurrentPlan = provider.currentSubscription?.plan.id == plan.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular
            ? Border.all(color: AppTheme.primaryColor, width: 2)
            : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: const Text(
                  '🔥 POPULAIRE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.appTheme.textPrimaryColor,
                        ),
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'ACTUEL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                if (plan.description != null)
                  Text(
                    plan.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.appTheme.textSecondaryColor,
                    ),
                  ),

                const SizedBox(height: 16),

                // Prix avec support multi-devises
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      plan.getFormattedPrice(_selectedCurrency).split(' ')[0],
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isPopular
                            ? AppTheme.primaryColor
                            : context.appTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getCurrencySymbol(_selectedCurrency),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isPopular
                            ? AppTheme.primaryColor
                            : context.appTheme.textSecondaryColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '/${plan.billingCycleDisplay.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.appTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),

                // Période d'essai si disponible
                if (plan.trialDays > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${plan.trialDays} jours d\'essai gratuit',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Limites et fonctionnalités
                _buildLimitsSection(plan),

                const SizedBox(height: 16),

                // Fonctionnalités
                ...plan.features.map((feature) => _buildFeatureRow(feature)),

                const SizedBox(height: 20),

                // Bouton d'action
                Row(
                  children: [
                    Expanded(
                      child: VLButton(
                        text: isCurrentPlan
                            ? 'Plan actuel'
                            : provider.hasActiveSubscription
                                ? 'Changer de plan'
                                : 'Choisir ce plan',
                        onPressed:
                            isCurrentPlan ? null : () => _selectPlan(plan),
                        type: isPopular
                            ? VLButtonType.premium
                            : VLButtonType.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsSection(SubscriptionPlanModel plan) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (plan.maxProjects > 0)
            _buildLimitRow(
                Icons.work_outline, 'Projets', '${plan.maxProjects}'),
          if (plan.maxInvestments > 0)
            _buildLimitRow(
                Icons.trending_up, 'Investissements', '${plan.maxInvestments}'),
        ],
      ),
    );
  }

  Widget _buildLimitRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.appTheme.textSecondaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.appTheme.textSecondaryColor,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.appTheme.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.primaryColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 14,
                color: context.appTheme.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pourquoi s\'abonner ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.appTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            Icons.psychology,
            'Matching IA avancé',
            'Algorithme d\'IA qui trouve les partenaires parfaits pour vos projets',
            Colors.purple,
          ),
          _buildBenefitItem(
            Icons.analytics,
            'Analytics détaillées',
            'Suivez les performances de vos projets avec des métriques avancées',
            Colors.blue,
          ),
          _buildBenefitItem(
            Icons.priority_high,
            'Support prioritaire',
            'Assistance rapide et personnalisée pour tous vos besoins',
            Colors.orange,
          ),
          _buildBenefitItem(
            Icons.visibility,
            'Visibilité améliorée',
            'Vos projets apparaissent en priorité dans les recherches',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(
      IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.appTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.appTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions fréquentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.appTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            'Puis-je annuler mon abonnement à tout moment ?',
            'Oui, vous pouvez annuler votre abonnement à tout moment. Il restera actif jusqu\'à la fin de la période payée.',
          ),
          _buildFAQItem(
            'Quels moyens de paiement acceptez-vous ?',
            'Nous acceptons Orange Money, MTN Mobile Money, et les cartes bancaires via My-CoolPay.',
          ),
          _buildFAQItem(
            'Y a-t-il une période d\'essai gratuite ?',
            'Nous offrons 7 jours d\'essai gratuit pour tous les nouveaux utilisateurs.',
          ),
          _buildFAQItem(
            'Que se passe-t-il si j\'annule ?',
            'Vous conservez l\'accès aux fonctionnalités premium jusqu\'à la fin de votre période d\'abonnement.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: context.appTheme.textPrimaryColor,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: context.appTheme.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // Méthode _formatDate supprimée car inutilisée

  void _selectPlan(SubscriptionPlanModel plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(plan: plan),
      ),
    );
  }

  void _showManageSubscriptionOptions(SubscriptionProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gérer l\'abonnement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.receipt, color: AppTheme.primaryColor),
              title: const Text('Historique des paiements'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Naviguer vers l'historique
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.orange),
              title: const Text('Annuler l\'abonnement'),
              onTap: () {
                Navigator.pop(context);
                _confirmCancelSubscription(provider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.blue),
              title: const Text('Aide et support'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Ouvrir le support
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmCancelSubscription(SubscriptionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler l\'abonnement'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler votre abonnement ? '
          'Vous conserverez l\'accès aux fonctionnalités premium '
          'jusqu\'à la fin de votre période d\'abonnement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Garder l\'abonnement'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              if (provider.currentSubscription != null) {
                final success = await provider.cancelSubscription(
                  subscriptionId: provider.currentSubscription!.id,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Abonnement annulé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de l\'annulation'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}
