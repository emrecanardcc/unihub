class University {
  final int id;
  final String name;
  final String shortName;
  final String domain;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.domain,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'],
      name: json['name'],
      shortName: json['short_name'],
      domain: json['domain'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'domain': domain,
    };
  }
}
