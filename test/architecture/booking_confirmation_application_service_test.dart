import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_confirmation_application_service.dart';
import 'package:mentora/application/booking/booking_confirmation_failure.dart';
import 'package:mentora/domain/booking/booking_confirmation_repository.dart';

void main() {
  group('AD-022 D12 — booking confirmation on paid outcome', () {
    test('confirms the session client booking through the boundary', () async {
      final repository = _Repository();
      final service = _service(repository);

      await service.confirmPaid('booking_1');

      expect(repository.calls, [('booking_1', 'client_session')]);
    });

    test('an unauthenticated session is rejected before the boundary', () {
      final repository = _Repository();
      final service = _service(repository, userId: null);

      expect(
        () => service.confirmPaid('booking_1'),
        throwsA(isA<BookingConfirmationUnauthenticatedFailure>()),
      );
      expect(repository.calls, isEmpty);
    });

    test('a missing or foreign booking fails as not-found', () {
      final service = _service(
        _Repository(error: const BookingConfirmationNotFoundException()),
      );

      expect(
        () => service.confirmPaid('booking_1'),
        throwsA(isA<BookingConfirmationNotFoundFailure>()),
      );
    });

    test('a booking not awaiting payment fails with its current state', () {
      final service = _service(
        _Repository(
          error: const BookingConfirmationStateException(
            currentStatus: 'confirmed',
          ),
        ),
      );

      expect(
        () => service.confirmPaid('booking_1'),
        throwsA(
          isA<BookingConfirmationInvalidStateFailure>().having(
            (failure) => failure.currentStatus,
            'currentStatus',
            'confirmed',
          ),
        ),
      );
    });

    test('infrastructure failures stay typed and are never success', () {
      final service = _service(_Repository(error: StateError('offline')));

      expect(
        () => service.confirmPaid('booking_1'),
        throwsA(isA<BookingConfirmationRepositoryFailure>()),
      );
    });
  });

  group('AD-022 D12 — confirmation adapter contract', () {
    final source = File(
      'lib/infrastructure/booking/'
      'firestore_booking_confirmation_repository.dart',
    ).readAsStringSync();

    test('transitions pending_payment to confirmed transactionally', () {
      expect(source, contains('runTransaction<void>'));
      expect(source, contains("!= 'pending_payment'"));
      expect(source, contains("'status': 'confirmed'"));
      expect(source, contains("'paymentStatus': 'paid'"));
      // The client owns the booking it confirms; foreign bookings read as
      // not-found.
      expect(source, contains("data['clientId'] != clientId"));
    });

    test('confirmation adds no expiration and no release authority', () {
      for (final forbidden in const [
        'reservationExpiresAt',
        'AuthoritativeClock',
        'delete',
        'not-occupying',
        'released',
      ]) {
        expect(source, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}

BookingConfirmationApplicationService _service(
  _Repository repository, {
  String? userId = 'client_session',
}) {
  return BookingConfirmationApplicationService(
    session: _Session(userId),
    repository: repository,
  );
}

final class _Repository implements BookingConfirmationRepository {
  _Repository({this.error});

  final Object? error;
  final List<(String, String)> calls = [];

  @override
  Future<void> confirmPaid({
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
