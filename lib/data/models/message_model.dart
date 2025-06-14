import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final String id;
  @JsonKey(name: 'conversation_id')
  final String conversationId;
  @JsonKey(name: 'sender_id')
  final String senderId;
  @JsonKey(name: 'sender_name')
  final String? senderName;
  final String content;
  @JsonKey(name: 'attachment_url')
  final String? attachmentUrl;
  @JsonKey(name: 'attachment_type')
  final String? attachmentType;
  @JsonKey(name: 'attachment_name')
  final String? attachmentName;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  final bool read;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  final MessageStatus status;
  @JsonKey(name: 'is_system_message')
  final bool isSystemMessage;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    required this.content,
    this.attachmentUrl,
    this.attachmentType,
    this.attachmentName,
    required this.createdAt,
    required this.updatedAt,
    this.read = false,
    this.readAt,
    this.status = MessageStatus.sent,
    this.isSystemMessage = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  // Constructeur pour l'envoi d'un nouveau message
  factory MessageModel.create({
    required String conversationId,
    required String senderId,
    String? senderName,
    required String content,
    String? attachmentUrl,
    String? attachmentType,
    String? attachmentName,
    bool isSystemMessage = false,
  }) {
    final now = DateTime.now();
    return MessageModel(
      id: 'temp_${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      content: content,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      attachmentName: attachmentName,
      createdAt: now,
      updatedAt: now,
      status: MessageStatus.sending,
      isSystemMessage: isSystemMessage,
    );
  }

  // Copy with
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? content,
    String? attachmentUrl,
    String? attachmentType,
    String? attachmentName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? read,
    DateTime? readAt,
    MessageStatus? status,
    bool? isSystemMessage,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentName: attachmentName ?? this.attachmentName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      read: read ?? this.read,
      readAt: readAt ?? this.readAt,
      status: status ?? this.status,
      isSystemMessage: isSystemMessage ?? this.isSystemMessage,
    );
  }

  // Propriétés dérivées
  bool get isSending => status == MessageStatus.sending;
  bool get isSent => status == MessageStatus.sent;
  bool get isDelivered => status == MessageStatus.delivered;
  bool get isError => status == MessageStatus.error;
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  // Vérifier si le message est un lien
  bool get isLink {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?([\w\-])+\.{1}([a-zA-Z]{2,63})([\/\w-]*)*\/?\??([^#\n\r]*)?#?([^\n\r]*)$',
    );
    return urlPattern.hasMatch(content);
  }
}

/// Énumération des statuts de message
enum MessageStatus {
  @JsonValue('SENDING')
  sending,
  @JsonValue('SENT')
  sent,
  @JsonValue('DELIVERED')
  delivered,
  @JsonValue('READ')
  read,
  @JsonValue('ERROR')
  error,
}
