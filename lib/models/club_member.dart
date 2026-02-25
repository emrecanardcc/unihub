import 'app_enums.dart';

class ClubMember {
  final int id;
  final int clubId;
  final String userId;
  final AppRole role;
  final MemberStatus status;
  final DateTime joinedAt;

  ClubMember({
    required this.id,
    required this.clubId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  factory ClubMember.fromJson(Map<String, dynamic> json) {
    return ClubMember(
      id: json['id'],
      clubId: json['club_id'],
      userId: json['user_id'],
      role: AppRole.fromString(json['role']),
      status: MemberStatus.fromString(json['status']),
      joinedAt: DateTime.parse(json['joined_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'user_id': userId,
      'role': role.toJson(),
      'status': status.toJson(),
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}
