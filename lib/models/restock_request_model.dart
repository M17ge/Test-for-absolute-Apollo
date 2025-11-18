enum RestockRequestStatus {
  pending,
  approvedBySupplier,
  invoiceGenerated,
  approvedByFinance,
  dispatched,
  completed,
  rejected
}

class RestockRequest {
  final String id;
  final String productId;
  final String productName;
  final int requestedQuantity;
  final double proposedPrice;
  final String inventoryManagerId;
  final String inventoryManagerName;
  final String? supplierId;
  final String? supplierName;
  final RestockRequestStatus status;
  final DateTime createdAt;
  final DateTime? approvedBySupplierAt;
  final DateTime? invoiceGeneratedAt;
  final DateTime? approvedByFinanceAt;
  final DateTime? dispatchedAt;
  final DateTime? completedAt;
  final String? financeManagerId;
  final String? financeManagerName;
  final String? invoiceId;
  final String? notes;
  final String? rejectionReason;

  RestockRequest({
    required this.id,
    required this.productId,
    required this.productName,
    required this.requestedQuantity,
    required this.proposedPrice,
    required this.inventoryManagerId,
    required this.inventoryManagerName,
    this.supplierId,
    this.supplierName,
    required this.status,
    required this.createdAt,
    this.approvedBySupplierAt,
    this.invoiceGeneratedAt,
    this.approvedByFinanceAt,
    this.dispatchedAt,
    this.completedAt,
    this.financeManagerId,
    this.financeManagerName,
    this.invoiceId,
    this.notes,
    this.rejectionReason,
  });

  double get totalAmount => requestedQuantity * proposedPrice;

  factory RestockRequest.fromMap(Map<String, dynamic> map, String id) {
    return RestockRequest(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      requestedQuantity: map['requestedQuantity'] ?? 0,
      proposedPrice: (map['proposedPrice'] ?? 0).toDouble(),
      inventoryManagerId: map['inventoryManagerId'] ?? '',
      inventoryManagerName: map['inventoryManagerName'] ?? '',
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      status: RestockRequestStatus.values.firstWhere(
        (e) => e.toString() == 'RestockRequestStatus.${map['status']}',
        orElse: () => RestockRequestStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      approvedBySupplierAt: map['approvedBySupplierAt'] != null
          ? DateTime.parse(map['approvedBySupplierAt'])
          : null,
      invoiceGeneratedAt: map['invoiceGeneratedAt'] != null
          ? DateTime.parse(map['invoiceGeneratedAt'])
          : null,
      approvedByFinanceAt: map['approvedByFinanceAt'] != null
          ? DateTime.parse(map['approvedByFinanceAt'])
          : null,
      dispatchedAt: map['dispatchedAt'] != null
          ? DateTime.parse(map['dispatchedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      financeManagerId: map['financeManagerId'],
      financeManagerName: map['financeManagerName'],
      invoiceId: map['invoiceId'],
      notes: map['notes'],
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'requestedQuantity': requestedQuantity,
      'proposedPrice': proposedPrice,
      'inventoryManagerId': inventoryManagerId,
      'inventoryManagerName': inventoryManagerName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'approvedBySupplierAt': approvedBySupplierAt?.toIso8601String(),
      'invoiceGeneratedAt': invoiceGeneratedAt?.toIso8601String(),
      'approvedByFinanceAt': approvedByFinanceAt?.toIso8601String(),
      'dispatchedAt': dispatchedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'financeManagerId': financeManagerId,
      'financeManagerName': financeManagerName,
      'invoiceId': invoiceId,
      'notes': notes,
      'rejectionReason': rejectionReason,
    };
  }
}
