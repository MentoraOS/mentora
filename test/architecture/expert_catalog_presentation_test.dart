import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/screens/client_dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Client Dashboard renders a typed Expert Catalog entry', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _appWithExperts([
        _expert(id: 'firestore_document_id', name: 'Awa Traoré'),
      ]),
    );
    await tester.pump();

    expect(find.text('Awa Traoré'), findsOneWidget);
    expect(find.text('Coach • Mali'), findsOneWidget);
  });

  testWidgets('Client Dashboard preserves the empty Catalog state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_appWithExperts(const []));
    await tester.pump();

    expect(find.text('Aucun expert disponible.'), findsOneWidget);
  });
}

Widget _appWithExperts(List<ExpertCatalogEntry> experts) {
  final service = ExpertCatalogApplicationService(
    repository: _FakeExpertCatalogRepository(experts),
  );

  return Provider<ExpertCatalogApplicationService>.value(
    value: service,
    child: const MaterialApp(home: ClientDashboardScreen()),
  );
}

final class _FakeExpertCatalogRepository implements ExpertCatalogRepository {
  const _FakeExpertCatalogRepository(this.experts);

  final List<ExpertCatalogEntry> experts;

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value(experts);
  }
}

ExpertCatalogEntry _expert({required String id, required String name}) {
  return ExpertCatalogEntry(
    id: id,
    name: name,
    job: 'Coach',
    country: 'Mali',
    rating: '4.9',
    online: true,
    availability: const {},
  );
}
