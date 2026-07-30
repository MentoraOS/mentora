import 'notification.dart';

class NotificationResult {
  final bool success;

  final String? message;

  final Notification? notification;

  const NotificationResult({
    required this.success,
    this.message,
    this.notification,
  });
}
