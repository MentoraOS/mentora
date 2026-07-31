import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/booking/expert_booking_occupancy_application_service.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy.dart';
import 'package:mentora/domain/booking/expert_booking_occupancy_repository.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/screens/expert_detail_screen.dart';
import 'package:provider/provider.dart';

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

    expect(find.text('09:00 • Réservé'), findsOneWidget);
    await tester.ensureVisible(find.text('09:00 • Réservé'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00 • Réservé'));
    await tester.pump();
    await _expectCannotContinue(tester);
  });

  testWidgets('empty occupancy preserves selectable availability', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const _Repository(occupancies: [])));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('09:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00'));
    await tester.pump();
    expect(find.text('09:00 • Réservé'), findsNothing);
    expect(
      find.text(
        'Impossible de vérifier les créneaux réservés. '
        'La réservation est temporairement indisponible.',
      ),
      findsNothing,
    );
    // AD-021: the client selects the expert's Consultation Offer before the
    // funnel can continue.
    await tester.ensureVisible(find.text('1 heure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 heure'));
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

Future<void> _expectFailureIsClosed(WidgetTester tester) async {
  expect(
    find.text(
      'Impossible de vérifier les créneaux réservés. '
      'La réservation est temporairement indisponible.',
    ),
    findsOneWidget,
  );
  await tester.ensureVisible(find.text('09:00'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('09:00'));
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

Widget _app(_Repository repository) {
  final service = ExpertBookingOccupancyApplicationService(
    repository: repository,
  );
  return Provider<ExpertBookingOccupancyApplicationService>.value(
    value: service,
    child: MaterialApp(
      home: ExpertDetailScreen(
        expert: ExpertCatalogEntry(
          id: 'expert_1',
          name: 'Expert',
          job: 'Coach',
          country: 'ML',
          rating: '5',
          online: true,
          availability: const {
            'Lundi': ['09:00', '10:00'],
          },
          // ARCH-009B: the expert must publish a rate for a Consultation
          // Offer to exist. Occupancy expectations below are unchanged.
          rate60: 50000,
        ),
      ),
    ),
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
