import '../models/event.dart';
import '../models/event_type.dart';
import '../models/notification.dart';
import '../repository/notification_repository.dart';
import 'base_event_listener.dart';
import '../filters/event_filter.dart';

class NotificationListener implements BaseEventListener, EventFilter {
  @override
  List<EventType> get supportedEvents => [
    EventType.lessonCompleted,
    EventType.courseCompleted,
  ];

  @override
  void handle(Event event) {
    if (event.type == EventType.lessonCompleted) {
      NotificationRepository.add(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          userId: event.userId,
          title: 'Leçon terminée',
          message: 'Votre progression a été mise à jour.',
          createdAt: DateTime.now(),
        ),
      );
    }

    if (event.type == EventType.courseCompleted) {
      NotificationRepository.add(
        NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          userId: event.userId,
          title: 'Formation terminée 🎉',
          message: 'Votre certificat sera bientôt disponible.',
          createdAt: DateTime.now(),
        ),
      );
    }
  }
}
