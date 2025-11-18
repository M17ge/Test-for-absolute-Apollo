enum ReceiptType {
  order,
  credit,
  appointment,
  supplierPayment
}

enum ReceiptStatus {
  pending,
  approved,
  paid,
  cancelled
}

class Receipt {
  final String id;
  final ReceiptType type;
  final String entityId; // Order ID, Credit ID, Appointment ID
  final String farmerId;
  final String farmerName;
  final String? supplierId;
  final String? supplierName;
  final double amount;
  final ReceiptStatus status;
  final String? financeManagerId;
  final String? financeManagerName;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? paidAt;
  final String description;
  final Map<String, dynamic> lineItems;
  final String? notes;

  Receipt({
    required this.id,
    required this.type,
    required this.entityId,
    required this.farmerId,
    required this.farmerName,
    this.supplierId,
    this.supplierName,
    required this.amount,
    required this.status,
    this.financeManagerId,
    this.financeManagerName,
    required this.createdAt,
    this.approvedAt,
    this.paidAt,
    required this.description,
    required this.lineItems,
    this.notes,
  });

  factory Receipt.fromMap(Map<String, dynamic> map, String id) {
    return Receipt(
      id: id,
      type: ReceiptType.values.firstWhere(
        (e) => e.toString() == 'ReceiptType.${map['type']}',
        orElse: () => ReceiptType.order,
      ),
      entityId: map['entityId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      amount: (map['amount'] ?? 0).toDouble(),
      status: ReceiptStatus.values.firstWhere(
        (e) => e.toString() == 'ReceiptStatus.${map['status']}',
        orElse: () => ReceiptStatus.pending,
      ),
      financeManagerId: map['financeManagerId'],
      financeManagerName: map['financeManagerName'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      paidAt: map['paidAt'] != null ? DateTime.parse(map['paidAt']) : null,
      description: map['description'] ?? '',
      lineItems: Map<String, dynamic>.from(map['lineItems'] ?? {}),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'entityId': entityId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'amount': amount,
      'status': status.toString().split('.').last,
      'financeManagerId': financeManagerId,
      'financeManagerName': financeManagerName,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'description': description,
      'lineItems': lineItems,
      'notes': notes,
    };
  }
}
