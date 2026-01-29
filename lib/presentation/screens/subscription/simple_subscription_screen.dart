import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/phone_validator.dart';
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
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final success = await provider.activateFreePlan();
              if (mounted && success) {
                scaffoldMessenger.showSnackBar(
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
      builder: (context) => _PhoneNumberForm(
        plan: plan,
        provider: provider,
        selectedCurrency: _selectedCurrency,
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

/// Formulaire de saisie du numéro de téléphone pour My-CoolPay
class _PhoneNumberForm extends StatefulWidget {
  final SubscriptionPlanModel plan;
  final SimpleSubscriptionProvider provider;
  final String selectedCurrency;

  const _PhoneNumberForm({
    required this.plan,
    required this.provider,
    required this.selectedCurrency,
  });

  @override
  State<_PhoneNumberForm> createState() => _PhoneNumberFormState();
}

class _PhoneNumberFormState extends State<_PhoneNumberForm> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _phoneError;
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
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
                'Souscrire au ${widget.plan.name}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prix: ${widget.plan.getFormattedPrice(widget.selectedCurrency)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Champ numéro de téléphone
              const Text(
                'Numéro de téléphone *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+237699999999',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryColor),
                  ),
                  errorText: _phoneError,
                ),
                onChanged: (value) {
                  if (_phoneError != null) {
                    setState(() {
                      _phoneError = null;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le numéro de téléphone est requis';
                  }
                  final validation = PhoneValidator.validatePhoneNumber(value);
                  return validation.isValid ? null : validation.message;
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Format international recommandé (ex: +237699999999)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Information My-CoolPay
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Méthodes de paiement disponibles',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Orange Money'),
                    Text('• MTN Mobile Money'),
                    Text('• Cartes bancaires (Visa, Mastercard)'),
                    SizedBox(height: 8),
                    Text(
                      'Vous serez redirigé vers la page sécurisée My-CoolPay pour finaliser votre paiement.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bouton de paiement
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handlePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Payer ${widget.plan.getFormattedPrice(widget.selectedCurrency)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneValidation =
        PhoneValidator.validatePhoneNumber(_phoneController.text);
    if (!phoneValidation.isValid) {
      setState(() {
        _phoneError = phoneValidation.message;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await widget.provider.subscribeToPlan(
        planId: widget.plan.id,
        phoneNumber: phoneValidation.formatted!,
      );

      if (!mounted) return;

      navigator.pop(); // Fermer le modal

      if (result != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Abonnement créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
                'Erreur: ${widget.provider.paymentError ?? 'Erreur inconnue'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _phoneError = 'Erreur lors du paiement: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
