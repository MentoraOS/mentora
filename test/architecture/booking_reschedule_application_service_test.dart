import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_reschedule_application_service.dart';
import 'package:mentora/application/booking/booking_reschedule_failure.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_failure.dart';
import 'package:mentora/domain/booking/booking_reschedule_repository.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';

void main() {
  group('Booking reschedule — C2/C3 path reuse', () {
    test('a legitimately offered new slot updates the full snapshot', () async {
      final repository = _Repository();
      final service = _service(repository);

      // Monday 10 August 2026, 10:00 — offered by the fixture availability.
      await service.reschedule(
        bookingId: 'booking_1',
        expertId: 'expert_1',
        durationMinutes: 60,
        year: 2026,
        month: 8,
        day: 10,
        hour: 10,
        minute: 0,
      );

      final call = repository.calls.single;
      expect(call.$1, 'booking_1');
      expect(call.$2, 'client_session');

      final update = call.$3;
      expect(update.startUtc, DateTime.utc(2026, 8, 10, 10, 0));
      expect(update.endUtc, DateTime.utc(2026, 8, 10, 11, 0));
      expect(update.expertTimezone, 'Africa/Bamako');
      expect(update.bookingDate, '2026-08-10');
      expect(update.bookingTime, '10:00');
    });

    test(
      'the reschedule calendar materializes with the booking duration',
      () async {
        final service = _service(_Repository());

        final occurrences = await service.materializeMonth(
          expertId: 'expert_1',
          durationMinutes: 60,
          year: 2026,
          month: 8,
        );

        // Five Mondays in August 2026, two ticks each.
        expect(occurrences, hasLength(10));
        expect(occurrences.first.durationMinutes, 60);
      },
    );

    test('a non-offered date or time is rejected before persistence', () async {
      final repository = _Repository();
      final service = _service(repository);

      for (final (day, hour, minute) in const [
        (11, 10, 0), // Tuesday — not offered.
        (10, 10, 30), // Offered day, non-offered time.
      ]) {
        await expectLater(
          service.reschedule(
            bookingId: 'booking_1',
            expertId: 'expert_1',
            durationMinutes: 60,
            year: 2026,
            month: 8,
            day: day,
            hour: hour,
            minute: minute,
          ),
          throwsA(isA<SelectableOccurrenceNotOfferedFailure>()),
        );
      }
      expect(repository.calls, isEmpty);
    });

    test('a missing expert or timezone fails closed', () async {
      await expectLater(
        _service(_Repository(), experts: const []).reschedule(
          bookingId: 'booking_1',
          expertId: 'expert_1',
          durationMinutes: 60,
          year: 2026,
          month: 8,
          day: 10,
          hour: 10,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceExpertNotFoundFailure>()),
      );

      await expectLater(
        _service(
          _Repository(),
          experts: [_expert(expertTimezone: null)],
        ).reschedule(
          bookingId: 'booking_1',
          expertId: 'expert_1',
          durationMinutes: 60,
          year: 2026,
          month: 8,
          day: 10,
          hour: 10,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceTimezoneUnavailableFailure>()),
      );
    });

    test('an unauthenticated session is rejected before any work', () {
      final repository = _Repository();
      final service = _service(repository, userId: null);

      expect(
        () => service.reschedule(
          bookingId: 'booking_1',
          expertId: 'expert_1',
          durationMinutes: 60,
          year: 2026,
          month: 8,
          day: 10,
          hour: 10,
          minute: 0,
        ),
        throwsA(isA<BookingRescheduleUnauthenticatedFailure>()),
      );
      expect(repository.calls, isEmpty);
    });

    test('lifecycle failures from the boundary stay typed', () async {
      Future<void> run(Object error, Matcher matcher) {
        return expectLater(
          _service(_Repository(error: error)).reschedule(
            bookingId: 'booking_1',
            expertId: 'expert_1',
            durationMinutes: 60,
            year: 2026,
            month: 8,
            day: 10,
            hour: 10,
            minute: 0,
          ),
          throwsA(matcher),
        );
      }

      await run(
        const BookingRescheduleNotFoundException(),
        isA<BookingRescheduleNotFoundFailure>(),
      );
      await run(
        const BookingRescheduleStateException(currentStatus: 'cancelled'),
        isA<BookingRescheduleInvalidStateFailure>(),
      );
      await run(
        const BookingRescheduleConsistencyException(),
        isA<BookingRescheduleInconsistentFailure>(),
      );
      await run(
        StateError('offline'),
        isA<BookingRescheduleRepositoryFailure>(),
      );
    });
  });

  group('Booking reschedule — adapter contract', () {
    final source = File(
      'lib/infrastructure/booking/'
      'firestore_booking_reschedule_repository.dart',
    ).readAsStringSync();

    test('guards ownership, state and snapshot duration, keeps history', () {
      expect(source, contains('runTransaction<void>'));
      expect(source, contains("data['clientId'] != clientId"));
      expect(source, contains('duration != newMinutes'));
      expect(
        source,
        contains("changes['previousStartUtc'] = data['startUtc']"),
      );
      expect(source, contains("changes['previousEndUtc'] = data['endUtc']"));
      expect(source, contains("'rescheduledAt': FieldValue.serverTimestamp()"));
      // Partial update only; nothing is deleted or replaced wholesale.
      expect(source, contains('transaction.update'));
      expect(source, isNot(contains('.delete(')));
      expect(source, isNot(contains('transaction.set(')));
      // Completed and cancelled reservations cannot move.
      expect(source, isNot(contains("'completed'")));
      expect(source, isNot(contains("'cancelled'")));
    });

    test('reschedule adds no refund, release or expiration authority', () {
      for (final forbidden in const [
        'refund',
        'reservationExpiresAt',
        'AuthoritativeClock',
        '_booking_creation_slots',
      ]) {
        expect(source, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}

ExpertCatalogEntry _expert({String? expertTimezone = 'Africa/Bamako'}) {
  return ExpertCatalogEntry(
    id: 'expert_1',
    name: 'Awa',
    job: 'Coach',
    country: 'ML',
    rating: '5',
    online: true,
    availability: const {
      'Lundi': ['09:00', '10:00'],
    },
    expertTimezone: expertTimezone,
  );
}

BookingRescheduleApplicationService _service(
  _Repository repository, {
  String? userId = 'client_session',
  List<ExpertCatalogEntry>? experts,
}) {
  return BookingRescheduleApplicationService(
    session: _Session(userId),
    repository: repository,
    expertCatalog: ExpertCatalogApplicationService(
      repository: _CatalogRepository(experts ?? [_expert()]),
    ),
    materialization: const CivilOccurrenceMaterializationAdapter(),
    interpretation: const CivilOccurrenceInterpretationAdapter(
      resolver: LaunchMarketTimezoneResolver(),
    ),
  );
}

final class _Repository implements BookingRescheduleRepository {
  _Repository({this.error});

  final Object? error;
  final List<(String, String, BookingRescheduleUpdate)> calls = [];

  @override
  Future<void> reschedule({
    required String bookingId,
    required String clientId,
    required BookingRescheduleUpdate update,
  }) async {
    if (error case final cause?) throw cause;
    calls.add((bookingId, clientId, update));
  }
}

final class _CatalogRepository implements ExpertCatalogRepository {
  const _CatalogRepository(this.experts);

  final List<ExpertCatalogEntry> experts;

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value(experts);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    for (final expert in experts) {
      if (expert.id == expertId) return expert;
    }
    return null;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
