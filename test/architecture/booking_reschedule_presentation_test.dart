import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_reschedule_application_service.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/notification/booking_notification_application_service.dart';
import 'package:mentora/domain/booking/booking_reschedule_repository.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/domain/notification/booking_notification_provider.dart';
import 'package:mentora/infrastructure/notification/simulated_notification_provider.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';
import 'package:mentora/screens/reschedule_booking_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('picking a new slot reschedules and notifies both parties', (
    tester,
  ) async {
    final repository = _Repository();
    final notifications = SimulatedNotificationProvider();
    await tester.pumpWidget(_app(repository, notifications));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('09:00').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00').first);
    await tester.pump();

    await tester.ensureVisible(find.text('Confirmer le nouveau créneau'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer le nouveau créneau'));
    await tester.pumpAndSettle();

    final call = repository.calls.single;
    expect(call.$1, 'booking_1');
    expect(call.$2, 'client_1');
    expect(call.$3.bookingTime, '09:00');
    expect(call.$3.startUtc.isUtc, isTrue);
    expect(call.$3.expertTimezone, 'Africa/Bamako');

    expect(notifications.sent, hasLength(2));
    expect(notifications.sent.map((n) => n.event).toSet(), {
      BookingNotificationEvent.bookingRescheduled,
    });
    expect(notifications.sent.map((n) => n.recipientId).toSet(), {
      'client_1',
      'expert_1',
    });
    expect(find.byType(RescheduleBookingScreen), findsNothing);
  });

  testWidgets('a reschedule failure keeps the screen and sends nothing', (
    tester,
  ) async {
    final repository = _Repository(
      error: const BookingRescheduleStateException(currentStatus: 'cancelled'),
    );
    final notifications = SimulatedNotificationProvider();
    await tester.pumpWidget(_app(repository, notifications));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('09:00').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00').first);
    await tester.pump();
    await tester.ensureVisible(find.text('Confirmer le nouveau créneau'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer le nouveau créneau'));
    await tester.pumpAndSettle();

    expect(notifications.sent, isEmpty);
    expect(find.byType(RescheduleBookingScreen), findsOneWidget);
    expect(
      find.text('Cette réservation ne peut plus être reprogrammée.'),
      findsOneWidget,
    );
  });

  testWidgets('a booking without a snapshotted duration fails closed', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      _app(repository, SimulatedNotificationProvider(), duration: null),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Impossible de charger'), findsOneWidget);
    expect(find.text('09:00'), findsNothing);
  });
}

Widget _app(
  _Repository repository,
  SimulatedNotificationProvider notifications, {
  int? duration = 60,
}) {
  final expert = ExpertCatalogEntry(
    id: 'expert_1',
    name: 'Awa',
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
    expertTimezone: 'Africa/Bamako',
  );

  return MultiProvider(
    providers: [
      Provider<BookingRescheduleApplicationService>.value(
        value: BookingRescheduleApplicationService(
          session: _Session(),
          repository: repository,
          expertCatalog: ExpertCatalogApplicationService(
            repository: _CatalogRepository(expert),
          ),
          materialization: const CivilOccurrenceMaterializationAdapter(),
          interpretation: const CivilOccurrenceInterpretationAdapter(
            resolver: LaunchMarketTimezoneResolver(),
          ),
        ),
      ),
      Provider<BookingNotificationApplicationService>.value(
        value: BookingNotificationApplicationService(
          session: _Session(),
          provider: notifications,
        ),
      ),
    ],
    child: MaterialApp(
      home: RescheduleBookingScreen(
        bookingId: 'booking_1',
        booking: <String, dynamic>{
          'expertId': 'expert_1',
          'expertName': 'Awa',
          'bookingDate': '2026-08-03',
          'bookingTime': '10:00',
          'status': 'confirmed',
          if (duration != null) 'duration': duration,
        },
      ),
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

final class _Session extends Fake implements AuthenticationSession {
  @override
  String get currentUserId => 'client_1';

  @override
  bool get isAuthenticated => true;
}
