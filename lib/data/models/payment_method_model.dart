import 'package:json_annotation/json_annotation.dart';
import 'currency_model.dart';

part 'payment_method_model.g.dart';

/// Modèle pour les méthodes de paiement My-CoolPay
@JsonSerializable()
class PaymentMethodModel {
  final String id;
  final String name;
  final String type;
  final String? operator;
  final String description;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'supported_currencies')
  final List<String> supportedCurrencies;
  @JsonKey(name: 'fee_percentage')
  final double feePercentage;
  @JsonKey(name: 'fee_fixed')
  final double feeFixed;
  @JsonKey(name: 'min_amount')
  final double minAmount;
  @JsonKey(name: 'max_amount')
  final double maxAmount;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    this.operator,
    required this.description,
    this.isActive = true,
    required this.supportedCurrencies,
    this.feePercentage = 0.0,
    this.feeFixed = 0.0,
    this.minAmount = 0.0,
    this.maxAmount = 999999999.0,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);

  /// Calculer les frais pour un montant donné
  double calculateFees(double amount) {
    final percentageFee = amount * (feePercentage / 100);
    return percentageFee + feeFixed;
  }

  /// Vérifier si le montant est valide
  bool isAmountValid(double amount) {
    return amount >= minAmount && amount <= maxAmount;
  }

  /// Obtenir l'icône selon le type
  String get iconPath {
    switch (type.toUpperCase()) {
      case 'MOBILE_MONEY':
        switch (operator?.toUpperCase()) {
          case 'ORANGE':
            return 'assets/icons/orange_money.png';
          case 'MTN':
            return 'assets/icons/mtn_momo.png';
          case 'MOOV':
            return 'assets/icons/moov_money.png';
          case 'EXPRESSU':
            return 'assets/icons/express_union.png';
          default:
            return 'assets/icons/mobile_money.png';
        }
      case 'BANK_CARD':
        return 'assets/icons/bank_card.png';
      case 'BANK_TRANSFER':
        return 'assets/icons/bank_transfer.png';
      case 'CASH':
        return 'assets/icons/cash.png';
      default:
        return 'assets/icons/payment_default.png';
    }
  }

  /// Obtenir la couleur selon l'opérateur
  String get colorHex {
    switch (operator?.toUpperCase()) {
      case 'ORANGE':
        return '#FF6600';
      case 'MTN':
        return '#FFCC00';
      case 'MOOV':
        return '#0066CC';
      case 'EXPRESSU':
        return '#008000';
      default:
        return '#6B7280';
    }
  }

  /// Formater l'affichage
  String get displayName {
    if (operator != null) {
      return '$name ($operator)';
    }
    return name;
  }

  /// Obtenir le code opérateur My-CoolPay
  String get operatorCode {
    switch (operator?.toUpperCase()) {
      case 'ORANGE':
        return 'CM_OM';
      case 'MTN':
        return 'CM_MOMO';
      case 'MOOV':
        return 'MOOV';
      case 'EXPRESSU':
        return 'EXPRESSU';
      default:
        return id;
    }
  }

  /// Vérifier si la devise est supportée
  bool supportsCurrency(Currency currency) {
    return supportedCurrencies.contains(currency.code);
  }

  bool get isMobileMoney => type.toUpperCase() == 'MOBILE_MONEY';
  bool get isBankCard => type.toUpperCase() == 'BANK_CARD';
  bool get isPaylink => id.toUpperCase() == 'PAYLINK';
}

/// Énumération des types de méthodes de paiement
enum PaymentMethodType {
  @JsonValue('MOBILE_MONEY')
  mobileMoney,
  @JsonValue('BANK_CARD')
  bankCard,
  @JsonValue('BANK_TRANSFER')
  bankTransfer,
  @JsonValue('CASH')
  cash,
  @JsonValue('PAYLINK')
  paylink,
  @JsonValue('OTHER')
  other,
}

/// Extension pour les types de méthodes de paiement
extension PaymentMethodTypeExtension on PaymentMethodType {
  String get value {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return 'MOBILE_MONEY';
      case PaymentMethodType.bankCard:
        return 'BANK_CARD';
      case PaymentMethodType.bankTransfer:
        return 'BANK_TRANSFER';
      case PaymentMethodType.cash:
        return 'CASH';
      case PaymentMethodType.paylink:
        return 'PAYLINK';
      case PaymentMethodType.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return 'Mobile Money';
      case PaymentMethodType.bankCard:
        return 'Carte Bancaire';
      case PaymentMethodType.bankTransfer:
        return 'Virement Bancaire';
      case PaymentMethodType.cash:
        return 'Espèces';
      case PaymentMethodType.paylink:
        return 'Lien de Paiement';
      case PaymentMethodType.other:
        return 'Autre';
    }
  }

  String get iconPath {
    switch (this) {
      case PaymentMethodType.mobileMoney:
        return 'assets/icons/mobile_money.png';
      case PaymentMethodType.bankCard:
        return 'assets/icons/bank_card.png';
      case PaymentMethodType.bankTransfer:
        return 'assets/icons/bank_transfer.png';
      case PaymentMethodType.cash:
        return 'assets/icons/cash.png';
      case PaymentMethodType.paylink:
        return 'assets/icons/paylink.png';
      case PaymentMethodType.other:
        return 'assets/icons/payment_default.png';
    }
  }
}

/// Modèle pour les sessions de paiement
class PaymentSessionModel {
  final String id;
  final String planId;
  final double amount;
  final String currency;
  final String status;
  final String? paymentUrl;
  final String? transactionRef;
  final DateTime createdAt;
  final DateTime? expiresAt;

  PaymentSessionModel({
    required this.id,
    required this.planId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentUrl,
    this.transactionRef,
    required this.createdAt,
    this.expiresAt,
  });

  factory PaymentSessionModel.fromJson(Map<String, dynamic> json) {
    return PaymentSessionModel(
      id: json['id']?.toString() ?? json['payment_id']?.toString() ?? '',
      planId: json['plan_id']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XAF',
      status: json['status'] ?? 'PENDING',
      paymentUrl: json['payment_url'] ?? json['checkout_url'],
      transactionRef: json['transaction_ref'] ?? json['external_reference'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_id': planId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_url': paymentUrl,
      'transaction_ref': transactionRef,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isFailed => status.toUpperCase() == 'FAILED';
}
