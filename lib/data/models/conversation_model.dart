import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel {
  final String id;
  final String title;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;
  final bool unread;
  final bool archived;
  final bool muted;
  @JsonKey(name: 'other_participant')
  final UserModel? otherParticipant;
  @JsonKey(name: 'last_message')
  final MessageModel? lastMessage;
  @JsonKey(name: 'message_count')
  final int messageCount;
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  @JsonKey(name: 'project_id')
  final String? projectId;
  @JsonKey(name: 'investment_id')
  final String? investmentId;

  ConversationModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.unread = false,
    this.archived = false,
    this.muted = false,
    this.otherParticipant,
    this.lastMessage,
    this.messageCount = 0,
    this.unreadCount = 0,
    this.projectId,
    this.investmentId,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  // Constructeur pour la création d'une nouvelle conversation
  factory ConversationModel.create({
    required String title,
    required UserModel otherParticipant,
    String? projectId,
    String? investmentId,
  }) {
    final now = DateTime.now();
    return ConversationModel(
      id: 'temp_${now.millisecondsSinceEpoch}',
      title: title,
      createdAt: now,
      updatedAt: now,
      lastMessageAt: now,
      otherParticipant: otherParticipant,
      projectId: projectId,
      investmentId: investmentId,
    );
  }

  // Copy with
  ConversationModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
    bool? unread,
    bool? archived,
    bool? muted,
    UserModel? otherParticipant,
    MessageModel? lastMessage,
    int? messageCount,
    int? unreadCount,
    String? projectId,
    String? investmentId,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unread: unread ?? this.unread,
      archived: archived ?? this.archived,
      muted: muted ?? this.muted,
      otherParticipant: otherParticipant ?? this.otherParticipant,
      lastMessage: lastMessage ?? this.lastMessage,
      messageCount: messageCount ?? this.messageCount,
      unreadCount: unreadCount ?? this.unreadCount,
      projectId: projectId ?? this.projectId,
      investmentId: investmentId ?? this.investmentId,
    );
  }
}
