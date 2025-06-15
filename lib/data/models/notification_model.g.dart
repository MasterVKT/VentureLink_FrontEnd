// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: json['id'] as String,
      recipient: json['recipient'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      deliveryMethods: json['delivery_methods'] as String?,
      delivered: json['delivered'] as bool? ?? false,
      contentType: json['content_type'] as String?,
      objectId: json['object_id'] as String?,
      actionUrl: json['action_url'] as String?,
      icon: json['icon'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipient': instance.recipient,
      'title': instance.title,
      'content': instance.content,
      'category': instance.category,
      'priority': instance.priority,
      'status': instance.status,
      'read_at': instance.readAt?.toIso8601String(),
      'delivery_methods': instance.deliveryMethods,
      'delivered': instance.delivered,
      'content_type': instance.contentType,
      'object_id': instance.objectId,
      'action_url': instance.actionUrl,
      'icon': instance.icon,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
