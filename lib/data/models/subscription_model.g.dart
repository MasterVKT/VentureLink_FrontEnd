// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    SubscriptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      plan: json['plan'] as String,
      status: json['status'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      billingCycle: json['billing_cycle'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      trialEndDate: json['trial_end_date'] == null
          ? null
          : DateTime.parse(json['trial_end_date'] as String),
      autoRenew: json['auto_renew'] as bool? ?? true,
      paymentMethod: json['payment_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$SubscriptionModelToJson(SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'plan': instance.plan,
      'status': instance.status,
      'price': instance.price,
      'currency': instance.currency,
      'billing_cycle': instance.billingCycle,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'trial_end_date': instance.trialEndDate?.toIso8601String(),
      'auto_renew': instance.autoRenew,
      'payment_method': instance.paymentMethod,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

SubscriptionPlanModel _$SubscriptionPlanModelFromJson(
        Map<String, dynamic> json) =>
    SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      billingCycle: json['billing_cycle'] as String,
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      trialDays: (json['trial_days'] as num?)?.toInt(),
      isPopular: json['is_popular'] as bool? ?? false,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      active: json['active'] as bool? ?? true,
    );

Map<String, dynamic> _$SubscriptionPlanModelToJson(
        SubscriptionPlanModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'currency': instance.currency,
      'billing_cycle': instance.billingCycle,
      'features': instance.features,
      'trial_days': instance.trialDays,
      'is_popular': instance.isPopular,
      'discount_percentage': instance.discountPercentage,
      'active': instance.active,
    };

PaymentSessionModel _$PaymentSessionModelFromJson(Map<String, dynamic> json) =>
    PaymentSessionModel(
      id: json['id'] as String,
      checkoutUrl: json['checkout_url'] as String,
      successUrl: json['success_url'] as String,
      cancelUrl: json['cancel_url'] as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$PaymentSessionModelToJson(
        PaymentSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'checkout_url': instance.checkoutUrl,
      'success_url': instance.successUrl,
      'cancel_url': instance.cancelUrl,
      'status': instance.status,
      'expires_at': instance.expiresAt.toIso8601String(),
    };
