import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_failure.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';

void main() {
  group('ExpertCatalogApplicationService', () {
    test('watches the complete Expert Catalog', () async {
      final service = ExpertCatalogApplicationService(
        repository: _FakeExpertCatalogRepository(
          experts: [_expert('expert_1')],
        ),
      );

      final experts = await service.watchExperts().first;

      expect(experts.single.id, 'expert_1');
    });

    test('preserves an empty Expert Catalog', () async {
      final service = ExpertCatalogApplicationService(
        repository: _FakeExpertCatalogRepository(),
      );

      expect(await service.watchExperts().first, isEmpty);
    });

    test('maps repository failures without exposing Infrastructure', () async {
      final cause = StateError('offline');
      final service = ExpertCatalogApplicationService(
        repository: _FakeExpertCatalogRepository(error: cause),
      );

      await expectLater(
        service.watchExperts(),
        emitsError(
          isA<ExpertCatalogInfrastructureFailure>().having(
            (failure) => failure.cause,
            'cause',
            cause,
          ),
        ),
      );
    });
  });
}

final class _FakeExpertCatalogRepository implements ExpertCatalogRepository {
  _FakeExpertCatalogRepository({this.experts = const [], this.error});

  final List<ExpertCatalogEntry> experts;
  final Object? error;

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    if (error case final error?) {
      return Stream.error(ExpertCatalogRepositoryException(cause: error));
    }
    return Stream.value(experts);
  }
}

ExpertCatalogEntry _expert(String id) {
  return ExpertCatalogEntry(
    id: id,
    name: 'Awa',
    job: 'Coach',
    country: 'ML',
    rating: '4.9',
    online: true,
    availability: const {},
  );
}
