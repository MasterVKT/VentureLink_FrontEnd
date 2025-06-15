import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import '../../../data/providers/simple_subscription_provider.dart';
import '../../../data/models/subscription_plan_model.dart';
import '../../common_widgets/vl_app_bar.dart';
import '../../common_widgets/vl_loading_indicator.dart';
import '../../widgets/subscription/subscription_plan_card.dart';

@RoutePage()
class SimpleSubscriptionScreen extends StatefulWidget {
  const SimpleSubscriptionScreen({super.key});

  @override
  State<SimpleSubscriptionScreen> createState() =>
      _SimpleSubscriptionScreenState();
}

class _SimpleSubscriptionScreenState extends State<SimpleSubscriptionScreen> {
  String _selectedCurrency = 'XAF';
  final List<String> _supportedCurrencies = ['XAF', 'EUR', 'USD'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SimpleSubscriptionProvider>();
      provider.loadPlans();
      provider.loadCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: VLAppBar(
        title: 'Abonnements Premium',
        actions: [
          // Sélecteur de devise
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange,
                color: AppTheme.primaryColor),
            onSelected: (currency) {
              setState(() {
                _selectedCurrency = currency;
              });
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
      body: Consumer<SimpleSubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPlans) {
            return const Center(child: VLLoadingIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadPlans(forceRefresh: true);
              await provider.loadCurrentSubscription(forceRefresh: true);
            },
            child: CustomScrollView(
              slivers: [
                // En-tête avec statut actuel
                SliverToBoxAdapter(
                  child: _buildCurrentSubscriptionHeader(provider),
                ),

                // Liste des plans
                SliverToBoxAdapter(
                  child: _buildPlansSection(provider),
                ),

                // Avantages Premium
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

  Widget _buildCurrentSubscriptionHeader(SimpleSubscriptionProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: provider.hasActiveSubscription
              ? [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)]
              : [Colors.grey[600]!, Colors.grey[500]!],
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
              'Plan ${provider.currentSubscription!.planName}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Statut: ${provider.currentSubscription!.statusDisplay}',
              style: const TextStyle(color: Colors.white70),
            ),
            if (provider.currentSubscription!.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expire le: ${_formatDate(provider.currentSubscription!.endDate!)}',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ] else ...[
            const Text(
              'Débloquez toutes les fonctionnalités premium',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlansSection(SimpleSubscriptionProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Plans disponibles',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                'Prix en $_selectedCurrency',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choisissez le plan qui correspond à vos besoins',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Liste des plans
          ...provider.activePlans.map((plan) => SubscriptionPlanCard(
                plan: plan,
                userCurrency: _selectedCurrency,
                isCurrentPlan: provider.currentSubscription?.planId == plan.id,
                isLoading: provider.isProcessingPayment,
                onSubscribe: () => _subscribeToPlan(plan, provider),
              )),
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
            'Pourquoi choisir Premium ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...[
            'Projets illimités pour développer votre portfolio',
            'IA Matching pour trouver les meilleurs investisseurs',
            'Analytics avancées pour optimiser vos projets',
            'Support prioritaire pour une assistance rapide',
            'Mise en avant de vos projets',
            'Accès aux fonctionnalités bêta',
          ].map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        benefit,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )),
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
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildFAQItem(
            'Puis-je annuler mon abonnement à tout moment ?',
            'Oui, vous pouvez annuler votre abonnement à tout moment. Vous conserverez l\'accès aux fonctionnalités premium jusqu\'à la fin de votre période de facturation.',
          ),
          _buildFAQItem(
            'Y a-t-il une période d\'essai gratuite ?',
            'Oui, la plupart de nos plans offrent une période d\'essai gratuite pour que vous puissiez tester toutes les fonctionnalités.',
          ),
          _buildFAQItem(
            'Quels sont les moyens de paiement acceptés ?',
            'Nous acceptons les paiements par Mobile Money (Orange Money, MTN Mobile Money), cartes bancaires et virements.',
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  void _subscribeToPlan(
      SubscriptionPlanModel plan, SimpleSubscriptionProvider provider) {
    if (plan.id == 'free') {
      _activateFreePlan(plan, provider);
    } else {
      _showPaymentOptions(plan, provider);
    }
  }

  void _activateFreePlan(
      SubscriptionPlanModel plan, SimpleSubscriptionProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Plan Gratuit'),
        content: Text('Voulez-vous activer le ${plan.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.activateFreePlan();
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plan gratuit activé avec succès !'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }

  void _showPaymentOptions(
      SubscriptionPlanModel plan, SimpleSubscriptionProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Titre
              Text(
                'Souscrire au ${plan.name}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prix: ${plan.getFormattedPrice(_selectedCurrency)}',
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Options de paiement
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildPaymentOption(
                      icon: Icons.link,
                      title: 'Lien de paiement',
                      subtitle: 'Paiement sécurisé via My-CoolPay',
                      onTap: () => _payWithLink(plan, provider),
                    ),
                    _buildPaymentOption(
                      icon: Icons.phone_android,
                      title: 'Orange Money',
                      subtitle: 'Paiement direct depuis votre mobile',
                      onTap: () => _payWithMobileMoney(plan, provider, 'CM_OM'),
                    ),
                    _buildPaymentOption(
                      icon: Icons.phone_android,
                      title: 'MTN Mobile Money',
                      subtitle: 'Paiement direct depuis votre mobile',
                      onTap: () =>
                          _payWithMobileMoney(plan, provider, 'CM_MOMO'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _payWithLink(
      SubscriptionPlanModel plan, SimpleSubscriptionProvider provider) async {
    Navigator.pop(context);

    final success = await provider.subscribeToPlan(
      planId: plan.id,
      currency: _selectedCurrency,
      paymentMethod: 'PAYLINK',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Abonnement créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erreur: ${provider.paymentError ?? 'Erreur inconnue'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _payWithMobileMoney(
    SubscriptionPlanModel plan,
    SimpleSubscriptionProvider provider,
    String operator,
  ) {
    Navigator.pop(context);

    // Afficher un dialog pour saisir le numéro de téléphone
    showDialog(
      context: context,
      builder: (context) => _MobileMoneyDialog(
        plan: plan,
        provider: provider,
        operator: operator,
        currency: _selectedCurrency,
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _MobileMoneyDialog extends StatefulWidget {
  final SubscriptionPlanModel plan;
  final SimpleSubscriptionProvider provider;
  final String operator;
  final String currency;

  const _MobileMoneyDialog({
    required this.plan,
    required this.provider,
    required this.operator,
    required this.currency,
  });

  @override
  State<_MobileMoneyDialog> createState() => _MobileMoneyDialogState();
}

class _MobileMoneyDialogState extends State<_MobileMoneyDialog> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isProcessing = false;
  bool _otpRequired = false;
  String? _transactionRef;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Paiement ${_getOperatorName()}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Plan: ${widget.plan.name}'),
          Text('Prix: ${widget.plan.getFormattedPrice(widget.currency)}'),
          const SizedBox(height: 16),
          if (!_otpRequired) ...[
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: '+237123456789',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ] else ...[
            TextField(
              controller: _otpController,
              decoration: const InputDecoration(
                labelText: 'Code OTP',
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processPayment,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_otpRequired ? 'Confirmer' : 'Payer'),
        ),
      ],
    );
  }

  void _processPayment() async {
    if (_otpRequired) {
      await _authorizePayment();
    } else {
      await _initiatePayment();
    }
  }

  Future<void> _initiatePayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez saisir votre numéro de téléphone')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final result = await widget.provider.payWithMobileMoney(
      planId: widget.plan.id,
      operator: widget.operator,
      phoneNumber: _phoneController.text,
      currency: widget.currency,
    );

    setState(() => _isProcessing = false);

    if (result != null && result['status'] == 'REQUIRE_OTP') {
      setState(() {
        _otpRequired = true;
        _transactionRef = result['transaction_ref'];
      });
    } else if (result != null && result['status'] == 'COMPLETED') {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement effectué avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Erreur: ${widget.provider.paymentError ?? 'Erreur inconnue'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _authorizePayment() async {
    if (_otpController.text.isEmpty || _transactionRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir le code OTP')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final success = await widget.provider.authorizePayment(
      transactionRef: _transactionRef!,
      otpCode: _otpController.text,
    );

    setState(() => _isProcessing = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paiement autorisé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Erreur: ${widget.provider.paymentError ?? 'Code OTP invalide'}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getOperatorName() {
    switch (widget.operator) {
      case 'CM_OM':
        return 'Orange Money';
      case 'CM_MOMO':
        return 'MTN Mobile Money';
      default:
        return 'Mobile Money';
    }
  }
}
