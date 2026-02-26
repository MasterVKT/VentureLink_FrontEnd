// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_api_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSubscriptionPaymentRequest _$CreateSubscriptionPaymentRequestFromJson(
        Map<String, dynamic> json) =>
    CreateSubscriptionPaymentRequest(
      planId: json['plan_id'] as String,
      currency: json['currency'] as String,
      paymentMethod: json['payment_method'] as String,
      phoneNumber: json['phone_number'] as String?,
      successUrl: json['success_url'] as String?,
      cancelUrl: json['cancel_url'] as String?,
    );

Map<String, dynamic> _$CreateSubscriptionPaymentRequestToJson(
        CreateSubscriptionPaymentRequest instance) =>
    <String, dynamic>{
      'plan_id': instance.planId,
      'currency': instance.currency,
      'payment_method': instance.paymentMethod,
      'phone_number': instance.phoneNumber,
      'success_url': instance.successUrl,
      'cancel_url': instance.cancelUrl,
    };

DirectPaymentRequest _$DirectPaymentRequestFromJson(
        Map<String, dynamic> json) =>
    DirectPaymentRequest(
      planId: json['plan_id'] as String,
      operator: json['operator'] as String,
      phoneNumber: json['phone_number'] as String,
    );

Map<String, dynamic> _$DirectPaymentRequestToJson(
        DirectPaymentRequest instance) =>
    <String, dynamic>{
      'plan_id': instance.planId,
      'operator': instance.operator,
      'phone_number': instance.phoneNumber,
    };

AuthorizeOTPRequest _$AuthorizeOTPRequestFromJson(Map<String, dynamic> json) =>
    AuthorizeOTPRequest(
      paymentId: json['payment_id'] as String,
      otpCode: json['otp_code'] as String,
    );

Map<String, dynamic> _$AuthorizeOTPRequestToJson(
        AuthorizeOTPRequest instance) =>
    <String, dynamic>{
      'payment_id': instance.paymentId,
      'otp_code': instance.otpCode,
    };

CreatePaymentRequest _$CreatePaymentRequestFromJson(
        Map<String, dynamic> json) =>
    CreatePaymentRequest(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      paymentType: json['payment_type'] as String? ?? 'OTHER',
      successUrl: json['success_url'] as String?,
      cancelUrl: json['cancel_url'] as String?,
      statementDescriptor: json['statement_descriptor'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$CreatePaymentRequestToJson(
        CreatePaymentRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
      'description': instance.description,
      'payment_type': instance.paymentType,
      'success_url': instance.successUrl,
      'cancel_url': instance.cancelUrl,
      'statement_descriptor': instance.statementDescriptor,
      'metadata': instance.metadata,
    };

RefundRequest _$RefundRequestFromJson(Map<String, dynamic> json) =>
    RefundRequest(
      amount: (json['amount'] as num?)?.toDouble(),
      reason: json['reason'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$RefundRequestToJson(RefundRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'reason': instance.reason,
      'notes': instance.notes,
    };

PaymentMethodsResponse _$PaymentMethodsResponseFromJson(
        Map<String, dynamic> json) =>
    PaymentMethodsResponse(
      methods: (json['methods'] as List<dynamic>)
          .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      supportedCurrencies: (json['supported_currencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$PaymentMethodsResponseToJson(
        PaymentMethodsResponse instance) =>
    <String, dynamic>{
      'methods': instance.methods,
      'supported_currencies': instance.supportedCurrencies,
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

AccountBalanceResponse _$AccountBalanceResponseFromJson(
        Map<String, dynamic> json) =>
    AccountBalanceResponse(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
      availableBalance: (json['available_balance'] as num).toDouble(),
      pendingAmount: (json['pending_amount'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$AccountBalanceResponseToJson(
        AccountBalanceResponse instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'currency': instance.currency,
      'available_balance': instance.availableBalance,
      'pending_amount': instance.pendingAmount,
      'last_updated': instance.lastUpdated.toIso8601String(),
    };

RefundResponse _$RefundResponseFromJson(Map<String, dynamic> json) =>
    RefundResponse(
      id: json['id'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      paymentId: json['payment_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$RefundResponseToJson(RefundResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'payment_id': instance.paymentId,
      'created_at': instance.createdAt.toIso8601String(),
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

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unused_element_parameter

class _PaymentApiService implements PaymentApiService {
  _PaymentApiService(
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
  Future<PaymentMethodsResponse> getPaymentMethods() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PaymentMethodsResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/methods/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late PaymentMethodsResponse _value;
    try {
      _value = PaymentMethodsResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaymentSessionModel> createSubscriptionPayment(
      CreateSubscriptionPaymentRequest request) async {
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
          '/subscription/create/',
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
  Future<PaymentSessionModel> initiateDirectPayment(
      DirectPaymentRequest request) async {
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
          '/payin/',
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
  Future<PaymentSessionModel> authorizePaymentOTP(
      AuthorizeOTPRequest request) async {
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
          '/authorize/',
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
  Future<PaymentSessionModel> checkPaymentStatus(String paymentId) async {
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
          '/${paymentId}/status/',
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
              '/history/',
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
  Future<AccountBalanceResponse> getAccountBalance() async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<AccountBalanceResponse>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/balance/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late AccountBalanceResponse _value;
    try {
      _value = AccountBalanceResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaymentSessionModel> createPayment(
      CreatePaymentRequest request) async {
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
          '/payments/create_payment/',
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
  Future<RefundResponse> refundPayment(
    String paymentId,
    RefundRequest request,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _options = _setStreamType<RefundResponse>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/${paymentId}/refund/',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(
            baseUrl: _combineBaseUrls(
          _dio.options.baseUrl,
          baseUrl,
        )));
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late RefundResponse _value;
    try {
      _value = RefundResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options);
      rethrow;
    }
    return _value;
  }

  @override
  Future<PaymentSessionModel> updatePaymentStatus(String paymentId) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<PaymentSessionModel>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          '/payments/${paymentId}/check_status/',
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
