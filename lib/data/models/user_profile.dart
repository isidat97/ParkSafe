class UserProfile {
  final String id;
  final String? fullName;
  final String? phone;
  final String? password;
  final String? avatarUrl;
  final String? role;
  final String? assignedLocationId;
  final String? fcmToken;
  final DateTime? createdAt;

  UserProfile({
    required this.id,
    this.fullName,
    this.phone,
    this.password,
    this.avatarUrl,
    this.role,
    this.assignedLocationId,
    this.fcmToken,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      password: json['password'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      assignedLocationId: json['assigned_location_id'] as String?,
      fcmToken: json['fcm_token'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'password': password,
      'avatar_url': avatarUrl,
      'role': role,
      'assigned_location_id': assignedLocationId,
      'fcm_token': fcmToken,
    };
  }

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? role,
    String? assignedLocationId,
    String? fcmToken,
  }) {
    return UserProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      assignedLocationId: assignedLocationId ?? this.assignedLocationId,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}

