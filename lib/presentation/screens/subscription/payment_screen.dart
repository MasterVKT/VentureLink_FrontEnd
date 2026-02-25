import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/simple_subscription_provider.dart';
import '../../../data/models/subscription_plan_model.dart';
import '../../../data/services/user_preferences_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/phone_validator.dart';
import '../../common_widgets/vl_app_bar.dart';
import '../../common_widgets/vl_button.dart';

@RoutePage()
class PaymentScreen extends StatefulWidget {
  final SubscriptionPlanModel plan;
  final String? selectedCurrency;

  const PaymentScreen({
    super.key,
    required this.plan,
    this.selectedCurrency,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  String _selectedCurrency = 'XAF';
  late UserPreferencesService _userPrefsService;

  // Contrôleurs pour les champs
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _userPrefsService = serviceLocator<UserPreferencesService>();
    _initializeCurrency();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _initializeCurrency() {
    if (widget.selectedCurrency != null) {
      _selectedCurrency = widget.selectedCurrency!;
    } else {
      final preferredCurrency = _userPrefsService.getPreferredCurrency();
      setState(() {
        _selectedCurrency = preferredCurrency;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: const VLAppBar(
        title: 'Paiement sécurisé',
      ),
      body: Consumer<SimpleSubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Résumé du plan
                      _buildPlanSummary(),

                      const SizedBox(height: 24),

                      // Information My-CoolPay
                      _buildMyCoolPayInfo(),

                      const SizedBox(height: 24),

                      // Sécurité et confidentialité
                      _buildSecurityInfo(),

                      const SizedBox(height: 24),

                      // Formulaire de paiement
                      _buildPaymentForm(),
                    ],
                  ),
                ),
              ),

              // Bouton de paiement
              _buildPaymentButton(subscriptionProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanSummary() {
    final appTheme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.plan.isPopular ? Icons.star : Icons.workspace_premium,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan ${widget.plan.name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: appTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.plan.billingCycleDisplay,
                      style: TextStyle(
                        fontSize: 14,
                        color: appTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Prix total',
                style: TextStyle(
                  fontSize: 16,
                  color: appTheme.textPrimaryColor,
                ),
              ),
              Text(
                widget.plan.getFormattedPrice(_selectedCurrency),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: appTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
          if (widget.plan.trialDays > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Inclut ${widget.plan.trialDays} jours d\'essai gratuit',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMyCoolPayInfo() {
    final appTheme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paiement My-CoolPay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: appTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Passerelle de paiement sécurisée',
                      style: TextStyle(
                        fontSize: 14,
                        color: appTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Méthodes de paiement supportées :',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: appTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodItem(
            icon: Icons.phone_android,
            title: 'Orange Money',
            description: 'Paiement mobile sécurisé',
          ),
          const SizedBox(height: 8),
          _buildPaymentMethodItem(
            icon: Icons.phone_android,
            title: 'MTN Mobile Money',
            description: 'Paiement mobile sécurisé',
          ),
          const SizedBox(height: 8),
          _buildPaymentMethodItem(
            icon: Icons.credit_card,
            title: 'Cartes bancaires',
            description: 'Visa, Mastercard',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final appTheme = context.appTheme;

    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appTheme.textPrimaryColor,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: appTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 16,
        ),
      ],
    );
  }

  Widget _buildSecurityInfo() {
    final appTheme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.security, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Paiement 100% sécurisé',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: appTheme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Toutes les transactions sont sécurisées et traitées par My-CoolPay, notre partenaire de paiement certifié. Vous choisirez votre méthode de paiement sur la page sécurisée My-CoolPay.',
            style: TextStyle(
              fontSize: 14,
              color: appTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    final appTheme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de facturation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: 'Ex: +237 6XX XXX XXX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                final validation =
                    PhoneValidator.validatePhoneNumber(value ?? '');
                return validation.isValid ? null : validation.message;
              },
            ),
            const SizedBox(height: 12),
            Text(
              'Ce numéro sera utilisé pour la facturation et les notifications de paiement.',
              style: TextStyle(
                fontSize: 12,
                color: appTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(SimpleSubscriptionProvider subscriptionProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: VLButton(
          text: 'Payer via My-CoolPay',
          onPressed: _isProcessing
              ? null
              : () => _processPayment(subscriptionProvider),
          type: VLButtonType.premium,
          isLoading: _isProcessing,
        ),
      ),
    );
  }

  Future<void> _processPayment(
      SimpleSubscriptionProvider subscriptionProvider) async {
    // Valider le formulaire
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs du formulaire'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await subscriptionProvider.subscribeToPlan(
        planId: widget.plan.id,
        phoneNumber: _phoneController.text.trim(),
      );

      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      if (result != null && result['payment_url'] != null) {
        // Rediriger vers My-CoolPay
        await _launchPaymentUrl(result['payment_url']);
      } else if (result != null && result['message'] != null) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(subscriptionProvider.paymentError ??
                'Erreur lors de la création du paiement. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        // Retourner à l'écran précédent après redirection
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        throw 'Impossible d\'ouvrir le lien de paiement';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'ouverture du lien: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text('Paiement initié'),
            ],
          ),
          content: const Text(
            'Votre demande d\'abonnement a été créée. Vous allez être redirigé vers My-CoolPay pour finaliser le paiement.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialog
                Navigator.of(context).pop(); // Retourner à l'écran précédent
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
