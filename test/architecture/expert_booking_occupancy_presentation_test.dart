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
import 'package:provider/provider.dart';

// Wave 2C protected semantics, preserved across the AD-022 C2 calendar
// migration: occupied slots stay visible and unselectable; a failed occupancy
// read closes selection entirely; empty occupancy keeps availability
// selectable. The C2 calendar shows one chip per concrete date, so a legacy
// weekday occupancy (`Lundi|09:00`) marks every displayed Monday.
void main() {
  testWidgets('occupied slots remain unavailable', (tester) async {
    await tester.pumpWidget(
      _app(
        _Repository(
          occupancies: [
            ExpertBookingOccupancy(bookingDate: 'Lundi', bookingTime: '09:00'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _selectOffer(tester);

    expect(find.text('09:00 • Réservé'), findsWidgets);
    await tester.ensureVisible(find.text('09:00 • Réservé').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00 • Réservé').first);
    await tester.pump();
    await _expectCannotContinue(tester);
  });

  testWidgets('empty occupancy preserves selectable availability', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const _Repository(occupancies: [])));
    await tester.pumpAndSettle();

    // AD-021: the client selects the expert's Consultation Offer before the
    // funnel can continue; the C2 calendar materializes per selected offer.
    await _selectOffer(tester);

    expect(find.text('09:00 • Réservé'), findsNothing);
    expect(
      find.text(
        'Impossible de vérifier les créneaux réservés. '
        'La réservation est temporairement indisponible.',
      ),
      findsNothing,
    );

    await tester.ensureVisible(find.text('09:00').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00').first);
    await tester.pump();

    await tester.ensureVisible(find.text('Préparer votre consultation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Préparer votre consultation'));
    await tester.pumpAndSettle();
    expect(find.text('Préparer la consultation'), findsOneWidget);
  });

  testWidgets('infrastructure failure disables slots and continuation', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Repository(error: StateError('offline'))));
    await tester.pumpAndSettle();

    await _expectFailureIsClosed(tester);
  });

  testWidgets('malformed-data failure disables slots and continuation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const _Repository(
          error: FormatException('invalid booking'),
          malformed: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _expectFailureIsClosed(tester);
  });
}

Future<void> _selectOffer(WidgetTester tester) async {
  await tester.ensureVisible(find.text('1 heure'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('1 heure'));
  await tester.pumpAndSettle();
}

Future<void> _expectFailureIsClosed(WidgetTester tester) async {
  expect(
    find.text(
      'Impossible de vérifier les créneaux réservés. '
      'La réservation est temporairement indisponible.',
    ),
    findsOneWidget,
  );
  await _selectOffer(tester);
  await tester.ensureVisible(find.text('09:00').first);
  await tester.pumpAndSettle();
  await tester.tap(find.text('09:00').first);
  await tester.pump();
  await _expectCannotContinue(tester);
}

Future<void> _expectCannotContinue(WidgetTester tester) async {
  await tester.tap(find.text('Préparer votre consultation'));
  await tester.pump();
  expect(
    find.text('Choisissez une date et une heure avant de continuer'),
    findsOneWidget,
  );
}

final ExpertCatalogEntry _expert = ExpertCatalogEntry(
  id: 'expert_1',
  name: 'Expert',
  job: 'Coach',
  country: 'ML',
  rating: '5',
  online: true,
  availability: const {
    'Lundi': ['09:00', '10:00'],
  },
  // ARCH-009B: the expert must publish a rate for a Consultation Offer to
  // exist. AD-022: the modern path requires an authoritative timezone.
  rate60: 50000,
  expertTimezone: 'Africa/Bamako',
);

Widget _app(_Repository repository) {
  final occupancy = ExpertBookingOccupancyApplicationService(
    repository: repository,
  );
  final selectableOccurrences = SelectableOccurrenceApplicationService(
    expertCatalog: ExpertCatalogApplicationService(
      repository: _CatalogRepository(_expert),
    ),
    materialization: const CivilOccurrenceMaterializationAdapter(),
  );
  return MultiProvider(
    providers: [
      Provider<ExpertBookingOccupancyApplicationService>.value(
        value: occupancy,
      ),
      Provider<SelectableOccurrenceApplicationService>.value(
        value: selectableOccurrences,
      ),
    ],
    child: MaterialApp(home: ExpertDetailScreen(expert: _expert)),
  );
}

final class _Repository implements ExpertBookingOccupancyRepository {
  const _Repository({
    this.occupancies = const [],
    this.error,
    this.malformed = false,
  });

  final List<ExpertBookingOccupancy> occupancies;
  final Object? error;
  final bool malformed;

  @override
  Future<List<ExpertBookingOccupancy>> loadForExpert(String expertId) async {
    if (error case final cause?) {
      throw ExpertBookingOccupancyRepositoryException(
        cause: cause,
        malformedData: malformed,
      );
    }
    return occupancies;
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
