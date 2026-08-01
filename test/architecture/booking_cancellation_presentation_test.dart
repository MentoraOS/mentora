import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_cancellation_application_service.dart';
import 'package:mentora/application/booking/booking_cancellation_failure.dart';
import 'package:mentora/application/notification/booking_notification_application_service.dart';
import 'package:mentora/domain/booking/booking_cancellation_repository.dart';
import 'package:mentora/domain/notification/booking_notification_provider.dart';
import 'package:mentora/infrastructure/notification/simulated_notification_provider.dart';
import 'package:mentora/screens/booking_detail_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('confirmed cancellation cancels, notifies both and closes', (
    tester,
  ) async {
    final repository = _Repository();
    final notifications = SimulatedNotificationProvider();
    await tester.pumpWidget(_app(repository, notifications));

    await tester.tap(find.text('Annuler la réservation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer l’annulation'));
    await tester.pumpAndSettle();

    expect(repository.calls, [('booking_1', 'client_1')]);
    expect(notifications.sent, hasLength(2));
    expect(notifications.sent.map((n) => n.event).toSet(), {
      BookingNotificationEvent.bookingCancelled,
    });
    expect(notifications.sent.map((n) => n.recipientId).toSet(), {
      'client_1',
      'expert_1',
    });
    // The screen closed back to the caller.
    expect(find.byType(BookingDetailScreen), findsNothing);
  });

  testWidgets('declining the dialog cancels nothing', (tester) async {
    final repository = _Repository();
    final notifications = SimulatedNotificationProvider();
    await tester.pumpWidget(_app(repository, notifications));

    await tester.tap(find.text('Annuler la réservation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retour'));
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(notifications.sent, isEmpty);
    expect(find.byType(BookingDetailScreen), findsOneWidget);
  });

  testWidgets('a non-cancellable state shows the message, no notification', (
    tester,
  ) async {
    final repository = _Repository(
      error: const BookingCancellationStateException(
        currentStatus: 'completed',
      ),
    );
    final notifications = SimulatedNotificationProvider();
    await tester.pumpWidget(_app(repository, notifications));

    await tester.tap(find.text('Annuler la réservation'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmer l’annulation'));
    await tester.pumpAndSettle();

    expect(notifications.sent, isEmpty);
    expect(
      find.text('Cette réservation ne peut plus être annulée.'),
      findsOneWidget,
    );
    expect(find.byType(BookingDetailScreen), findsOneWidget);
  });

  testWidgets('an already-cancelled booking disables the button', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(
      _app(repository, SimulatedNotificationProvider(), status: 'cancelled'),
    );

    final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(button.onPressed, isNull);
  });
}

Widget _app(
  _Repository repository,
  SimulatedNotificationProvider notifications, {
  String status = 'confirmed',
}) {
  return MultiProvider(
    providers: [
      Provider<BookingCancellationApplicationService>.value(
        value: BookingCancellationApplicationService(
          session: _Session(),
          repository: repository,
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
      home: BookingDetailScreen(
        bookingId: 'booking_1',
        booking: <String, dynamic>{
          'expertId': 'expert_1',
          'expertName': 'Awa',
          'bookingDate': '2026-08-03',
          'bookingTime': '09:00',
          'status': status,
          'amount': 50000,
        },
      ),
    ),
  );
}

final class _Repository implements BookingCancellationRepository {
  _Repository({this.error});

  final Object? error;
  final List<(String, String)> calls = [];

  @override
  Future<void> cancel({
    required String bookingId,
    required String clientId,
  }) async {
    if (error case final cause?) throw cause;
    calls.add((bookingId, clientId));
  }
}

final class _Session extends Fake implements AuthenticationSession {
  @override
  String get currentUserId => 'client_1';

  @override
  bool get isAuthenticated => true;
}
