import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_confirmation_application_service.dart';
import 'package:mentora/domain/booking/booking_confirmation_repository.dart';
import 'package:mentora/screens/booking_success_screen.dart';
import 'package:mentora/screens/payment_screen.dart';
import 'package:provider/provider.dart';

// AD-022 decisions 11/12: only Booking confirms the reservation. A confirmed
// payment leads to the success page; a failed Booking confirmation never
// does — payment ambiguity is never presented as a confirmed reservation.
void main() {
  testWidgets('a paid outcome confirms the booking and navigates', (
    tester,
  ) async {
    final repository = _Repository();
    await tester.pumpWidget(_app(repository));

    await _pay(tester);

    expect(repository.calls, [('booking_1', 'client_1')]);
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
  });

  testWidgets('a failed confirmation never shows the success page', (
    tester,
  ) async {
    final repository = _Repository(error: StateError('offline'));
    await tester.pumpWidget(_app(repository));

    await _pay(tester);

    expect(find.byType(BookingSuccessScreen), findsNothing);
    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(
      find.textContaining('La confirmation de la réservation a échoué'),
      findsOneWidget,
    );
  });
}

Future<void> _pay(WidgetTester tester) async {
  await tester.ensureVisible(
    find.textContaining("J'accepte les Conditions Générales"),
  );
  await tester.pump();
  await tester.tap(find.byType(CheckboxListTile));
  await tester.pump();

  final button = find.textContaining('Payer ');
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  // The simulated provider takes three seconds.
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

Widget _app(_Repository repository) {
  final service = BookingConfirmationApplicationService(
    session: _Session(),
    repository: repository,
  );
  return Provider<BookingConfirmationApplicationService>.value(
    value: service,
    child: const MaterialApp(
      home: PaymentScreen(
        bookingId: 'booking_1',
        expertName: 'Expert',
        selectedDate: '03/08/2026',
        selectedTime: '09:00',
        aiSummary: '',
        amountMinor: 50000,
        currency: 'XOF',
      ),
    ),
  );
}

final class _Repository implements BookingConfirmationRepository {
  _Repository({this.error});

  final Object? error;
  final List<(String, String)> calls = [];

  @override
  Future<void> confirmPaid({
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
