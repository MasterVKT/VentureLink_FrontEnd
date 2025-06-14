import 'package:json_annotation/json_annotation.dart';

part 'payment_session_model.g.dart';

/// Modèle pour les sessions de paiement My-CoolPay selon le guide d'harmonisation
@JsonSerializable()
class PaymentSessionModel {
  final String id;
  @JsonKey(name: 'payment_url')
  final String? paymentUrl;
  @JsonKey(name: 'checkout_url')
  final String? checkoutUrl;
  @JsonKey(name: 'success_url')
  final String? successUrl;
  @JsonKey(name: 'cancel_url')
  final String? cancelUrl;
  final PaymentStatus status;
  final String amount;
  final String currency;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  @JsonKey(name: 'merchant_reference')
  final String? merchantReference;
  @JsonKey(name: 'otp_required')
  final bool otpRequired;
  @JsonKey(name: 'otp_code')
  final String? otpCode;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'error_message')
  final String? errorMessage;
  @JsonKey(name: 'provider_response')
  final Map<String, dynamic>? providerResponse;

  PaymentSessionModel({
    required this.id,
    this.paymentUrl,
    this.checkoutUrl,
    this.successUrl,
    this.cancelUrl,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.phoneNumber,
    this.transactionId,
    this.merchantReference,
    this.otpRequired = false,
    this.otpCode,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.errorMessage,
    this.providerResponse,
  });

  factory PaymentSessionModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentSessionModelToJson(this);

  /// Getters utilitaires
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get isPending => status == PaymentStatus.pending;
  bool get isCompleted => status == PaymentStatus.completed;
  bool get isFailed => status == PaymentStatus.failed;
  bool get isCancelled => status == PaymentStatus.cancelled;
  bool get isProcessing => status == PaymentStatus.processing;

  String get statusDisplay {
    switch (status) {
      case PaymentStatus.pending:
        return 'En attente';
      case PaymentStatus.processing:
        return 'En cours';
      case PaymentStatus.awaitingOtp:
        return 'En attente OTP';
      case PaymentStatus.completed:
        return 'Terminé';
      case PaymentStatus.failed:
        return 'Échec';
      case PaymentStatus.cancelled:
        return 'Annulé';
      case PaymentStatus.expired:
        return 'Expiré';
      case PaymentStatus.refunded:
        return 'Remboursé';
    }
  }

  String get formattedAmount {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '$amount €';
      case 'XAF':
        return '$amount FCFA';
      case 'USD':
        return '\$$amount';
      default:
        return '$amount $currency';
    }
  }

  bool get canRetry {
    return isFailed || (isExpired && !isCompleted);
  }

  bool get needsOtp {
    return status == PaymentStatus.awaitingOtp && otpRequired;
  }

  String get displayUrl {
    return paymentUrl ?? checkoutUrl ?? '';
  }
}

/// Énumération des statuts de paiement My-CoolPay
enum PaymentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('AWAITING_OTP')
  awaitingOtp,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('FAILED')
  failed,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('REFUNDED')
  refunded,
}

/// Extension pour conversion des statuts de paiement
extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.processing:
        return 'PROCESSING';
      case PaymentStatus.awaitingOtp:
        return 'AWAITING_OTP';
      case PaymentStatus.completed:
        return 'COMPLETED';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.cancelled:
        return 'CANCELLED';
      case PaymentStatus.expired:
        return 'EXPIRED';
      case PaymentStatus.refunded:
        return 'REFUNDED';
    }
  }

  static PaymentStatus fromString(String value) {
    switch (value) {
      case 'PENDING':
        return PaymentStatus.pending;
      case 'PROCESSING':
        return PaymentStatus.processing;
      case 'AWAITING_OTP':
        return PaymentStatus.awaitingOtp;
      case 'COMPLETED':
        return PaymentStatus.completed;
      case 'FAILED':
        return PaymentStatus.failed;
      case 'CANCELLED':
        return PaymentStatus.cancelled;
      case 'EXPIRED':
        return PaymentStatus.expired;
      case 'REFUNDED':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  bool get isFinalized {
    return this == PaymentStatus.completed ||
        this == PaymentStatus.failed ||
        this == PaymentStatus.cancelled ||
        this == PaymentStatus.expired ||
        this == PaymentStatus.refunded;
  }

  bool get isSuccess {
    return this == PaymentStatus.completed;
  }

  bool get isError {
    return this == PaymentStatus.failed ||
        this == PaymentStatus.cancelled ||
        this == PaymentStatus.expired;
  }
}
