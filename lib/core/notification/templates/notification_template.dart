import '../../events/models/phoenix_event.dart';

abstract class NotificationTemplate {
  const NotificationTemplate();

  String get eventName;

  String title(PhoenixEvent event);

  String body(PhoenixEvent event);
}
