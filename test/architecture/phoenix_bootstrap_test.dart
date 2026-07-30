import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/events/engine/phoenix_event_bus.dart';
import 'package:mentora/core/events/models/phoenix_event.dart';
import 'package:mentora/core/phoenix/bootstrap/phoenix_bootstrap.dart';

void main() {
  group('Phoenix Bootstrap', () {
    test(
      'should initialize notification system and handle booking confirmed event',
      () async {
        PhoenixBootstrap.reset();

        await PhoenixBootstrap.initialize();

        final event = PhoenixEvent(
          id: 'evt_bootstrap_001',
          name: 'booking.confirmed',
          source: 'booking',
          userId: 'client_001',
          consultationId: 'consultation_001',
          occurredAt: DateTime.now(),
        );

        await PhoenixEventBus.publish(event);

        final notifications = await PhoenixBootstrap.notificationEngine
            .findByUser('client_001');

        expect(notifications.length, 2);
        expect(notifications.first.title, 'Booking Confirmed');
      },
    );
  });
}
