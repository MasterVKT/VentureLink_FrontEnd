// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSubscriptionModel _$UserSubscriptionModelFromJson(
        Map<String, dynamic> json) =>
    UserSubscriptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      plan: json['plan'] == null
          ? null
          : SubscriptionPlanModel.fromJson(
              json['plan'] as Map<String, dynamic>),
      status: $enumDecode(_$SubscriptionStatusEnumMap, json['status']),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      trialEndDate: json['trial_end_date'] == null
          ? null
          : DateTime.parse(json['trial_end_date'] as String),
      autoRenew: json['auto_renew'] as bool? ?? true,
      paymentMethod: json['payment_method'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastPaymentDate: json['last_payment_date'] == null
          ? null
          : DateTime.parse(json['last_payment_date'] as String),
      nextBillingDate: json['next_billing_date'] == null
          ? null
          : DateTime.parse(json['next_billing_date'] as String),
      cancellationDate: json['cancellation_date'] == null
          ? null
          : DateTime.parse(json['cancellation_date'] as String),
      cancellationReason: json['cancellation_reason'] as String?,
    );

Map<String, dynamic> _$UserSubscriptionModelToJson(
        UserSubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'plan_id': instance.planId,
      'plan': instance.plan,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'trial_end_date': instance.trialEndDate?.toIso8601String(),
      'auto_renew': instance.autoRenew,
      'payment_method': instance.paymentMethod,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_payment_date': instance.lastPaymentDate?.toIso8601String(),
      'next_billing_date': instance.nextBillingDate?.toIso8601String(),
      'cancellation_date': instance.cancellationDate?.toIso8601String(),
      'cancellation_reason': instance.cancellationReason,
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'ACTIVE',
  SubscriptionStatus.trial: 'TRIAL',
  SubscriptionStatus.pending: 'PENDING',
  SubscriptionStatus.cancelled: 'CANCELLED',
  SubscriptionStatus.expired: 'EXPIRED',
  SubscriptionStatus.pastDue: 'PAST_DUE',
  SubscriptionStatus.suspended: 'SUSPENDED',
};
