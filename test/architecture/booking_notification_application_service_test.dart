import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/notification/booking_notification_application_service.dart';
import 'package:mentora/domain/notification/booking_notification_provider.dart';
import 'package:mentora/infrastructure/notification/simulated_notification_provider.dart';

void main() {
  group('Booking notifications — best-effort lifecycle events', () {
    test('creation notifies the client and the expert distinctly', () async {
      final provider = SimulatedNotificationProvider();
      final service = _service(provider);

      await service.notifyBookingCreated(
        bookingId: 'booking_1',
        expertId: 'expert_1',
        expertName: 'Awa',
        displayDate: '03/08/2026',
        displayTime: '09:00',
      );

      expect(provider.sent, hasLength(2));

      final client = provider.sent.singleWhere(
        (n) => n.audience == BookingNotificationAudience.client,
      );
      final expert = provider.sent.singleWhere(
        (n) => n.audience == BookingNotificationAudience.expert,
      );

      expect(client.recipientId, 'client_1');
      expect(client.event, BookingNotificationEvent.bookingCreated);
      expect(client.bookingId, 'booking_1');
      expect(client.body, contains('Awa'));
      expect(client.body, contains('03/08/2026'));

      expect(expert.recipientId, 'expert_1');
      expect(expert.event, BookingNotificationEvent.bookingCreated);
      expect(expert.body, contains('09:00'));
    });

    test('every lifecycle event reaches both parties', () async {
      final provider = SimulatedNotificationProvider();
      final service = _service(provider);

      Future<void> run(
        Future<void> Function({
          required String bookingId,
          required String expertId,
          required String expertName,
          required String displayDate,
          required String displayTime,
        })
        notify,
      ) {
        return notify(
          bookingId: 'booking_1',
          expertId: 'expert_1',
          expertName: 'Awa',
          displayDate: '03/08/2026',
          displayTime: '09:00',
        );
      }

      await run(service.notifyBookingConfirmed);
      await run(service.notifyBookingCancelled);
      await run(service.notifyBookingRescheduled);
      await run(service.notifyConsultationUpcoming);

      expect(provider.sent, hasLength(8));
      expect(provider.sent.map((n) => n.event).toSet(), {
        BookingNotificationEvent.bookingConfirmed,
        BookingNotificationEvent.bookingCancelled,
        BookingNotificationEvent.bookingRescheduled,
        BookingNotificationEvent.consultationUpcoming,
      });
    });

    test('a provider failure never fails the caller workflow', () async {
      final service = BookingNotificationApplicationService(
        session: _Session('client_1'),
        provider: const _ThrowingProvider(),
      );

      await service.notifyBookingConfirmed(
        bookingId: 'booking_1',
        expertId: 'expert_1',
        expertName: 'Awa',
        displayDate: '03/08/2026',
        displayTime: '09:00',
      );
      // Reaching this point without an exception is the guarantee.
    });

    test('a missing session still notifies the expert only', () async {
      final provider = SimulatedNotificationProvider();
      final service = BookingNotificationApplicationService(
        session: _Session(null),
        provider: provider,
      );

      await service.notifyBookingCreated(
        bookingId: 'booking_1',
        expertId: 'expert_1',
        expertName: 'Awa',
        displayDate: '03/08/2026',
        displayTime: '09:00',
      );

      expect(provider.sent, hasLength(1));
      expect(provider.sent.single.audience, BookingNotificationAudience.expert);
    });

    test('a blank expert identity is skipped without failing', () async {
      final provider = SimulatedNotificationProvider();
      final service = _service(provider);

      await service.notifyBookingCreated(
        bookingId: 'booking_1',
        expertId: ' ',
        expertName: 'Awa',
        displayDate: '03/08/2026',
        displayTime: '09:00',
      );

      expect(provider.sent, hasLength(1));
      expect(provider.sent.single.audience, BookingNotificationAudience.client);
    });
  });
}

BookingNotificationApplicationService _service(
  BookingNotificationProvider provider,
) {
  return BookingNotificationApplicationService(
    session: _Session('client_1'),
    provider: provider,
  );
}

final class _ThrowingProvider implements BookingNotificationProvider {
  const _ThrowingProvider();

  @override
  Future<void> send(BookingNotification notification) async {
    throw StateError('channel down');
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
