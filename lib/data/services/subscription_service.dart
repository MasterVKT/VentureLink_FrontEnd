import 'package:dio/dio.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';
import 'api_service.dart';

class SubscriptionService {
  final ApiService _apiService;

  SubscriptionService(this._apiService);

  /// Récupérer tous les plans d'abonnement disponibles
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final response = await _apiService.get('/payments/plans/');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => SubscriptionPlanModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Erreur lors du chargement des plans');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des plans: $e');
    }
  }

  /// Récupérer l'abonnement actuel de l'utilisateur
  Future<UserSubscriptionModel?> getCurrentSubscription() async {
    try {
      final response = await _apiService.get('/payments/subscription/');

      if (response.statusCode == 200) {
        return UserSubscriptionModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        // Aucun abonnement actuel
        return null;
      } else {
        throw Exception('Erreur lors du chargement de l\'abonnement');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Erreur lors du chargement de l\'abonnement: $e');
    }
  }

  /// Créer un nouvel abonnement
  Future<Map<String, dynamic>> createSubscription({
    required String planId,
    required String billingCurrency,
    required String paymentMethod,
    String? phoneNumber,
    String? returnUrl,
    String? cancelUrl,
  }) async {
    try {
      final response = await _apiService.post(
        '/payments/subscription/create/',
        data: {
          'plan_id': planId,
          'billing_currency': billingCurrency,
          'payment_method': paymentMethod,
          if (phoneNumber != null) 'phone_number': phoneNumber,
          if (returnUrl != null) 'return_url': returnUrl,
          if (cancelUrl != null) 'cancel_url': cancelUrl,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la création de l\'abonnement');
      }
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'abonnement: $e');
    }
  }

  /// Annuler un abonnement
  Future<bool> cancelSubscription({String? reason}) async {
    try {
      final response = await _apiService.post(
        '/payments/subscription/cancel/',
        data: {
          if (reason != null) 'reason': reason,
          'immediate': false,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de l\'abonnement: $e');
    }
  }

  /// Créer un paiement direct avec My-CoolPay
  Future<Map<String, dynamic>> createDirectPayment({
    required String planId,
    required String operator,
    required String phoneNumber,
    String currency = 'XAF',
  }) async {
    try {
      // D'abord récupérer le plan pour obtenir le prix
      final plans = await getSubscriptionPlans();
      final plan = plans.firstWhere((p) => p.id == planId);
      final amount = plan.getPriceInCurrency(currency);

      final response = await _apiService.post(
        '/payments/payin/',
        data: {
          'amount': amount.toString(),
          'currency': currency,
          'phone_number': phoneNumber,
          'operator': operator,
          'description': 'Abonnement ${plan.name}',
          'customer_name': 'Utilisateur VentureLink',
          'customer_email': 'user@venturelink.com',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de l\'initiation du paiement');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'initiation du paiement: $e');
    }
  }

  /// Autoriser un paiement avec code OTP
  Future<Map<String, dynamic>> authorizePayment({
    required String transactionRef,
    required String otpCode,
  }) async {
    try {
      final response = await _apiService.post(
        '/payments/authorize/',
        data: {
          'transaction_ref': transactionRef,
          'otp_code': otpCode,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de l\'autorisation du paiement');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'autorisation du paiement: $e');
    }
  }

  /// Vérifier le statut d'un paiement
  Future<Map<String, dynamic>> checkPaymentStatus(String paymentId) async {
    try {
      final response = await _apiService.get('/payments/$paymentId/status/');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Erreur lors de la vérification du statut');
      }
    } catch (e) {
      throw Exception('Erreur lors de la vérification du statut: $e');
    }
  }

  /// Récupérer les méthodes de paiement disponibles
  Future<List<Map<String, dynamic>>> getPaymentMethods({
    String? currency,
    String? country,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (currency != null) queryParams['currency'] = currency;
      if (country != null) queryParams['country'] = country;

      final response = await _apiService.get(
        '/payments/methods/',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Erreur lors du chargement des méthodes de paiement');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des méthodes de paiement: $e');
    }
  }

  /// Créer des données de test pour le développement
  List<SubscriptionPlanModel> createTestPlans() {
    final now = DateTime.now();

    return [
      SubscriptionPlanModel(
        id: 'free',
        name: 'Gratuit',
        description: 'Plan de base pour commencer',
        priceXaf: 0,
        priceEur: 0,
        priceUsd: 0,
        price: 0,
        currency: 'EUR',
        durationMonths: 0,
        billingCycle: 'NONE',
        trialDays: 0,
        features: [
          'Création de 1 projet',
          'Messagerie de base',
          'Support communautaire',
        ],
        maxProjects: 1,
        maxInvestments: 3,
        prioritySupport: false,
        advancedAnalytics: false,
        isActive: true,
        isPopular: false,
        sortOrder: 1,
        createdAt: now,
        updatedAt: now,
      ),
      SubscriptionPlanModel(
        id: 'basic_monthly',
        name: 'Basic Mensuel',
        description: 'Plan de base pour entrepreneurs débutants',
        priceXaf: 6500,
        priceEur: 9.99,
        priceUsd: 10.99,
        price: 9.99,
        currency: 'EUR',
        durationMonths: 1,
        billingCycle: 'MONTHLY',
        trialDays: 7,
        features: [
          'Création de 5 projets',
          'Messagerie avancée',
          'Analytics de base',
          'Support par email',
        ],
        maxProjects: 5,
        maxInvestments: 10,
        prioritySupport: false,
        advancedAnalytics: false,
        isActive: true,
        isPopular: false,
        sortOrder: 2,
        createdAt: now,
        updatedAt: now,
      ),
      SubscriptionPlanModel(
        id: 'premium_monthly',
        name: 'Premium Mensuel',
        description: 'Plan complet pour entrepreneurs confirmés',
        priceXaf: 19500,
        priceEur: 29.99,
        priceUsd: 32.99,
        price: 29.99,
        currency: 'EUR',
        durationMonths: 1,
        billingCycle: 'MONTHLY',
        trialDays: 14,
        features: [
          'Projets illimités',
          'IA Matching avancé',
          'Analytics détaillées',
          'Support prioritaire',
          'Mise en avant des projets',
        ],
        maxProjects: 0, // Illimité
        maxInvestments: 0, // Illimité
        prioritySupport: true,
        advancedAnalytics: true,
        isActive: true,
        isPopular: true,
        sortOrder: 3,
        createdAt: now,
        updatedAt: now,
      ),
      SubscriptionPlanModel(
        id: 'premium_yearly',
        name: 'Premium Annuel',
        description: 'Plan premium avec 2 mois gratuits',
        priceXaf: 196800,
        priceEur: 299.99,
        priceUsd: 329.99,
        price: 299.99,
        currency: 'EUR',
        durationMonths: 12,
        billingCycle: 'YEARLY',
        trialDays: 30,
        features: [
          'Toutes les fonctionnalités Premium',
          'Économie de 2 mois',
          'Support téléphonique',
          'Accès bêta aux nouvelles fonctionnalités',
          'Consultation stratégique mensuelle',
        ],
        maxProjects: 0, // Illimité
        maxInvestments: 0, // Illimité
        prioritySupport: true,
        advancedAnalytics: true,
        isActive: true,
        isPopular: false,
        sortOrder: 4,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
