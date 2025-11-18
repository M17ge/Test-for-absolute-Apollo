enum UserRole {
  farmer,
  financeManager,
  inventoryManager,
  supplier,
  driver,
  dispatchManager,
  trainer,
  serviceManager,
  admin
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isActive;
  final bool isApproved;
  final String? approvedBy;
  final DateTime? approvedAt;
  final Map<String, dynamic>? metadata;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.photoUrl,
    required this.createdAt,
    this.isActive = true,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
    this.metadata,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.farmer,
      ),
      photoUrl: map['photoUrl'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      isActive: map['isActive'] ?? true,
      isApproved: map['isApproved'] ?? false,
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.toString().split('.').last,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  AppUser copyWith({
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    String? photoUrl,
    DateTime? createdAt,
    bool? isActive,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
