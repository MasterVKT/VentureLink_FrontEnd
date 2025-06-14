import 'package:json_annotation/json_annotation.dart';
import 'subscription_plan_model.dart';

part 'user_subscription_model.g.dart';

/// Modèle pour l'abonnement d'un utilisateur selon le guide d'harmonisation
@JsonSerializable()
class UserSubscriptionModel {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'plan_id')
  final String planId;
  final SubscriptionPlanModel? plan;
  final SubscriptionStatus status;
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @JsonKey(name: 'trial_end_date')
  final DateTime? trialEndDate;
  @JsonKey(name: 'auto_renew')
  final bool autoRenew;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'last_payment_date')
  final DateTime? lastPaymentDate;
  @JsonKey(name: 'next_billing_date')
  final DateTime? nextBillingDate;
  @JsonKey(name: 'cancellation_date')
  final DateTime? cancellationDate;
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;

  UserSubscriptionModel({
    required this.id,
    required this.userId,
    required this.planId,
    this.plan,
    required this.status,
    required this.startDate,
    this.endDate,
    this.trialEndDate,
    this.autoRenew = true,
    this.paymentMethod,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.lastPaymentDate,
    this.nextBillingDate,
    this.cancellationDate,
    this.cancellationReason,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$UserSubscriptionModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserSubscriptionModelToJson(this);

  /// Getters utilitaires
  bool get isInTrial => status == SubscriptionStatus.trial;
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isPending => status == SubscriptionStatus.pending;

  bool get isTrialActive =>
      trialEndDate != null && DateTime.now().isBefore(trialEndDate!);

  int get daysUntilExpiry {
    if (endDate == null) return 0;
    final now = DateTime.now();
    if (endDate!.isBefore(now)) return 0;
    return endDate!.difference(now).inDays;
  }

  int get daysUntilTrialEnd {
    if (trialEndDate == null) return 0;
    final now = DateTime.now();
    if (trialEndDate!.isBefore(now)) return 0;
    return trialEndDate!.difference(now).inDays;
  }

  String get statusDisplay {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Actif';
      case SubscriptionStatus.trial:
        return 'Période d\'essai';
      case SubscriptionStatus.pending:
        return 'En attente';
      case SubscriptionStatus.cancelled:
        return 'Annulé';
      case SubscriptionStatus.expired:
        return 'Expiré';
      case SubscriptionStatus.pastDue:
        return 'Paiement en retard';
      case SubscriptionStatus.suspended:
        return 'Suspendu';
    }
  }

  String get planName => plan?.name ?? 'Plan inconnu';

  bool get canUpgrade {
    return isActive && plan != null && plan!.id != 'premium_yearly';
  }

  bool get canCancel {
    return isActive && !isCancelled;
  }

  bool get canReactivate {
    return isCancelled && DateTime.now().isBefore(endDate ?? DateTime.now());
  }
}

/// Énumération des statuts d'abonnement selon le backend
enum SubscriptionStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('TRIAL')
  trial,
  @JsonValue('PENDING')
  pending,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('PAST_DUE')
  pastDue,
  @JsonValue('SUSPENDED')
  suspended,
}

/// Extension pour conversion des statuts
extension SubscriptionStatusExtension on SubscriptionStatus {
  String get value {
    switch (this) {
      case SubscriptionStatus.active:
        return 'ACTIVE';
      case SubscriptionStatus.trial:
        return 'TRIAL';
      case SubscriptionStatus.pending:
        return 'PENDING';
      case SubscriptionStatus.cancelled:
        return 'CANCELLED';
      case SubscriptionStatus.expired:
        return 'EXPIRED';
      case SubscriptionStatus.pastDue:
        return 'PAST_DUE';
      case SubscriptionStatus.suspended:
        return 'SUSPENDED';
    }
  }

  static SubscriptionStatus fromString(String value) {
    switch (value) {
      case 'ACTIVE':
        return SubscriptionStatus.active;
      case 'TRIAL':
        return SubscriptionStatus.trial;
      case 'PENDING':
        return SubscriptionStatus.pending;
      case 'CANCELLED':
        return SubscriptionStatus.cancelled;
      case 'EXPIRED':
        return SubscriptionStatus.expired;
      case 'PAST_DUE':
        return SubscriptionStatus.pastDue;
      case 'SUSPENDED':
        return SubscriptionStatus.suspended;
      default:
        return SubscriptionStatus.pending;
    }
  }
}
