// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeRate _$ExchangeRateFromJson(Map<String, dynamic> json) => ExchangeRate(
      baseCurrency: json['base_currency'] as String,
      rates: (json['rates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$ExchangeRateToJson(ExchangeRate instance) =>
    <String, dynamic>{
      'base_currency': instance.baseCurrency,
      'rates': instance.rates,
      'timestamp': instance.timestamp.toIso8601String(),
    };
