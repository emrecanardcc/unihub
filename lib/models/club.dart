import 'app_enums.dart';

class Club {
  final int id;
  final int universityId;
  final String name;
  final String shortName;
  final String description;
  final String category;
  final String mainColor;
  final String? logoPath;
  final String? bannerPath;
  final List<String> tags;
  final ClubStatus status;

  Club({
    required this.id,
    required this.universityId,
    required this.name,
    required this.shortName,
    required this.description,
    required this.category,
    required this.mainColor,
    this.logoPath,
    this.bannerPath,
    required this.tags,
    required this.status,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'],
      universityId: json['university_id'],
      name: json['name'],
      shortName: json['short_name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Genel',
      mainColor: json['main_color'] ?? '#00FFFF',
      logoPath: json['logo_path'],
      bannerPath: json['banner_path'],
      tags: List<String>.from(json['tags'] ?? []),
      status: ClubStatus.fromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'university_id': universityId,
      'name': name,
      'short_name': shortName,
      'description': description,
      'category': category,
      'main_color': mainColor,
      'logo_path': logoPath,
      'banner_path': bannerPath,
      'tags': tags,
      'status': status.toJson(),
    };
  }
}
