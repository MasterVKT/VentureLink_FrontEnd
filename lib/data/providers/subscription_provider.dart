import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../models/subscription_plan_model.dart';
import '../models/payment_method_model.dart' hide PaymentSessionModel;
import '../models/payment_session_model.dart';
import '../repositories/subscription_repository.dart';
import '../services/subscription_api_service.dart' hide PaymentMethodModel;
import '../services/payment_api_service.dart';
import '../../core/errors/api_exceptions.dart';

/// Provider pour gérer l'état des abonnements
class SubscriptionProvider with ChangeNotifier {
  final SubscriptionRepository _repository;

  // État des plans d'abonnement
  List<SubscriptionPlanModel> _plans = [];
  bool _isLoadingPlans = false;
  String? _plansError;

  // État de l'abonnement courant
  SubscriptionModel? _currentSubscription;
  bool _isLoadingSubscription = false;
  String? _subscriptionError;

  // État des méthodes de paiement
  List<PaymentMethodModel> _paymentMethods = [];
  bool _isLoadingMethods = false;
  String? _methodsError;

  // État de la session de paiement
  PaymentSessionModel? _currentPaymentSession;
  bool _isProcessingPayment = false;
  String? _paymentError;

  // Devise sélectionnée par l'utilisateur
  String _selectedCurrency = 'XAF'; // Valeur par défaut

  // Constructeur
  SubscriptionProvider({required SubscriptionRepository repository})
      : _repository = repository;

  // Factory pour initialisation avec dépendances
  static Future<SubscriptionProvider> init() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();

    // Configuration de Dio
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    // Création des services
    final subscriptionService = SubscriptionApiService(dio);
    final paymentService = PaymentApiService(dio);

    // Création du repository
    final repository = SubscriptionRepository(
      subscriptionService: subscriptionService,
      paymentService: paymentService,
      prefs: prefs,
    );

    return SubscriptionProvider(repository: repository);
  }

  // Getters
  List<SubscriptionPlanModel> get plans => _plans;
  bool get isLoadingPlans => _isLoadingPlans;
  String? get plansError => _plansError;

  SubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoadingSubscription => _isLoadingSubscription;
  String? get subscriptionError => _subscriptionError;

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  bool get isLoadingMethods => _isLoadingMethods;
  String? get methodsError => _methodsError;

  PaymentSessionModel? get currentPaymentSession => _currentPaymentSession;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentError => _paymentError;

  String get selectedCurrency => _selectedCurrency;

  bool get hasActiveSubscription =>
      _currentSubscription != null && _currentSubscription!.isActive;

  /// Compteurs pour les fonctionnalités Premium
  int get projectsCreatedCount {
    // TODO: Implémenter la récupération depuis l'API/base de données
    // Pour le moment, on retourne une valeur codée en dur
    return 1;
  }

  int get investmentProposalsCount {
    // TODO: Implémenter la récupération depuis l'API/base de données
    // Pour le moment, on retourne une valeur codée en dur
    return 3;
  }

  int get dailyMessagesCount {
    // TODO: Implémenter la récupération depuis l'API/base de données
    // Pour le moment, on retourne une valeur codée en dur
    return 5;
  }

  /// Retourne la limite de projets en fonction de l'abonnement
  int get projectLimit {
    // Si pas d'abonnement actif, limite par défaut
    if (_currentSubscription == null || !_currentSubscription!.isActive) {
      return 1; // Limite de base pour utilisateurs gratuits
    }

    // Selon le plan
    switch (_currentSubscription!.plan.name) {
      case 'FREE':
        return 1;
      case 'BASIC_MONTHLY':
      case 'BASIC_YEARLY':
        return 5;
      case 'PREMIUM_MONTHLY':
      case 'PREMIUM_YEARLY':
        return -1; // Illimité
      default:
        return 1; // Valeur par défaut
    }
  }

  // Récupère tous les plans d'abonnement
  Future<void> loadPlans({bool forceRefresh = false}) async {
    _isLoadingPlans = true;
    _plansError = null;
    notifyListeners();

    try {
      _plans =
          await _repository.getSubscriptionPlans(forceRefresh: forceRefresh);
      _isLoadingPlans = false;
      notifyListeners();
    } on ApiException catch (e) {
      _isLoadingPlans = false;
      _plansError = e.message;
      notifyListeners();
    } catch (e) {
      _isLoadingPlans = false;
      _plansError = 'Une erreur est survenue lors du chargement des plans';
      notifyListeners();
    }
  }

  // Récupère les détails d'un plan d'abonnement
  Future<SubscriptionPlanModel?> getPlanDetails(String planId) async {
    try {
      return await _repository.getSubscriptionPlanDetails(planId);
    } on ApiException catch (e) {
      _plansError = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _plansError = 'Erreur lors de la récupération des détails du plan';
      notifyListeners();
      return null;
    }
  }

  // Récupère l'abonnement actuel de l'utilisateur
  Future<void> loadCurrentSubscription({bool forceRefresh = false}) async {
    _isLoadingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      _currentSubscription = await _repository.getCurrentSubscription(
        forceRefresh: forceRefresh,
      );
      _isLoadingSubscription = false;
      notifyListeners();
    } on ApiException catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = e.message;
      notifyListeners();
    } catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = 'Erreur lors de la récupération de l\'abonnement';
      notifyListeners();
    }
  }

  // Récupère les méthodes de paiement disponibles
  Future<void> loadPaymentMethods({bool forceRefresh = false}) async {
    _isLoadingMethods = true;
    _methodsError = null;
    notifyListeners();

    try {
      _paymentMethods = await _repository.getPaymentMethods(
        forceRefresh: forceRefresh,
      );
      _isLoadingMethods = false;
      notifyListeners();
    } on ApiException catch (e) {
      _isLoadingMethods = false;
      _methodsError = e.message;
      notifyListeners();
    } catch (e) {
      _isLoadingMethods = false;
      _methodsError = 'Erreur lors du chargement des méthodes de paiement';
      notifyListeners();
    }
  }

  // Change la devise sélectionnée
  void setSelectedCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  // Initie un paiement pour souscrire à un abonnement
  Future<PaymentSessionModel?> initiateSubscriptionPayment({
    required String planId,
    required String paymentMethod,
    String? phoneNumber,
    String? successUrl,
    String? cancelUrl,
  }) async {
    _isProcessingPayment = true;
    _paymentError = null;
    _currentPaymentSession = null;
    notifyListeners();

    try {
      final session = await _repository.createSubscriptionPayment(
        planId: planId,
        currency: _selectedCurrency,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      _currentPaymentSession = session;
      _isProcessingPayment = false;
      notifyListeners();
      return session;
    } on ApiException catch (e) {
      _isProcessingPayment = false;
      _paymentError = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _isProcessingPayment = false;
      _paymentError = 'Erreur lors de l\'initialisation du paiement';
      notifyListeners();
      return null;
    }
  }

  // Vérifie le statut d'un paiement
  Future<PaymentSessionModel?> checkPaymentStatus(String paymentId) async {
    _isProcessingPayment = true;
    notifyListeners();

    try {
      final session = await _repository.checkPaymentStatus(paymentId);
      _currentPaymentSession = session;
      _isProcessingPayment = false;

      // Si le paiement est complété, recharger l'abonnement
      if (session.isCompleted) {
        await loadCurrentSubscription(forceRefresh: true);
      }

      notifyListeners();
      return session;
    } on ApiException catch (e) {
      _isProcessingPayment = false;
      _paymentError = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _isProcessingPayment = false;
      _paymentError = 'Erreur lors de la vérification du paiement';
      notifyListeners();
      return null;
    }
  }

  // Créer un abonnement après un paiement réussi
  Future<SubscriptionModel?> createSubscription({
    required String planId,
    bool autoRenew = true,
    String? paymentMethodId,
    String? paymentSessionId,
  }) async {
    _isLoadingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      final subscription = await _repository.createSubscription(
        planId: planId,
        currency: _selectedCurrency,
        autoRenew: autoRenew,
        paymentMethodId: paymentMethodId,
        paymentSessionId: paymentSessionId,
      );

      _currentSubscription = subscription;
      _isLoadingSubscription = false;
      notifyListeners();
      return subscription;
    } on ApiException catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = e.message;
      notifyListeners();
      return null;
    } catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = 'Erreur lors de la création de l\'abonnement';
      notifyListeners();
      return null;
    }
  }

  // Annule un abonnement
  Future<bool> cancelSubscription({
    required String subscriptionId,
    String? reason,
    bool cancelImmediately = false,
    String? feedback,
  }) async {
    _isLoadingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      await _repository.cancelSubscription(
        subscriptionId: subscriptionId,
        reason: reason,
        cancelImmediately: cancelImmediately,
        feedback: feedback,
      );

      // Recharger l'abonnement actuel
      await loadCurrentSubscription(forceRefresh: true);

      return true;
    } on ApiException catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = 'Erreur lors de l\'annulation de l\'abonnement';
      notifyListeners();
      return false;
    }
  }

  // Réactive un abonnement annulé
  Future<bool> reactivateSubscription(String subscriptionId) async {
    _isLoadingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      final subscription =
          await _repository.reactivateSubscription(subscriptionId);
      _currentSubscription = subscription;
      _isLoadingSubscription = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = 'Erreur lors de la réactivation de l\'abonnement';
      notifyListeners();
      return false;
    }
  }

  // Change le plan d'abonnement
  Future<bool> changePlan({
    required String subscriptionId,
    required String newPlanId,
    bool prorate = true,
  }) async {
    _isLoadingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      final subscription = await _repository.changePlan(
        subscriptionId: subscriptionId,
        newPlanId: newPlanId,
        prorate: prorate,
        currency: _selectedCurrency,
      );

      _currentSubscription = subscription;
      _isLoadingSubscription = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoadingSubscription = false;
      _subscriptionError = 'Erreur lors du changement de plan';
      notifyListeners();
      return false;
    }
  }

  // Réinitialise l'état de paiement
  void resetPaymentState() {
    _currentPaymentSession = null;
    _isProcessingPayment = false;
    _paymentError = null;
    notifyListeners();
  }
}
