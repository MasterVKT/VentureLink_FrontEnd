import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/payment_method_model.dart' hide PaymentSessionModel;
import '../models/payment_session_model.dart';

part 'payment_api_service.g.dart';

/// Service API pour les paiements avec Retrofit
@RestApi(baseUrl: "http://localhost:8000/api/v1/")
abstract class PaymentApiService {
  factory PaymentApiService(Dio dio, {String baseUrl}) = _PaymentApiService;

  /// Obtenir les méthodes de paiement disponibles
  @GET("/methods/")
  Future<PaymentMethodsResponse> getPaymentMethods();

  /// Créer un paiement d'abonnement
  @POST("/subscription/create/")
  Future<PaymentSessionModel> createSubscriptionPayment(
    @Body() CreateSubscriptionPaymentRequest request,
  );

  /// Initier un paiement direct (Mobile Money)
  @POST("/payin/")
  Future<PaymentSessionModel> initiateDirectPayment(
    @Body() DirectPaymentRequest request,
  );

  /// Autoriser un paiement avec code OTP
  @POST("/authorize/")
  Future<PaymentSessionModel> authorizePaymentOTP(
    @Body() AuthorizeOTPRequest request,
  );

  /// Vérifier le statut d'un paiement
  @GET("/{paymentId}/status/")
  Future<PaymentSessionModel> checkPaymentStatus(
    @Path("paymentId") String paymentId,
  );

  /// Obtenir l'historique des paiements
  @GET("/history/")
  Future<PaginatedResponse<PaymentHistoryModel>> getPaymentHistory();

  /// Obtenir le solde du compte (admin seulement)
  @GET("/balance/")
  Future<AccountBalanceResponse> getAccountBalance();

  /// Créer un paiement générique
  @POST("/payments/create_payment/")
  Future<PaymentSessionModel> createPayment(
    @Body() CreatePaymentRequest request,
  );

  /// Rembourser un paiement
  @POST("/payments/{paymentId}/refund/")
  Future<RefundResponse> refundPayment(
    @Path("paymentId") String paymentId,
    @Body() RefundRequest request,
  );

  /// Vérifier et mettre à jour le statut d'un paiement
  @POST("/payments/{paymentId}/check_status/")
  Future<PaymentSessionModel> updatePaymentStatus(
    @Path("paymentId") String paymentId,
  );
}

/// Modèles de requête

@JsonSerializable()
class CreateSubscriptionPaymentRequest {
  @JsonKey(name: 'plan_id')
  final String planId;
  final String currency;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'success_url')
  final String? successUrl;
  @JsonKey(name: 'cancel_url')
  final String? cancelUrl;

  CreateSubscriptionPaymentRequest({
    required this.planId,
    required this.currency,
    required this.paymentMethod,
    this.phoneNumber,
    this.successUrl,
    this.cancelUrl,
  });

  factory CreateSubscriptionPaymentRequest.fromJson(
          Map<String, dynamic> json) =>
      _$CreateSubscriptionPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() =>
      _$CreateSubscriptionPaymentRequestToJson(this);
}

@JsonSerializable()
class DirectPaymentRequest {
  @JsonKey(name: 'plan_id')
  final String planId;
  final String operator;
  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  DirectPaymentRequest({
    required this.planId,
    required this.operator,
    required this.phoneNumber,
  });

  factory DirectPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$DirectPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DirectPaymentRequestToJson(this);
}

@JsonSerializable()
class AuthorizeOTPRequest {
  @JsonKey(name: 'payment_id')
  final String paymentId;
  @JsonKey(name: 'otp_code')
  final String otpCode;

  AuthorizeOTPRequest({
    required this.paymentId,
    required this.otpCode,
  });

  factory AuthorizeOTPRequest.fromJson(Map<String, dynamic> json) =>
      _$AuthorizeOTPRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorizeOTPRequestToJson(this);
}

@JsonSerializable()
class CreatePaymentRequest {
  final double amount;
  final String currency;
  final String description;
  @JsonKey(name: 'payment_type')
  final String paymentType;
  @JsonKey(name: 'success_url')
  final String? successUrl;
  @JsonKey(name: 'cancel_url')
  final String? cancelUrl;
  @JsonKey(name: 'statement_descriptor')
  final String? statementDescriptor;
  final Map<String, dynamic>? metadata;

  CreatePaymentRequest({
    required this.amount,
    required this.currency,
    required this.description,
    this.paymentType = 'OTHER',
    this.successUrl,
    this.cancelUrl,
    this.statementDescriptor,
    this.metadata,
  });

  factory CreatePaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentRequestToJson(this);
}

@JsonSerializable()
class RefundRequest {
  final double? amount;
  final String? reason;
  final String? notes;

  RefundRequest({
    this.amount,
    this.reason,
    this.notes,
  });

  factory RefundRequest.fromJson(Map<String, dynamic> json) =>
      _$RefundRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefundRequestToJson(this);
}

/// Modèles de réponse

@JsonSerializable()
class PaymentMethodsResponse {
  final List<PaymentMethodModel> methods;
  @JsonKey(name: 'supported_currencies')
  final List<String> supportedCurrencies;

  PaymentMethodsResponse({
    required this.methods,
    required this.supportedCurrencies,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodsResponseToJson(this);
}

@JsonSerializable()
class PaymentHistoryModel {
  final String id;
  final String amount;
  final String currency;
  final String status;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final String description;

  PaymentHistoryModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
    required this.description,
  });

  factory PaymentHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentHistoryModelToJson(this);

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
}

@JsonSerializable()
class AccountBalanceResponse {
  final double balance;
  final String currency;
  @JsonKey(name: 'available_balance')
  final double availableBalance;
  @JsonKey(name: 'pending_amount')
  final double pendingAmount;
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  AccountBalanceResponse({
    required this.balance,
    required this.currency,
    required this.availableBalance,
    required this.pendingAmount,
    required this.lastUpdated,
  });

  factory AccountBalanceResponse.fromJson(Map<String, dynamic> json) =>
      _$AccountBalanceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBalanceResponseToJson(this);
}

@JsonSerializable()
class RefundResponse {
  final String id;
  final String status;
  final double amount;
  final String currency;
  @JsonKey(name: 'payment_id')
  final String paymentId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  RefundResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    required this.paymentId,
    required this.createdAt,
  });

  factory RefundResponse.fromJson(Map<String, dynamic> json) =>
      _$RefundResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefundResponseToJson(this);
}

/// Classe pour gérer les réponses paginées
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
