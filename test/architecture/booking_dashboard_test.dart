import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_cancellation_application_service.dart';
import 'package:mentora/application/booking/booking_dashboard_application_service.dart';
import 'package:mentora/application/booking/booking_dashboard_failure.dart';
import 'package:mentora/application/notification/booking_notification_application_service.dart';
import 'package:mentora/domain/booking/booking_cancellation_repository.dart';
import 'package:mentora/domain/booking/booking_overview.dart';
import 'package:mentora/infrastructure/notification/simulated_notification_provider.dart';
import 'package:mentora/screens/booking_dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('BookingDashboardApplicationService', () {
    test('a client session watches their own bookings', () async {
      final repository = _OverviewRepository();
      final service = BookingDashboardApplicationService(
        session: _Session('client_1'),
        repository: repository,
      );

      final future = service.watchMyBookings().first;
      repository.push([_overview(bookingId: 'b1')]);
      final bookings = await future;

      expect(repository.clientQueries, ['client_1']);
      expect(repository.expertQueries, isEmpty);
      expect(bookings.single.bookingId, 'b1');
    });

    test('an expert session watches the bookings made with them', () async {
      final repository = _OverviewRepository();
      final service = BookingDashboardApplicationService(
        session: _Session('expert_1', isExpert: true),
        repository: repository,
      );

      final future = service.watchMyBookings().first;
      repository.push(const []);
      await future;

      expect(repository.expertQueries, ['expert_1']);
      expect(repository.clientQueries, isEmpty);
    });

    test('an unauthenticated session fails typed', () {
      final service = BookingDashboardApplicationService(
        session: _Session(null),
        repository: _OverviewRepository(),
      );

      expect(
        service.watchMyBookings().first,
        throwsA(isA<BookingDashboardUnauthenticatedFailure>()),
      );
    });

    test('repository errors surface typed, never as empty data', () {
      final repository = _OverviewRepository();
      final service = BookingDashboardApplicationService(
        session: _Session('client_1'),
        repository: repository,
      );

      final future = service.watchMyBookings().first;
      repository.pushError(
        const BookingOverviewRepositoryException(cause: 'offline'),
      );

      expect(future, throwsA(isA<BookingDashboardRepositoryFailure>()));
    });
  });

  group('BookingDashboardScreen', () {
    testWidgets('sections, badges and per-status actions are correct', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1080, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final repository = _OverviewRepository();
      await tester.pumpWidget(_app(repository));

      final today = DateTime.now();
      final todayString =
          '${today.year}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      repository.push([
        _overview(
          bookingId: 'today_confirmed',
          status: 'confirmed',
          bookingDate: todayString,
        ),
        _overview(
          bookingId: 'upcoming_pending',
          status: 'pending_payment',
          bookingDate: '2099-01-04',
        ),
        _overview(bookingId: 'done', status: 'completed'),
        _overview(bookingId: 'gone', status: 'cancelled'),
      ]);
      await tester.pumpAndSettle();

      // Sections.
      expect(find.text('Aujourd’hui'), findsOneWidget);
      expect(find.text('À venir'), findsOneWidget);
      expect(find.text('Terminées'), findsOneWidget);
      expect(find.text('Annulées'), findsOneWidget);

      // Badges.
      expect(find.text('Confirmée'), findsOneWidget);
      expect(find.text('Paiement en attente'), findsOneWidget);
      expect(find.text('Terminée'), findsOneWidget);
      expect(find.text('Annulée'), findsOneWidget);

      // Card content: duration, price, timezone.
      expect(find.text('60 min'), findsNWidgets(4));
      final money = NumberFormat('#,##0', 'fr_FR');
      expect(find.text('${money.format(50000)} XOF'), findsNWidgets(4));
      expect(find.text('Africa/Bamako'), findsNWidgets(4));

      // Per-status actions.
      expect(find.text('Payer'), findsOneWidget);
      expect(find.text('Reprogrammer'), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Donner un avis'), findsOneWidget);
      // Details on confirmed, completed and cancelled — never on
      // pending_payment.
      expect(find.text('Voir les détails'), findsNWidgets(3));
    });

    testWidgets('the dashboard refreshes immediately when data changes', (
      tester,
    ) async {
      final repository = _OverviewRepository();
      await tester.pumpWidget(_app(repository));

      repository.push([_overview(bookingId: 'b1', status: 'confirmed')]);
      await tester.pumpAndSettle();
      expect(find.text('Confirmée'), findsOneWidget);
      expect(find.text('Annulée'), findsNothing);

      // A lifecycle change re-emits: no screen reopening involved.
      repository.push([_overview(bookingId: 'b1', status: 'cancelled')]);
      await tester.pumpAndSettle();
      expect(find.text('Annulée'), findsOneWidget);
      expect(find.text('Confirmée'), findsNothing);

      // Completion streams the same way: the card moves to Terminées.
      repository.push([_overview(bookingId: 'b1', status: 'completed')]);
      await tester.pumpAndSettle();
      expect(find.text('Terminées'), findsOneWidget);
      expect(find.text('Terminée'), findsOneWidget);
      expect(find.text('Annulée'), findsNothing);
    });

    testWidgets('cancelling from a confirmed card notifies both parties', (
      tester,
    ) async {
      final repository = _OverviewRepository();
      final cancellations = _CancellationRepository();
      final notifications = SimulatedNotificationProvider();
      await tester.pumpWidget(
        _app(
          repository,
          cancellations: cancellations,
          notifications: notifications,
        ),
      );

      repository.push([_overview(bookingId: 'b1', status: 'confirmed')]);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmer l’annulation'));
      await tester.pumpAndSettle();

      expect(cancellations.calls, [('b1', 'client_1')]);
      expect(notifications.sent, hasLength(2));
      expect(notifications.sent.map((n) => n.recipientId).toSet(), {
        'client_1',
        'expert_1',
      });
    });

    testWidgets('an empty dashboard says so', (tester) async {
      final repository = _OverviewRepository();
      await tester.pumpWidget(_app(repository));

      repository.push(const []);
      await tester.pumpAndSettle();

      expect(find.text('Aucune réservation pour le moment.'), findsOneWidget);
    });
  });
}

BookingOverview _overview({
  required String bookingId,
  String status = 'confirmed',
  String bookingDate = '2099-01-03',
}) {
  return BookingOverview(
    bookingId: bookingId,
    status: status,
    clientId: 'client_1',
    expertId: 'expert_1',
    expertName: 'Awa',
    bookingDate: bookingDate,
    bookingTime: '09:00',
    durationMinutes: 60,
    amountMinor: 50000,
    currency: 'XOF',
    expertTimezone: 'Africa/Bamako',
    aiSummary: '',
    raw: const <String, dynamic>{},
  );
}

Widget _app(
  _OverviewRepository repository, {
  _CancellationRepository? cancellations,
  SimulatedNotificationProvider? notifications,
}) {
  return MultiProvider(
    providers: [
      Provider<BookingDashboardApplicationService>.value(
        value: BookingDashboardApplicationService(
          session: _Session('client_1'),
          repository: repository,
        ),
      ),
      Provider<BookingCancellationApplicationService>.value(
        value: BookingCancellationApplicationService(
          session: _Session('client_1'),
          repository: cancellations ?? _CancellationRepository(),
        ),
      ),
      Provider<BookingNotificationApplicationService>.value(
        value: BookingNotificationApplicationService(
          session: _Session('client_1'),
          provider: notifications ?? SimulatedNotificationProvider(),
        ),
      ),
    ],
    child: const MaterialApp(home: BookingDashboardScreen()),
  );
}

final class _OverviewRepository implements BookingOverviewRepository {
  final _controller = StreamController<List<BookingOverview>>.broadcast();
  final List<String> clientQueries = [];
  final List<String> expertQueries = [];

  void push(List<BookingOverview> bookings) => _controller.add(bookings);

  void pushError(Object error) => _controller.addError(error);

  @override
  Stream<List<BookingOverview>> watchForClient(String clientId) {
    clientQueries.add(clientId);
    return _controller.stream;
  }

  @override
  Stream<List<BookingOverview>> watchForExpert(String expertId) {
    expertQueries.add(expertId);
    return _controller.stream;
  }
}

final class _CancellationRepository implements BookingCancellationRepository {
  final List<(String, String)> calls = [];

  @override
  Future<void> cancel({
    required String bookingId,
    required String clientId,
  }) async {
    calls.add((bookingId, clientId));
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId, {this.isExpert = false});

  @override
  final String? currentUserId;

  @override
  final bool isExpert;

  @override
  bool get isAuthenticated => currentUserId != null;
}
