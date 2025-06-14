// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String?,
      content: json['content'] as String,
      attachmentUrl: json['attachment_url'] as String?,
      attachmentType: json['attachment_type'] as String?,
      attachmentName: json['attachment_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      read: json['read'] as bool? ?? false,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      status: $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.sent,
      isSystemMessage: json['is_system_message'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'sender_id': instance.senderId,
      'sender_name': instance.senderName,
      'content': instance.content,
      'attachment_url': instance.attachmentUrl,
      'attachment_type': instance.attachmentType,
      'attachment_name': instance.attachmentName,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'read': instance.read,
      'read_at': instance.readAt?.toIso8601String(),
      'status': _$MessageStatusEnumMap[instance.status]!,
      'is_system_message': instance.isSystemMessage,
    };

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'SENDING',
  MessageStatus.sent: 'SENT',
  MessageStatus.delivered: 'DELIVERED',
  MessageStatus.read: 'READ',
  MessageStatus.error: 'ERROR',
};
