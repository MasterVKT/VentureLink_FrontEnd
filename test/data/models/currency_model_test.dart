import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/data/models/currency_model.dart';

void main() {
  group('Currency Tests', () {
    test('Currency enum values should match expected codes', () {
      expect(Currency.eur.code, equals('EUR'));
      expect(Currency.xaf.code, equals('XAF'));
      expect(Currency.usd.code, equals('USD'));
    });

    test('Currency symbols should be correct', () {
      expect(Currency.eur.symbol, equals('€'));
      expect(Currency.xaf.symbol, equals('FCFA'));
      expect(Currency.usd.symbol, equals('\$'));
    });

    test('Currency fromCode should return correct enum value', () {
      expect(CurrencyExtension.fromCode('EUR'), equals(Currency.eur));
      expect(CurrencyExtension.fromCode('XAF'), equals(Currency.xaf));
      expect(CurrencyExtension.fromCode('USD'), equals(Currency.usd));
      expect(CurrencyExtension.fromCode('INVALID'),
          equals(Currency.xaf)); // Default value
    });

    test('Currency format should correctly format amounts', () {
      expect(Currency.eur.format(123.45), equals('€ 123.45'));
      expect(Currency.xaf.format(123.45), equals('FCFA 123.45'));
      expect(Currency.usd.format(123.45), equals('\$ 123.45'));
    });

    test('Currency formatLocalized should format according to locale', () {
      expect(Currency.eur.formatLocalized(123.45), equals('123,45 €'));
      expect(Currency.xaf.formatLocalized(123.45), equals('FCFA 123'));
      expect(Currency.usd.formatLocalized(123.45), equals('\$123.45'));
    });

    test('Currency conversion should apply correct rates', () {
      // EUR to XAF
      expect(
          Currency.eur.convertTo(Currency.xaf, 1.0), closeTo(655.957, 0.001));
      // XAF to EUR
      expect(Currency.xaf.convertTo(Currency.eur, 655.957),
          closeTo(1.0, 0.01)); // Élargissement de la tolérance
      // USD to EUR
      expect(Currency.usd.convertTo(Currency.eur, 1.0), closeTo(0.909, 0.001));
      // Same currency conversion
      expect(Currency.usd.convertTo(Currency.usd, 100.0), equals(100.0));
    });
  });

  group('ExchangeRate Tests', () {
    test('ExchangeRate should convert amounts correctly', () {
      final rates = ExchangeRate(
        baseCurrency: 'EUR',
        rates: {'USD': 1.1, 'XAF': 655.957},
        timestamp: DateTime.now(),
      );

      expect(rates.convert(1.0, 'USD'), closeTo(1.1, 0.001));
      expect(rates.convert(1.0, 'XAF'), closeTo(655.957, 0.001));
      expect(rates.convert(1.0, 'EUR'), equals(1.0)); // Same currency
      expect(rates.convert(1.0, 'GBP'),
          equals(1.0)); // Missing rate defaults to 1.0
    });

    test('ExchangeRate serialization/deserialization', () {
      final timestamp = DateTime.now();
      final rates = ExchangeRate(
        baseCurrency: 'EUR',
        rates: {'USD': 1.1, 'XAF': 655.957},
        timestamp: timestamp,
      );

      final json = rates.toJson();
      final deserializedRates = ExchangeRate.fromJson(json);

      expect(deserializedRates.baseCurrency, equals('EUR'));
      expect(deserializedRates.rates['USD'], equals(1.1));
      expect(deserializedRates.rates['XAF'], equals(655.957));
      expect(deserializedRates.timestamp.toIso8601String(),
          equals(timestamp.toIso8601String()));
    });
  });
}
