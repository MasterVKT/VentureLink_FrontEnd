// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationPreferencesModel _$NotificationPreferencesModelFromJson(
        Map<String, dynamic> json) =>
    NotificationPreferencesModel(
      enablePush: json['enable_push'] as bool? ?? true,
      enableEmail: json['enable_email'] as bool? ?? true,
      enableSms: json['enable_sms'] as bool? ?? false,
      enableApp: json['enable_app'] as bool? ?? true,
      projectNotifications: json['project_notifications'] as bool? ?? true,
      investmentNotifications:
          json['investment_notifications'] as bool? ?? true,
      messageNotifications: json['message_notifications'] as bool? ?? true,
      paymentNotifications: json['payment_notifications'] as bool? ?? true,
      systemNotifications: json['system_notifications'] as bool? ?? true,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
      minimumPriority: json['minimum_priority'] as String? ?? 'LOW',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NotificationPreferencesModelToJson(
        NotificationPreferencesModel instance) =>
    <String, dynamic>{
      'enable_push': instance.enablePush,
      'enable_email': instance.enableEmail,
      'enable_sms': instance.enableSms,
      'enable_app': instance.enableApp,
      'project_notifications': instance.projectNotifications,
      'investment_notifications': instance.investmentNotifications,
      'message_notifications': instance.messageNotifications,
      'payment_notifications': instance.paymentNotifications,
      'system_notifications': instance.systemNotifications,
      'quiet_hours_start': instance.quietHoursStart,
      'quiet_hours_end': instance.quietHoursEnd,
      'minimum_priority': instance.minimumPriority,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
