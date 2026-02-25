class Faculty {
  final int id;
  final int universityId;
  final String name;

  Faculty({
    required this.id,
    required this.universityId,
    required this.name,
  });

  factory Faculty.fromJson(Map<String, dynamic> json) {
    return Faculty(
      id: json['id'],
      universityId: json['university_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'university_id': universityId,
      'name': name,
    };
  }
}
