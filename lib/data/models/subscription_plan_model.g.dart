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
      priceXaf: (json['price_xaf'] as num).toDouble(),
      priceEur: (json['price_eur'] as num).toDouble(),
      priceUsd: (json['price_usd'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      durationMonths: (json['duration_months'] as num).toInt(),
      billingCycle: json['billing_cycle'] as String,
      trialDays: (json['trial_days'] as num?)?.toInt() ?? 0,
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      maxProjects: (json['max_projects'] as num?)?.toInt() ?? 0,
      maxInvestments: (json['max_investments'] as num?)?.toInt() ?? 0,
      prioritySupport: json['priority_support'] as bool? ?? false,
      advancedAnalytics: json['advanced_analytics'] as bool? ?? false,
      isActive: json['is_active'] as bool,
      isPopular: json['is_popular'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      externalPlanId: json['external_plan_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SubscriptionPlanModelToJson(
        SubscriptionPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price_xaf': instance.priceXaf,
      'price_eur': instance.priceEur,
      'price_usd': instance.priceUsd,
      'price': instance.price,
      'currency': instance.currency,
      'duration_months': instance.durationMonths,
      'billing_cycle': instance.billingCycle,
      'trial_days': instance.trialDays,
      'features': instance.features,
      'max_projects': instance.maxProjects,
      'max_investments': instance.maxInvestments,
      'priority_support': instance.prioritySupport,
      'advanced_analytics': instance.advancedAnalytics,
      'is_active': instance.isActive,
      'is_popular': instance.isPopular,
      'sort_order': instance.sortOrder,
      'external_plan_id': instance.externalPlanId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
