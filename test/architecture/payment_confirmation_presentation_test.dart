import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_confirmation_application_service.dart';
import 'package:mentora/application/payment/payment_collection_application_service.dart';
import 'package:mentora/domain/booking/booking_confirmation_repository.dart';
import 'package:mentora/domain/payment/payment_collection_provider.dart';
import 'package:mentora/infrastructure/payment/simulated_payment_provider.dart';
import 'package:mentora/screens/booking_success_screen.dart';
import 'package:mentora/screens/payment_screen.dart';
import 'package:provider/provider.dart';

// AD-022 decisions 11/12: the provider boundary yields confirmed or
// definitively rejected; ambiguity throws. Only a confirmed collection
// reaches the Booking-owned confirmation, and neither a rejection, an
// ambiguous outcome nor a failed confirmation ever shows the success page.
void main() {
  testWidgets('a confirmed collection confirms the booking and navigates', (
    tester,
  ) async {
    final repository = _ConfirmationRepository();
    await tester.pumpWidget(_app(confirmation: repository));

    await _pay(tester);

    expect(repository.calls, [('booking_1', 'client_1')]);
    expect(find.byType(BookingSuccessScreen), findsOneWidget);
  });

  testWidgets('a definitive rejection never confirms and never navigates', (
    tester,
  ) async {
    final repository = _ConfirmationRepository();
    await tester.pumpWidget(
      _app(
        confirmation: repository,
        provider: const _StubProvider(
          result: PaymentCollectionRejected(reason: 'insufficient funds'),
        ),
      ),
    );

    await _pay(tester);

    expect(repository.calls, isEmpty);
    expect(find.byType(BookingSuccessScreen), findsNothing);
    expect(find.textContaining('Paiement refusé'), findsOneWidget);
  });

  testWidgets('an ambiguous outcome is never presented as success', (
    tester,
  ) async {
    final repository = _ConfirmationRepository();
    await tester.pumpWidget(
      _app(
        confirmation: repository,
        provider: const _StubProvider(
          failure: PaymentCollectionAmbiguousFailure(),
        ),
      ),
    );

    await _pay(tester);

    expect(repository.calls, isEmpty);
    expect(find.byType(BookingSuccessScreen), findsNothing);
    expect(find.textContaining('n’a pas pu être vérifié'), findsOneWidget);
  });

  testWidgets('a failed confirmation never shows the success page', (
    tester,
  ) async {
    final repository = _ConfirmationRepository(error: StateError('offline'));
    await tester.pumpWidget(_app(confirmation: repository));

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

Widget _app({
  required _ConfirmationRepository confirmation,
  PaymentCollectionProvider provider = const SimulatedPaymentProvider(),
}) {
  return MultiProvider(
    providers: [
      Provider<PaymentCollectionApplicationService>.value(
        value: PaymentCollectionApplicationService(provider: provider),
      ),
      Provider<BookingConfirmationApplicationService>.value(
        value: BookingConfirmationApplicationService(
          session: _Session(),
          repository: confirmation,
        ),
      ),
    ],
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

final class _StubProvider implements PaymentCollectionProvider {
  const _StubProvider({this.result, this.failure});

  final PaymentCollectionResult? result;
  final PaymentCollectionProviderFailure? failure;

  @override
  Future<PaymentCollectionResult> collect(
    PaymentCollectionRequest request,
  ) async {
    if (failure case final failure?) throw failure;
    return result!;
  }
}

final class _ConfirmationRepository implements BookingConfirmationRepository {
  _ConfirmationRepository({this.error});

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
