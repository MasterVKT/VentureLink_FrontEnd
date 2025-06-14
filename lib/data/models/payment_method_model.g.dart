// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      operator: json['operator'] as String?,
      description: json['description'] as String,
      isActive: json['is_active'] as bool? ?? true,
      supportedCurrencies: (json['supported_currencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      feePercentage: (json['fee_percentage'] as num?)?.toDouble() ?? 0.0,
      feeFixed: (json['fee_fixed'] as num?)?.toDouble() ?? 0.0,
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0.0,
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? 999999999.0,
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'operator': instance.operator,
      'description': instance.description,
      'is_active': instance.isActive,
      'supported_currencies': instance.supportedCurrencies,
      'fee_percentage': instance.feePercentage,
      'fee_fixed': instance.feeFixed,
      'min_amount': instance.minAmount,
      'max_amount': instance.maxAmount,
    };
