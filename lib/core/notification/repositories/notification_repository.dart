import '../models/notification.dart';
import '../models/notification_result.dart';

abstract class NotificationRepository {
  Future<NotificationResult> create(Notification notification);

  Future<NotificationResult> update(Notification notification);

  Future<Notification?> findById(String notificationId);

  Future<List<Notification>> findByUser(String userId);
}
