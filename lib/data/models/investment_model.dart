import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'project_model.dart';

part 'investment_model.g.dart';

@JsonSerializable()
class InvestmentModel {
  final String id;
  final UserModel investor;
  final ProjectModel project;
  final double amount;
  final String currency;
  @JsonKey(name: 'investment_type')
  final String investmentType;
  @JsonKey(name: 'equity_percentage')
  final double? equityPercentage;
  @JsonKey(name: 'interest_rate')
  final double? interestRate;
  @JsonKey(name: 'term_months')
  final int? termMonths;
  final String status;
  final String? description;
  @JsonKey(name: 'contract_file')
  final String? contractFile;
  final String? notes;
  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  InvestmentModel({
    required this.id,
    required this.investor,
    required this.project,
    required this.amount,
    this.currency = 'EUR',
    required this.investmentType,
    this.equityPercentage,
    this.interestRate,
    this.termMonths,
    this.status = 'PENDING',
    this.description,
    this.contractFile,
    this.notes,
    this.approvedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvestmentModel.fromJson(Map<String, dynamic> json) =>
      _$InvestmentModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvestmentModelToJson(this);

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';

  InvestmentModel copyWith({
    String? id,
    UserModel? investor,
    ProjectModel? project,
    double? amount,
    String? currency,
    String? investmentType,
    double? equityPercentage,
    double? interestRate,
    int? termMonths,
    String? status,
    String? description,
    String? contractFile,
    String? notes,
    DateTime? approvedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentModel(
      id: id ?? this.id,
      investor: investor ?? this.investor,
      project: project ?? this.project,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      investmentType: investmentType ?? this.investmentType,
      equityPercentage: equityPercentage ?? this.equityPercentage,
      interestRate: interestRate ?? this.interestRate,
      termMonths: termMonths ?? this.termMonths,
      status: status ?? this.status,
      description: description ?? this.description,
      contractFile: contractFile ?? this.contractFile,
      notes: notes ?? this.notes,
      approvedAt: approvedAt ?? this.approvedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class InvestmentStatsModel {
  @JsonKey(name: 'total_invested')
  final double totalInvested;
  @JsonKey(name: 'total_equity')
  final double totalEquity;
  @JsonKey(name: 'total_loan')
  final double totalLoan;
  @JsonKey(name: 'total_donation')
  final double totalDonation;
  @JsonKey(name: 'total_convertible_note')
  final double totalConvertibleNote;
  @JsonKey(name: 'investments_count')
  final int investmentsCount;
  @JsonKey(name: 'pending_count')
  final int pendingCount;
  @JsonKey(name: 'approved_count')
  final int approvedCount;
  @JsonKey(name: 'completed_count')
  final int completedCount;
  @JsonKey(name: 'rejected_count')
  final int rejectedCount;
  @JsonKey(name: 'projects_count')
  final int projectsCount;

  InvestmentStatsModel({
    required this.totalInvested,
    required this.totalEquity,
    required this.totalLoan,
    required this.totalDonation,
    required this.totalConvertibleNote,
    required this.investmentsCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.completedCount,
    required this.rejectedCount,
    required this.projectsCount,
  });

  factory InvestmentStatsModel.fromJson(Map<String, dynamic> json) =>
      _$InvestmentStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvestmentStatsModelToJson(this);

  // Getters utiles pour l'affichage
  double get totalAmount => totalInvested;
  int get totalInvestments => investmentsCount;
  int get activeInvestments => approvedCount;
  int get pendingInvestments => pendingCount;
}
