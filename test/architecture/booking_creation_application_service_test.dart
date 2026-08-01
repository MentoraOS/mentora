import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_creation_application_service.dart';
import 'package:mentora/application/booking/booking_creation_failure.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/scheduling/civil_selection.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_application_service.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_failure.dart';
import 'package:mentora/domain/booking/booking_creation.dart';
import 'package:mentora/domain/booking/booking_creation_repository.dart';
import 'package:mentora/domain/expert_catalog/consultation_offer.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';

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
      'snapshots the canonical occurrence and forwards exact values',
      () async {
        final repository = _Repository(result: 'booking_authoritative');
        final service = _service(repository);

        final result = await _create(service);
        final booking = repository.booking!;

        expect(result, 'booking_authoritative');
        expect(booking.clientId, 'client_session');
        expect(booking.expertId, 'expert_1');
        expect(booking.expertName, 'Expert');
        expect(booking.clientNeed, 'Need');
        expect(booking.aiSummary, 'Summary');
        expect(booking.agoraChannel, 'mentora_test_channel');

        // AD-022 C3: Monday 3 August 2026, 09:00 Africa/Bamako, 60 minutes
        // becomes the canonical UTC occurrence, identity preserved.
        expect(booking.startUtc, DateTime.utc(2026, 8, 3, 9, 0));
        expect(booking.endUtc, DateTime.utc(2026, 8, 3, 10, 0));
        expect(booking.expertTimezone, 'Africa/Bamako');

        // Clarification C decision 12: legacy fields become deterministic
        // derived transport, no longer 'Lundi'.
        expect(booking.bookingDate, '2026-08-03');
        expect(booking.bookingTime, '09:00');
      },
    );

    test('a selection that is not offered fails before persistence', () {
      final repository = _Repository();
      final service = _service(repository);

      expect(
        () => _create(service, hour: 9, minute: 30),
        throwsA(isA<SelectableOccurrenceNotOfferedFailure>()),
      );
      expect(repository.calls, 0);
    });

    test('a missing expert timezone fails before persistence', () {
      final repository = _Repository();
      final service = _service(repository, expertTimezone: null);

      expect(
        () => _create(service),
        throwsA(isA<SelectableOccurrenceTimezoneUnavailableFailure>()),
      );
      expect(repository.calls, 0);
    });

    test('an unsupported expert timezone fails before persistence', () {
      // Europe/Paris is a valid identity but outside the launch-market
      // resolver: interpretation fails closed, nothing is persisted.
      final repository = _Repository();
      final service = _service(repository, expertTimezone: 'Europe/Paris');

      expect(
        () => _create(service),
        throwsA(isA<SelectableOccurrenceTimezoneUnavailableFailure>()),
      );
      expect(repository.calls, 0);
    });

    test('a later Catalog timezone change never moves the snapshot', () async {
      final repository = _Repository();
      final catalog = _CatalogRepository(_expert());
      final service = _service(repository, catalog: catalog);

      await _create(service);
      final booking = repository.booking!;

      // The expert later declares a different timezone; the accepted
      // reservation keeps the identity and instants snapshotted at creation.
      catalog.expert = _expert(expertTimezone: 'Africa/Dakar');

      expect(booking.startUtc, DateTime.utc(2026, 8, 3, 9, 0));
      expect(booking.endUtc, DateTime.utc(2026, 8, 3, 10, 0));
      expect(booking.expertTimezone, 'Africa/Bamako');
    });

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

ExpertCatalogEntry _expert({String? expertTimezone = 'Africa/Bamako'}) {
  return ExpertCatalogEntry(
    id: 'expert_1',
    name: 'Expert',
    job: 'Coach',
    country: 'ML',
    rating: '5',
    online: true,
    availability: const {
      'Lundi': ['09:00'],
    },
    expertTimezone: expertTimezone,
  );
}

BookingCreationApplicationService _service(
  _Repository repository, {
  String? userId = 'client_session',
  String? expertTimezone = 'Africa/Bamako',
  _CatalogRepository? catalog,
}) {
  final catalogRepository =
      catalog ?? _CatalogRepository(_expert(expertTimezone: expertTimezone));
  return BookingCreationApplicationService(
    session: _Session(userId),
    repository: repository,
    selectableOccurrences: SelectableOccurrenceApplicationService(
      expertCatalog: ExpertCatalogApplicationService(
        repository: catalogRepository,
      ),
      materialization: const CivilOccurrenceMaterializationAdapter(),
    ),
    interpretation: const CivilOccurrenceInterpretationAdapter(
      resolver: LaunchMarketTimezoneResolver(),
    ),
    channelFactory: () => 'mentora_test_channel',
  );
}

Future<String> _create(
  BookingCreationApplicationService service, {
  String expertId = 'expert_1',
  ConsultationOffer? offer,
  int hour = 9,
  int minute = 0,
}) {
  return service.create(
    expertId: expertId,
    expertName: 'Expert',
    // Monday 3 August 2026 — the canonical AD-022 example.
    occurrence: CivilSelection(
      year: 2026,
      month: 8,
      day: 3,
      hour: hour,
      minute: minute,
      durationMinutes: 60,
    ),
    clientNeed: 'Need',
    aiSummary: 'Summary',
    offer: offer ?? _offer(),
  );
}

ConsultationOffer _offer({
  String expertId = 'expert_1',
  bool clientSelectable = true,
}) {
  return ConsultationOffer(
    offerId: 'expert:$expertId:consultation:60m',
    expertId: expertId,
    durationMinutes: 60,
    amountMinor: 50000,
    currency: 'XOF',
    clientSelectable: clientSelectable,
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

final class _CatalogRepository implements ExpertCatalogRepository {
  _CatalogRepository(this.expert);

  ExpertCatalogEntry expert;

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value([expert]);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    return expert.id == expertId ? expert : null;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
