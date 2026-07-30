import '../models/notification.dart';

abstract class NotificationStrategy {
  const NotificationStrategy();

  Future<List<Notification>> build(Notification notification);
}
