import 'package:json_annotation/json_annotation.dart';

part 'subscription_model.g.dart';

@JsonSerializable()
class SubscriptionModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String plan;
  final String status;
  final double price;
  final String currency;
  @JsonKey(name: 'billing_cycle')
  final String billingCycle;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @JsonKey(name: 'trial_end_date')
  final DateTime? trialEndDate;
  @JsonKey(name: 'auto_renew')
  final bool autoRenew;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.price,
    this.currency = 'EUR',
    required this.billingCycle,
    required this.startDate,
    this.endDate,
    this.trialEndDate,
    this.autoRenew = true,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionModelToJson(this);

  // Getters utilitaires
  bool get isActive => status == 'ACTIVE';
  bool get isTrial => status == 'TRIAL';
  bool get isExpired => status == 'EXPIRED';
  bool get isCancelled => status == 'CANCELLED';

  bool get isMonthly => billingCycle == 'MONTHLY';
  bool get isYearly => billingCycle == 'YEARLY';

  bool get isInTrial =>
      trialEndDate != null && DateTime.now().isBefore(trialEndDate!);

  String get planDisplayName {
    switch (plan) {
      case 'FREE':
        return 'Gratuit';
      case 'PREMIUM_MONTHLY':
        return 'Premium Mensuel';
      case 'PREMIUM_YEARLY':
        return 'Premium Annuel';
      default:
        return plan;
    }
  }

  int get daysUntilExpiry {
    if (endDate == null) return 0;
    return endDate!.difference(DateTime.now()).inDays;
  }

  double get monthlyEquivalent {
    if (isMonthly) return price;
    return price / 12; // Pour l'annuel
  }
}

@JsonSerializable()
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  @JsonKey(name: 'billing_cycle')
  final String billingCycle;
  final List<String> features;
  @JsonKey(name: 'trial_days')
  final int? trialDays;
  @JsonKey(name: 'is_popular')
  final bool isPopular;
  @JsonKey(name: 'discount_percentage')
  final double? discountPercentage;
  final bool active;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.currency = 'EUR',
    required this.billingCycle,
    this.features = const [],
    this.trialDays,
    this.isPopular = false,
    this.discountPercentage,
    this.active = true,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanModelToJson(this);

  double get discountedPrice {
    if (discountPercentage == null) return price;
    return price * (1 - discountPercentage! / 100);
  }

  String get formattedPrice {
    return '${discountedPrice.toStringAsFixed(2)} €';
  }

  String get billingCycleText {
    switch (billingCycle) {
      case 'MONTHLY':
        return 'par mois';
      case 'YEARLY':
        return 'par an';
      default:
        return billingCycle.toLowerCase();
    }
  }
}

@JsonSerializable()
class PaymentSessionModel {
  final String id;
  @JsonKey(name: 'checkout_url')
  final String checkoutUrl;
  @JsonKey(name: 'success_url')
  final String successUrl;
  @JsonKey(name: 'cancel_url')
  final String cancelUrl;
  final String status;
  @JsonKey(name: 'expires_at')
  final DateTime expiresAt;

  PaymentSessionModel({
    required this.id,
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
    required this.status,
    required this.expiresAt,
  });

  factory PaymentSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSessionModelToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
