// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionPlanModel _$SubscriptionPlanModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      priceXaf: const PriceConverter().fromJson(json['price_xaf']),
      priceEur: const PriceConverter().fromJson(json['price_eur']),
      priceUsd: const PriceConverter().fromJson(json['price_usd']),
      price: const PriceConverter().fromJson(json['price']),
      currency: json['currency'] as String?,
      durationMonths: const IntConverter().fromJson(json['duration_months']),
      billingCycle: const SafeStringConverter().fromJson(json['billing_cycle']),
      trialDays: json['trial_days'] == null
          ? 0
          : const IntConverter().fromJson(json['trial_days']),
      features: const SafeStringListConverter().fromJson(json['features']),
      maxProjects: json['max_projects'] == null
          ? 0
          : const IntConverter().fromJson(json['max_projects']),
      maxInvestments: json['max_investments'] == null
          ? 0
          : const IntConverter().fromJson(json['max_investments']),
      prioritySupport: json['priority_support'] as bool? ?? false,
      advancedAnalytics: json['advanced_analytics'] as bool? ?? false,
      isActive: json['is_active'] as bool,
      isPopular: json['is_popular'] as bool? ?? false,
      sortOrder: json['sort_order'] == null
          ? 0
          : const IntConverter().fromJson(json['sort_order']),
      externalPlanId: json['external_plan_id'] as String?,
      createdAt: const SafeDateTimeConverter().fromJson(json['created_at']),
      updatedAt: const SafeDateTimeConverter().fromJson(json['updated_at']),
    );

Map<String, dynamic> _$SubscriptionPlanModelToJson(
        SubscriptionPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price_xaf': const PriceConverter().toJson(instance.priceXaf),
      'price_eur': const PriceConverter().toJson(instance.priceEur),
      'price_usd': const PriceConverter().toJson(instance.priceUsd),
      'price': _$JsonConverterToJson<dynamic, double>(
          instance.price, const PriceConverter().toJson),
      'currency': instance.currency,
      'duration_months': const IntConverter().toJson(instance.durationMonths),
      'billing_cycle':
          const SafeStringConverter().toJson(instance.billingCycle),
      'trial_days': const IntConverter().toJson(instance.trialDays),
      'features': const SafeStringListConverter().toJson(instance.features),
      'max_projects': const IntConverter().toJson(instance.maxProjects),
      'max_investments': const IntConverter().toJson(instance.maxInvestments),
      'priority_support': instance.prioritySupport,
      'advanced_analytics': instance.advancedAnalytics,
      'is_active': instance.isActive,
      'is_popular': instance.isPopular,
      'sort_order': const IntConverter().toJson(instance.sortOrder),
      'external_plan_id': instance.externalPlanId,
      'created_at': const SafeDateTimeConverter().toJson(instance.createdAt),
      'updated_at': const SafeDateTimeConverter().toJson(instance.updatedAt),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
