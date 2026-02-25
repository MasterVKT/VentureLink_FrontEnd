import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/subscription_provider.dart';
import '../../../data/models/subscription_plan_model.dart';
import '../../../data/models/payment_session_model.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
// import 'package:venturelink/core/router/app_router.dart'; // TODO: Restaurer après génération

@RoutePage()
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final TextEditingController _promoCodeController = TextEditingController();
  SubscriptionPlanModel? _selectedPlan;
  Map<String, dynamic>? _promoCodeData;
  bool _showPromoCodeField = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      subscriptionProvider.loadPlans();
      subscriptionProvider.loadCurrentSubscription();
    });
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          if (subscriptionProvider.isLoadingPlans) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConfig.defaultPadding),
                  child: Column(
                    children: [
                      _buildCurrentSubscriptionCard(subscriptionProvider),
                      const SizedBox(height: 24),
                      _buildPremiumFeatures(),
                      const SizedBox(height: 32),
                      _buildPricingPlans(subscriptionProvider),
                      const SizedBox(height: 24),
                      _buildPromoCodeSection(subscriptionProvider),
                      const SizedBox(height: 32),
                      _buildFAQ(),
                      const SizedBox(
                          height: 100), // Espace pour le bouton flottant
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          if (subscriptionProvider.hasActiveSubscription ||
              _selectedPlan == null) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(
                horizontal: AppConfig.defaultPadding),
            child: FloatingActionButton.extended(
              onPressed: subscriptionProvider.isProcessingPayment
                  ? null
                  : () => _subscribeToPlan(subscriptionProvider),
              backgroundColor: AppTheme.premiumGold,
              foregroundColor: Colors.black,
              icon: subscriptionProvider.isProcessingPayment
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.star),
              label: Text(
                subscriptionProvider.isProcessingPayment
                    ? 'Traitement...'
                    : 'Passer à Premium ${_selectedPlan!.getFormattedPrice("EUR")}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'VentureLink Premium',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.premiumGold, AppTheme.premiumOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.star,
              size: 80,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(SubscriptionProvider provider) {
    final subscription = provider.currentSubscription;
    if (subscription == null) return const SizedBox.shrink();

    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [AppTheme.premiumGold, AppTheme.premiumOrange],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Abonnement actuel: ${subscription.plan.name}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Statut: ${_getStatusText(subscription.status)}',
              style: const TextStyle(color: Colors.white),
            ),
            if (subscription.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                subscription.isActive
                    ? 'Renouvellement: ${_formatDate(subscription.endDate!)}'
                    : 'Expire le: ${_formatDate(subscription.endDate!)}',
                style: const TextStyle(color: Colors.white),
              ),
            ],
            if (subscription.plan.trialDays > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Période d\'essai - ${subscription.daysRemaining} jours restants',
                  style: const TextStyle(
                    color: AppTheme.premiumOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFeatures() {
    final features = [
      {
        'icon': Icons.business_center,
        'title': 'Projets illimités',
        'description': 'Créez jusqu\'à 5 projets actifs simultanément',
      },
      {
        'icon': Icons.photo_library,
        'title': 'Plus de médias',
        'description': '10 photos par projet vs 3 en gratuit',
      },
      {
        'icon': Icons.message,
        'title': 'Messages illimités',
        'description': 'Communiquez sans limite avec vos investisseurs',
      },
      {
        'icon': Icons.favorite,
        'title': 'Favoris illimités',
        'description': 'Sauvegardez tous les projets qui vous intéressent',
      },
      {
        'icon': Icons.analytics,
        'title': 'Analytics avancés',
        'description': 'Tableaux de bord et statistiques détaillées',
      },
      {
        'icon': Icons.search,
        'title': 'Recherches sauvegardées',
        'description': 'Jusqu\'à 10 recherches personnalisées',
      },
      {
        'icon': Icons.priority_high,
        'title': 'Support prioritaire',
        'description': 'Assistance rapide et dédiée',
      },
      {
        'icon': Icons.star_outline,
        'title': 'Badge Premium',
        'description': 'Mettez en avant votre profil et vos projets',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fonctionnalités Premium',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: AppTheme.premiumGold,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        feature['description'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingPlans(SubscriptionProvider provider) {
    final plans = provider.plans;
    if (plans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez votre plan',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...plans.map((plan) => _buildPlanCard(plan, provider)),
      ],
    );
  }

  Widget _buildPlanCard(
      SubscriptionPlanModel plan, SubscriptionProvider provider) {
    final isSelected = _selectedPlan?.id == plan.id;
    final savings = _calculateYearlySavings(provider.plans);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.premiumGold : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.premiumGold.withValues(alpha: 0.1) : null,
        ),
        child: Stack(
          children: [
            if (plan.isPopular)
              Positioned(
                top: 0,
                right: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppTheme.premiumGold,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'POPULAIRE',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Radio<String>(
                    value: plan.id,
                    groupValue: _selectedPlan?.id,
                    onChanged: (value) {
                      setState(() {
                        _selectedPlan = plan;
                      });
                    },
                    activeColor: AppTheme.premiumGold,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          plan.description ?? "",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        if (plan.billingCycle == 'YEARLY' && savings > 0) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Économisez ${savings.toStringAsFixed(0)}€/an',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.getFormattedPrice("EUR"),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppTheme.premiumGold,
                        ),
                      ),
                      Text(
                        plan.billingCycleDisplay,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection(SubscriptionProvider provider) {
    return Column(
      children: [
        if (!_showPromoCodeField)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showPromoCodeField = true;
              });
            },
            icon: const Icon(Icons.local_offer),
            label: const Text('J\'ai un code promo'),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _promoCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Code promo',
                      hintText: 'Entrez votre code',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _showPromoCodeField = false;
                              _promoCodeController.clear();
                              _promoCodeData = null;
                            });
                          },
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _validatePromoCode(provider),
                          child: const Text('Valider'),
                        ),
                      ),
                    ],
                  ),
                  if (_promoCodeData != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Code valide ! ${_promoCodeData!['discount_percentage']}% de réduction',
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFAQ() {
    final faqItems = [
      {
        'question': 'Puis-je annuler mon abonnement à tout moment ?',
        'answer':
            'Oui, vous pouvez annuler votre abonnement à tout moment. Vous garderez l\'accès aux fonctionnalités Premium jusqu\'à la fin de votre période payée.',
      },
      {
        'question': 'Y a-t-il une période d\'essai gratuite ?',
        'answer':
            'Oui, nous offrons 7 jours d\'essai gratuit pour découvrir toutes les fonctionnalités Premium.',
      },
      {
        'question': 'Que se passe-t-il si je dépasse mes limites ?',
        'answer':
            'Si vous dépassez vos limites Premium, vous recevrez une notification. Vous pourrez toujours accéder à vos données mais certaines actions seront limitées.',
      },
      {
        'question': 'Les prix incluent-ils la TVA ?',
        'answer':
            'Oui, tous les prix affichés incluent la TVA applicable selon votre pays de résidence.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions fréquentes',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...faqItems.map((item) => ExpansionTile(
              title: Text(
                item['question']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(
                    item['answer']!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Future<void> _validatePromoCode(SubscriptionProvider provider) async {
    if (_promoCodeController.text.trim().isEmpty) return;

    // TODO: Implement promo code validation once the API is ready
    // Cette fonctionnalité sera implémentée quand l'API le supportera
    setState(() {
      _promoCodeData = {'discount_percentage': 10}; // Simulé pour le moment
    });
  }

  Future<void> _subscribeToPlan(SubscriptionProvider provider) async {
    if (_selectedPlan == null) return;

    final session = await provider.initiateSubscriptionPayment(
      planId: _selectedPlan!.id,
      paymentMethod:
          "credit_card", // Par défaut, à modifier selon les options disponibles
    );

    if (session != null && mounted) {
      // Ouvrir la WebView de paiement
      _openPaymentWebView(session);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.paymentError ??
              'Erreur lors de la création du paiement'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Ouvre la WebView de paiement
  Future<void> _openPaymentWebView(PaymentSessionModel session) async {
    try {
      // TODO: Restaurer après génération des routes
      // final result = await context.router.push(
      //   PaymentWebViewRoute(
      //     sessionId: session.id,
      //     paymentUrl: session.displayUrl,
      //     successUrl: session.successUrl ?? 'https://venturelink.com/success',
      //     cancelUrl: session.cancelUrl ?? 'https://venturelink.com/cancel',
      //   ),
      // );
      const result = false; // Temporaire

      // Si le paiement est réussi, actualiser l'abonnement
      if (result == true) {
        final subscriptionProvider = context.read<SubscriptionProvider>();
        await subscriptionProvider.loadCurrentSubscription(forceRefresh: true);
      }
    } catch (e) {
      _showErrorMessage('Erreur lors de l\'ouverture du paiement: $e');
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Actif';
      case 'TRIAL':
        return 'Période d\'essai';
      case 'CANCELLED':
        return 'Annulé';
      case 'EXPIRED':
        return 'Expiré';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  double _calculateYearlySavings(List<SubscriptionPlanModel> plans) {
    // Trouve le plan mensuel et annuel pour comparer
    final monthlyPlan = plans.firstWhere(
      (plan) => plan.billingCycle == 'MONTHLY' && plan.name.contains('Premium'),
      orElse: () => SubscriptionPlanModel(
        id: '',
        name: '',
        priceXaf: 0,
        priceEur: 0,
        priceUsd: 0,
        price: 0,
        currency: 'EUR',
        durationMonths: 0,
        billingCycle: '',
        features: [],
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final yearlyPlan = plans.firstWhere(
      (plan) => plan.billingCycle == 'YEARLY' && plan.name.contains('Premium'),
      orElse: () => SubscriptionPlanModel(
        id: '',
        name: '',
        priceXaf: 0,
        priceEur: 0,
        priceUsd: 0,
        price: 0,
        currency: 'EUR',
        durationMonths: 0,
        billingCycle: '',
        features: [],
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (monthlyPlan.id.isEmpty || yearlyPlan.id.isEmpty) return 0;

    // Calcul de l'économie (prix mensuel × 12 - prix annuel)
    return (monthlyPlan.getPriceInCurrency('EUR') * 12) -
        yearlyPlan.getPriceInCurrency('EUR');
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
