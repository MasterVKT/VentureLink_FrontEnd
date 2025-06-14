import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:venturelink/data/models/subscription_plan_model.dart';
import 'package:venturelink/data/providers/subscription_provider.dart';
import 'package:venturelink/data/repositories/subscription_repository.dart';

@GenerateMocks([SubscriptionRepository])
import 'subscription_provider_test.mocks.dart';

void main() {
  group('SubscriptionProvider Tests', () {
    late MockSubscriptionRepository mockRepository;
    late SubscriptionProvider provider;

    setUp(() {
      mockRepository = MockSubscriptionRepository();
      provider = SubscriptionProvider(repository: mockRepository);
    });

    test('loadPlans - should update state correctly on success', () async {
      // Arrange
      final now = DateTime.now();
      final plans = [
        SubscriptionPlanModel(
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
        ),
        SubscriptionPlanModel(
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
        ),
      ];

      when(mockRepository.getSubscriptionPlans(forceRefresh: false))
          .thenAnswer((_) async => plans);

      // Initial state
      expect(provider.plans, isEmpty);
      expect(provider.isLoadingPlans, isFalse);
      expect(provider.plansError, isNull);

      // Act
      await provider.loadPlans();

      // Assert
      expect(provider.plans, equals(plans));
      expect(provider.isLoadingPlans, isFalse);
      expect(provider.plansError, isNull);
      verify(mockRepository.getSubscriptionPlans(forceRefresh: false))
          .called(1);
    });

    test('loadPlans - should update state correctly on error', () async {
      // Arrange
      when(mockRepository.getSubscriptionPlans(forceRefresh: false))
          .thenThrow(Exception('Network error'));

      // Initial state
      expect(provider.plans, isEmpty);
      expect(provider.isLoadingPlans, isFalse);
      expect(provider.plansError, isNull);

      // Act
      await provider.loadPlans();

      // Assert
      expect(provider.plans, isEmpty);
      expect(provider.isLoadingPlans, isFalse);
      expect(provider.plansError, isNotNull);
      verify(mockRepository.getSubscriptionPlans(forceRefresh: false))
          .called(1);
    });

    test('loadCurrentSubscription - should update state correctly on success',
        () async {
      // Arrange
      final now = DateTime.now();
      final plan = SubscriptionPlanModel(
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

      final subscription = SubscriptionModel(
        id: 'sub_123',
        userId: 'user_123',
        plan: plan,
        status: 'ACTIVE',
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        currency: 'XAF',
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      when(mockRepository.getCurrentSubscription(forceRefresh: false))
          .thenAnswer((_) async => subscription);

      // Initial state
      expect(provider.currentSubscription, isNull);
      expect(provider.isLoadingSubscription, isFalse);
      expect(provider.subscriptionError, isNull);

      // Act
      await provider.loadCurrentSubscription();

      // Assert
      expect(provider.currentSubscription, equals(subscription));
      expect(provider.isLoadingSubscription, isFalse);
      expect(provider.subscriptionError, isNull);
      verify(mockRepository.getCurrentSubscription(forceRefresh: false))
          .called(1);
    });

    test('loadCurrentSubscription - should handle null subscription', () async {
      // Arrange
      when(mockRepository.getCurrentSubscription(forceRefresh: false))
          .thenAnswer((_) async => null);

      // Initial state
      expect(provider.currentSubscription, isNull);
      expect(provider.isLoadingSubscription, isFalse);
      expect(provider.subscriptionError, isNull);

      // Act
      await provider.loadCurrentSubscription();

      // Assert
      expect(provider.currentSubscription, isNull);
      expect(provider.isLoadingSubscription, isFalse);
      expect(provider.subscriptionError, isNull);
      verify(mockRepository.getCurrentSubscription(forceRefresh: false))
          .called(1);
    });

    test('setSelectedCurrency - should update currency and notify listeners',
        () async {
      // Arrange
      bool listenerCalled = false;
      provider.addListener(() {
        listenerCalled = true;
      });

      // Initial state
      expect(provider.selectedCurrency, equals('XAF'));

      // Act
      provider.setSelectedCurrency('EUR');

      // Assert
      expect(provider.selectedCurrency, equals('EUR'));
      expect(listenerCalled, isTrue);
    });

    test('hasActiveSubscription - should return false when no subscription',
        () {
      // Initial state - no subscription
      expect(provider.currentSubscription, isNull);
      expect(provider.hasActiveSubscription, isFalse);
    });

    test('resetPaymentState - should notify listeners', () async {
      // Arrange
      bool listenerCalled = false;
      provider.addListener(() {
        listenerCalled = true;
      });

      // Act
      provider.resetPaymentState();

      // Assert
      expect(listenerCalled, isTrue);
    });
  });
}
