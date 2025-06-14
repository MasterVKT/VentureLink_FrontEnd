// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardStatsModel _$DashboardStatsModelFromJson(Map<String, dynamic> json) =>
    DashboardStatsModel(
      totalProjects: (json['totalProjects'] as num).toInt(),
      totalViews: (json['totalViews'] as num).toInt(),
      totalInteractions: (json['totalInteractions'] as num).toInt(),
      totalMessages: (json['totalMessages'] as num).toInt(),
      totalInvestments: (json['totalInvestments'] as num).toInt(),
      totalInvested: (json['totalInvested'] as num).toDouble(),
      avgViewDuration: (json['avgViewDuration'] as num).toInt(),
      projects:
          ProjectStatsModel.fromJson(json['projects'] as Map<String, dynamic>),
      growth: GrowthStatsModel.fromJson(json['growth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DashboardStatsModelToJson(
        DashboardStatsModel instance) =>
    <String, dynamic>{
      'totalProjects': instance.totalProjects,
      'totalViews': instance.totalViews,
      'totalInteractions': instance.totalInteractions,
      'totalMessages': instance.totalMessages,
      'totalInvestments': instance.totalInvestments,
      'totalInvested': instance.totalInvested,
      'avgViewDuration': instance.avgViewDuration,
      'projects': instance.projects,
      'growth': instance.growth,
    };

ProjectStatsModel _$ProjectStatsModelFromJson(Map<String, dynamic> json) =>
    ProjectStatsModel(
      active: (json['active'] as num).toInt(),
      draft: (json['draft'] as num).toInt(),
      funded: (json['funded'] as num).toInt(),
      archived: (json['archived'] as num).toInt(),
    );

Map<String, dynamic> _$ProjectStatsModelToJson(ProjectStatsModel instance) =>
    <String, dynamic>{
      'active': instance.active,
      'draft': instance.draft,
      'funded': instance.funded,
      'archived': instance.archived,
    };

GrowthStatsModel _$GrowthStatsModelFromJson(Map<String, dynamic> json) =>
    GrowthStatsModel(
      views: (json['views'] as num).toDouble(),
      interactions: (json['interactions'] as num).toDouble(),
      messages: (json['messages'] as num).toDouble(),
      investments: (json['investments'] as num).toDouble(),
    );

Map<String, dynamic> _$GrowthStatsModelToJson(GrowthStatsModel instance) =>
    <String, dynamic>{
      'views': instance.views,
      'interactions': instance.interactions,
      'messages': instance.messages,
      'investments': instance.investments,
    };

VisitorStatsModel _$VisitorStatsModelFromJson(Map<String, dynamic> json) =>
    VisitorStatsModel(
      date: DateTime.parse(json['date'] as String),
      views: (json['views'] as num).toInt(),
      uniqueVisitors: (json['uniqueVisitors'] as num).toInt(),
      returningVisitors: (json['returningVisitors'] as num).toInt(),
    );

Map<String, dynamic> _$VisitorStatsModelToJson(VisitorStatsModel instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'views': instance.views,
      'uniqueVisitors': instance.uniqueVisitors,
      'returningVisitors': instance.returningVisitors,
    };

InteractionStatsModel _$InteractionStatsModelFromJson(
        Map<String, dynamic> json) =>
    InteractionStatsModel(
      date: DateTime.parse(json['date'] as String),
      favorites: (json['favorites'] as num).toInt(),
      shares: (json['shares'] as num).toInt(),
      comments: (json['comments'] as num).toInt(),
      interests: (json['interests'] as num).toInt(),
    );

Map<String, dynamic> _$InteractionStatsModelToJson(
        InteractionStatsModel instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'favorites': instance.favorites,
      'shares': instance.shares,
      'comments': instance.comments,
      'interests': instance.interests,
    };

ConversionStatsModel _$ConversionStatsModelFromJson(
        Map<String, dynamic> json) =>
    ConversionStatsModel(
      date: DateTime.parse(json['date'] as String),
      viewToInterest: (json['viewToInterest'] as num).toDouble(),
      interestToContact: (json['interestToContact'] as num).toDouble(),
      contactToInvestment: (json['contactToInvestment'] as num).toDouble(),
    );

Map<String, dynamic> _$ConversionStatsModelToJson(
        ConversionStatsModel instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'viewToInterest': instance.viewToInterest,
      'interestToContact': instance.interestToContact,
      'contactToInvestment': instance.contactToInvestment,
    };

ProjectPerformanceModel _$ProjectPerformanceModelFromJson(
        Map<String, dynamic> json) =>
    ProjectPerformanceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      views: (json['views'] as num).toInt(),
      interests: (json['interests'] as num).toInt(),
      messages: (json['messages'] as num).toInt(),
      investments: (json['investments'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      conversionRate: (json['conversionRate'] as num).toDouble(),
      growth: (json['growth'] as num).toDouble(),
    );

Map<String, dynamic> _$ProjectPerformanceModelToJson(
        ProjectPerformanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'views': instance.views,
      'interests': instance.interests,
      'messages': instance.messages,
      'investments': instance.investments,
      'amount': instance.amount,
      'conversionRate': instance.conversionRate,
      'growth': instance.growth,
    };

ActivityModel _$ActivityModelFromJson(Map<String, dynamic> json) =>
    ActivityModel(
      id: json['id'] as String,
      type: json['type'] as String,
      targetType: json['targetType'] as String,
      targetId: json['targetId'] as String,
      targetName: json['targetName'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      amount: (json['amount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ActivityModelToJson(ActivityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'targetType': instance.targetType,
      'targetId': instance.targetId,
      'targetName': instance.targetName,
      'userId': instance.userId,
      'userName': instance.userName,
      'timestamp': instance.timestamp.toIso8601String(),
      'amount': instance.amount,
    };
