import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/data/services/payment_api_service.dart';
import 'package:venturelink/data/models/payment_method_model.dart'
    as payment_method;

void main() {
  group('PaymentApiService Tests', () {
    test('CreateSubscriptionPaymentRequest should have correct properties', () {
      final request = CreateSubscriptionPaymentRequest(
        planId: 'premium_monthly',
        currency: 'XAF',
        paymentMethod: 'mobile_money',
        phoneNumber: '237600000000',
      );

      expect(request.planId, equals('premium_monthly'));
      expect(request.currency, equals('XAF'));
      expect(request.paymentMethod, equals('mobile_money'));
      expect(request.phoneNumber, equals('237600000000'));
      expect(request.successUrl, isNull);
      expect(request.cancelUrl, isNull);

      final json = request.toJson();
      expect(json['plan_id'], equals('premium_monthly'));
      expect(json['currency'], equals('XAF'));
      expect(json['payment_method'], equals('mobile_money'));
      expect(json['phone_number'], equals('237600000000'));
    });

    test('DirectPaymentRequest should have correct properties', () {
      final request = DirectPaymentRequest(
        planId: 'premium_monthly',
        operator: 'MTN',
        phoneNumber: '237600000000',
      );

      expect(request.planId, equals('premium_monthly'));
      expect(request.operator, equals('MTN'));
      expect(request.phoneNumber, equals('237600000000'));

      final json = request.toJson();
      expect(json['plan_id'], equals('premium_monthly'));
      expect(json['operator'], equals('MTN'));
      expect(json['phone_number'], equals('237600000000'));
    });

    test('AuthorizeOTPRequest should have correct properties', () {
      final request = AuthorizeOTPRequest(
        paymentId: 'pay_123456',
        otpCode: '123456',
      );

      expect(request.paymentId, equals('pay_123456'));
      expect(request.otpCode, equals('123456'));

      final json = request.toJson();
      expect(json['payment_id'], equals('pay_123456'));
      expect(json['otp_code'], equals('123456'));
    });

    test('CreatePaymentRequest should have correct properties', () {
      final request = CreatePaymentRequest(
        amount: 30000,
        currency: 'XAF',
        description: 'Premium subscription',
        paymentType: 'SUBSCRIPTION',
      );

      expect(request.amount, equals(30000));
      expect(request.currency, equals('XAF'));
      expect(request.description, equals('Premium subscription'));
      expect(request.paymentType, equals('SUBSCRIPTION'));

      final json = request.toJson();
      expect(json['amount'], equals(30000));
      expect(json['currency'], equals('XAF'));
      expect(json['description'], equals('Premium subscription'));
      expect(json['payment_type'], equals('SUBSCRIPTION'));
    });

    test('PaymentMethodsResponse should have correct properties', () {
      final methods = [
        payment_method.PaymentMethodModel(
          id: 'mobile_money',
          name: 'Mobile Money',
          type: 'MOBILE_MONEY',
          description: 'Paiement par mobile money',
          supportedCurrencies: ['XAF', 'EUR'],
        ),
        payment_method.PaymentMethodModel(
          id: 'bank_card',
          name: 'Carte Bancaire',
          type: 'BANK_CARD',
          description: 'Paiement par carte bancaire',
          supportedCurrencies: ['XAF', 'EUR', 'USD'],
        ),
      ];

      final response = PaymentMethodsResponse(
        methods: methods,
        supportedCurrencies: ['XAF', 'EUR', 'USD'],
      );

      expect(response.methods.length, equals(2));
      expect(response.supportedCurrencies.length, equals(3));
      expect(response.methods[0].id, equals('mobile_money'));
      expect(response.methods[1].id, equals('bank_card'));

      final json = response.toJson();
      expect(json['methods'].length, equals(2));
      expect(json['supported_currencies'].length, equals(3));

      // Les objets sérialisés sont des Maps, donc nous pouvons accéder à leurs propriétés
      final methodsJson = json['methods'] as List;
      expect(methodsJson[0]['id'], equals('mobile_money'));
      expect(methodsJson[1]['id'], equals('bank_card'));
    });

    test('RefundResponse should have correct properties', () {
      final refund = RefundResponse(
        id: 'refund_123456',
        status: 'COMPLETED',
        amount: 30000,
        currency: 'XAF',
        paymentId: 'pay_123456',
        createdAt: DateTime.parse('2025-05-27T10:00:00Z'),
      );

      expect(refund.id, equals('refund_123456'));
      expect(refund.status, equals('COMPLETED'));
      expect(refund.amount, equals(30000));
      expect(refund.currency, equals('XAF'));
      expect(refund.paymentId, equals('pay_123456'));

      final json = refund.toJson();
      expect(json['id'], equals('refund_123456'));
      expect(json['status'], equals('COMPLETED'));
      expect(json['amount'], equals(30000));
      expect(json['currency'], equals('XAF'));
      expect(json['payment_id'], equals('pay_123456'));
      expect(json['created_at'], equals('2025-05-27T10:00:00.000Z'));
    });
  });
}
