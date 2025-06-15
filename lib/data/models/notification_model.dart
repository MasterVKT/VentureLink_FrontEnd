import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final String id;
  final String recipient;
  final String title;
  final String content;
  final String category;
  final String priority;
  final String status;
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @JsonKey(name: 'delivery_methods')
  final String? deliveryMethods;
  final bool delivered;
  @JsonKey(name: 'content_type')
  final String? contentType;
  @JsonKey(name: 'object_id')
  final String? objectId;
  @JsonKey(name: 'action_url')
  final String? actionUrl;
  final String? icon;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    required this.title,
    required this.content,
    required this.category,
    required this.priority,
    required this.status,
    this.readAt,
    this.deliveryMethods,
    this.delivered = false,
    this.contentType,
    this.objectId,
    this.actionUrl,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Getters utilitaires
  bool get isUnread => status == 'UNREAD';
  bool get isRead => status == 'READ';
  bool get isArchived => status == 'ARCHIVED';
  bool get isDeleted => status == 'DELETED';

  bool get isHighPriority => priority == 'HIGH' || priority == 'URGENT';
  bool get isUrgent => priority == 'URGENT';
  bool get isLowPriority => priority == 'LOW';

  bool get isProjectCategory => category == 'PROJECT';
  bool get isInvestmentCategory => category == 'INVESTMENT';
  bool get isMessageCategory => category == 'MESSAGE';
  bool get isPaymentCategory => category == 'PAYMENT';
  bool get isSystemCategory => category == 'SYSTEM';
  bool get isGeneralCategory => category == 'GENERAL';

  Color get priorityColor {
    switch (priority) {
      case 'URGENT':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'NORMAL':
        return Colors.blue;
      case 'LOW':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case 'PROJECT':
        return Icons.work;
      case 'INVESTMENT':
        return Icons.attach_money;
      case 'MESSAGE':
        return Icons.message;
      case 'PAYMENT':
        return Icons.payment;
      case 'SYSTEM':
        return Icons.settings;
      case 'GENERAL':
      default:
        return Icons.notifications;
    }
  }

  Color get categoryColor {
    switch (category) {
      case 'PROJECT':
        return Colors.blue;
      case 'INVESTMENT':
        return Colors.green;
      case 'MESSAGE':
        return Colors.purple;
      case 'PAYMENT':
        return Colors.orange;
      case 'SYSTEM':
        return Colors.grey;
      case 'GENERAL':
      default:
        return Colors.indigo;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? recipient,
    String? title,
    String? content,
    String? category,
    String? priority,
    String? status,
    DateTime? readAt,
    String? deliveryMethods,
    bool? delivered,
    String? contentType,
    String? objectId,
    String? actionUrl,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipient: recipient ?? this.recipient,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      readAt: readAt ?? this.readAt,
      deliveryMethods: deliveryMethods ?? this.deliveryMethods,
      delivered: delivered ?? this.delivered,
      contentType: contentType ?? this.contentType,
      objectId: objectId ?? this.objectId,
      actionUrl: actionUrl ?? this.actionUrl,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, category: $category, priority: $priority, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
