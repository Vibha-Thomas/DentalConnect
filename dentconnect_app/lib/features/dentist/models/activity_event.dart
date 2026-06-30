class ActivityEvent {
  final String id;
  final String entityType;
  final String entityId;
  final String eventType;
  final String description;
  final String? actorId;
  final String? createdAt;

  ActivityEvent({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.eventType,
    required this.description,
    this.actorId,
    this.createdAt,
  });

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    return ActivityEvent(
      id: json['id'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      eventType: json['eventType'] as String? ?? '',
      description: json['description'] as String? ?? '',
      actorId: json['actorId'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
