import 'package:flutter/material.dart';
import '../models/payment_method_model.dart';
import '../models/payment_session_model.dart';
import '../services/api_service.dart';
import '../services/payment_api_service.dart';

class PaymentProvider with ChangeNotifier {
  final PaymentApiService _apiService;
  final ApiService _rawApiService;

  PaymentProvider(
    this._apiService, {
    ApiService? rawApiService,
  }) : _rawApiService = rawApiService ?? ApiService();

  // État
  bool _isLoading = false;
  String? _error;

  // Données
  List<PaymentMethodModel> _paymentMethods = [];
  List<String> _supportedCurrencies = [];
  List<PaymentHistoryModel> _paymentHistory = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  List<String> get supportedCurrencies => _supportedCurrencies;
  List<PaymentHistoryModel> get paymentHistory => _paymentHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;

  /// Charger les méthodes de paiement disponibles
  Future<void> loadPaymentMethods() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _apiService.getPaymentMethods();
      _paymentMethods = response.methods;
      _supportedCurrencies = response.supportedCurrencies;
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des méthodes: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Créer un paiement d'abonnement
  Future<Map<String, dynamic>> createSubscriptionPayment({
    required String planId,
    required String paymentMethod,
    required String currency,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = CreateSubscriptionPaymentRequest(
        planId: planId,
        paymentMethod: paymentMethod,
        currency: currency,
      );

      final result = await _apiService.createSubscriptionPayment(request);

      return {
        'success': true,
        'payment_id': result.id,
        'payment_url': result.paymentUrl,
        'transaction_ref': result.transactionId,
      };
    } catch (e) {
      _setError('Erreur lors de la création du paiement: ${e.toString()}');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Initier un paiement direct (Mobile Money)
  Future<Map<String, dynamic>> initiateDirectPayment({
    required String planId,
    required String operator,
    required String phoneNumber,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = DirectPaymentRequest(
        planId: planId,
        operator: operator,
        phoneNumber: phoneNumber,
      );

      final result = await _apiService.initiateDirectPayment(request);

      return {
        'success': true,
        'payment_id': result.id,
        'transaction_ref': result.transactionId,
        'action': result.providerResponse?['action'],
        'ussd': result.providerResponse?['ussd'],
      };
    } catch (e) {
      _setError('Erreur lors de l\'initiation du paiement: ${e.toString()}');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Autoriser un paiement avec code OTP
  Future<Map<String, dynamic>> authorizePaymentOTP({
    required String paymentId,
    required String otpCode,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final request = AuthorizeOTPRequest(
        paymentId: paymentId,
        otpCode: otpCode,
      );

      final result = await _apiService.authorizePaymentOTP(request);

      return {
        'success': true,
        'action': result.providerResponse?['action'],
        'ussd': result.providerResponse?['ussd'],
        'transaction_ref': result.transactionId,
      };
    } catch (e) {
      _setError('Erreur lors de l\'autorisation: ${e.toString()}');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  /// Vérifier le statut d'un paiement
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _apiService.checkPaymentStatus(paymentId);

      return {
        'success': true,
        'payment_id': result.id,
        'status': result.status.value,
        'amount': result.amount,
        'currency': result.currency,
        'description': result.providerResponse?['description'],
        'created_at': result.createdAt.toIso8601String(),
        'completed_at': result.updatedAt.toIso8601String(),
      };
    } catch (e) {
      _setError('Erreur lors de la vérification: ${e.toString()}');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> initiateInvestmentPayment({
    required String investmentId,
    required String currency,
    required String returnUrl,
    required String paymentMethod,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _rawApiService.post(
        '/payments/investments/$investmentId/initiate/',
        data: {
          'currency': currency,
          'return_url': returnUrl,
          'payment_method': paymentMethod,
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return {
          'success': true,
          'payment_url': data['payment_url'],
          'transaction_id': data['transaction_id'] ?? data['transaction_ref'],
          'expires_at': data['expires_at'],
        };
      }

      return {
        'success': false,
        'error': 'Réponse invalide du serveur',
      };
    } catch (e) {
      _setError('Erreur lors de l\'initiation du paiement: ${e.toString()}');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<PaymentInitiationResult> initiatePayment({
    required String projectId,
    required double amount,
    required String currency,
    required String paymentMethod,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await _rawApiService.post(
        '/payments/investments/$projectId/initiate/',
        data: {
          'amount': amount,
          'currency': currency,
          'payment_method': paymentMethod,
          'return_url': 'venturelink://payment-success',
        },
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final paymentUrl =
            (data['payment_url'] ?? data['checkout_url'])?.toString();
        final transactionId =
            (data['transaction_id'] ?? data['transaction_ref'] ?? data['id'])
                ?.toString();

        if (paymentUrl != null &&
            paymentUrl.isNotEmpty &&
            transactionId != null &&
            transactionId.isNotEmpty) {
          return PaymentInitiationResult.success(
            paymentUrl: paymentUrl,
            transactionId: transactionId,
          );
        }
      }

      return const PaymentInitiationResult.failure(
        error: 'Réponse invalide du serveur',
      );
    } catch (e) {
      _setError('Erreur lors de l\'initiation du paiement: ${e.toString()}');
      return PaymentInitiationResult.failure(error: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> checkInvestmentPaymentStatus(
    String transactionId,
  ) async {
    _setLoading(true);
    _setError(null);

    Future<Map<String, dynamic>> tryPath(String path) async {
      final response = await _rawApiService.get(path);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final status =
            data['status'] ?? data['payment_status'] ?? data['state'];
        return {
          'success': true,
          'status': status?.toString(),
          'raw': data,
        };
      }
      return {
        'success': false,
        'error': 'Réponse invalide du serveur',
      };
    }

    try {
      try {
        return await tryPath('/payments/transactions/$transactionId/status/');
      } catch (_) {
        return await tryPath('/payments/$transactionId/status/');
      }
    } catch (e) {
      _setError('Erreur lors de la vérification: ${e.toString()}');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadPaymentHistory() async {
    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      final response = await _apiService.getPaymentHistory();
      _paymentHistory = response.results;
    } catch (e) {
      _historyError = e.toString();
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Obtenir une méthode de paiement par code
  PaymentMethodModel? getPaymentMethodByCode(String code) {
    try {
      return _paymentMethods.firstWhere((method) => method.id == code);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les méthodes de paiement mobile
  List<PaymentMethodModel> get mobilePaymentMethods {
    return _paymentMethods.where((method) => method.type == 'mobile').toList();
  }

  /// Obtenir les méthodes de paiement par carte
  List<PaymentMethodModel> get cardPaymentMethods {
    return _paymentMethods.where((method) => method.type == 'card').toList();
  }

  /// Obtenir les méthodes de redirection
  List<PaymentMethodModel> get redirectPaymentMethods {
    return _paymentMethods
        .where((method) => method.type == 'redirect')
        .toList();
  }

  /// Vérifier si une devise est supportée
  bool isCurrencySupported(String currency) {
    return _supportedCurrencies.contains(currency);
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    if (error != null) {
      notifyListeners();
    }
  }

  /// Rafraîchir les données
  Future<void> refresh() async {
    await loadPaymentMethods();
  }

  /// Nettoyer les données
  void clear() {
    _paymentMethods.clear();
    _supportedCurrencies.clear();
    _paymentHistory.clear();
    _isLoadingHistory = false;
    _historyError = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

class PaymentInitiationResult {
  final bool success;
  final String? paymentUrl;
  final String? transactionId;
  final String? error;

  const PaymentInitiationResult._({
    required this.success,
    this.paymentUrl,
    this.transactionId,
    this.error,
  });

  const PaymentInitiationResult.success({
    required String paymentUrl,
    required String transactionId,
  }) : this._(
          success: true,
          paymentUrl: paymentUrl,
          transactionId: transactionId,
        );

  const PaymentInitiationResult.failure({required String error})
      : this._(success: false, error: error);
}
