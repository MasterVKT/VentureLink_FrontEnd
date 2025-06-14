import 'package:json_annotation/json_annotation.dart';

part 'currency_model.g.dart';

/// Énumération des devises supportées
@JsonEnum()
enum Currency {
  @JsonValue('EUR')
  eur,
  @JsonValue('XAF')
  xaf,
  @JsonValue('USD')
  usd,
}

/// Extensions pour manipuler les devises
extension CurrencyExtension on Currency {
  /// Obtenir le code de la devise
  String get code {
    switch (this) {
      case Currency.eur:
        return 'EUR';
      case Currency.xaf:
        return 'XAF';
      case Currency.usd:
        return 'USD';
    }
  }

  /// Obtenir le symbole de la devise
  String get symbol {
    switch (this) {
      case Currency.eur:
        return '€';
      case Currency.xaf:
        return 'FCFA';
      case Currency.usd:
        return '\$';
    }
  }

  /// Obtenir le nom complet de la devise
  String get name {
    switch (this) {
      case Currency.eur:
        return 'Euro';
      case Currency.xaf:
        return 'Franc CFA';
      case Currency.usd:
        return 'Dollar US';
    }
  }

  /// Formater un montant avec le symbole de la devise
  String format(double amount) {
    return '$symbol ${amount.toStringAsFixed(2)}';
  }

  /// Formater un montant selon la locale appropriée
  String formatLocalized(double amount) {
    switch (this) {
      case Currency.eur:
        return '${amount.toStringAsFixed(2).replaceAll('.', ',')} $symbol';
      case Currency.xaf:
        return '$symbol ${amount.toStringAsFixed(0)}';
      case Currency.usd:
        return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  /// Convertir une valeur de cette devise vers une autre devise
  /// Utilise des taux de conversion simplifiés
  double convertTo(Currency targetCurrency, double amount) {
    if (this == targetCurrency) return amount;

    // Taux de conversion simplifiés
    const Map<String, Map<String, double>> conversionRates = {
      'EUR': {
        'XAF': 655.957,
        'USD': 1.1,
      },
      'XAF': {
        'EUR': 0.00152,
        'USD': 0.00167,
      },
      'USD': {
        'EUR': 0.909,
        'XAF': 595.0,
      },
    };

    final rate = conversionRates[code]?[targetCurrency.code] ?? 1.0;
    return amount * rate;
  }

  /// Créer une instance Currency à partir d'un code de devise
  static Currency fromCode(String code) {
    switch (code.toUpperCase()) {
      case 'EUR':
        return Currency.eur;
      case 'XAF':
        return Currency.xaf;
      case 'USD':
        return Currency.usd;
      default:
        return Currency.xaf; // Valeur par défaut
    }
  }
}

/// Modèle pour les taux de change
@JsonSerializable()
class ExchangeRate {
  @JsonKey(name: 'base_currency')
  final String baseCurrency;

  @JsonKey(name: 'rates')
  final Map<String, double> rates;

  @JsonKey(name: 'timestamp')
  final DateTime timestamp;

  ExchangeRate({
    required this.baseCurrency,
    required this.rates,
    required this.timestamp,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) =>
      _$ExchangeRateFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeRateToJson(this);

  /// Convertir un montant de la devise de base vers une autre devise
  double convert(double amount, String targetCurrency) {
    if (baseCurrency == targetCurrency) return amount;
    final rate = rates[targetCurrency] ?? 1.0;
    return amount * rate;
  }
}
