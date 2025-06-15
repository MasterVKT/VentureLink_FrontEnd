import 'package:flutter/foundation.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';
import '../services/subscription_service.dart';

class SimpleSubscriptionProvider with ChangeNotifier {
  final SubscriptionService _subscriptionService;

  // État des plans
  List<SubscriptionPlanModel> _plans = [];
  bool _isLoadingPlans = false;
  String? _plansError;

  // État de l'abonnement actuel
  UserSubscriptionModel? _currentSubscription;
  bool _isLoadingSubscription = false;
  String? _subscriptionError;

  // État du paiement
  bool _isProcessingPayment = false;
  String? _paymentError;

  SimpleSubscriptionProvider(this._subscriptionService);

  // Getters
  List<SubscriptionPlanModel> get plans => _plans;
  bool get isLoadingPlans => _isLoadingPlans;
  String? get plansError => _plansError;

  UserSubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoadingSubscription => _isLoadingSubscription;
  String? get subscriptionError => _subscriptionError;

  bool get hasActiveSubscription =>
      _currentSubscription != null && _currentSubscription!.isActive;

  bool get isProcessingPayment => _isProcessingPayment;
  String? get paymentError => _paymentError;

  List<SubscriptionPlanModel> get activePlans =>
      _plans.where((plan) => plan.isActive).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  /// Charger les plans d'abonnement
  Future<void> loadPlans({bool forceRefresh = false}) async {
    if (_isLoadingPlans) return;

    _isLoadingPlans = true;
    _plansError = null;
    notifyListeners();

    try {
      // Essayer de charger depuis l'API
      _plans = await _subscriptionService.getSubscriptionPlans();
      debugPrint(
          '✅ Plans d\'abonnement chargés depuis l\'API: ${_plans.length}');
    } catch (e) {
      debugPrint('❌ Erreur chargement plans API: $e');
      // Fallback sur les données de test
      _plans = _subscriptionService.createTestPlans();
      debugPrint('✅ Plans de test chargés: ${_plans.length}');
    }

    _isLoadingPlans = false;
    notifyListeners();
  }

  /// Charger l'abonnement actuel
  Future<void> loadCurrentSubscription({bool forceRefresh = false}) async {
    if (_isLoadingSubscription) return;

    _isLoadingSubscription = true;
    _subscriptionError = null;
    notifyListeners();

    try {
      _currentSubscription =
          await _subscriptionService.getCurrentSubscription();
      debugPrint(
          '✅ Abonnement actuel chargé: ${_currentSubscription?.planName ?? 'Aucun'}');
    } catch (e) {
      debugPrint('❌ Erreur chargement abonnement: $e');
      _subscriptionError = e.toString();
      _currentSubscription = null;
    }

    _isLoadingSubscription = false;
    notifyListeners();
  }

  /// Souscrire à un plan
  Future<bool> subscribeToPlan({
    required String planId,
    required String currency,
    String paymentMethod = 'PAYLINK',
    String? phoneNumber,
  }) async {
    if (_isProcessingPayment) return false;

    _isProcessingPayment = true;
    _paymentError = null;
    notifyListeners();

    try {
      final result = await _subscriptionService.createSubscription(
        planId: planId,
        billingCurrency: currency,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber,
        returnUrl: 'https://app.venturelink.com/subscription/success',
        cancelUrl: 'https://app.venturelink.com/subscription/cancel',
      );

      debugPrint('✅ Abonnement créé: $result');

      // Recharger l'abonnement actuel
      await loadCurrentSubscription(forceRefresh: true);

      _isProcessingPayment = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Erreur souscription: $e');
      _paymentError = e.toString();
      _isProcessingPayment = false;
      notifyListeners();
      return false;
    }
  }

  /// Paiement direct avec Mobile Money
  Future<Map<String, dynamic>?> payWithMobileMoney({
    required String planId,
    required String operator,
    required String phoneNumber,
    String currency = 'XAF',
  }) async {
    if (_isProcessingPayment) return null;

    _isProcessingPayment = true;
    _paymentError = null;
    notifyListeners();

    try {
      final result = await _subscriptionService.createDirectPayment(
        planId: planId,
        operator: operator,
        phoneNumber: phoneNumber,
        currency: currency,
      );

      debugPrint('✅ Paiement Mobile Money initié: $result');
      return result;
    } catch (e) {
      debugPrint('❌ Erreur paiement Mobile Money: $e');
      _paymentError = e.toString();
      return null;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }

  /// Autoriser un paiement avec OTP
  Future<bool> authorizePayment({
    required String transactionRef,
    required String otpCode,
  }) async {
    try {
      final result = await _subscriptionService.authorizePayment(
        transactionRef: transactionRef,
        otpCode: otpCode,
      );

      debugPrint('✅ Paiement autorisé: $result');

      // Recharger l'abonnement actuel
      await loadCurrentSubscription(forceRefresh: true);

      _isProcessingPayment = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Erreur autorisation paiement: $e');
      _paymentError = e.toString();
      _isProcessingPayment = false;
      notifyListeners();
      return false;
    }
  }

  /// Annuler un abonnement
  Future<bool> cancelSubscription({String? reason}) async {
    if (_currentSubscription == null) return false;

    try {
      final success =
          await _subscriptionService.cancelSubscription(reason: reason);

      if (success) {
        await loadCurrentSubscription(forceRefresh: true);
        debugPrint('✅ Abonnement annulé');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Erreur annulation abonnement: $e');
      _subscriptionError = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Obtenir un plan par ID
  SubscriptionPlanModel? getPlanById(String planId) {
    try {
      return _plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si l'utilisateur peut créer plus de projets
  bool canCreateProject() {
    if (_currentSubscription == null) return true; // Plan gratuit par défaut

    final plan = getPlanById(_currentSubscription!.planId);
    if (plan == null) return true;

    // Si maxProjects est 0, c'est illimité
    return plan.maxProjects == 0;
  }

  /// Obtenir la limite de projets
  int getProjectLimit() {
    if (_currentSubscription == null) return 1; // Plan gratuit par défaut

    final plan = getPlanById(_currentSubscription!.planId);
    if (plan == null) return 1;

    return plan.maxProjects == 0 ? -1 : plan.maxProjects; // -1 = illimité
  }

  /// Réinitialiser les erreurs
  void clearErrors() {
    _plansError = null;
    _subscriptionError = null;
    _paymentError = null;
    notifyListeners();
  }

  /// Simuler l'activation d'un plan gratuit
  Future<bool> activateFreePlan() async {
    try {
      // Simuler l'activation du plan gratuit
      final freePlan = _plans.firstWhere((plan) => plan.id == 'free');

      _currentSubscription = UserSubscriptionModel(
        id: 'free_subscription_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        planId: freePlan.id,
        plan: freePlan,
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)), // 1 an
        autoRenew: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('✅ Plan gratuit activé');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Erreur activation plan gratuit: $e');
      return false;
    }
  }
}
