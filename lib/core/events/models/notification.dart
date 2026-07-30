enum NotificationStatus { unread, read, archived }

class NotificationModel {
  final String id;

  final String userId;

  final String title;

  final String message;

  final String? action;

  final DateTime createdAt;

  final NotificationStatus status;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    this.action,
    required this.createdAt,
    this.status = NotificationStatus.unread,
  });

  NotificationModel copyWith({NotificationStatus? status}) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      message: message,
      action: action,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}
