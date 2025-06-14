// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvestmentModel _$InvestmentModelFromJson(Map<String, dynamic> json) =>
    InvestmentModel(
      id: json['id'] as String,
      investor: UserModel.fromJson(json['investor'] as Map<String, dynamic>),
      project: ProjectModel.fromJson(json['project'] as Map<String, dynamic>),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
      investmentType: json['investment_type'] as String,
      equityPercentage: (json['equity_percentage'] as num?)?.toDouble(),
      interestRate: (json['interest_rate'] as num?)?.toDouble(),
      termMonths: (json['term_months'] as num?)?.toInt(),
      status: json['status'] as String? ?? 'PENDING',
      description: json['description'] as String?,
      contractFile: json['contract_file'] as String?,
      notes: json['notes'] as String?,
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$InvestmentModelToJson(InvestmentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'investor': instance.investor,
      'project': instance.project,
      'amount': instance.amount,
      'currency': instance.currency,
      'investment_type': instance.investmentType,
      'equity_percentage': instance.equityPercentage,
      'interest_rate': instance.interestRate,
      'term_months': instance.termMonths,
      'status': instance.status,
      'description': instance.description,
      'contract_file': instance.contractFile,
      'notes': instance.notes,
      'approved_at': instance.approvedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

InvestmentStatsModel _$InvestmentStatsModelFromJson(
        Map<String, dynamic> json) =>
    InvestmentStatsModel(
      totalInvested: (json['total_invested'] as num).toDouble(),
      totalEquity: (json['total_equity'] as num).toDouble(),
      totalLoan: (json['total_loan'] as num).toDouble(),
      totalDonation: (json['total_donation'] as num).toDouble(),
      totalConvertibleNote: (json['total_convertible_note'] as num).toDouble(),
      investmentsCount: (json['investments_count'] as num).toInt(),
      pendingCount: (json['pending_count'] as num).toInt(),
      approvedCount: (json['approved_count'] as num).toInt(),
      completedCount: (json['completed_count'] as num).toInt(),
      rejectedCount: (json['rejected_count'] as num).toInt(),
      projectsCount: (json['projects_count'] as num).toInt(),
    );

Map<String, dynamic> _$InvestmentStatsModelToJson(
        InvestmentStatsModel instance) =>
    <String, dynamic>{
      'total_invested': instance.totalInvested,
      'total_equity': instance.totalEquity,
      'total_loan': instance.totalLoan,
      'total_donation': instance.totalDonation,
      'total_convertible_note': instance.totalConvertibleNote,
      'investments_count': instance.investmentsCount,
      'pending_count': instance.pendingCount,
      'approved_count': instance.approvedCount,
      'completed_count': instance.completedCount,
      'rejected_count': instance.rejectedCount,
      'projects_count': instance.projectsCount,
    };
