import '../models/notification.dart';
import '../models/notification_result.dart';
import 'notification_repository.dart';

class MemoryNotificationRepository implements NotificationRepository {
  final Map<String, Notification> _notifications = {};

  @override
  Future<NotificationResult> create(Notification notification) async {
    _notifications[notification.id] = notification;

    return NotificationResult(success: true, notification: notification);
  }

  @override
  Future<NotificationResult> update(Notification notification) async {
    _notifications[notification.id] = notification;

    return NotificationResult(success: true, notification: notification);
  }

  @override
  Future<Notification?> findById(String notificationId) async {
    return _notifications[notificationId];
  }

  @override
  Future<List<Notification>> findByUser(String userId) async {
    return _notifications.values.where((n) => n.userId == userId).toList();
  }
}
