// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      notificationType: json['notification_type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      relatedObjectId: json['related_object_id'] as String?,
      relatedObjectType: json['related_object_type'] as String?,
      actionUrl: json['action_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'notification_type': instance.notificationType,
      'is_read': instance.isRead,
      'related_object_id': instance.relatedObjectId,
      'related_object_type': instance.relatedObjectType,
      'action_url': instance.actionUrl,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
