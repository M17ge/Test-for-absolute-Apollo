enum CreditStatus {
  pending,
  approved,
  rejected,
  active,
  paid,
  defaulted
}

class Credit {
  final String id;
  final String farmerId;
  final String farmerName;
  final double amount;
  final double interestRate;
  final int durationMonths;
  final CreditStatus status;
  final String? financeManagerId;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final DateTime? dueDate;
  final double amountPaid;
  final double amountDue;
  final String purpose;
  final List<Payment> payments;

  Credit({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.amount,
    required this.interestRate,
    required this.durationMonths,
    required this.status,
    this.financeManagerId,
    required this.requestDate,
    this.approvalDate,
    this.dueDate,
    this.amountPaid = 0,
    required this.amountDue,
    required this.purpose,
    this.payments = const [],
  });

  factory Credit.fromMap(Map<String, dynamic> map, String id) {
    return Credit(
      id: id,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      interestRate: (map['interestRate'] ?? 0).toDouble(),
      durationMonths: map['durationMonths'] ?? 0,
      status: CreditStatus.values.firstWhere(
        (e) => e.toString() == 'CreditStatus.${map['status']}',
        orElse: () => CreditStatus.pending,
      ),
      financeManagerId: map['financeManagerId'],
      requestDate: DateTime.parse(map['requestDate'] ?? DateTime.now().toIso8601String()),
      approvalDate: map['approvalDate'] != null ? DateTime.parse(map['approvalDate']) : null,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      amountPaid: (map['amountPaid'] ?? 0).toDouble(),
      amountDue: (map['amountDue'] ?? 0).toDouble(),
      purpose: map['purpose'] ?? '',
      payments: (map['payments'] as List? ?? [])
          .map((p) => Payment.fromMap(p))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'amount': amount,
      'interestRate': interestRate,
      'durationMonths': durationMonths,
      'status': status.toString().split('.').last,
      'financeManagerId': financeManagerId,
      'requestDate': requestDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'amountPaid': amountPaid,
      'amountDue': amountDue,
      'purpose': purpose,
      'payments': payments.map((p) => p.toMap()).toList(),
    };
  }
}

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String method;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    required this.method,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      method: map['method'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'method': method,
    };
  }
}
