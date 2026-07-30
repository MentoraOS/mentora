import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_creation_application_service.dart';
import 'package:mentora/application/booking/booking_creation_failure.dart';
import 'package:mentora/domain/booking/booking_creation.dart';
import 'package:mentora/domain/booking/booking_creation_repository.dart';

void main() {
  group('BookingCreationApplicationService', () {
    test('rejects an unauthenticated session before persistence', () {
      final repository = _Repository();
      final service = _service(repository, userId: null);

      expect(
        () => _create(service),
        throwsA(isA<BookingCreationUnauthenticatedFailure>()),
      );
      expect(repository.calls, 0);
    });

    test('rejects invalid input before persistence', () {
      final repository = _Repository();
      final service = _service(repository);

      expect(
        () => _create(service, expertId: ' '),
        throwsA(isA<BookingCreationInvalidRequestFailure>()),
      );
      expect(repository.calls, 0);
    });

    test(
      'forwards exact values with authoritative client and returns ID',
      () async {
        final repository = _Repository(result: 'booking_authoritative');
        final service = _service(repository);

        final result = await _create(service);
        final booking = repository.booking!;

        expect(result, 'booking_authoritative');
        expect(booking.clientId, 'client_session');
        expect(booking.expertId, 'expert_1');
        expect(booking.expertName, 'Expert');
        expect(booking.bookingDate, ' Lundi ');
        expect(booking.bookingTime, ' 09:00 ');
        expect(booking.clientNeed, 'Need');
        expect(booking.aiSummary, 'Summary');
        expect(booking.agoraChannel, 'mentora_test_channel');
      },
    );

    test('preserves conflict as an explicit Application failure', () {
      final service = _service(
        _Repository(error: const BookingCreationConflictException()),
      );
      expect(
        () => _create(service),
        throwsA(isA<BookingCreationSlotConflictFailure>()),
      );
    });

    test('distinguishes unavailable, malformed, and unknown persistence', () {
      final unavailable = StateError('offline');
      final malformed = const FormatException('invalid persisted state');
      final unknown = StateError('write failed');

      expect(
        () => _create(
          _service(
            _Repository(
              error: BookingCreationRepositoryException(
                cause: unavailable,
                infrastructureUnavailable: true,
              ),
            ),
          ),
        ),
        throwsA(isA<BookingCreationInfrastructureUnavailableFailure>()),
      );
      expect(
        () => _create(
          _service(
            _Repository(
              error: BookingCreationRepositoryException(
                cause: malformed,
                malformedData: true,
              ),
            ),
          ),
        ),
        throwsA(isA<BookingCreationMalformedDataFailure>()),
      );
      expect(
        () => _create(
          _service(
            _Repository(
              error: BookingCreationRepositoryException(cause: unknown),
            ),
          ),
        ),
        throwsA(isA<BookingCreationPersistenceFailure>()),
      );
    });
  });
}

BookingCreationApplicationService _service(
  _Repository repository, {
  String? userId = 'client_session',
}) {
  return BookingCreationApplicationService(
    session: _Session(userId),
    repository: repository,
    channelFactory: () => 'mentora_test_channel',
  );
}

Future<String> _create(
  BookingCreationApplicationService service, {
  String expertId = 'expert_1',
}) {
  return service.create(
    expertId: expertId,
    expertName: 'Expert',
    bookingDate: ' Lundi ',
    bookingTime: ' 09:00 ',
    clientNeed: 'Need',
    aiSummary: 'Summary',
  );
}

final class _Repository implements BookingCreationRepository {
  _Repository({this.result = 'booking_1', this.error});

  final String result;
  final Object? error;
  int calls = 0;
  BookingCreation? booking;

  @override
  Future<String> create(BookingCreation booking) async {
    calls++;
    this.booking = booking;
    if (error case final cause?) throw cause;
    return result;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
