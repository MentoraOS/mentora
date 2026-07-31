import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/booking/expert_booking_occupancy_application_service.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_application_service.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy_repository.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/screens/expert_detail_screen.dart';
import 'package:mentora/screens/pre_consultation_screen.dart';
import 'package:provider/provider.dart';

// AD-022 Wave C2: the selected slot travels through navigation as a
// structured civil occurrence — explicit year/month/day/hour/minute plus the
// authoritative offer duration — never as a localized weekday string.
void main() {
  testWidgets('the structured occurrence travels through navigation', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('1 heure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 heure'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('09:00').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00').first);
    await tester.pump();

    await tester.ensureVisible(find.text('Préparer votre consultation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Préparer votre consultation'));
    await tester.pumpAndSettle();

    final screen = tester.widget<PreConsultationScreen>(
      find.byType(PreConsultationScreen),
    );

    // The transported value is structured civil data with the authoritative
    // offer duration; nothing was reconstructed from a display string.
    expect(screen.occurrence.durationMinutes, 60);
    expect(screen.occurrence.hour, 9);
    expect(screen.occurrence.minute, 0);
    expect(screen.occurrence.year, greaterThanOrEqualTo(2020));
    expect(screen.occurrence.month, inInclusiveRange(1, 12));
    expect(screen.occurrence.day, inInclusiveRange(1, 31));
    expect(screen.offer.durationMinutes, 60);
    expect(screen.expertId, 'expert_1');

    // The confirmed slot is rendered from the structured value.
    final rendered = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          RegExp(r'^\d{2}/\d{2}/\d{4} • 09:00$').hasMatch(widget.data!),
    );
    expect(rendered, findsOneWidget);
  });
}

Widget _app() {
  final expert = ExpertCatalogEntry(
    id: 'expert_1',
    name: 'Expert',
    job: 'Coach',
    country: 'ML',
    rating: '5',
    online: true,
    availability: const {
      'Lundi': ['09:00'],
      'Mardi': ['09:00'],
      'Mercredi': ['09:00'],
      'Jeudi': ['09:00'],
      'Vendredi': ['09:00'],
      'Samedi': ['09:00'],
      'Dimanche': ['09:00'],
    },
    rate60: 50000,
    expertTimezone: 'Africa/Bamako',
  );

  return MultiProvider(
    providers: [
      Provider<ExpertBookingOccupancyApplicationService>.value(
        value: ExpertBookingOccupancyApplicationService(
          repository: const _EmptyOccupancyRepository(),
        ),
      ),
      Provider<SelectableOccurrenceApplicationService>.value(
        value: SelectableOccurrenceApplicationService(
          expertCatalog: ExpertCatalogApplicationService(
            repository: _CatalogRepository(expert),
          ),
          materialization: const CivilOccurrenceMaterializationAdapter(),
        ),
      ),
    ],
    child: MaterialApp(home: ExpertDetailScreen(expert: expert)),
  );
}

final class _EmptyOccupancyRepository
    implements ExpertBookingOccupancyRepository {
  const _EmptyOccupancyRepository();

  @override
  Future<List<ExpertBookingOccupancy>> loadForExpert(String expertId) async {
    return const [];
  }
}

final class _CatalogRepository implements ExpertCatalogRepository {
  const _CatalogRepository(this.expert);

  final ExpertCatalogEntry expert;

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value([expert]);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    return expert.id == expertId ? expert : null;
  }
}
