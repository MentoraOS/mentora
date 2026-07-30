import '../models/event.dart';

abstract class BaseEventListener {
  void handle(Event event);
}
