import '../models/phoenix_event.dart';
import 'phoenix_event_listener.dart';

class BookingConfirmedListener extends PhoenixEventListener {
  const BookingConfirmedListener();

  @override
  bool supports(PhoenixEvent event) {
    return event.name == 'booking.confirmed';
  }

  @override
  Future<void> handle(PhoenixEvent event) async {
    // Pour l’instant, on garde simple.
    // Plus tard ici :
    // - NotificationEngine
    // - AnalyticsEngine
    // - AuditEngine

    print('Booking confirmed event received: ${event.consultationId}');
  }
}
