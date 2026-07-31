import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_failure.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/infrastructure/expert_catalog/expert_catalog_firestore_mapper.dart';

ExpertCatalogEntry expert({
  String id = 'expert_1',
  String country = 'ML',
  String? expertTimezone,
}) {
  return ExpertCatalogEntry(
    id: id,
    name: 'Awa',
    job: 'Coach',
    country: country,
    rating: '4.8',
    online: true,
    availability: const <String, List<String>>{},
    expertTimezone: expertTimezone,
  );
}

ExpertCatalogEntry mapped(Map<String, dynamic> data, {String id = 'expert_1'}) {
  return const ExpertCatalogFirestoreMapper().fromMap(
    documentId: id,
    data: data,
  );
}

void main() {
  group('AD-022 Wave C1 — authoritative lookup', () {
    test('returns the expert when present', () async {
      final service = ExpertCatalogApplicationService(
        repository: _Repository(
          experts: [
            expert(),
            expert(id: 'expert_2'),
          ],
        ),
      );

      final found = await service.findById('expert_2');

      expect(found, isNotNull);
      expect(found!.id, 'expert_2');
    });

    test('returns null when the expert does not exist', () async {
      final service = ExpertCatalogApplicationService(
        repository: _Repository(experts: [expert()]),
      );

      expect(await service.findById('missing_expert'), isNull);
    });

    test('requests exactly the identity it was asked for', () async {
      final repository = _Repository(experts: [expert()]);
      final service = ExpertCatalogApplicationService(repository: repository);

      await service.findById('expert_1');

      expect(repository.requestedIds, ['expert_1']);
    });

    test('watchExperts behaviour is unchanged', () async {
      final service = ExpertCatalogApplicationService(
        repository: _Repository(
          experts: [
            expert(),
            expert(id: 'expert_2'),
          ],
        ),
      );

      final experts = await service.watchExperts().first;

      expect(experts.map((entry) => entry.id), ['expert_1', 'expert_2']);
    });
  });

  group('AD-022 Wave C1 — failure semantics', () {
    test('an infrastructure failure is never reported as not-found', () async {
      final service = ExpertCatalogApplicationService(
        repository: _Repository(error: StateError('offline')),
      );

      await expectLater(
        service.findById('expert_1'),
        throwsA(isA<ExpertCatalogInfrastructureFailure>()),
      );
    });

    test('an unexpected error is translated, not leaked', () async {
      final service = ExpertCatalogApplicationService(
        repository: _RawThrowingRepository(),
      );

      await expectLater(
        service.findById('expert_1'),
        throwsA(isA<ExpertCatalogInfrastructureFailure>()),
      );
    });
  });

  group('AD-022 Wave C1 — expert timezone preservation', () {
    test('a declared identity survives the lookup verbatim', () async {
      final service = ExpertCatalogApplicationService(
        repository: _Repository(
          experts: [expert(expertTimezone: 'Africa/Bamako')],
        ),
      );

      final found = await service.findById('expert_1');

      expect(found!.expertTimezone, 'Africa/Bamako');
      expect(found.expertTimezone, isNot('UTC'));
      expect(found.expertTimezone, isNot('+00:00'));
    });

    test('an expert without a timezone stays readable', () async {
      final service = ExpertCatalogApplicationService(
        repository: _Repository(experts: [expert()]),
      );

      final found = await service.findById('expert_1');

      expect(found, isNotNull);
      expect(found!.expertTimezone, isNull);
    });

    test('country never derives a timezone through the lookup', () async {
      for (final country in const ['ML', 'SN', 'CI', 'FR']) {
        final service = ExpertCatalogApplicationService(
          repository: _Repository(experts: [expert(country: country)]),
        );

        final found = await service.findById('expert_1');

        expect(found!.country, country);
        expect(found.expertTimezone, isNull, reason: country);
      }
    });

    test('Wave A mapper semantics are unchanged for the lookup path', () {
      // The same mapper serves both read paths, so absent, blank and
      // non-string identities behave exactly as Wave A established.
      expect(mapped(<String, dynamic>{}).expertTimezone, isNull);
      expect(
        mapped(<String, dynamic>{'expertTimezone': ''}).expertTimezone,
        isNull,
      );
      expect(
        mapped(<String, dynamic>{'expertTimezone': '   '}).expertTimezone,
        isNull,
      );
      expect(
        mapped(<String, dynamic>{'expertTimezone': 42}).expertTimezone,
        isNull,
      );
      expect(
        mapped(<String, dynamic>{
          'expertTimezone': 'Africa/Dakar',
        }).expertTimezone,
        'Africa/Dakar',
      );
    });

    test('a malformed identity is carried, not rejected or replaced', () {
      // Catalog stays tolerant: validity is established where Scheduling
      // interprets, so one bad document cannot poison the lookup path.
      expect(
        mapped(<String, dynamic>{
          'expertTimezone': 'Not A Zone',
        }).expertTimezone,
        'Not A Zone',
      );
    });

    test('the document id becomes the entry identity', () {
      expect(mapped(<String, dynamic>{}, id: 'expert_9').id, 'expert_9');
    });
  });
}

final class _Repository implements ExpertCatalogRepository {
  _Repository({this.experts = const [], this.error});

  final List<ExpertCatalogEntry> experts;
  final Object? error;
  final List<String> requestedIds = <String>[];

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    if (error case final error?) {
      return Stream.error(ExpertCatalogRepositoryException(cause: error));
    }
    return Stream.value(experts);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    requestedIds.add(expertId);
    if (error case final error?) {
      throw ExpertCatalogRepositoryException(cause: error);
    }
    for (final entry in experts) {
      if (entry.id == expertId) return entry;
    }
    return null;
  }
}

final class _RawThrowingRepository implements ExpertCatalogRepository {
  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() => const Stream.empty();

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    throw StateError('unexpected');
  }
}
