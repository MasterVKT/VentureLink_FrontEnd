import 'package:json_annotation/json_annotation.dart';

part 'subscription_plan_model.g.dart';

/// Modèle pour les plans d'abonnement selon le guide d'harmonisation
@JsonSerializable()
class SubscriptionPlanModel {
  final String id;
  final String name;
  final String? description;

  @JsonKey(name: 'price_xaf')
  final double priceXaf;
  @JsonKey(name: 'price_eur')
  final double priceEur;
  @JsonKey(name: 'price_usd')
  final double priceUsd;

  final double price;
  final String currency;
  @JsonKey(name: 'duration_months')
  final int durationMonths;

  @JsonKey(name: 'billing_cycle')
  final String billingCycle;
  @JsonKey(name: 'trial_days')
  final int trialDays;
  final List<String> features;
  @JsonKey(name: 'max_projects')
  final int maxProjects;
  @JsonKey(name: 'max_investments')
  final int maxInvestments;
  @JsonKey(name: 'priority_support')
  final bool prioritySupport;
  @JsonKey(name: 'advanced_analytics')
  final bool advancedAnalytics;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_popular')
  final bool isPopular;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'external_plan_id')
  final String? externalPlanId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    this.description,
    required this.priceXaf,
    required this.priceEur,
    required this.priceUsd,
    required this.price,
    required this.currency,
    required this.durationMonths,
    required this.billingCycle,
    this.trialDays = 0,
    required this.features,
    this.maxProjects = 0,
    this.maxInvestments = 0,
    this.prioritySupport = false,
    this.advancedAnalytics = false,
    required this.isActive,
    this.isPopular = false,
    this.sortOrder = 0,
    this.externalPlanId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionPlanModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionPlanModelToJson(this);

  double getPriceInCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'XAF':
        return priceXaf;
      case 'EUR':
        return priceEur;
      case 'USD':
        return priceUsd;
      default:
        return priceXaf;
    }
  }

  String getFormattedPrice(String currencyCode) {
    final price = getPriceInCurrency(currencyCode);
    switch (currencyCode.toUpperCase()) {
      case 'XAF':
        return '${price.toStringAsFixed(0)} FCFA';
      case 'EUR':
        return '${price.toStringAsFixed(2)} €';
      case 'USD':
        return '\$${price.toStringAsFixed(2)}';
      default:
        return '${price.toStringAsFixed(0)} FCFA';
    }
  }

  String get billingCycleDisplay {
    switch (billingCycle) {
      case 'MONTHLY':
        return 'Mensuel';
      case 'YEARLY':
        return 'Annuel';
      case 'WEEKLY':
        return 'Hebdomadaire';
      case 'DAILY':
        return 'Quotidien';
      default:
        return billingCycle;
    }
  }

  SubscriptionPlanModel copyWith({
    String? id,
    String? name,
    String? description,
    double? priceXaf,
    double? priceEur,
    double? priceUsd,
    double? price,
    String? currency,
    int? durationMonths,
    String? billingCycle,
    int? trialDays,
    List<String>? features,
    int? maxProjects,
    int? maxInvestments,
    bool? prioritySupport,
    bool? advancedAnalytics,
    bool? isActive,
    bool? isPopular,
    int? sortOrder,
    String? externalPlanId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SubscriptionPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      priceXaf: priceXaf ?? this.priceXaf,
      priceEur: priceEur ?? this.priceEur,
      priceUsd: priceUsd ?? this.priceUsd,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      durationMonths: durationMonths ?? this.durationMonths,
      billingCycle: billingCycle ?? this.billingCycle,
      trialDays: trialDays ?? this.trialDays,
      features: features ?? this.features,
      maxProjects: maxProjects ?? this.maxProjects,
      maxInvestments: maxInvestments ?? this.maxInvestments,
      prioritySupport: prioritySupport ?? this.prioritySupport,
      advancedAnalytics: advancedAnalytics ?? this.advancedAnalytics,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      sortOrder: sortOrder ?? this.sortOrder,
      externalPlanId: externalPlanId ?? this.externalPlanId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionPlanModel plan;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final bool autoRenew;
  final String currency;
  final String? lastPaymentId;
  final String? externalSubscriptionId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    required this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.autoRenew = true,
    required this.currency,
    this.lastPaymentId,
    this.externalSubscriptionId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'].toString(),
      userId:
          json['user_id']?.toString() ?? json['user_email']?.toString() ?? '',
      plan: SubscriptionPlanModel.fromJson(json['plan']),
      status: json['status'] ?? 'PENDING',
      startDate: DateTime.parse(json['start_date']),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      nextBillingDate: json['next_billing_date'] != null
          ? DateTime.parse(json['next_billing_date'])
          : null,
      autoRenew: json['auto_renew'] ?? true,
      currency: json['currency'] ?? 'XAF',
      lastPaymentId: json['last_payment']?.toString(),
      externalSubscriptionId: json['external_subscription_id'],
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan': plan.toJson(),
      'status': status,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'next_billing_date': nextBillingDate?.toIso8601String(),
      'auto_renew': autoRenew,
      'currency': currency,
      'last_payment': lastPaymentId,
      'external_subscription_id': externalSubscriptionId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isExpired => endDate != null && DateTime.now().isAfter(endDate!);

  int get daysRemaining {
    if (endDate == null) return -1;
    final now = DateTime.now();
    if (now.isAfter(endDate!)) return 0;
    return endDate!.difference(now).inDays;
  }

  String get statusDisplay {
    switch (status) {
      case 'COMPLETED':
        return 'Actif';
      case 'PENDING':
        return 'En attente';
      case 'FAILED':
        return 'Échec';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }
}
