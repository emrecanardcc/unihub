enum AppRole {
  member,
  coordinator,
  vicePresident,
  president;

  static AppRole fromString(String value) {
    // Handle Turkish DB values
    switch (value) {
      case 'uye':
        return AppRole.member;
      case 'koordinator':
        return AppRole.coordinator;
      case 'baskan_yardimcisi':
        return AppRole.vicePresident;
      case 'baskan':
        return AppRole.president;
    }
    
    return AppRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AppRole.member,
    );
  }

  String toJson() => name;
}

enum MemberStatus {
  pending,
  approved,
  rejected;

  static MemberStatus fromString(String value) {
    return MemberStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MemberStatus.pending,
    );
  }

  String toJson() => name;
}

enum ClubStatus {
  active,
  suspended,
  closed;

  static ClubStatus fromString(String value) {
    return ClubStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ClubStatus.active,
    );
  }

  String toJson() => name;
}
