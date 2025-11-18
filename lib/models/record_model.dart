enum RecordType {
  orderCreated,
  orderUpdated,
  orderApproval,
  creditRequested,
  creditApproved,
  creditRejected,
  paymentMade,
  appointmentBooked,
  appointmentPaymentApproved,
  appointmentPaymentRejected,
  trainerAssigned,
  attendanceMarked,
  certificateIssued,
  productAdded,
  productUpdated,
  stockUpdated,
  userCreated,
  userUpdated,
  receiptGenerated,
  restockRequest,
  restockApproval,
  restockRejection,
  invoiceApproval,
}

class ActivityRecord {
  final String id;
  final RecordType type;
  final String userId;
  final String userName;
  final UserRole userRole;
  final String entityId; // ID of the order, credit, appointment, etc.
  final String entityType; // 'order', 'credit', 'appointment', etc.
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final String? notes;

  ActivityRecord({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.entityId,
    required this.entityType,
    required this.details,
    required this.timestamp,
    this.notes,
  });

  factory ActivityRecord.fromMap(Map<String, dynamic> map, String id) {
    return ActivityRecord(
      id: id,
      type: RecordType.values.firstWhere(
        (e) => e.toString() == 'RecordType.${map['type']}',
        orElse: () => RecordType.userCreated,
      ),
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userRole: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['userRole']}',
        orElse: () => UserRole.farmer,
      ),
      entityId: map['entityId'] ?? '',
      entityType: map['entityType'] ?? '',
      details: Map<String, dynamic>.from(map['details'] ?? {}),
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'userId': userId,
      'userName': userName,
      'userRole': userRole.toString().split('.').last,
      'entityId': entityId,
      'entityType': entityType,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }
}
