import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  final String title;
  final String message;
  @JsonKey(name: 'notification_type')
  final String notificationType;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'related_object_id')
  final String? relatedObjectId;
  @JsonKey(name: 'related_object_type')
  final String? relatedObjectType;
  @JsonKey(name: 'action_url')
  final String? actionUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.notificationType,
    this.isRead = false,
    this.relatedObjectId,
    this.relatedObjectType,
    this.actionUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Getters utilitaires
  bool get isImportant =>
      notificationType == 'HIGH' || notificationType == 'URGENT';
  bool get isMessage => notificationType == 'MESSAGE';
  bool get isInvestment => notificationType == 'INVESTMENT';
  bool get isProjectUpdate => notificationType == 'PROJECT_UPDATE';
  bool get isSystem => notificationType == 'SYSTEM';

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? notificationType,
    bool? isRead,
    String? relatedObjectId,
    String? relatedObjectType,
    String? actionUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      isRead: isRead ?? this.isRead,
      relatedObjectId: relatedObjectId ?? this.relatedObjectId,
      relatedObjectType: relatedObjectType ?? this.relatedObjectType,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
