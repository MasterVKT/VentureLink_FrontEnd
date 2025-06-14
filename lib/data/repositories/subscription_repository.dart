import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_plan_model.dart';
import '../models/payment_method_model.dart' hide PaymentSessionModel;
import '../models/payment_session_model.dart';
import '../services/subscription_api_service.dart' hide PaymentMethodModel;
import '../services/payment_api_service.dart';
import '../../core/errors/api_exceptions.dart';

class SubscriptionRepository {
  final SubscriptionApiService _subscriptionService;
  final PaymentApiService _paymentService;
  final SharedPreferences _prefs;

  // Clés pour le cache local
  static const String _plansKey = 'subscription_plans';
  static const String _methodsKey = 'payment_methods';
  static const String _currentSubscriptionKey = 'current_subscription';

  // Durée de validité du cache (en minutes)
  static const int _cacheDuration = 15;

  // Cache en mémoire
  List<SubscriptionPlanModel>? _cachedPlans;
  List<PaymentMethodModel>? _cachedMethods;
  SubscriptionModel? _cachedCurrentSubscription;
  DateTime? _plansLastFetched;
  DateTime? _methodsLastFetched;
  DateTime? _subscriptionLastFetched;

  SubscriptionRepository({
    required SubscriptionApiService subscriptionService,
    required PaymentApiService paymentService,
    required SharedPreferences prefs,
  })  : _subscriptionService = subscriptionService,
        _paymentService = paymentService,
        _prefs = prefs;

  /// Récupère tous les plans d'abonnement disponibles
  /// Utilise le cache si disponible et valide
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans({
    bool forceRefresh = false,
  }) async {
    // Vérifier si le cache en mémoire est valide
    if (!forceRefresh &&
        _cachedPlans != null &&
        _plansLastFetched != null &&
        DateTime.now().difference(_plansLastFetched!).inMinutes <
            _cacheDuration) {
      return _cachedPlans!;
    }

    try {
      // Récupérer les plans depuis l'API
      final response = await _subscriptionService.getSubscriptionPlans();
      _cachedPlans = response.plans;
      _plansLastFetched = DateTime.now();

      // Mettre à jour le cache local
      await _savePlansToCache(response.plans);

      return response.plans;
    } on DioException catch (e) {
      // Tenter de récupérer depuis le cache local si erreur réseau
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedPlans = _getPlansFromCache();
        if (cachedPlans.isNotEmpty) {
          return cachedPlans;
        }
      }
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère les détails d'un plan d'abonnement spécifique
  Future<SubscriptionPlanModel> getSubscriptionPlanDetails(
      String planId) async {
    try {
      // Vérifier d'abord dans le cache en mémoire
      if (_cachedPlans != null) {
        final cachedPlan = _cachedPlans!.firstWhere((plan) => plan.id == planId,
            orElse: () => throw UnknownException(
                'Plan d\'abonnement non trouvé dans le cache'));
        return cachedPlan;
      }

      // Récupérer depuis l'API
      return await _subscriptionService.getSubscriptionPlanDetails(planId);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère les méthodes de paiement disponibles
  Future<List<PaymentMethodModel>> getPaymentMethods({
    bool forceRefresh = false,
  }) async {
    // Vérifier si le cache en mémoire est valide
    if (!forceRefresh &&
        _cachedMethods != null &&
        _methodsLastFetched != null &&
        DateTime.now().difference(_methodsLastFetched!).inMinutes <
            _cacheDuration) {
      return _cachedMethods!;
    }

    try {
      // Récupérer les méthodes depuis l'API
      final response = await _paymentService.getPaymentMethods();
      _cachedMethods = response.methods;
      _methodsLastFetched = DateTime.now();

      // Mettre à jour le cache local
      await _saveMethodsToCache(response.methods);

      return response.methods;
    } on DioException catch (e) {
      // Tenter de récupérer depuis le cache local si erreur réseau
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cachedMethods = _getMethodsFromCache();
        if (cachedMethods.isNotEmpty) {
          return cachedMethods;
        }
      }
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Récupère l'abonnement actuel de l'utilisateur
  Future<SubscriptionModel?> getCurrentSubscription({
    bool forceRefresh = false,
  }) async {
    // Vérifier si le cache en mémoire est valide
    if (!forceRefresh &&
        _cachedCurrentSubscription != null &&
        _subscriptionLastFetched != null &&
        DateTime.now().difference(_subscriptionLastFetched!).inMinutes <
            _cacheDuration) {
      return _cachedCurrentSubscription;
    }

    try {
      // Récupérer l'abonnement depuis l'API
      final subscription = await _subscriptionService.getCurrentSubscription();
      _cachedCurrentSubscription = subscription;
      _subscriptionLastFetched = DateTime.now();

      // Mettre à jour le cache local
      await _saveCurrentSubscriptionToCache(subscription);

      return subscription;
    } on DioException catch (e) {
      // Gestion spéciale pour 404 (pas d'abonnement actif)
      if (e.response?.statusCode == 404) {
        _cachedCurrentSubscription = null;
        await _prefs.remove(_currentSubscriptionKey);
        return null;
      }

      // Tenter de récupérer depuis le cache local si erreur réseau
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return _getCurrentSubscriptionFromCache();
      }
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Crée un paiement pour souscrire à un abonnement
  Future<PaymentSessionModel> createSubscriptionPayment({
    required String planId,
    required String currency,
    required String paymentMethod,
    String? phoneNumber,
    String? successUrl,
    String? cancelUrl,
  }) async {
    try {
      final request = CreateSubscriptionPaymentRequest(
        planId: planId,
        currency: currency,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
      );

      return await _paymentService.createSubscriptionPayment(request);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Vérifie le statut d'un paiement
  Future<PaymentSessionModel> checkPaymentStatus(String paymentId) async {
    try {
      return await _paymentService.checkPaymentStatus(paymentId);
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Crée un abonnement après un paiement réussi
  Future<SubscriptionModel> createSubscription({
    required String planId,
    required String currency,
    bool autoRenew = true,
    String? paymentMethodId,
    String? paymentSessionId,
  }) async {
    try {
      final request = CreateSubscriptionRequest(
        planId: planId,
        currency: currency,
        autoRenew: autoRenew,
        paymentMethodId: paymentMethodId,
        paymentSessionId: paymentSessionId,
      );

      final subscription =
          await _subscriptionService.createSubscription(request);

      // Mettre à jour le cache
      _cachedCurrentSubscription = subscription;
      _subscriptionLastFetched = DateTime.now();
      await _saveCurrentSubscriptionToCache(subscription);

      return subscription;
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Annule un abonnement
  Future<CancelSubscriptionResponse> cancelSubscription({
    required String subscriptionId,
    String? reason,
    bool cancelImmediately = false,
    String? feedback,
  }) async {
    try {
      final request = CancelSubscriptionRequest(
        reason: reason,
        cancelImmediately: cancelImmediately,
        feedback: feedback,
      );

      final response = await _subscriptionService.cancelSubscription(
        subscriptionId,
        request,
      );

      // Invalider le cache si annulation immédiate
      if (cancelImmediately) {
        _cachedCurrentSubscription = null;
        await _prefs.remove(_currentSubscriptionKey);
      }

      return response;
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Réactive un abonnement annulé
  Future<SubscriptionModel> reactivateSubscription(
      String subscriptionId) async {
    try {
      final subscription =
          await _subscriptionService.reactivateSubscription(subscriptionId);

      // Mettre à jour le cache
      _cachedCurrentSubscription = subscription;
      _subscriptionLastFetched = DateTime.now();
      await _saveCurrentSubscriptionToCache(subscription);

      return subscription;
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Change le plan d'abonnement
  Future<SubscriptionModel> changePlan({
    required String subscriptionId,
    required String newPlanId,
    bool prorate = true,
    String? currency,
  }) async {
    try {
      final request = ChangePlanRequest(
        newPlanId: newPlanId,
        prorate: prorate,
        currency: currency,
      );

      final subscription = await _subscriptionService.changePlan(
        subscriptionId,
        request,
      );

      // Mettre à jour le cache
      _cachedCurrentSubscription = subscription;
      _subscriptionLastFetched = DateTime.now();
      await _saveCurrentSubscriptionToCache(subscription);

      return subscription;
    } on DioException catch (e) {
      throw ApiExceptionHandler.handleDioError(e);
    } catch (e) {
      throw ApiExceptionHandler.handleError(e);
    }
  }

  /// Enregistre les plans dans le cache local
  Future<void> _savePlansToCache(List<SubscriptionPlanModel> plans) async {
    try {
      final plansJson = plans.map((plan) => plan.toJson()).toList();
      await _prefs.setString(_plansKey, plansJson.toString());
    } catch (_) {
      // Ignorer les erreurs de cache
    }
  }

  /// Récupère les plans depuis le cache local
  List<SubscriptionPlanModel> _getPlansFromCache() {
    try {
      final plansJson = _prefs.getString(_plansKey);
      if (plansJson == null) return [];

      // Parse le JSON et transforme en liste de plans
      // Note: Cette implémentation simplifiée devrait être améliorée
      // avec une vraie fonction de parsing JSON
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Enregistre les méthodes de paiement dans le cache local
  Future<void> _saveMethodsToCache(List<PaymentMethodModel> methods) async {
    try {
      final methodsJson = methods.map((method) => method.toJson()).toList();
      await _prefs.setString(_methodsKey, methodsJson.toString());
    } catch (_) {
      // Ignorer les erreurs de cache
    }
  }

  /// Récupère les méthodes de paiement depuis le cache local
  List<PaymentMethodModel> _getMethodsFromCache() {
    try {
      final methodsJson = _prefs.getString(_methodsKey);
      if (methodsJson == null) return [];

      // Parse le JSON et transforme en liste de méthodes
      // Note: Cette implémentation simplifiée devrait être améliorée
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Enregistre l'abonnement actuel dans le cache local
  Future<void> _saveCurrentSubscriptionToCache(
      SubscriptionModel subscription) async {
    try {
      await _prefs.setString(
          _currentSubscriptionKey, subscription.toJson().toString());
    } catch (_) {
      // Ignorer les erreurs de cache
    }
  }

  /// Récupère l'abonnement actuel depuis le cache local
  SubscriptionModel? _getCurrentSubscriptionFromCache() {
    try {
      final subscriptionJson = _prefs.getString(_currentSubscriptionKey);
      if (subscriptionJson == null) return null;

      // Parse le JSON et transforme en abonnement
      // Note: Cette implémentation simplifiée devrait être améliorée
      return null;
    } catch (_) {
      return null;
    }
  }
}
