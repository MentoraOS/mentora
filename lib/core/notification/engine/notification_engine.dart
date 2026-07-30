import '../domains/notification_domain.dart';
import '../models/notification.dart';
import '../models/notification_result.dart';

class NotificationEngine {
  final NotificationDomain domain;

  const NotificationEngine({required this.domain});

  Future<NotificationResult> create(Notification notification) {
    return domain.create(notification);
  }

  Future<NotificationResult> send(Notification notification) {
    return domain.send(notification);
  }

  Future<NotificationResult> markDelivered(Notification notification) {
    return domain.markDelivered(notification);
  }

  Future<NotificationResult> markRead(Notification notification) {
    return domain.markRead(notification);
  }

  Future<Notification?> findById(String id) {
    return domain.findById(id);
  }

  Future<List<Notification>> findByUser(String userId) {
    return domain.findByUser(userId);
  }
}
