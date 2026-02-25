class Department {
  final int id;
  final int facultyId;
  final String name;

  Department({
    required this.id,
    required this.facultyId,
    required this.name,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      facultyId: json['faculty_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'faculty_id': facultyId,
      'name': name,
    };
  }
}
