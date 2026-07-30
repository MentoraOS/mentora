import '../models/event.dart';
import '../models/event_context.dart';
import '../models/event_metadata.dart';
//import '../models/event_priority.dart';
import '../models/event_type.dart';

class EventBuilder {
  EventBuilder._();

  static Event create({
    required EventType type,
    required String source,
    required EventContext context,
    Map<String, dynamic> payload = const {},
    EventPriority priority = EventPriority.normal,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return Event(
      id: 'evt_$timestamp',
      type: type,
      source: source,
      userId: context.userId,
      createdAt: DateTime.now(),
      priority: priority,
      metadata: EventMetadata(correlationId: 'corr_$timestamp'),
      context: context,
      payload: payload,
    );
  }
}
