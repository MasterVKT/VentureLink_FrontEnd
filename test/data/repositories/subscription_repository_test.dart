import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:venturelink/data/models/subscription_plan_model.dart';
import 'package:venturelink/data/models/payment_session_model.dart';
import 'package:venturelink/data/services/subscription_api_service.dart';
import 'package:venturelink/data/services/payment_api_service.dart';
import 'package:venturelink/data/repositories/subscription_repository.dart';

@GenerateMocks([
  SubscriptionApiService,
  PaymentApiService,
  SharedPreferences,
])
import 'subscription_repository_test.mocks.dart';

void main() {
  group('SubscriptionRepository Tests', () {
    late MockSubscriptionApiService mockSubscriptionService;
    late MockPaymentApiService mockPaymentService;
    late MockSharedPreferences mockPrefs;
    late SubscriptionRepository repository;

    setUp(() {
      mockSubscriptionService = MockSubscriptionApiService();
      mockPaymentService = MockPaymentApiService();
      mockPrefs = MockSharedPreferences();
      repository = SubscriptionRepository(
        subscriptionService: mockSubscriptionService,
        paymentService: mockPaymentService,
        prefs: mockPrefs,
      );
    });

    test('getSubscriptionPlans - should return plans from service', () async {
      // Arrange
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

      final response = PlanResponse(
        plans: [plan1, plan2],
        totalCount: 2,
      );

      when(mockSubscriptionService.getSubscriptionPlans())
          .thenAnswer((_) async => response);

      // Act
      final result = await repository.getSubscriptionPlans();

      // Assert
      expect(result.length, equals(2));
      expect(result[0].id, equals('free'));
      expect(result[1].id, equals('premium_monthly'));
      verify(mockSubscriptionService.getSubscriptionPlans()).called(1);
      verify(mockPrefs.setString(any, any)).called(1); // Cache update
    });

    test('getSubscriptionPlans - should return cached plans on network error',
        () async {
      // Arrange
      when(mockSubscriptionService.getSubscriptionPlans()).thenThrow(
          DioException(
              requestOptions: RequestOptions(),
              type: DioExceptionType.connectionError));

      when(mockPrefs.getString(any)).thenReturn('[]'); // Empty cache

      // Act
      final result = await repository.getSubscriptionPlans();

      // Assert
      expect(result, isEmpty);
      verify(mockSubscriptionService.getSubscriptionPlans()).called(1);
      verify(mockPrefs.getString(any)).called(1);
    });

    test('getCurrentSubscription - should return subscription from service',
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

      when(mockSubscriptionService.getCurrentSubscription())
          .thenAnswer((_) async => subscription);

      // Act
      final result = await repository.getCurrentSubscription();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('sub_123'));
      expect(result.plan.id, equals('premium_monthly'));
      verify(mockSubscriptionService.getCurrentSubscription()).called(1);
    });

    test('getCurrentSubscription - should return null when 404 response',
        () async {
      // Arrange
      when(mockSubscriptionService.getCurrentSubscription())
          .thenThrow(DioException(
              requestOptions: RequestOptions(),
              response: Response(
                statusCode: 404,
                requestOptions: RequestOptions(),
              )));

      // Act
      final result = await repository.getCurrentSubscription();

      // Assert
      expect(result, isNull);
      verify(mockSubscriptionService.getCurrentSubscription()).called(1);
      verify(mockPrefs.remove(any)).called(1); // Cache invalidation
    });

    test('createSubscriptionPayment - should create payment session', () async {
      // Arrange
      final mockPaymentSession = PaymentSessionModel(
        id: 'pay_123',
        amount: '30000',
        currency: 'XAF',
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        paymentMethod: 'mobile_money',
        updatedAt: DateTime.now(),
      );

      when(mockPaymentService.createSubscriptionPayment(any))
          .thenAnswer((_) async => mockPaymentSession);

      // Act
      final result = await repository.createSubscriptionPayment(
        planId: 'premium_monthly',
        currency: 'XAF',
        paymentMethod: 'mobile_money',
        phoneNumber: '237600000000',
      );

      // Assert
      expect(result.id, equals('pay_123'));
      expect(result.status, equals(PaymentStatus.pending));
      verify(mockPaymentService.createSubscriptionPayment(any)).called(1);
    });

    test('checkPaymentStatus - should return payment status', () async {
      // Arrange
      final mockPaymentSession = PaymentSessionModel(
        id: 'pay_123',
        amount: '30000',
        currency: 'XAF',
        status: PaymentStatus.completed,
        createdAt: DateTime.now(),
        paymentMethod: 'mobile_money',
        updatedAt: DateTime.now(),
      );

      when(mockPaymentService.checkPaymentStatus('pay_123'))
          .thenAnswer((_) async => mockPaymentSession);

      // Act
      final result = await repository.checkPaymentStatus('pay_123');

      // Assert
      expect(result.id, equals('pay_123'));
      expect(result.status, equals(PaymentStatus.completed));
      verify(mockPaymentService.checkPaymentStatus('pay_123')).called(1);
    });

    test(
        'cancelSubscription - should call service and update cache if immediate',
        () async {
      // Arrange
      final now = DateTime.now();
      final response = CancelSubscriptionResponse(
        id: 'sub_123',
        status: 'CANCELLED',
        cancellationDate: now,
        endDate: now.add(const Duration(days: 30)),
        message:
            'Votre abonnement sera actif jusqu\'au terme de la période payée',
      );

      when(mockSubscriptionService.cancelSubscription(any, any))
          .thenAnswer((_) async => response);

      // Act
      final result = await repository.cancelSubscription(
        subscriptionId: 'sub_123',
        cancelImmediately: true,
      );

      // Assert
      expect(result.id, equals('sub_123'));
      expect(result.status, equals('CANCELLED'));
      verify(mockSubscriptionService.cancelSubscription(any, any)).called(1);
      verify(mockPrefs.remove(any)).called(1); // Cache invalidation
    });
  });
}
