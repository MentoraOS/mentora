class MentoraEvent {
  final String name;
  final Map<String, dynamic> payload;
  final DateTime occurredAt;

  const MentoraEvent({
    required this.name,
    required this.payload,
    required this.occurredAt,
  });
}
