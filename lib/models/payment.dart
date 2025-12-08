class Payment {
  final int? id;
  final int? clientId;
  final String? clientName;
  final String paymentNumber;
  final int? declarationId;
  final String? declarationNumber;
  final double amount;
  final String currency;
  final String? paymentType;
  final String status;
  final DateTime? dueDate;
  final DateTime? createdAt;

  Payment({
    this.id,
    this.clientId,
    this.clientName,
    required this.paymentNumber,
    this.declarationId,
    this.declarationNumber,
    required this.amount,
    required this.currency,
    this.paymentType,
    required this.status,
    this.dueDate,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      clientId: json['clientId'],
      clientName: json['clientName'],
      paymentNumber: json['paymentNumber'] ?? '',
      declarationId: json['declarationId'],
      declarationNumber: json['declarationNumber'],
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'BYN',
      paymentType: json['paymentType'],
      status: json['status'] ?? 'PENDING',
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'amount': amount,
      'currency': currency,
      'status': status,
    };
    if (clientId != null) data['clientId'] = clientId;
    if (declarationId != null) data['declarationId'] = declarationId;
    if (paymentType != null) data['paymentType'] = paymentType;
    if (dueDate != null) {
      data['dueDate'] = dueDate!.toIso8601String().split('T')[0];
    }
    return data;
  }
}

