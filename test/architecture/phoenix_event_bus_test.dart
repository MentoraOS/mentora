import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/events/engine/phoenix_event_bus.dart';
import 'package:mentora/core/events/listeners/booking_confirmed_listener.dart';
import 'package:mentora/core/events/models/phoenix_event.dart';

void main() {
  group('Phoenix Event Bus', () {
    test('should publish booking confirmed event', () async {
      PhoenixEventBus.clear();

      PhoenixEventBus.register(const BookingConfirmedListener());

      final event = PhoenixEvent(
        id: 'evt_001',
        name: 'booking.confirmed',
        source: 'booking',
        consultationId: 'consultation_001',
        occurredAt: DateTime.now(),
      );

      await PhoenixEventBus.publish(event);

      expect(true, isTrue);
    });
  });
}
