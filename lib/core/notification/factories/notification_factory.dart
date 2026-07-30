import '../../events/models/phoenix_event.dart';

import '../models/notification.dart';
import '../models/notification_channel.dart';
import '../models/notification_priority.dart';
import '../models/notification_status.dart';
import '../templates/notification_template_registry.dart';

class NotificationFactory {
  final NotificationTemplateRegistry templateRegistry;

  const NotificationFactory({required this.templateRegistry});

  Notification? fromEvent(PhoenixEvent event) {
    final template = templateRegistry.resolve(event.name);

    if (template == null) {
      return null;
    }

    return Notification(
      id: 'notification_${event.id}',
      userId: event.userId ?? '',
      title: template.title(event),
      body: template.body(event),
      channel: NotificationChannel.inApp,
      priority: NotificationPriority.normal,
      status: NotificationStatus.pending,
      createdAt: DateTime.now(),
    );
  }
}
