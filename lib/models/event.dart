class SpeakerModel {
  final int id;
  final int eventId;
  final String fullName;
  final String? linkedinUrl;
  final String? bio;

  SpeakerModel({
    required this.id,
    required this.eventId,
    required this.fullName,
    this.linkedinUrl,
    this.bio,
  });

  factory SpeakerModel.fromJson(Map<String, dynamic> json) {
    return SpeakerModel(
      id: json['id'],
      eventId: json['event_id'],
      fullName: json['full_name'] ?? '',
      linkedinUrl: json['linkedin_url'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_id': eventId,
      'full_name': fullName,
      'linkedin_url': linkedinUrl,
      'bio': bio,
    };
  }
}

class EventModel {
  final int id;
  final int clubId;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime? createdAt;
  final List<SpeakerModel> speakers;

  EventModel({
    required this.id,
    required this.clubId,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    this.createdAt,
    this.speakers = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final speakersJson = json['event_speakers'] as List<dynamic>? ?? [];
    final String? startStr = json['start_time']?.toString();
    final DateTime parsedStart = startStr != null ? (DateTime.tryParse(startStr) ?? DateTime.now()) : DateTime.now();
    return EventModel(
      id: json['id'],
      clubId: json['club_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startTime: parsedStart,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      speakers: speakersJson.map((item) => SpeakerModel.fromJson(item)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'club_id': clubId,
      'title': title,
      'description': description,
      'location': location,
      'start_time': startTime.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'event_speakers': speakers.map((speaker) => speaker.toJson()).toList(),
    };
  }
}
