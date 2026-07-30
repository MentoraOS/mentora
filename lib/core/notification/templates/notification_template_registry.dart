import '../../events/registry/phoenix_registry.dart';
import 'notification_template.dart';

class NotificationTemplateRegistry
    extends PhoenixRegistry<NotificationTemplate> {
  void registerTemplate(NotificationTemplate template) {
    register(template.eventName, template);
  }
}
