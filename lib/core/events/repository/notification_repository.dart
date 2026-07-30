import '../models/notification.dart';

class NotificationRepository {
  NotificationRepository._();

  static final List<NotificationModel> _notifications = [];

  static List<NotificationModel> findAll() {
    return List.unmodifiable(_notifications);
  }

  static List<NotificationModel> forUser(String userId) {
    return _notifications
        .where((notification) => notification.userId == userId)
        .toList();
  }

  static void add(NotificationModel notification) {
    _notifications.add(notification);
  }

  static int unreadCount(String userId) {
    return _notifications.where((notification) {
      return notification.userId == userId &&
          notification.status == NotificationStatus.unread;
    }).length;
  }

  static void clear() {
    _notifications.clear();
  }
}
