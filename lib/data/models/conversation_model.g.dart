// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      unread: json['unread'] as bool? ?? false,
      archived: json['archived'] as bool? ?? false,
      muted: json['muted'] as bool? ?? false,
      otherParticipant: json['other_participant'] == null
          ? null
          : UserModel.fromJson(
              json['other_participant'] as Map<String, dynamic>),
      lastMessage: json['last_message'] == null
          ? null
          : MessageModel.fromJson(json['last_message'] as Map<String, dynamic>),
      messageCount: (json['message_count'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      projectId: json['project_id'] as String?,
      investmentId: json['investment_id'] as String?,
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'unread': instance.unread,
      'archived': instance.archived,
      'muted': instance.muted,
      'other_participant': instance.otherParticipant,
      'last_message': instance.lastMessage,
      'message_count': instance.messageCount,
      'unread_count': instance.unreadCount,
      'project_id': instance.projectId,
      'investment_id': instance.investmentId,
    };
