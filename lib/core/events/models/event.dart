import 'event_type.dart';
import 'event_metadata.dart';
import 'event_context.dart';

enum EventPriority { low, normal, high, critical }

class Event {
  final String id;

  final EventMetadata metadata;

  final EventContext context;

  final EventType type;

  final String source;

  final String userId;

  final DateTime createdAt;

  final EventPriority priority;

  final Map<String, dynamic> payload;

  const Event({
    required this.context,
    required this.metadata,
    required this.id,
    required this.type,
    required this.source,
    required this.userId,
    required this.createdAt,
    this.priority = EventPriority.normal,
    this.payload = const {},
  });
}
