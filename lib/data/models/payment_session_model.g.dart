// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentSessionModel _$PaymentSessionModelFromJson(Map<String, dynamic> json) =>
    PaymentSessionModel(
      id: json['id'] as String,
      paymentUrl: json['payment_url'] as String?,
      checkoutUrl: json['checkout_url'] as String?,
      successUrl: json['success_url'] as String?,
      cancelUrl: json['cancel_url'] as String?,
      status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String,
      phoneNumber: json['phone_number'] as String?,
      transactionId: json['transaction_id'] as String?,
      merchantReference: json['merchant_reference'] as String?,
      otpRequired: json['otp_required'] as bool? ?? false,
      otpCode: json['otp_code'] as String?,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      errorMessage: json['error_message'] as String?,
      providerResponse: json['provider_response'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$PaymentSessionModelToJson(
        PaymentSessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payment_url': instance.paymentUrl,
      'checkout_url': instance.checkoutUrl,
      'success_url': instance.successUrl,
      'cancel_url': instance.cancelUrl,
      'status': _$PaymentStatusEnumMap[instance.status]!,
      'amount': instance.amount,
      'currency': instance.currency,
      'payment_method': instance.paymentMethod,
      'phone_number': instance.phoneNumber,
      'transaction_id': instance.transactionId,
      'merchant_reference': instance.merchantReference,
      'otp_required': instance.otpRequired,
      'otp_code': instance.otpCode,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'error_message': instance.errorMessage,
      'provider_response': instance.providerResponse,
    };

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'PENDING',
  PaymentStatus.processing: 'PROCESSING',
  PaymentStatus.awaitingOtp: 'AWAITING_OTP',
  PaymentStatus.completed: 'COMPLETED',
  PaymentStatus.failed: 'FAILED',
  PaymentStatus.cancelled: 'CANCELLED',
  PaymentStatus.expired: 'EXPIRED',
  PaymentStatus.refunded: 'REFUNDED',
};
