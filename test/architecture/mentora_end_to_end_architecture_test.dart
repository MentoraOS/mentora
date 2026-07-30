import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/events/engine/phoenix_event_bus.dart';
import 'package:mentora/core/events/models/phoenix_event.dart';
import 'package:mentora/core/phoenix/bootstrap/phoenix_bootstrap.dart';

void main() {
  group('Mentora End-to-End Architecture', () {
    test(
      'should run Phoenix V1 flow from booking confirmed event to notification',
      () async {
        PhoenixBootstrap.reset();

        await PhoenixBootstrap.initialize();

        final event = PhoenixEvent(
          id: 'evt_e2e_001',
          name: 'booking.confirmed',
          source: 'booking',
          userId: 'client_001',
          consultationId: 'consultation_001',
          payload: const {'bookingId': 'booking_001', 'expertId': 'expert_001'},
          occurredAt: DateTime.now(),
        );

        await PhoenixEventBus.publish(event);

        final notifications = await PhoenixBootstrap.notificationEngine
            .findByUser('client_001');

        expect(notifications.length, 2);
        expect(notifications.first.title, 'Booking Confirmed');
        expect(
          notifications.any((notification) => notification.body.isNotEmpty),
          isTrue,
        );
      },
    );
  });
}
