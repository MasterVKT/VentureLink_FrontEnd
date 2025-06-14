// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSubscriptionRequest _$CreateSubscriptionRequestFromJson(
        Map<String, dynamic> json) =>
    CreateSubscriptionRequest(
      planId: json['plan_id'] as String,
      currency: json['currency'] as String,
      autoRenew: json['auto_renew'] as bool? ?? true,
      paymentMethodId: json['payment_method_id'] as String?,
      paymentSessionId: json['payment_session_id'] as String?,
    );

Map<String, dynamic> _$CreateSubscriptionRequestToJson(
        CreateSubscriptionRequest instance) =>
    <String, dynamic>{
      'plan_id': instance.planId,
      'currency': instance.currency,
      'auto_renew': instance.autoRenew,
      'payment_method_id': instance.paymentMethodId,
      'payment_session_id': instance.paymentSessionId,
    };

CancelSubscriptionRequest _$CancelSubscriptionRequestFromJson(
        Map<String, dynamic> json) =>
    CancelSubscriptionRequest(
      reason: json['reason'] as String?,
      cancelImmediately: json['cancel_immediately'] as bool? ?? false,
      feedback: json['feedback'] as String?,
    );

Map<String, dynamic> _$CancelSubscriptionRequestToJson(
        CancelSubscriptionRequest instance) =>
    <String, dynamic>{
      'reason': instance.reason,
      'cancel_immediately': instance.cancelImmediately,
      'feedback': instance.feedback,
    };

UpdateSubscriptionRequest _$UpdateSubscriptionRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateSubscriptionRequest(
      autoRenew: json['auto_renew'] as bool?,
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$UpdateSubscriptionRequestToJson(
        UpdateSubscriptionRequest instance) =>
    <String, dynamic>{
      'auto_renew': instance.autoRenew,
      'currency': instance.currency,
    };

ChangePlanRequest _$ChangePlanRequestFromJson(Map<String, dynamic> json) =>
    ChangePlanRequest(
      newPlanId: json['new_plan_id'] as String,
      prorate: json['prorate'] as bool? ?? true,
      currency: json['currency'] as String?,
    );

Map<String, dynamic> _$ChangePlanRequestToJson(ChangePlanRequest instance) =>
    <String, dynamic>{
      'new_plan_id': instance.newPlanId,
      'prorate': instance.prorate,
      'currency': instance.currency,
    };

CreatePaymentSessionRequest _$CreatePaymentSessionRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentSessionRequest(
      planId: json['plan_id'] as String,
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String,
      phoneNumber: json['phone_number'] as String?,
      successUrl: json['success_url'] as String?,
      cancelUrl: json['cancel_url'] as String?,
    );

Map<String, dynamic> _$CreatePaymentSessionRequestToJson(
        CreatePaymentSessionRequest instance) =>
    <String, dynamic>{
      'plan_id': instance.planId,
      'currency': instance.currency,
      'payment_method': instance.paymentMethod,
      'phone_number': instance.phoneNumber,
      'success_url': instance.successUrl,
      'cancel_url': instance.cancelUrl,
    };

ConfirmPaymentRequest _$ConfirmPaymentRequestFromJson(
        Map<String, dynamic> json) =>
    ConfirmPaymentRequest(
      otpCode: json['otp_code'] as String,
      transactionId: json['transaction_id'] as String?,
    );

Map<String, dynamic> _$ConfirmPaymentRequestToJson(
        ConfirmPaymentRequest instance) =>
    <String, dynamic>{
      'otp_code': instance.otpCode,
      'transaction_id': instance.transactionId,
    };

ValidatePromoCodeRequest _$ValidatePromoCodeRequestFromJson(
        Map<String, dynamic> json) =>
    ValidatePromoCodeRequest(
      code: json['code'] as String,
      planId: json['plan_id'] as String?,
    );

Map<String, dynamic> _$ValidatePromoCodeRequestToJson(
        ValidatePromoCodeRequest instance) =>
    <String, dynamic>{
      'code': instance.code,
      'plan_id': instance.planId,
    };

PlanResponse _$PlanResponseFromJson(Map<String, dynamic> json) => PlanResponse(
      plans: (json['plans'] as List<dynamic>)
          .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num).toInt(),
    );

Map<String, dynamic> _$PlanResponseToJson(PlanResponse instance) =>
    <String, dynamic>{
      'plans': instance.plans,
      'total_count': instance.totalCount,
    };

CancelSubscriptionResponse _$CancelSubscriptionResponseFromJson(
        Map<String, dynamic> json) =>
    CancelSubscriptionResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      cancellationDate: DateTime.parse(json['cancellation_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      message: json['message'] as String,
    );

Map<String, dynamic> _$CancelSubscriptionResponseToJson(
        CancelSubscriptionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'cancellation_date': instance.cancellationDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'message': instance.message,
    };

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    PaginatedResponse<T>(
      count: (json['count'] as num).toInt(),
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>).map(fromJsonT).toList(),
    );

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'count': instance.count,
      'next': instance.next,
      'previous': instance.previous,
      'results': instance.results.map(toJsonT).toList(),
    };

PaymentHistoryModel _$PaymentHistoryModelFromJson(Map<String, dynamic> json) =>
    PaymentHistoryModel(
      id: json['id'] as String,
      amount: json['amount'] as String,
      currency: json['currency'] as String,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      transactionId: json['transaction_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      description: json['description'] as String,
    );

Map<String, dynamic> _$PaymentHistoryModelToJson(
        PaymentHistoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'currency': instance.currency,
      'status': instance.status,
      'payment_method': instance.paymentMethod,
      'transaction_id': instance.transactionId,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'description': instance.description,
    };

PaymentMethodModel _$PaymentMethodModelFromJson(Map<String, dynamic> json) =>
    PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      operatorCode: json['operator_code'] as String,
      currencies: (json['currencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      maxAmount: (json['max_amount'] as num?)?.toDouble(),
      fees: (json['fees'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$PaymentMethodModelToJson(PaymentMethodModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'operator_code': instance.operatorCode,
      'currencies': instance.currencies,
      'min_amount': instance.minAmount,
      'max_amount': instance.maxAmount,
      'fees': instance.fees,
      'is_active': instance.isActive,
    };

PromoCodeValidationResponse _$PromoCodeValidationResponseFromJson(
        Map<String, dynamic> json) =>
    PromoCodeValidationResponse(
      valid: json['valid'] as bool,
      message: json['message'] as String?,
      discountAmount: (json['discount_amount'] as num?)?.toDouble(),
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      minAmount: (json['min_amount'] as num?)?.toDouble(),
      maxDiscount: (json['max_discount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PromoCodeValidationResponseToJson(
        PromoCodeValidationResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'message': instance.message,
      'discount_amount': instance.discountAmount,
      'discount_percentage': instance.discountPercentage,
      'min_amount': instance.minAmount,
      'max_discount': instance.maxDiscount,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element

class _SubscriptionApiService implements SubscriptionApiService {
  _SubscriptionApiService(
    this._dio, {
    this.baseUrl,
    this.errorLogger,
  }) {
    baseUrl ??= 'http://localhost:8000/api/v1/';
  }

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<PlanResponse> getSubscriptionPlans() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PlanResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/plans/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PlanResponse _value;
    try {
      _value = PlanResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscriptionPlanModel> getSubscriptionPlanDetails(
      String planId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<SubscriptionPlanModel>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/plans/${planId}/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscriptionPlanModel _value;
    try {
      _value = SubscriptionPlanModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscriptionModel> createSubscription(
      CreateSubscriptionRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<SubscriptionModel>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/subscription/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscriptionModel _value;
    try {
      _value = SubscriptionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscriptionModel> getCurrentSubscription() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<SubscriptionModel>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/subscription/current/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscriptionModel _value;
    try {
      _value = SubscriptionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<CancelSubscriptionResponse> cancelSubscription(
    String subscriptionId,
    CancelSubscriptionRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<CancelSubscriptionResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/subscription/${subscriptionId}/cancel/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late CancelSubscriptionResponse _value;
    try {
      _value = CancelSubscriptionResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscriptionModel> updateSubscription(
    String subscriptionId,
    UpdateSubscriptionRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<SubscriptionModel>(Options(
      method: 'PUT',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/subscription/${subscriptionId}/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscriptionModel _value;
    try {
      _value = SubscriptionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaginatedResponse<SubscriptionModel>> getSubscriptionHistory() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<PaginatedResponse<SubscriptionModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/payments/subscription/history/',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PaginatedResponse<SubscriptionModel> _value;
    try {
      _value = PaginatedResponse<SubscriptionModel>.fromJson(
        _result.data!,
        (json) => SubscriptionModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscriptionModel> reactivateSubscription(
      String subscriptionId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<SubscriptionModel>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/subscription/${subscriptionId}/reactivate/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscriptionModel _value;
    try {
      _value = SubscriptionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SubscriptionModel> changePlan(
    String subscriptionId,
    ChangePlanRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<SubscriptionModel>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/subscription/${subscriptionId}/change-plan/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SubscriptionModel _value;
    try {
      _value = SubscriptionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaginatedResponse<PaymentHistoryModel>> getPaymentHistory() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options =
        _setStreamType<PaginatedResponse<PaymentHistoryModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              '/payments/history/',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(
                baseUrl: _combineBaseUrls(
              _dio.options.baseUrl,
              baseUrl,
            )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PaginatedResponse<PaymentHistoryModel> _value;
    try {
      _value = PaginatedResponse<PaymentHistoryModel>.fromJson(
        _result.data!,
        (json) => PaymentHistoryModel.fromJson(json as Map<String, dynamic>),
      );
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaymentSessionModel> createPaymentSession(
      CreatePaymentSessionRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<PaymentSessionModel>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/session/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PaymentSessionModel _value;
    try {
      _value = PaymentSessionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaymentSessionModel> checkPaymentStatus(String sessionId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PaymentSessionModel>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/session/${sessionId}/status/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PaymentSessionModel _value;
    try {
      _value = PaymentSessionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaymentSessionModel> confirmPayment(
    String sessionId,
    ConfirmPaymentRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<PaymentSessionModel>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/session/${sessionId}/confirm/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PaymentSessionModel _value;
    try {
      _value = PaymentSessionModel.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<List<PaymentMethodModel>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/methods/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<List<dynamic>>(_options);
    late List<PaymentMethodModel> _value;
    try {
      _value = _result.data!
          .map((dynamic i) =>
              PaymentMethodModel.fromJson(i as Map<String, dynamic>))
          .toList();
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PromoCodeValidationResponse> validatePromoCode(
      ValidatePromoCodeRequest request) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<PromoCodeValidationResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/promo-codes/validate/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PromoCodeValidationResponse _value;
    try {
      _value = PromoCodeValidationResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(
    String dioBaseUrl,
    String? baseUrl,
  ) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
