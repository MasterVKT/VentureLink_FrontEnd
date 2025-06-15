class InvestmentStatsModel {
  final double totalInvested;
  final int investmentsCount;
  final int pendingCount;
  final int approvedCount;
  final int completedCount;
  final int rejectedCount;
  final int projectsCount;
  final double totalEquity;
  final double totalLoan;
  final double totalDonation;
  final double totalConvertibleNote;

  InvestmentStatsModel({
    required this.totalInvested,
    required this.investmentsCount,
    required this.pendingCount,
    required this.approvedCount,
    required this.completedCount,
    required this.rejectedCount,
    required this.projectsCount,
    required this.totalEquity,
    required this.totalLoan,
    required this.totalDonation,
    required this.totalConvertibleNote,
  });

  factory InvestmentStatsModel.fromJson(Map<String, dynamic> json) {
    final byType = json['by_type'] as Map<String, dynamic>? ?? {};

    return InvestmentStatsModel(
      totalInvested: double.parse(json['total_invested']?.toString() ?? '0'),
      investmentsCount: json['total_investments'] ?? 0,
      pendingCount: json['pending_investments'] ?? 0,
      approvedCount: json['approved_investments'] ?? 0,
      completedCount: json['completed_investments'] ?? 0,
      rejectedCount: json['rejected_investments'] ?? 0,
      projectsCount: json['projects_count'] ?? 0,
      totalEquity:
          double.parse(byType['EQUITY']?['total_amount']?.toString() ?? '0'),
      totalLoan:
          double.parse(byType['LOAN']?['total_amount']?.toString() ?? '0'),
      totalDonation:
          double.parse(byType['DONATION']?['total_amount']?.toString() ?? '0'),
      totalConvertibleNote: double.parse(
          byType['CONVERTIBLE_NOTE']?['total_amount']?.toString() ?? '0'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_invested': totalInvested.toString(),
      'total_investments': investmentsCount,
      'pending_investments': pendingCount,
      'approved_investments': approvedCount,
      'completed_investments': completedCount,
      'rejected_investments': rejectedCount,
      'projects_count': projectsCount,
      'by_type': {
        'EQUITY': {
          'total_amount': totalEquity.toString(),
        },
        'LOAN': {
          'total_amount': totalLoan.toString(),
        },
        'DONATION': {
          'total_amount': totalDonation.toString(),
        },
        'CONVERTIBLE_NOTE': {
          'total_amount': totalConvertibleNote.toString(),
        },
      },
    };
  }
}
