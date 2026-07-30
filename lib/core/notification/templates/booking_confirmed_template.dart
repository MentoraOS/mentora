import '../../events/models/phoenix_event.dart';
import 'notification_template.dart';

class BookingConfirmedTemplate extends NotificationTemplate {
  const BookingConfirmedTemplate();

  @override
  String get eventName => 'booking.confirmed';

  @override
  String title(PhoenixEvent event) {
    return 'Booking Confirmed';
  }

  @override
  String body(PhoenixEvent event) {
    return 'Your booking has been confirmed successfully.';
  }
}
