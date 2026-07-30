import 'notification_channel.dart';
import 'notification_priority.dart';
import 'notification_status.dart';

class Notification {
  final String id;

  final String userId;

  final String title;

  final String body;

  final NotificationChannel channel;

  final NotificationPriority priority;

  final NotificationStatus status;

  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.channel,
    required this.priority,
    required this.status,
    required this.createdAt,
  });

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationChannel? channel,
    NotificationPriority? priority,
    NotificationStatus? status,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      channel: channel ?? this.channel,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
