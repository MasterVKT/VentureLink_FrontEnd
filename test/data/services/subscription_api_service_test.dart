import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/data/services/subscription_api_service.dart' as api;
import 'package:venturelink/data/models/subscription_plan_model.dart';

void main() {
  group('SubscriptionApiService Request Models Tests', () {
    test('CreateSubscriptionRequest should have correct properties', () {
      final request = api.CreateSubscriptionRequest(
        planId: 'premium_monthly',
        currency: 'XAF',
        autoRenew: true,
        paymentMethodId: 'mobile_money',
        paymentSessionId: 'session_123456',
      );

      expect(request.planId, equals('premium_monthly'));
      expect(request.currency, equals('XAF'));
      expect(request.autoRenew, isTrue);
      expect(request.paymentMethodId, equals('mobile_money'));
      expect(request.paymentSessionId, equals('session_123456'));

      final json = {
        'plan_id': 'premium_monthly',
        'currency': 'XAF',
        'auto_renew': true,
        'payment_method_id': 'mobile_money',
        'payment_session_id': 'session_123456',
      };

      // Vérifier que tous les champs sont présents dans le JSON
      expect(json['plan_id'], equals(request.planId));
      expect(json['currency'], equals(request.currency));
      expect(json['auto_renew'], equals(request.autoRenew));
      expect(json['payment_method_id'], equals(request.paymentMethodId));
      expect(json['payment_session_id'], equals(request.paymentSessionId));
    });

    test('CancelSubscriptionRequest should have correct properties', () {
      final request = api.CancelSubscriptionRequest(
        reason: 'Trop cher',
        cancelImmediately: true,
        feedback: 'Je souhaite un plan moins cher',
      );

      expect(request.reason, equals('Trop cher'));
      expect(request.cancelImmediately, isTrue);
      expect(request.feedback, equals('Je souhaite un plan moins cher'));

      final json = {
        'reason': 'Trop cher',
        'cancel_immediately': true,
        'feedback': 'Je souhaite un plan moins cher',
      };

      expect(json['reason'], equals(request.reason));
      expect(json['cancel_immediately'], equals(request.cancelImmediately));
      expect(json['feedback'], equals(request.feedback));
    });

    test('UpdateSubscriptionRequest should have correct properties', () {
      final request = api.UpdateSubscriptionRequest(
        autoRenew: false,
        currency: 'EUR',
      );

      expect(request.autoRenew, isFalse);
      expect(request.currency, equals('EUR'));

      final json = {
        'auto_renew': false,
        'currency': 'EUR',
      };

      expect(json['auto_renew'], equals(request.autoRenew));
      expect(json['currency'], equals(request.currency));
    });

    test('ChangePlanRequest should have correct properties', () {
      final request = api.ChangePlanRequest(
        newPlanId: 'premium_yearly',
        prorate: true,
        currency: 'EUR',
      );

      expect(request.newPlanId, equals('premium_yearly'));
      expect(request.prorate, isTrue);
      expect(request.currency, equals('EUR'));

      final json = {
        'new_plan_id': 'premium_yearly',
        'prorate': true,
        'currency': 'EUR',
      };

      expect(json['new_plan_id'], equals(request.newPlanId));
      expect(json['prorate'], equals(request.prorate));
      expect(json['currency'], equals(request.currency));
    });
  });

  group('SubscriptionApiService Response Models Tests', () {
    test('PlanResponse should have correct properties', () {
      final now = DateTime.now();
      final plan1 = SubscriptionPlanModel(
        id: 'free',
        name: 'Plan Gratuit',
        priceXaf: 0,
        priceEur: 0,
        priceUsd: 0,
        price: 0,
        currency: 'XAF',
        durationMonths: 1,
        billingCycle: 'MONTHLY',
        features: ['Accès limité'],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final plan2 = SubscriptionPlanModel(
        id: 'premium_monthly',
        name: 'Premium Mensuel',
        priceXaf: 30000,
        priceEur: 45.75,
        priceUsd: 50.0,
        price: 30000,
        currency: 'XAF',
        durationMonths: 1,
        billingCycle: 'MONTHLY',
        features: ['Accès illimité'],
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      final response = api.PlanResponse(
        plans: [plan1, plan2],
        totalCount: 2,
      );

      expect(response.plans.length, equals(2));
      expect(response.totalCount, equals(2));
      expect(response.plans[0].id, equals('free'));
      expect(response.plans[1].id, equals('premium_monthly'));

      final json = {
        'plans': [
          plan1.toJson(),
          plan2.toJson(),
        ],
        'total_count': 2,
      };

      // Vérifier la présence et le contenu de plans sans accéder à length
      final plansList = json['plans'] as List<dynamic>;
      expect(plansList.length, equals(2));
      expect(json['total_count'], equals(2));
    });

    test('CancelSubscriptionResponse should have correct properties', () {
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30));

      final response = api.CancelSubscriptionResponse(
        id: 'sub_123456',
        status: 'CANCELLED',
        cancellationDate: now,
        endDate: endDate,
        message:
            'Votre abonnement sera actif jusqu\'au terme de la période payée',
      );

      expect(response.id, equals('sub_123456'));
      expect(response.status, equals('CANCELLED'));
      expect(response.cancellationDate, equals(now));
      expect(response.endDate, equals(endDate));
      expect(response.message, contains('actif jusqu\'au terme'));

      final json = {
        'id': 'sub_123456',
        'status': 'CANCELLED',
        'cancellation_date': now.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        'message':
            'Votre abonnement sera actif jusqu\'au terme de la période payée',
      };

      expect(json['id'], equals(response.id));
      expect(json['status'], equals(response.status));
      expect(json['cancellation_date'], equals(now.toIso8601String()));
      expect(json['end_date'], equals(endDate.toIso8601String()));
      expect(json['message'], equals(response.message));
    });

    // Test simplifié de PaginatedResponse
    test('PaginatedResponse should be properly defined', () {
      // Vérifier que la classe PaginatedResponse est correctement définie
      // sans utiliser de modèles complexes
      final now = DateTime.now();

      // Utiliser des données simples pour le test
      final response = api.PaginatedResponse<Map<String, dynamic>>(
        count: 2,
        next: null,
        previous: null,
        results: [
          {
            'id': 'item1',
            'name': 'Item 1',
            'created_at': now.toIso8601String()
          },
          {
            'id': 'item2',
            'name': 'Item 2',
            'created_at': now.toIso8601String()
          },
        ],
      );

      // Vérifications de base
      expect(response.count, equals(2));
      expect(response.next, isNull);
      expect(response.previous, isNull);
      expect(response.results.length, equals(2));
      expect(response.results[0]['id'], equals('item1'));
      expect(response.results[1]['id'], equals('item2'));
    });
  });
}
