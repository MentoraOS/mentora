import '../models/notification.dart';
import '../models/notification_channel.dart';

class NotificationRouter {
  const NotificationRouter();

  Future<void> route(Notification notification) async {
    switch (notification.channel) {
      case NotificationChannel.push:
        await _sendPush(notification);
        break;

      case NotificationChannel.email:
        await _sendEmail(notification);
        break;

      case NotificationChannel.sms:
        await _sendSms(notification);
        break;

      case NotificationChannel.whatsapp:
        await _sendWhatsApp(notification);
        break;

      case NotificationChannel.inApp:
        await _sendInApp(notification);
        break;
    }
  }

  Future<void> _sendPush(Notification notification) async {}

  Future<void> _sendEmail(Notification notification) async {}

  Future<void> _sendSms(Notification notification) async {}

  Future<void> _sendWhatsApp(Notification notification) async {}

  Future<void> _sendInApp(Notification notification) async {}
}
