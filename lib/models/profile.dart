class Profile {
  final String id;
  final String email;
  final String fullName;
  final String? studentEmail;
  final String? avatarUrl;
  final int? universityId;
  final int? facultyId;     // Yeni
  final int? departmentId;  // Yeni
  final String role; // 'admin', 'moderator', 'member'
  final bool isVerified;
  final String? firstName;  // Yeni
  final String? lastName;   // Yeni
  final DateTime? birthDate; // Yeni
  final String? personalEmail; // Yeni
  final DateTime? createdAt; // Yeni

  Profile({
    required this.id,
    required this.email,
    required this.fullName,
    this.studentEmail,
    this.avatarUrl,
    this.universityId,
    this.facultyId,
    this.departmentId,
    this.role = 'member',
    this.isVerified = false,
    this.firstName,
    this.lastName,
    this.birthDate,
    this.personalEmail,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      studentEmail: json['student_email'],
      avatarUrl: json['avatar_url'],
      universityId: json['university_id'],
      facultyId: json['faculty_id'],
      departmentId: json['department_id'],
      role: json['role'] ?? 'member',
      isVerified: json['is_verified'] ?? false,
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date']) : null,
      personalEmail: json['personal_email'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'student_email': studentEmail,
      'avatar_url': avatarUrl,
      'university_id': universityId,
      'faculty_id': facultyId,
      'department_id': departmentId,
      'role': role,
      'is_verified': isVerified,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate?.toIso8601String(),
      'personal_email': personalEmail,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
