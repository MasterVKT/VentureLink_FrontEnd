import 'package:json_annotation/json_annotation.dart';

part 'analytics_model.g.dart';

/// Modèle pour les statistiques du tableau de bord
@JsonSerializable()
class DashboardStatsModel {
  final int totalProjects;
  final int totalViews;
  final int totalInteractions;
  final int totalMessages;
  final int totalInvestments;
  final double totalInvested;
  final int avgViewDuration;
  final ProjectStatsModel projects;
  final GrowthStatsModel growth;

  DashboardStatsModel({
    required this.totalProjects,
    required this.totalViews,
    required this.totalInteractions,
    required this.totalMessages,
    required this.totalInvestments,
    required this.totalInvested,
    required this.avgViewDuration,
    required this.projects,
    required this.growth,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardStatsModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory DashboardStatsModel.fromMap(Map<String, dynamic> map) {
    return DashboardStatsModel(
      totalProjects: map['total_projects'] as int? ?? 0,
      totalViews: map['total_views'] as int? ?? 0,
      totalInteractions: map['total_interactions'] as int? ?? 0,
      totalMessages: map['total_messages'] as int? ?? 0,
      totalInvestments: map['total_investments'] as int? ?? 0,
      totalInvested: (map['total_invested'] as num?)?.toDouble() ?? 0.0,
      avgViewDuration: map['avg_view_duration'] as int? ?? 0,
      projects: ProjectStatsModel.fromMap(
          map['projects'] as Map<String, dynamic>? ?? {}),
      growth: GrowthStatsModel.fromMap(
          map['growth'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Modèle pour les statistiques des projets
@JsonSerializable()
class ProjectStatsModel {
  final int active;
  final int draft;
  final int funded;
  final int archived;

  ProjectStatsModel({
    required this.active,
    required this.draft,
    required this.funded,
    required this.archived,
  });

  factory ProjectStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectStatsModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory ProjectStatsModel.fromMap(Map<String, dynamic> map) {
    return ProjectStatsModel(
      active: map['active'] as int? ?? 0,
      draft: map['draft'] as int? ?? 0,
      funded: map['funded'] as int? ?? 0,
      archived: map['archived'] as int? ?? 0,
    );
  }

  /// Nombre total de projets
  int get total => active + draft + funded + archived;
}

/// Modèle pour les taux de croissance
@JsonSerializable()
class GrowthStatsModel {
  final double views;
  final double interactions;
  final double messages;
  final double investments;

  GrowthStatsModel({
    required this.views,
    required this.interactions,
    required this.messages,
    required this.investments,
  });

  factory GrowthStatsModel.fromJson(Map<String, dynamic> json) =>
      _$GrowthStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$GrowthStatsModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory GrowthStatsModel.fromMap(Map<String, dynamic> map) {
    return GrowthStatsModel(
      views: (map['views'] as num?)?.toDouble() ?? 0.0,
      interactions: (map['interactions'] as num?)?.toDouble() ?? 0.0,
      messages: (map['messages'] as num?)?.toDouble() ?? 0.0,
      investments: (map['investments'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Modèle pour les statistiques de visiteurs
@JsonSerializable()
class VisitorStatsModel {
  final DateTime date;
  final int views;
  final int uniqueVisitors;
  final int returningVisitors;

  VisitorStatsModel({
    required this.date,
    required this.views,
    required this.uniqueVisitors,
    required this.returningVisitors,
  });

  factory VisitorStatsModel.fromJson(Map<String, dynamic> json) =>
      _$VisitorStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$VisitorStatsModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory VisitorStatsModel.fromMap(Map<String, dynamic> map) {
    return VisitorStatsModel(
      date: DateTime.parse(map['date'] as String),
      views: map['views'] as int? ?? 0,
      uniqueVisitors: map['unique_visitors'] as int? ?? 0,
      returningVisitors: map['returning_visitors'] as int? ?? 0,
    );
  }
}

/// Modèle pour les statistiques d'interactions
@JsonSerializable()
class InteractionStatsModel {
  final DateTime date;
  final int favorites;
  final int shares;
  final int comments;
  final int interests;

  InteractionStatsModel({
    required this.date,
    required this.favorites,
    required this.shares,
    required this.comments,
    required this.interests,
  });

  factory InteractionStatsModel.fromJson(Map<String, dynamic> json) =>
      _$InteractionStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$InteractionStatsModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory InteractionStatsModel.fromMap(Map<String, dynamic> map) {
    return InteractionStatsModel(
      date: DateTime.parse(map['date'] as String),
      favorites: map['favorites'] as int? ?? 0,
      shares: map['shares'] as int? ?? 0,
      comments: map['comments'] as int? ?? 0,
      interests: map['interests'] as int? ?? 0,
    );
  }

  /// Total des interactions
  int get total => favorites + shares + comments + interests;
}

/// Modèle pour les statistiques de conversion
@JsonSerializable()
class ConversionStatsModel {
  final DateTime date;
  final double viewToInterest;
  final double interestToContact;
  final double contactToInvestment;

  ConversionStatsModel({
    required this.date,
    required this.viewToInterest,
    required this.interestToContact,
    required this.contactToInvestment,
  });

  factory ConversionStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ConversionStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversionStatsModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory ConversionStatsModel.fromMap(Map<String, dynamic> map) {
    return ConversionStatsModel(
      date: DateTime.parse(map['date'] as String),
      viewToInterest: (map['view_to_interest'] as num?)?.toDouble() ?? 0.0,
      interestToContact:
          (map['interest_to_contact'] as num?)?.toDouble() ?? 0.0,
      contactToInvestment:
          (map['contact_to_investment'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Modèle pour les performances des projets
@JsonSerializable()
class ProjectPerformanceModel {
  final String id;
  final String title;
  final int views;
  final int interests;
  final int messages;
  final int investments;
  final double amount;
  final double conversionRate;
  final double growth;

  ProjectPerformanceModel({
    required this.id,
    required this.title,
    required this.views,
    required this.interests,
    required this.messages,
    required this.investments,
    required this.amount,
    required this.conversionRate,
    required this.growth,
  });

  factory ProjectPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectPerformanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectPerformanceModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory ProjectPerformanceModel.fromMap(Map<String, dynamic> map) {
    return ProjectPerformanceModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      views: map['views'] as int? ?? 0,
      interests: map['interests'] as int? ?? 0,
      messages: map['messages'] as int? ?? 0,
      investments: map['investments'] as int? ?? 0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      conversionRate: (map['conversion_rate'] as num?)?.toDouble() ?? 0.0,
      growth: (map['growth'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Modèle pour les activités récentes
@JsonSerializable()
class ActivityModel {
  final String id;
  final String type;
  final String targetType;
  final String targetId;
  final String targetName;
  final String userId;
  final String userName;
  final DateTime timestamp;
  final double? amount;

  ActivityModel({
    required this.id,
    required this.type,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    required this.userId,
    required this.userName,
    required this.timestamp,
    this.amount,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityModelToJson(this);

  /// Constructeur à partir d'une Map dynamique
  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      targetType: map['target_type'] as String? ?? '',
      targetId: map['target_id'] as String? ?? '',
      targetName: map['target_name'] as String? ?? '',
      userId: map['user_id'] as String? ?? '',
      userName: map['user_name'] as String? ?? '',
      timestamp: DateTime.parse(map['timestamp'] as String),
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
    );
  }

  /// Icône associée au type d'activité
  String get iconName {
    switch (type) {
      case 'view':
        return 'visibility';
      case 'interest':
        return 'favorite';
      case 'message':
        return 'message';
      case 'investment':
        return 'monetization_on';
      case 'comment':
        return 'comment';
      case 'share':
        return 'share';
      case 'profile_view':
        return 'person';
      default:
        return 'notifications';
    }
  }
}
