enum AppointmentStatus {
  scheduled,
  confirmed,
  completed,
  cancelled
}

enum CertificationType {
  organicFarming,
  pestControl,
  soilManagement,
  cropRotation,
  irrigation,
  harvesting,
  storage,
  other
}

class Appointment {
  final String id;
  final String farmerId;
  final String farmerName;
  final String trainerId;
  final String trainerName;
  final CertificationType certificationType;
  final DateTime scheduledDate;
  final String location;
  final AppointmentStatus status;
  final String? notes;
  final bool certificateIssued;
  final DateTime? certificateIssuedDate;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.trainerId,
    required this.trainerName,
    required this.certificationType,
    required this.scheduledDate,
    required this.location,
    required this.status,
    this.notes,
    this.certificateIssued = false,
    this.certificateIssuedDate,
    required this.createdAt,
  });

  factory Appointment.fromMap(Map<String, dynamic> map, String id) {
    return Appointment(
      id: id,
      farmerId: map['farmerId'] ?? '',
      farmerName: map['farmerName'] ?? '',
      trainerId: map['trainerId'] ?? '',
      trainerName: map['trainerName'] ?? '',
      certificationType: CertificationType.values.firstWhere(
        (e) => e.toString() == 'CertificationType.${map['certificationType']}',
        orElse: () => CertificationType.other,
      ),
      scheduledDate: DateTime.parse(map['scheduledDate'] ?? DateTime.now().toIso8601String()),
      location: map['location'] ?? '',
      status: AppointmentStatus.values.firstWhere(
        (e) => e.toString() == 'AppointmentStatus.${map['status']}',
        orElse: () => AppointmentStatus.scheduled,
      ),
      notes: map['notes'],
      certificateIssued: map['certificateIssued'] ?? false,
      certificateIssuedDate: map['certificateIssuedDate'] != null 
          ? DateTime.parse(map['certificateIssuedDate']) 
          : null,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'farmerName': farmerName,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'certificationType': certificationType.toString().split('.').last,
      'scheduledDate': scheduledDate.toIso8601String(),
      'location': location,
      'status': status.toString().split('.').last,
      'notes': notes,
      'certificateIssued': certificateIssued,
      'certificateIssuedDate': certificateIssuedDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
