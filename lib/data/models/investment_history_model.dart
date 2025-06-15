class InvestmentHistoryModel {
  final String id;
  final String investmentId;
  final UserModel user;
  final String oldStatus;
  final String newStatus;
  final String? comment;
  final DateTime createdAt;

  InvestmentHistoryModel({
    required this.id,
    required this.investmentId,
    required this.user,
    required this.oldStatus,
    required this.newStatus,
    this.comment,
    required this.createdAt,
  });

  factory InvestmentHistoryModel.fromJson(Map<String, dynamic> json) {
    return InvestmentHistoryModel(
      id: json['id'],
      investmentId: json['investment'],
      user: UserModel.fromJson(json['user']),
      oldStatus: json['old_status'],
      newStatus: json['new_status'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investment': investmentId,
      'user': user.toJson(),
      'old_status': oldStatus,
      'new_status': newStatus,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }
}
