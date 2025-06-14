import 'dart:async';

import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:venturelink/core/theme/app_theme.dart';
import 'package:venturelink/data/providers/payment_provider.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/presentation/common_widgets/vl_app_bar.dart';
import 'package:venturelink/presentation/common_widgets/vl_loading_indicator.dart';

@RoutePage()
class PaymentWebViewScreen extends StatefulWidget {
  final String sessionId;
  final String paymentUrl;
  final String successUrl;
  final String cancelUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.sessionId,
    required this.paymentUrl,
    required this.successUrl,
    required this.cancelUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isPaymentComplete = false;
  bool _isCheckingStatus = false;
  Timer? _statusCheckTimer;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _startStatusCheckTimer();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress < 100) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
            _checkRedirectionUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkRedirectionUrl(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_checkRedirectionUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  bool _checkRedirectionUrl(String url) {
    // Vérifier si l'URL correspond à une redirection de succès ou d'annulation
    if (url.startsWith(widget.successUrl) ||
        url.contains('payment_status=success')) {
      _handlePaymentSuccess();
      return true;
    } else if (url.startsWith(widget.cancelUrl) ||
        url.contains('payment_status=cancel')) {
      _handlePaymentCancellation();
      return true;
    }
    return false;
  }

  void _startStatusCheckTimer() {
    // Vérifier le statut du paiement toutes les 5 secondes
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isPaymentComplete && !_isCheckingStatus) {
        _checkPaymentStatus();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isCheckingStatus) return;

    setState(() {
      _isCheckingStatus = true;
    });

    try {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);
      final result = await paymentProvider.checkPaymentStatus(widget.sessionId);

      if (result['success'] == true) {
        final status = result['status'];

        if (status == 'COMPLETED') {
          _handlePaymentSuccess();
        } else if (['FAILED', 'CANCELLED', 'EXPIRED'].contains(status)) {
          _handlePaymentFailure(result['description'] ?? 'Paiement échoué');
        }
      } else {
        _retryCount++;
        if (_retryCount > 5) {
          // Après 5 tentatives, considérer comme un échec
          _handlePaymentFailure('Impossible de vérifier le statut du paiement');
        }
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut: $e');
      _retryCount++;
    } finally {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  void _handlePaymentSuccess() {
    if (_isPaymentComplete) return;

    _isPaymentComplete = true;
    _statusCheckTimer?.cancel();

    // Mettre à jour le statut d'abonnement
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    subscriptionProvider.loadCurrentSubscription(forceRefresh: true);

    // Afficher un message de succès et revenir à l'écran précédent
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('Paiement réussi ! Votre abonnement est maintenant actif.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Attendre un peu pour que l'utilisateur voie le message puis revenir
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        context.router.pop(true); // Retourner true pour indiquer un succès
      }
    });
  }

  void _handlePaymentCancellation() {
    if (_isPaymentComplete) return;

    _isPaymentComplete = true;
    _statusCheckTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paiement annulé.'),
        backgroundColor: Colors.orange,
      ),
    );

    context.router.pop(false); // Retourner false pour indiquer une annulation
  }

  void _handlePaymentFailure(String message) {
    if (_isPaymentComplete) return;

    _isPaymentComplete = true;
    _statusCheckTimer?.cancel();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Échec du paiement: $message'),
        backgroundColor: Colors.red,
      ),
    );

    context.router.pop(false); // Retourner false pour indiquer un échec
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Demander confirmation avant de quitter
        if (!_isPaymentComplete) {
          final shouldPop = await _showExitConfirmationDialog();
          return shouldPop;
        }
        return true;
      },
      child: Scaffold(
        appBar: const VLAppBar(
          title: 'Paiement sécurisé',
          automaticallyImplyLeading: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: VLLoadingIndicator(),
              ),
          ],
        ),
        bottomNavigationBar: _buildInfoBar(),
      ),
    );
  }

  Widget _buildInfoBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(
              Icons.security,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Transaction sécurisée via My-CoolPay',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ),
            if (_isCheckingStatus)
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le paiement ?'),
        content: const Text(
            'Si vous quittez maintenant, votre transaction sera annulée. Voulez-vous vraiment quitter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Non, continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
