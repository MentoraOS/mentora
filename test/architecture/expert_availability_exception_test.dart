import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/expert_availability_exception/expert_availability_exception_application_service.dart';
import 'package:mentora/application/expert_availability_exception/expert_availability_exception_failure.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_application_service.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_failure.dart';
import 'package:mentora/domain/expert_availability_exception/expert_availability_exception.dart';
import 'package:mentora/domain/expert_catalog/consultation_offer.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';

void main() {
  group('ExpertAvailabilityExceptionApplicationService', () {
    test('creates an exception for the session expert', () async {
      final repository = _ExceptionRepository();
      final service = _service(repository);

      await service.create(
        startDate: '2026-08-10',
        endDate: '2026-08-14',
        reason: 'Congé',
      );

      final created = repository.created.single;
      expect(created.$1, 'expert_1');
      expect(created.$2, '2026-08-10');
      expect(created.$3, '2026-08-14');
      expect(created.$4, 'Congé');
    });

    test('lists and deletes the expert exceptions', () async {
      final repository = _ExceptionRepository(
        stored: [_exception(id: 'x1', start: '2026-08-10', end: '2026-08-14')],
      );
      final service = _service(repository);

      expect((await service.listMine()).single.id, 'x1');

      await service.delete('x1');
      expect(repository.deleted, [('x1', 'expert_1')]);
    });

    test('invalid windows fail closed, nothing persisted', () async {
      final repository = _ExceptionRepository();
      final service = _service(repository);

      for (final (start, end, reason) in const [
        ('2026-8-1', '2026-08-02', 'Congé'), // malformed date
        ('2026-08-05', '2026-08-01', 'Congé'), // inverted window
        ('2026-08-01', '2026-08-02', '  '), // blank reason
      ]) {
        await expectLater(
          service.create(startDate: start, endDate: end, reason: reason),
          throwsA(isA<ExpertAvailabilityExceptionInvalidFailure>()),
        );
      }
      expect(repository.created, isEmpty);
    });

    test('a client session is forbidden', () {
      final service = _service(_ExceptionRepository(), isExpert: false);

      expect(
        () => service.listMine(),
        throwsA(isA<ExpertAvailabilityExceptionForbiddenFailure>()),
      );
    });

    test('deleting a foreign or unknown exception fails as not-found', () {
      final service = _service(
        _ExceptionRepository(
          error: const ExpertAvailabilityExceptionNotFoundException(),
        ),
      );

      expect(
        () => service.delete('missing'),
        throwsA(isA<ExpertAvailabilityExceptionNotFoundFailure>()),
      );
    });
  });

  group('C2 funnel — exception filtering', () {
    test('occurrences inside an exception window disappear', () async {
      // Mondays 3, 10, 17, 24, 31 August 2026; block the 10th through 17th.
      final service = _funnel(
        exceptions: [
          _exception(id: 'x1', start: '2026-08-10', end: '2026-08-17'),
        ],
      );

      final occurrences = await service.materializeMonth(
        expertId: 'expert_1',
        offer: _offer(),
        year: 2026,
        month: 8,
      );

      expect(occurrences.map((o) => o.day).toSet(), {3, 24, 31});
    });

    test('a blocked date can no longer be revalidated', () async {
      final service = _funnel(
        exceptions: [
          _exception(id: 'x1', start: '2026-08-10', end: '2026-08-10'),
        ],
      );

      await expectLater(
        service.revalidate(
          expertId: 'expert_1',
          offer: _offer(),
          year: 2026,
          month: 8,
          day: 10,
          hour: 9,
          minute: 0,
        ),
        throwsA(isA<SelectableOccurrenceNotOfferedFailure>()),
      );

      // The unblocked Monday still revalidates.
      await service.revalidate(
        expertId: 'expert_1',
        offer: _offer(),
        year: 2026,
        month: 8,
        day: 3,
        hour: 9,
        minute: 0,
      );
    });

    test('no exceptions means the funnel is unchanged', () async {
      final withEmpty = await _funnel(exceptions: const []).materializeMonth(
        expertId: 'expert_1',
        offer: _offer(),
        year: 2026,
        month: 8,
      );
      final withoutRepository = await _funnel(exceptions: null)
          .materializeMonth(
            expertId: 'expert_1',
            offer: _offer(),
            year: 2026,
            month: 8,
          );

      expect(withEmpty, hasLength(5));
      expect(withoutRepository, hasLength(5));
    });
  });

  group('Availability exceptions — adapter contract', () {
    final source = File(
      'lib/infrastructure/expert_availability_exception/'
      'firestore_expert_availability_exception_repository.dart',
    ).readAsStringSync();

    test('uses its own collection and never writes the expert document', () {
      expect(source, contains("collection('expert_availability_exceptions')"));
      expect(source, isNot(contains("collection('experts')")));
      expect(source, isNot(contains('availabilityUpdatedAt')));
      // Foreign deletion is guarded.
      expect(source, contains("data['expertId'] != expertId"));
    });
  });
}

ExpertAvailabilityException _exception({
  required String id,
  required String start,
  required String end,
}) {
  return ExpertAvailabilityException(
    id: id,
    expertId: 'expert_1',
    startDate: start,
    endDate: end,
    reason: 'Congé',
  );
}

ConsultationOffer _offer() {
  return ConsultationOffer(
    offerId: 'expert:expert_1:consultation:60m',
    expertId: 'expert_1',
    durationMinutes: 60,
    amountMinor: 50000,
    currency: 'XOF',
    clientSelectable: true,
  );
}

ExpertAvailabilityExceptionApplicationService _service(
  _ExceptionRepository repository, {
  bool isExpert = true,
}) {
  return ExpertAvailabilityExceptionApplicationService(
    session: _Session('expert_1', isExpert: isExpert),
    repository: repository,
  );
}

SelectableOccurrenceApplicationService _funnel({
  required List<ExpertAvailabilityException>? exceptions,
}) {
  return SelectableOccurrenceApplicationService(
    expertCatalog: ExpertCatalogApplicationService(
      repository: const _CatalogRepository(),
    ),
    materialization: const CivilOccurrenceMaterializationAdapter(),
    availabilityExceptions: exceptions == null
        ? null
        : _ExceptionRepository(stored: exceptions),
  );
}

final class _ExceptionRepository
    implements ExpertAvailabilityExceptionRepository {
  _ExceptionRepository({this.stored = const [], this.error});

  final List<ExpertAvailabilityException> stored;
  final Object? error;
  final List<(String, String, String, String)> created = [];
  final List<(String, String)> deleted = [];

  @override
  Future<void> create({
    required String expertId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    if (error case final cause?) throw cause;
    created.add((expertId, startDate, endDate, reason));
  }

  @override
  Future<List<ExpertAvailabilityException>> listByExpertId(
    String expertId,
  ) async {
    if (error case final cause?) throw cause;
    return stored;
  }

  @override
  Future<void> delete({required String id, required String expertId}) async {
    if (error case final cause?) throw cause;
    deleted.add((id, expertId));
  }
}

final class _CatalogRepository implements ExpertCatalogRepository {
  const _CatalogRepository();

  static final ExpertCatalogEntry _expert = ExpertCatalogEntry(
    id: 'expert_1',
    name: 'Awa',
    job: 'Coach',
    country: 'ML',
    rating: '5',
    online: true,
    availability: const {
      'Lundi': ['09:00'],
    },
    expertTimezone: 'Africa/Bamako',
  );

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value([_expert]);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    return _expert.id == expertId ? _expert : null;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId, {required this.isExpert});

  @override
  final String? currentUserId;

  @override
  final bool isExpert;

  @override
  bool get isAuthenticated => currentUserId != null;
}
