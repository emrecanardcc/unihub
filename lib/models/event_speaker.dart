class EventSpeaker {
  final int id;
  final int eventId;
  final String fullName;
  final String? linkedinUrl;
  final String? bio;

  EventSpeaker({
    required this.id,
    required this.eventId,
    required this.fullName,
    this.linkedinUrl,
    this.bio,
  });

  factory EventSpeaker.fromJson(Map<String, dynamic> json) {
    return EventSpeaker(
      id: json['id'],
      eventId: json['event_id'],
      fullName: json['full_name'],
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
