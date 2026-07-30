import '../models/event.dart';

class EventRepository {
  EventRepository._();

  static final List<Event> _events = [];

  static List<Event> findAll() {
    return List.unmodifiable(_events);
  }

  static void add(Event event) {
    _events.add(event);
  }

  static void clear() {
    _events.clear();
  }
}
