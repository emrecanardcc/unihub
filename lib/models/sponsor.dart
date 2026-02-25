class Sponsor {
  final int id;
  final String name;
  final String description;
  final String? logoPath;
  final String? bannerPath;
  final DateTime createdAt;

  Sponsor({
    required this.id,
    required this.name,
    required this.description,
    this.logoPath,
    this.bannerPath,
    required this.createdAt,
  });

  factory Sponsor.fromJson(Map<String, dynamic> json) {
    return Sponsor(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logoPath: json['logo_path'],
      bannerPath: json['banner_path'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_path': logoPath,
      'banner_path': bannerPath,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
