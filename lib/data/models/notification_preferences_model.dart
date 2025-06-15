import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'notification_preferences_model.g.dart';

@JsonSerializable()
class NotificationPreferencesModel {
  @JsonKey(name: 'enable_push')
  final bool enablePush;

  @JsonKey(name: 'enable_email')
  final bool enableEmail;

  @JsonKey(name: 'enable_sms')
  final bool enableSms;

  @JsonKey(name: 'enable_app')
  final bool enableApp;

  @JsonKey(name: 'project_notifications')
  final bool projectNotifications;

  @JsonKey(name: 'investment_notifications')
  final bool investmentNotifications;

  @JsonKey(name: 'message_notifications')
  final bool messageNotifications;

  @JsonKey(name: 'payment_notifications')
  final bool paymentNotifications;

  @JsonKey(name: 'system_notifications')
  final bool systemNotifications;

  @JsonKey(name: 'quiet_hours_start')
  final String? quietHoursStart;

  @JsonKey(name: 'quiet_hours_end')
  final String? quietHoursEnd;

  @JsonKey(name: 'minimum_priority')
  final String minimumPriority;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  const NotificationPreferencesModel({
    this.enablePush = true,
    this.enableEmail = true,
    this.enableSms = false,
    this.enableApp = true,
    this.projectNotifications = true,
    this.investmentNotifications = true,
    this.messageNotifications = true,
    this.paymentNotifications = true,
    this.systemNotifications = true,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.minimumPriority = 'LOW',
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesModelToJson(this);

  /// Créer des préférences par défaut
  factory NotificationPreferencesModel.defaultPreferences() {
    final now = DateTime.now();
    return NotificationPreferencesModel(
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Vérifier si les notifications sont activées pour une catégorie
  bool isEnabledForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'PROJECT':
        return projectNotifications;
      case 'INVESTMENT':
        return investmentNotifications;
      case 'MESSAGE':
        return messageNotifications;
      case 'PAYMENT':
        return paymentNotifications;
      case 'SYSTEM':
        return systemNotifications;
      default:
        return true; // Par défaut, toutes les catégories sont activées
    }
  }

  /// Vérifier si une méthode de livraison est activée
  bool isDeliveryMethodEnabled(String method) {
    switch (method.toUpperCase()) {
      case 'PUSH':
        return enablePush;
      case 'EMAIL':
        return enableEmail;
      case 'SMS':
        return enableSms;
      case 'APP':
        return enableApp;
      default:
        return false;
    }
  }

  /// Vérifier si une priorité est suffisamment élevée
  bool isPriorityAllowed(String priority) {
    const priorityOrder = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
    final minIndex = priorityOrder.indexOf(minimumPriority);
    final currentIndex = priorityOrder.indexOf(priority);

    if (minIndex == -1 || currentIndex == -1) return true;
    return currentIndex >= minIndex;
  }

  /// Vérifier si on est dans les heures silencieuses
  bool isInQuietHours() {
    if (quietHoursStart == null || quietHoursEnd == null) return false;

    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay.fromDateTime(now);

      final startParts = quietHoursStart!.split(':');
      final endParts = quietHoursEnd!.split(':');

      final startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );

      final endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );

      final currentMinutes = currentTime.hour * 60 + currentTime.minute;
      final startMinutes = startTime.hour * 60 + startTime.minute;
      final endMinutes = endTime.hour * 60 + endTime.minute;

      if (startMinutes <= endMinutes) {
        // Heures silencieuses dans la même journée
        return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
      } else {
        // Heures silencieuses traversent minuit
        return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
      }
    } catch (e) {
      return false; // En cas d'erreur de parsing, pas d'heures silencieuses
    }
  }

  /// Obtenir un résumé des préférences
  Map<String, dynamic> getSummary() {
    return {
      'delivery_methods': {
        'push': enablePush,
        'email': enableEmail,
        'sms': enableSms,
        'app': enableApp,
      },
      'categories': {
        'project': projectNotifications,
        'investment': investmentNotifications,
        'message': messageNotifications,
        'payment': paymentNotifications,
        'system': systemNotifications,
      },
      'minimum_priority': minimumPriority,
      'has_quiet_hours': quietHoursStart != null && quietHoursEnd != null,
      'in_quiet_hours': isInQuietHours(),
    };
  }

  NotificationPreferencesModel copyWith({
    bool? enablePush,
    bool? enableEmail,
    bool? enableSms,
    bool? enableApp,
    bool? projectNotifications,
    bool? investmentNotifications,
    bool? messageNotifications,
    bool? paymentNotifications,
    bool? systemNotifications,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? minimumPriority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreferencesModel(
      enablePush: enablePush ?? this.enablePush,
      enableEmail: enableEmail ?? this.enableEmail,
      enableSms: enableSms ?? this.enableSms,
      enableApp: enableApp ?? this.enableApp,
      projectNotifications: projectNotifications ?? this.projectNotifications,
      investmentNotifications:
          investmentNotifications ?? this.investmentNotifications,
      messageNotifications: messageNotifications ?? this.messageNotifications,
      paymentNotifications: paymentNotifications ?? this.paymentNotifications,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      minimumPriority: minimumPriority ?? this.minimumPriority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NotificationPreferencesModel(enablePush: $enablePush, enableEmail: $enableEmail, minimumPriority: $minimumPriority)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationPreferencesModel &&
        other.enablePush == enablePush &&
        other.enableEmail == enableEmail &&
        other.enableSms == enableSms &&
        other.enableApp == enableApp &&
        other.projectNotifications == projectNotifications &&
        other.investmentNotifications == investmentNotifications &&
        other.messageNotifications == messageNotifications &&
        other.paymentNotifications == paymentNotifications &&
        other.systemNotifications == systemNotifications &&
        other.quietHoursStart == quietHoursStart &&
        other.quietHoursEnd == quietHoursEnd &&
        other.minimumPriority == minimumPriority;
  }

  @override
  int get hashCode {
    return Object.hash(
      enablePush,
      enableEmail,
      enableSms,
      enableApp,
      projectNotifications,
      investmentNotifications,
      messageNotifications,
      paymentNotifications,
      systemNotifications,
      quietHoursStart,
      quietHoursEnd,
      minimumPriority,
    );
  }
}
