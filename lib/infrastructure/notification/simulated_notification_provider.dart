import '../../domain/notification/booking_notification_provider.dart';

/// Development stand-in for a real notification provider.
///
/// Records every notification in memory and completes immediately. Swapping
/// in FCM, OneSignal or any other channel means replacing this adapter only.
final class SimulatedNotificationProvider
    implements BookingNotificationProvider {
  SimulatedNotificationProvider();

  final List<BookingNotification> sent = [];

  @override
  Future<void> send(BookingNotification notification) async {
    sent.add(notification);
  }
}
