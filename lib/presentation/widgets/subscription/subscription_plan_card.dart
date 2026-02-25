import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/subscription_plan_model.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlanModel plan;
  final String userCurrency;
  final VoidCallback onSubscribe;
  final bool isCurrentPlan;
  final bool isLoading;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.userCurrency,
    required this.onSubscribe,
    this.isCurrentPlan = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final price = plan.getPriceInCurrency(userCurrency);
    final formattedPrice = plan.getFormattedPrice(userCurrency);
    final isFree = price == 0;

    return Card(
      elevation: plan.isPopular ? 8 : 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: plan.isPopular
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: plan.isPopular
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    Colors.white,
                  ],
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec badge populaire
            if (plan.isPopular) _buildPopularBadge(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du plan et icône
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getPlanColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getPlanIcon(),
                          color: _getPlanColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (plan.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                plan.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Prix
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isFree ? 'Gratuit' : formattedPrice,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: _getPlanColor(),
                        ),
                      ),
                      if (!isFree) ...[
                        const SizedBox(width: 8),
                        Text(
                          '/${plan.billingCycleDisplay.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Période d'essai
                  if (plan.trialDays > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${plan.trialDays} jours d\'essai gratuit',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Fonctionnalités
                  ...plan.features.map((feature) => _buildFeatureItem(feature)),

                  const SizedBox(height: 24),

                  // Bouton d'action
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isCurrentPlan ? null : onSubscribe,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentPlan
                            ? Colors.grey
                            : (plan.isPopular
                                ? AppTheme.primaryColor
                                : _getPlanColor()),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isCurrentPlan
                                  ? 'Plan actuel'
                                  : (isFree ? 'Activer' : 'S\'abonner'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  // Badge plan actuel
                  if (isCurrentPlan) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Votre plan actuel',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'PLUS POPULAIRE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: _getPlanColor(),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlanColor() {
    if (plan.id.contains('free')) {
      return Colors.grey;
    } else if (plan.id.contains('basic')) {
      return Colors.blue;
    } else if (plan.id.contains('premium')) {
      return AppTheme.primaryColor;
    } else {
      return AppTheme.primaryColor;
    }
  }

  IconData _getPlanIcon() {
    if (plan.id.contains('free')) {
      return Icons.person;
    } else if (plan.id.contains('basic')) {
      return Icons.business;
    } else if (plan.id.contains('premium')) {
      return Icons.star;
    } else {
      return Icons.workspace_premium;
    }
  }
}
