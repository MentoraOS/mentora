import '../models/notification.dart';
import '../models/notification_result.dart';
import '../models/notification_status.dart';
import '../repositories/notification_repository.dart';

class NotificationDomain {
  final NotificationRepository repository;

  const NotificationDomain({required this.repository});

  Future<NotificationResult> create(Notification notification) {
    return repository.create(notification);
  }

  Future<NotificationResult> send(Notification notification) async {
    if (notification.status != NotificationStatus.pending) {
      return const NotificationResult(
        success: false,
        message: 'Notification cannot be sent.',
      );
    }

    final sent = notification.copyWith(status: NotificationStatus.sent);

    return repository.update(sent);
  }

  Future<NotificationResult> markDelivered(Notification notification) async {
    final delivered = notification.copyWith(
      status: NotificationStatus.delivered,
    );

    return repository.update(delivered);
  }

  Future<NotificationResult> markRead(Notification notification) async {
    final read = notification.copyWith(status: NotificationStatus.read);

    return repository.update(read);
  }

  Future<Notification?> findById(String id) {
    return repository.findById(id);
  }

  Future<List<Notification>> findByUser(String userId) {
    return repository.findByUser(userId);
  }
}
