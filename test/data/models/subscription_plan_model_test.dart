import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/data/models/subscription_plan_model.dart';

void main() {
  group('SubscriptionPlanModel Tests', () {
    final DateTime now = DateTime.now();
    final testPlan = SubscriptionPlanModel(
      id: 'premium_monthly',
      name: 'Premium Mensuel',
      description: 'Abonnement premium mensuel',
      priceXaf: 30000,
      priceEur: 45.75,
      priceUsd: 50.0,
      price: 45.75,
      currency: 'EUR',
      durationMonths: 1,
      billingCycle: 'MONTHLY',
      trialDays: 7,
      features: ['Accès illimité', 'Support prioritaire', 'Analyses avancées'],
      maxProjects: 10,
      maxInvestments: 20,
      prioritySupport: true,
      advancedAnalytics: true,
      isActive: true,
      isPopular: true,
      sortOrder: 2,
      externalPlanId: 'premium_monthly_v1',
      createdAt: now,
      updatedAt: now,
    );

    test('SubscriptionPlanModel constructor should create a valid instance',
        () {
      expect(testPlan.id, equals('premium_monthly'));
      expect(testPlan.name, equals('Premium Mensuel'));
      expect(testPlan.priceXaf, equals(30000));
      expect(testPlan.priceEur, equals(45.75));
      expect(testPlan.priceUsd, equals(50.0));
      expect(testPlan.features.length, equals(3));
      expect(testPlan.maxProjects, equals(10));
      expect(testPlan.prioritySupport, isTrue);
    });

    test('toJson should serialize all fields correctly', () {
      final json = testPlan.toJson();

      expect(json['id'], equals('premium_monthly'));
      expect(json['name'], equals('Premium Mensuel'));
      expect(json['price_xaf'], equals(30000));
      expect(json['price_eur'], equals(45.75));
      expect(json['duration_months'], equals(1));
      expect(
          json['features'],
          equals(
              ['Accès illimité', 'Support prioritaire', 'Analyses avancées']));
      expect(json['created_at'], equals(now.toIso8601String()));
    });

    test('fromJson should deserialize a valid JSON object', () {
      final json = testPlan.toJson();
      final deserializedPlan = SubscriptionPlanModel.fromJson(json);

      expect(deserializedPlan.id, equals(testPlan.id));
      expect(deserializedPlan.name, equals(testPlan.name));
      expect(deserializedPlan.priceXaf, equals(testPlan.priceXaf));
      expect(deserializedPlan.priceEur, equals(testPlan.priceEur));
      expect(deserializedPlan.priceUsd, equals(testPlan.priceUsd));
      expect(deserializedPlan.features, equals(testPlan.features));
      expect(
          deserializedPlan.prioritySupport, equals(testPlan.prioritySupport));
    });

    test('getPriceInCurrency should return correct price for each currency',
        () {
      expect(testPlan.getPriceInCurrency('XAF'), equals(30000));
      expect(testPlan.getPriceInCurrency('EUR'), equals(45.75));
      expect(testPlan.getPriceInCurrency('USD'), equals(50.0));
      expect(testPlan.getPriceInCurrency('INVALID'),
          equals(30000)); // Default to XAF
    });

    test('getFormattedPrice should format prices with currency symbols', () {
      expect(testPlan.getFormattedPrice('XAF'), equals('30000 FCFA'));
      expect(testPlan.getFormattedPrice('EUR'), equals('45.75 €'));
      expect(testPlan.getFormattedPrice('USD'), equals('\$50.00'));
    });

    test('billingCycleDisplay should return localized billing cycle', () {
      final monthlyPlan = testPlan.copyWith(billingCycle: 'MONTHLY');
      final yearlyPlan = testPlan.copyWith(billingCycle: 'YEARLY');
      final weeklyPlan = testPlan.copyWith(billingCycle: 'WEEKLY');
      final dailyPlan = testPlan.copyWith(billingCycle: 'DAILY');
      final customPlan = testPlan.copyWith(billingCycle: 'CUSTOM');

      expect(monthlyPlan.billingCycleDisplay, equals('Mensuel'));
      expect(yearlyPlan.billingCycleDisplay, equals('Annuel'));
      expect(weeklyPlan.billingCycleDisplay, equals('Hebdomadaire'));
      expect(dailyPlan.billingCycleDisplay, equals('Quotidien'));
      expect(customPlan.billingCycleDisplay, equals('CUSTOM'));
    });

    test('copyWith should create a new instance with modified fields', () {
      final updatedPlan = testPlan.copyWith(
        name: 'New Name',
        priceEur: 50.0,
        isActive: false,
      );

      expect(updatedPlan.id, equals(testPlan.id)); // unchanged
      expect(updatedPlan.name, equals('New Name')); // changed
      expect(updatedPlan.priceEur, equals(50.0)); // changed
      expect(updatedPlan.priceXaf, equals(testPlan.priceXaf)); // unchanged
      expect(updatedPlan.isActive, isFalse); // changed
      expect(updatedPlan.isPopular, equals(testPlan.isPopular)); // unchanged
    });
  });
}
