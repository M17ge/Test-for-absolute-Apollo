enum AttendanceStatus {
  scheduled,
  attended,
  absent,
  cancelled
}

class SessionAttendance {
  final String id;
  final String appointmentId;
  final String farmerId;
  final String farmerName;
  final String trainerId;
  final String trainerName;
  final DateTime sessionDate;
  final AttendanceStatus status;
  final String? farmerSignature; // Base64 encoded signature
  final String? trainerSignature; // Base64 encoded signature
  final DateTime? signedAt;
  final String? notes;
  final int durationMinutes;

  SessionAttendance({
    required this.id,
    required this.appointmentId,
    required this.farmerId,
    required this.farmerName,
    required this.trainerId,
    required this.trainerName,
    required this.sessionDate,
    required this.status,
    this.farmerSignature,
    this.trainerSignature,
    this.signedAt,
    this.notes,
    this.durationMinutes = 0,
  });

  factory SessionAttendance.fromMap(Map<String, dynamic> map, String id) {
    return SessionAttendance(
      id: id,
      appointmentId: map['appointmentId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      trainerId: map['trainerId'] ?? '',
      trainerName: map['trainerName'] ?? '',
      sessionDate: DateTime.parse(map['sessionDate'] ?? DateTime.now().toIso8601String()),
      status: AttendanceStatus.values.firstWhere(
        (e) => e.toString() == 'AttendanceStatus.${map['status']}',
        orElse: () => AttendanceStatus.scheduled,
      ),
      farmerSignature: map['farmerSignature'],
      trainerSignature: map['trainerSignature'],
      signedAt: map['signedAt'] != null ? DateTime.parse(map['signedAt']) : null,
      notes: map['notes'],
      durationMinutes: map['durationMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'sessionDate': sessionDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'farmerSignature': farmerSignature,
      'trainerSignature': trainerSignature,
      'signedAt': signedAt?.toIso8601String(),
      'notes': notes,
      'durationMinutes': durationMinutes,
    };
  }
}
