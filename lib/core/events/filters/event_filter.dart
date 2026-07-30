import '../models/event_type.dart';

abstract class EventFilter {
  List<EventType> get supportedEvents;
}
