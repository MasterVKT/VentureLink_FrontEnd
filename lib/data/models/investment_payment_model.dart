class InvestmentPaymentModel {
  final String id;
  final String investmentId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String status;
  final String? transactionId;
  final Map<String, dynamic>? paymentDetails;
  final String? notes;
  final String? receiptFile;
  final DateTime createdAt;
  final DateTime? completedAt;

  InvestmentPaymentModel({
    required this.id,
    required this.investmentId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.transactionId,
    this.paymentDetails,
    this.notes,
    this.receiptFile,
    required this.createdAt,
    this.completedAt,
  });

  bool get isPending => status == 'PENDING';
  bool get isProcessing => status == 'PROCESSING';
  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isRefunded => status == 'REFUNDED';

  factory InvestmentPaymentModel.fromJson(Map<String, dynamic> json) {
    return InvestmentPaymentModel(
      id: json['id'],
      investmentId: json['investment'],
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      transactionId: json['transaction_id'],
      paymentDetails: json['payment_details'],
      notes: json['notes'],
      receiptFile: json['receipt_file'],
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investment': investmentId,
      'amount': amount.toString(),
      'currency': currency,
      'payment_method': paymentMethod,
      'status': status,
      'transaction_id': transactionId,
      'payment_details': paymentDetails,
      'notes': notes,
      'receipt_file': receiptFile,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}
