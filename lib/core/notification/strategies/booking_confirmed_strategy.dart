import '../models/notification.dart';
import '../models/notification_channel.dart';
import 'notification_strategy.dart';

class BookingConfirmedStrategy extends NotificationStrategy {
  const BookingConfirmedStrategy();

  @override
  Future<List<Notification>> build(Notification notification) async {
    return [
      notification.copyWith(
        id: '${notification.id}_push',
        channel: NotificationChannel.push,
      ),

      notification.copyWith(
        id: '${notification.id}_in_app',
        channel: NotificationChannel.inApp,
      ),
    ];
  }
}
