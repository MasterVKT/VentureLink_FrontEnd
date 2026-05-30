import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String url;
  final String transactionId;

  const PaymentWebView({
    super.key,
    required this.url,
    required this.transactionId,
  });

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
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
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
            _handleReturnUrl(url);
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
            _handleReturnUrl(url);
          },
          onNavigationRequest: (request) {
            if (_handleReturnUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  bool _handleReturnUrl(String url) {
    final lower = url.toLowerCase();

    if (lower.startsWith('venturelink://') ||
        lower.contains('venturelink://payment-success') ||
        lower.contains('venturelink://payment-failed') ||
        lower.contains('venturelink://payment-cancelled')) {
      if (lower.contains('success')) {
        Navigator.pop(context, true);
      } else if (lower.contains('failed')) {
        Navigator.pop(context, false);
      } else {
        Navigator.pop(context, null);
      }
      return true;
    }

    return false;
  }

  Future<bool> _confirmExit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le paiement ?'),
        content: const Text('Êtes-vous sûr de vouloir annuler ce paiement ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (!mounted) return false;
    return confirm == true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldExit = await _confirmExit();
        if (shouldExit) {
          navigator.pop(null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paiement sécurisé'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final shouldExit = await _confirmExit();
              if (!mounted) return;
              if (shouldExit) {
                navigator.pop(null);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
