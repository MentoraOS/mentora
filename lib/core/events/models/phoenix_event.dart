class PhoenixEvent {
  final String id;
  final String name;
  final String source;

  final String? userId;
  final String? workspaceId;
  final String? consultationId;

  final Map<String, dynamic> payload;

  final DateTime occurredAt;

  const PhoenixEvent({
    required this.id,
    required this.name,
    required this.source,
    this.userId,
    this.workspaceId,
    this.consultationId,
    this.payload = const {},
    required this.occurredAt,
  });
}
