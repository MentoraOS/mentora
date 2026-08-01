import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_cancellation_application_service.dart';
import 'package:mentora/application/booking/booking_cancellation_failure.dart';
import 'package:mentora/domain/booking/booking_cancellation_repository.dart';

void main() {
  group('Booking cancellation — Booking-owned lifecycle transition', () {
    test('cancels the session client booking through the boundary', () async {
      final repository = _Repository();
      final service = _service(repository);

      await service.cancel('booking_1');

      expect(repository.calls, [('booking_1', 'client_session')]);
    });

    test('an unauthenticated session is rejected before the boundary', () {
      final repository = _Repository();
      final service = _service(repository, userId: null);

      expect(
        () => service.cancel('booking_1'),
        throwsA(isA<BookingCancellationUnauthenticatedFailure>()),
      );
      expect(repository.calls, isEmpty);
    });

    test('a missing or foreign booking fails as not-found', () {
      final service = _service(
        _Repository(error: const BookingCancellationNotFoundException()),
      );

      expect(
        () => service.cancel('booking_1'),
        throwsA(isA<BookingCancellationNotFoundFailure>()),
      );
    });

    test('a non-cancellable state fails with its current status', () {
      final service = _service(
        _Repository(
          error: const BookingCancellationStateException(
            currentStatus: 'completed',
          ),
        ),
      );

      expect(
        () => service.cancel('booking_1'),
        throwsA(
          isA<BookingCancellationInvalidStateFailure>().having(
            (failure) => failure.currentStatus,
            'currentStatus',
            'completed',
          ),
        ),
      );
    });

    test('infrastructure failures stay typed and are never success', () {
      final service = _service(_Repository(error: StateError('offline')));

      expect(
        () => service.cancel('booking_1'),
        throwsA(isA<BookingCancellationRepositoryFailure>()),
      );
    });
  });

  group('Booking cancellation — adapter contract', () {
    final source = File(
      'lib/infrastructure/booking/'
      'firestore_booking_cancellation_repository.dart',
    ).readAsStringSync();

    test('guards ownership and state, keeps history, records the actor', () {
      expect(source, contains('runTransaction<void>'));
      expect(source, contains("data['clientId'] != clientId"));
      expect(source, contains("'pending_payment'"));
      expect(source, contains("'confirmed'"));
      expect(source, contains("'status': 'cancelled'"));
      expect(source, contains("'cancelledAt': FieldValue.serverTimestamp()"));
      expect(source, contains("'cancelledBy': 'client'"));
      // Nothing is deleted: the update is partial and keeps every fact.
      expect(source, contains('transaction.update'));
      expect(source, isNot(contains('.delete(')));
      expect(source, isNot(contains('transaction.set(')));
    });

    test('a completed consultation is not cancellable', () {
      expect(source, isNot(contains("'completed'")));
    });

    test('cancellation adds no refund, release or expiration authority', () {
      for (final forbidden in const [
        'refund',
        'reservationExpiresAt',
        'AuthoritativeClock',
        '_booking_creation_slots',
        'startUtc',
        'endUtc',
      ]) {
        expect(source, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}

BookingCancellationApplicationService _service(
  _Repository repository, {
  String? userId = 'client_session',
}) {
  return BookingCancellationApplicationService(
    session: _Session(userId),
    repository: repository,
  );
}

final class _Repository implements BookingCancellationRepository {
  _Repository({this.error});

  final Object? error;
  final List<(String, String)> calls = [];

  @override
  Future<void> cancel({
    required String bookingId,
    required String clientId,
  }) async {
    if (error case final cause?) throw cause;
    calls.add((bookingId, clientId));
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
