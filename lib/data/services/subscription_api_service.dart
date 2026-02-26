import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';
import '../models/subscription_plan_model.dart';
import '../models/payment_session_model.dart';

part 'subscription_api_service.g.dart';

/// Service API pour les abonnements avec Retrofit
@RestApi(baseUrl: "http://localhost:8000/api/v1/")
abstract class SubscriptionApiService {
  factory SubscriptionApiService(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) =
      _SubscriptionApiService;

  /// Obtenir tous les plans d'abonnement disponibles
  @GET("/payments/plans/")
  Future<PlanResponse> getSubscriptionPlans();

  /// Obtenir les détails d'un plan d'abonnement spécifique
  @GET("/payments/plans/{planId}/")
  Future<SubscriptionPlanModel> getSubscriptionPlanDetails(
    @Path("planId") String planId,
  );

  /// Créer une nouvelle souscription
  @POST("/payments/subscription/")
  Future<SubscriptionModel> createSubscription(
    @Body() CreateSubscriptionRequest request,
  );

  /// Obtenir les détails de l'abonnement actuel de l'utilisateur
  @GET("/payments/subscription/current/")
  Future<SubscriptionModel> getCurrentSubscription();

  /// Annuler un abonnement
  @POST("/payments/subscription/{subscriptionId}/cancel/")
  Future<CancelSubscriptionResponse> cancelSubscription(
    @Path("subscriptionId") String subscriptionId,
    @Body() CancelSubscriptionRequest request,
  );

  /// Mettre à jour un abonnement
  @PUT("/payments/subscription/{subscriptionId}/")
  Future<SubscriptionModel> updateSubscription(
    @Path("subscriptionId") String subscriptionId,
    @Body() UpdateSubscriptionRequest request,
  );

  /// Obtenir l'historique des abonnements de l'utilisateur
  @GET("/payments/subscription/history/")
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptionHistory();

  /// Réactiver un abonnement annulé
  @POST("/payments/subscription/{subscriptionId}/reactivate/")
  Future<SubscriptionModel> reactivateSubscription(
    @Path("subscriptionId") String subscriptionId,
  );

  /// Changer de plan d'abonnement
  @POST("/payments/subscription/{subscriptionId}/change-plan/")
  Future<SubscriptionModel> changePlan(
    @Path("subscriptionId") String subscriptionId,
    @Body() ChangePlanRequest request,
  );

  /// Obtenir l'historique des paiements
  @GET("/payments/history/")
  Future<PaginatedResponse<PaymentHistoryModel>> getPaymentHistory();

  /// Créer une session de paiement My-CoolPay
  @POST("/payments/session/")
  Future<PaymentSessionModel> createPaymentSession(
    @Body() CreatePaymentSessionRequest request,
  );

  /// Vérifier le statut d'une session de paiement
  @GET("/payments/session/{sessionId}/status/")
  Future<PaymentSessionModel> checkPaymentStatus(
    @Path("sessionId") String sessionId,
  );

  /// Confirmer un paiement avec OTP
  @POST("/payments/session/{sessionId}/confirm/")
  Future<PaymentSessionModel> confirmPayment(
    @Path("sessionId") String sessionId,
    @Body() ConfirmPaymentRequest request,
  );

  /// Obtenir les méthodes de paiement disponibles
  @GET("/payments/methods/")
  Future<List<PaymentMethodModel>> getPaymentMethods();

  /// Valider un code promo
  @POST("/payments/promo-codes/validate/")
  Future<PromoCodeValidationResponse> validatePromoCode(
    @Body() ValidatePromoCodeRequest request,
  );
}

/// Modèles de requête

@JsonSerializable()
class CreateSubscriptionRequest {
  @JsonKey(name: 'plan_id')
  final String planId;
  final String currency;
  @JsonKey(name: 'auto_renew')
  final bool autoRenew;
  @JsonKey(name: 'payment_method_id')
  final String? paymentMethodId;
  @JsonKey(name: 'payment_session_id')
  final String? paymentSessionId;

  CreateSubscriptionRequest({
    required this.planId,
    required this.currency,
    this.autoRenew = true,
    this.paymentMethodId,
    this.paymentSessionId,
  });

  factory CreateSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateSubscriptionRequestToJson(this);
}

@JsonSerializable()
class CancelSubscriptionRequest {
  final String? reason;
  @JsonKey(name: 'cancel_immediately')
  final bool cancelImmediately;
  final String? feedback;

  CancelSubscriptionRequest({
    this.reason,
    this.cancelImmediately = false,
    this.feedback,
  });

  factory CancelSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelSubscriptionRequestToJson(this);
}

@JsonSerializable()
class UpdateSubscriptionRequest {
  @JsonKey(name: 'auto_renew')
  final bool? autoRenew;
  final String? currency;

  UpdateSubscriptionRequest({
    this.autoRenew,
    this.currency,
  });

  factory UpdateSubscriptionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateSubscriptionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateSubscriptionRequestToJson(this);
}

@JsonSerializable()
class ChangePlanRequest {
  @JsonKey(name: 'new_plan_id')
  final String newPlanId;
  @JsonKey(name: 'prorate')
  final bool prorate;
  final String? currency;

  ChangePlanRequest({
    required this.newPlanId,
    this.prorate = true,
    this.currency,
  });

  factory ChangePlanRequest.fromJson(Map<String, dynamic> json) =>
      _$ChangePlanRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePlanRequestToJson(this);
}

@JsonSerializable()
class CreatePaymentSessionRequest {
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

  CreatePaymentSessionRequest({
    required this.planId,
    required this.currency,
    required this.paymentMethod,
    this.phoneNumber,
    this.successUrl,
    this.cancelUrl,
  });

  factory CreatePaymentSessionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePaymentSessionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreatePaymentSessionRequestToJson(this);
}

@JsonSerializable()
class ConfirmPaymentRequest {
  @JsonKey(name: 'otp_code')
  final String otpCode;
  @JsonKey(name: 'transaction_id')
  final String? transactionId;

  ConfirmPaymentRequest({
    required this.otpCode,
    this.transactionId,
  });

  factory ConfirmPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfirmPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmPaymentRequestToJson(this);
}

@JsonSerializable()
class ValidatePromoCodeRequest {
  final String code;
  @JsonKey(name: 'plan_id')
  final String? planId;

  ValidatePromoCodeRequest({
    required this.code,
    this.planId,
  });

  factory ValidatePromoCodeRequest.fromJson(Map<String, dynamic> json) =>
      _$ValidatePromoCodeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ValidatePromoCodeRequestToJson(this);
}

/// Modèles de réponse

@JsonSerializable()
class PlanResponse {
  final List<SubscriptionPlanModel> plans;
  @JsonKey(name: 'total_count')
  final int totalCount;

  PlanResponse({
    required this.plans,
    required this.totalCount,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) =>
      _$PlanResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PlanResponseToJson(this);
}

@JsonSerializable()
class CancelSubscriptionResponse {
  final String id;
  final String status;
  @JsonKey(name: 'cancellation_date')
  final DateTime cancellationDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  final String message;

  CancelSubscriptionResponse({
    required this.id,
    required this.status,
    required this.cancellationDate,
    required this.endDate,
    required this.message,
  });

  factory CancelSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$CancelSubscriptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CancelSubscriptionResponseToJson(this);
}

/// Classe générique pour les réponses paginées
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
class PaymentMethodModel {
  final String id;
  final String name;
  final String type;
  @JsonKey(name: 'operator_code')
  final String operatorCode;
  final List<String> currencies;
  @JsonKey(name: 'min_amount')
  final double? minAmount;
  @JsonKey(name: 'max_amount')
  final double? maxAmount;
  final double? fees;
  @JsonKey(name: 'is_active')
  final bool isActive;

  PaymentMethodModel({
    required this.id,
    required this.name,
    required this.type,
    required this.operatorCode,
    required this.currencies,
    this.minAmount,
    this.maxAmount,
    this.fees,
    required this.isActive,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentMethodModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMethodModelToJson(this);

  bool supportsCurrency(String currency) {
    return currencies.contains(currency.toUpperCase());
  }
}

@JsonSerializable()
class PromoCodeValidationResponse {
  final bool valid;
  final String? message;
  @JsonKey(name: 'discount_amount')
  final double? discountAmount;
  @JsonKey(name: 'discount_percentage')
  final double? discountPercentage;
  @JsonKey(name: 'min_amount')
  final double? minAmount;
  @JsonKey(name: 'max_discount')
  final double? maxDiscount;

  PromoCodeValidationResponse({
    required this.valid,
    this.message,
    this.discountAmount,
    this.discountPercentage,
    this.minAmount,
    this.maxDiscount,
  });

  factory PromoCodeValidationResponse.fromJson(Map<String, dynamic> json) =>
      _$PromoCodeValidationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PromoCodeValidationResponseToJson(this);
}
