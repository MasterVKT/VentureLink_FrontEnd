import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venturelink/data/models/subscription_plan_model.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/presentation/screens/subscription/payment_screen.dart'
    as subscription_payment;

class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  static final List<SubscriptionPlanModel> _plans = [
    SubscriptionPlanModel(
      id: 'FREE',
      name: 'FREE',
      description: 'Gratuit, 2 projets max, fonctionnalités de base',
      priceXaf: 0,
      priceEur: 0,
      priceUsd: 0,
      durationMonths: 0,
      billingCycle: '',
      features: const [
        '2 projets maximum',
        'Messagerie de base',
        'Notifications',
      ],
      maxProjects: 2,
      maxInvestments: 0,
      prioritySupport: false,
      advancedAnalytics: false,
      isActive: true,
      isPopular: false,
      sortOrder: 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    SubscriptionPlanModel(
      id: 'BASIC_MONTHLY',
      name: 'BASIC_MONTHLY',
      description: '5 000 XAF/mois, 5 projets, support prioritaire',
      priceXaf: 5000,
      priceEur: 7.5,
      priceUsd: 8.2,
      durationMonths: 1,
      billingCycle: 'MONTHLY',
      features: const [
        '5 projets',
        'Support prioritaire',
        'Analytics basiques',
        'Badge "Vérifié"',
      ],
      maxProjects: 5,
      maxInvestments: 0,
      prioritySupport: true,
      advancedAnalytics: false,
      isActive: true,
      isPopular: false,
      sortOrder: 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    SubscriptionPlanModel(
      id: 'BASIC_YEARLY',
      name: 'BASIC_YEARLY',
      description: '50 000 XAF/an, 5 projets, 2 mois gratuits',
      priceXaf: 50000,
      priceEur: 75,
      priceUsd: 82,
      durationMonths: 12,
      billingCycle: 'YEARLY',
      features: const [
        '5 projets',
        'Support prioritaire',
        'Analytics basiques',
        'Badge "Vérifié"',
        '2 mois gratuits',
      ],
      maxProjects: 5,
      maxInvestments: 0,
      prioritySupport: true,
      advancedAnalytics: false,
      isActive: true,
      isPopular: false,
      sortOrder: 2,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    SubscriptionPlanModel(
      id: 'PREMIUM_MONTHLY',
      name: 'PREMIUM_MONTHLY',
      description: '15 000 XAF/mois, projets illimités, analytics avancés',
      priceXaf: 15000,
      priceEur: 22.5,
      priceUsd: 24.6,
      durationMonths: 1,
      billingCycle: 'MONTHLY',
      features: const [
        'Projets illimités',
        'Support prioritaire 24/7',
        'Analytics avancés',
        'Matching IA prioritaire',
        'Badge "Premium"',
      ],
      maxProjects: -1,
      maxInvestments: 0,
      prioritySupport: true,
      advancedAnalytics: true,
      isActive: true,
      isPopular: true,
      sortOrder: 3,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
    SubscriptionPlanModel(
      id: 'PREMIUM_YEARLY',
      name: 'PREMIUM_YEARLY',
      description: '150 000 XAF/an, projets illimités, 2 mois gratuits',
      priceXaf: 150000,
      priceEur: 225,
      priceUsd: 246,
      durationMonths: 12,
      billingCycle: 'YEARLY',
      features: const [
        'Projets illimités',
        'Support prioritaire 24/7',
        'Analytics avancés',
        'Matching IA prioritaire',
        'Badge "Premium"',
        '2 mois gratuits',
      ],
      maxProjects: -1,
      maxInvestments: 0,
      prioritySupport: true,
      advancedAnalytics: true,
      isActive: true,
      isPopular: false,
      sortOrder: 4,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnements'),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          final currentPlan = provider.currentSubscription?.plan.name ?? 'FREE';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(currentPlan),
              const SizedBox(height: 24),
              _buildPlanCard(
                context,
                plan: 'FREE',
                title: 'Gratuit',
                price: '0 XAF',
                period: '',
                features: const [
                  '2 projets maximum',
                  'Messagerie de base',
                  'Notifications',
                ],
                isCurrentPlan: currentPlan == 'FREE',
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                plan: 'BASIC_MONTHLY',
                title: 'Basic',
                price: '5 000 XAF',
                period: '/ mois',
                features: const [
                  '5 projets',
                  'Support prioritaire',
                  'Analytics basiques',
                  'Badge "Vérifié"',
                ],
                isCurrentPlan: currentPlan == 'BASIC_MONTHLY',
                isPopular: false,
              ),
              const SizedBox(height: 16),
              _buildPlanCard(
                context,
                plan: 'PREMIUM_MONTHLY',
                title: 'Premium',
                price: '15 000 XAF',
                period: '/ mois',
                features: const [
                  'Projets illimités',
                  'Support prioritaire 24/7',
                  'Analytics avancés',
                  'Matching IA prioritaire',
                  'Badge "Premium"',
                ],
                isCurrentPlan: currentPlan == 'PREMIUM_MONTHLY',
                isPopular: true,
              ),
              const SizedBox(height: 24),
              _buildYearlyPlansInfo(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String currentPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisissez votre plan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Plan actuel : ${_getPlanDisplayName(currentPlan)}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String plan,
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isCurrentPlan,
    bool isPopular = false,
  }) {
    return Card(
      elevation: isPopular ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPopular
            ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPopular)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'POPULAIRE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isPopular) const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                if (period.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      period,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 32),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isCurrentPlan)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text(
                  'Plan actuel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              ElevatedButton(
                onPressed: () => _upgradeToPlan(context, plan),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Choisir ce plan'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearlyPlansInfo(BuildContext context) {
    return Card(
      color: Colors.blue.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 12),
                Text(
                  'Économisez avec l\'abonnement annuel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Les abonnements annuels incluent 2 mois gratuits !',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _upgradeToPlan(context, 'BASIC_YEARLY'),
                    child: const Text('Basic Annuel\n50 000 XAF'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _upgradeToPlan(context, 'PREMIUM_YEARLY'),
                    child: const Text('Premium Annuel\n150 000 XAF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getPlanDisplayName(String plan) {
    switch (plan) {
      case 'FREE':
        return 'Gratuit';
      case 'BASIC_MONTHLY':
        return 'Basic (Mensuel)';
      case 'BASIC_YEARLY':
        return 'Basic (Annuel)';
      case 'PREMIUM_MONTHLY':
        return 'Premium (Mensuel)';
      case 'PREMIUM_YEARLY':
        return 'Premium (Annuel)';
      default:
        return 'Inconnu';
    }
  }

  Future<void> _upgradeToPlan(BuildContext context, String plan) async {
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer de plan'),
        content: Text(
          'Voulez-vous passer au plan ${_getPlanDisplayName(plan)} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => navigator.pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => navigator.pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final planModel = _plans.firstWhere((p) => p.name == plan);
      navigator.push(
        MaterialPageRoute(
          builder: (context) => subscription_payment.PaymentScreen(plan: planModel),
        ),
      );
    }
  }
}

