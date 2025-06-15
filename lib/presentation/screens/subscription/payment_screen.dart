import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/payment_provider.dart';
import '../../../data/models/subscription_plan_model.dart';
import '../../../data/models/payment_method_model.dart';
import '../../../data/services/user_preferences_service.dart';
import '../../../core/di/service_locator.dart';
import '../../common_widgets/vl_app_bar.dart';
import '../../common_widgets/vl_loading_indicator.dart';
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
  PaymentMethodModel? _selectedPaymentMethod;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isProcessing = false;
  bool _otpRequired = false;
  String? _paymentId;
  String _selectedCurrency = 'XAF';
  late UserPreferencesService _userPrefsService;

  @override
  void initState() {
    super.initState();
    _userPrefsService = serviceLocator<UserPreferencesService>();
    _initializeCurrency();
    _loadPaymentMethods();
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
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _loadPaymentMethods() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PaymentProvider>(context, listen: false).loadPaymentMethods();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: const VLAppBar(
        title: 'Paiement',
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(child: VLLoadingIndicator());
          }

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

                      // Méthodes de paiement
                      _buildPaymentMethodsSection(paymentProvider),

                      const SizedBox(height: 24),

                      // Champ téléphone pour Mobile Money
                      if (_selectedPaymentMethod?.isMobileMoney == true)
                        _buildPhoneNumberSection(),

                      const SizedBox(height: 16),

                      // Section OTP si nécessaire
                      if (_otpRequired) _buildOTPSection(),

                      const SizedBox(height: 24),

                      // Sécurité et confidentialité
                      _buildSecurityInfo(),
                    ],
                  ),
                ),
              ),

              // Bouton de paiement
              _buildPaymentButton(paymentProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlanSummary() {
    final price = widget.plan.getPriceInCurrency(_selectedCurrency);
    final appTheme = context.appTheme;

    return Container(
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
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
                color: Colors.green.withOpacity(0.1),
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

  Widget _buildPaymentMethodsSection(PaymentProvider paymentProvider) {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: appTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Choisissez votre méthode de paiement préférée',
          style: TextStyle(
            fontSize: 14,
            color: appTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paymentProvider.paymentMethods.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final method = paymentProvider.paymentMethods[index];
            final isSelected = _selectedPaymentMethod?.id == method.id;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        method.iconPath,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.payment,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: appTheme.textPrimaryColor,
                            ),
                          ),
                          if (method.supportedCurrencies.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Devises: ${method.supportedCurrencies.join(", ")}',
                              style: TextStyle(
                                fontSize: 12,
                                color: appTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Radio<String>(
                      value: method.id,
                      groupValue: _selectedPaymentMethod?.id,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = method;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
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

  Widget _buildPhoneNumberSection() {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numéro de téléphone',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: appTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Entrez le numéro associé à votre compte ${_selectedPaymentMethod?.operator}',
          style: TextStyle(
            fontSize: 14,
            color: appTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Ex: 699123456',
            prefixText: '+237 ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildOTPSection() {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Code OTP',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: appTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Entrez le code OTP reçu par SMS',
          style: TextStyle(
            fontSize: 14,
            color: appTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            hintText: 'Ex: 123456',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
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
            'Toutes les transactions sont sécurisées et traitées par My-CoolPay, notre partenaire de paiement certifié.',
            style: TextStyle(
              fontSize: 14,
              color: appTheme.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(PaymentProvider paymentProvider) {
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
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: VLButton(
          text: _otpRequired ? 'Confirmer le paiement' : 'Procéder au paiement',
          onPressed: _selectedPaymentMethod == null || _isProcessing
              ? null
              : () => _processPayment(paymentProvider),
          type: VLButtonType.premium,
          isLoading: _isProcessing,
        ),
      ),
    );
  }

  Future<void> _processPayment(PaymentProvider paymentProvider) async {
    if (_selectedPaymentMethod == null) return;

    if (_otpRequired && _otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code OTP')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_otpRequired && _paymentId != null) {
        // Confirmation OTP
        final result = await paymentProvider.authorizePaymentOTP(
          paymentId: _paymentId!,
          otpCode: _otpController.text,
        );

        setState(() {
          _isProcessing = false;
        });

        if (result['success']) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['error'] ??
                  'Échec de la confirmation. Veuillez réessayer.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Initialisation du paiement
        final method = _selectedPaymentMethod!;

        if (method.isMobileMoney) {
          // Paiement mobile money
          final result = await paymentProvider.initiateDirectPayment(
            planId: widget.plan.id,
            operator: method.operatorCode,
            phoneNumber: _phoneController.text,
          );

          setState(() {
            _isProcessing = false;
          });

          if (result['success']) {
            setState(() {
              _otpRequired = true;
              _paymentId = result['payment_id'];
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez entrer le code OTP reçu par SMS'),
                backgroundColor: Colors.blue,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ??
                    'Échec du paiement. Veuillez réessayer.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Autres méthodes de paiement (PayLink, cartes, etc.)
          final result = await paymentProvider.createSubscriptionPayment(
            planId: widget.plan.id,
            paymentMethod: method.id,
            currency: _selectedCurrency,
          );

          setState(() {
            _isProcessing = false;
          });

          if (result['success'] && result['payment_url'] != null) {
            await _launchPaymentUrl(result['payment_url']);
          } else if (result['success']) {
            _showSuccessDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ??
                    'Échec du paiement. Veuillez réessayer.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _launchPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir l\'URL de paiement'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Paiement réussi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Votre abonnement a été activé avec succès!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.appTheme.textSecondaryColor,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Retourner à l'écran d'abonnement avec refresh
                Navigator.of(context).pop(); // Fermer la dialog
                Navigator.of(context).pop(
                    true); // Retourner à l'écran précédent avec result=true
              },
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}
