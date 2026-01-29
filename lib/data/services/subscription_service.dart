import 'package:dio/dio.dart';
import '../models/subscription_plan_model.dart';
import '../models/user_subscription_model.dart';
import 'api_service.dart';
import 'package:flutter/foundation.dart';

class SubscriptionService {
  final ApiService _apiService;

  SubscriptionService(this._apiService);

  /// Récupérer tous les plans d'abonnement disponibles
  Future<List<SubscriptionPlanModel>> getSubscriptionPlans() async {
    try {
      final response = await _apiService.get('/payments/plans/');

      if (response.statusCode == 200) {
        // Gérer la structure paginée de l'API
        final Map<String, dynamic> responseData = response.data;
        final List<dynamic> data = responseData['results'] ?? responseData;

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
        // Vérifier si la réponse contient un abonnement ou juste un message
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Si la réponse contient has_subscription: false, retourner null
          if (data.containsKey('has_subscription') &&
              data['has_subscription'] == false) {
            return null;
          }
          // Sinon essayer de parser l'abonnement
          return UserSubscriptionModel.fromJson(data);
        }
        return null;
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
      // Pour les autres erreurs, retourner null plutôt que de lancer une exception
      debugPrint('❌ Erreur getCurrentSubscription: $e');
      return null;
    }
  }

  /// Créer un nouvel abonnement (simplifié pour My-CoolPay)
  Future<Map<String, dynamic>> createSubscription({
    required String planId,
    required String phoneNumber,
  }) async {
    try {
      final response = await _apiService.post(
        '/payments/subscription/create/',
        data: {
          'plan_id': planId,
          'phone_number': phoneNumber,
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

  /// Récupérer les méthodes de paiement disponibles (My-CoolPay uniquement)
  Future<Map<String, dynamic>> getPaymentMethods({
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
        return response.data;
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
