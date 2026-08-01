import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/booking/booking_overview.dart';
import 'package:mentora/widgets/consultation_timeline.dart';

void main() {
  group('ConsultationTimeline — status projection', () {
    testWidgets('a pending payment shows creation done, payment current', (
      tester,
    ) async {
      await tester.pumpWidget(_app('pending_payment'));

      _expectSteps(tester, done: 1, current: 'Paiement confirmé');
      expect(find.text('Payer la réservation'), findsOneWidget);
    });

    testWidgets('a confirmed booking shows three steps done', (tester) async {
      await tester.pumpWidget(_app('confirmed'));

      _expectSteps(tester, done: 3, current: 'Consultation à venir');
      // Next step summary — the label also appears as the current step.
      expect(find.text('Consultation à venir'), findsNWidgets(2));
    });

    testWidgets('a completed consultation only awaits the review', (
      tester,
    ) async {
      await tester.pumpWidget(_app('completed'));

      _expectSteps(tester, done: 5, current: 'Avis');
      expect(find.text('Donner un avis'), findsOneWidget);
    });

    testWidgets('a cancelled booking marks nothing and says so', (
      tester,
    ) async {
      await tester.pumpWidget(_app('cancelled'));

      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(find.byIcon(Icons.radio_button_checked), findsNothing);
      expect(find.text('Aucune — réservation annulée'), findsOneWidget);
    });

    testWidgets('every step and the remaining-time placeholder render', (
      tester,
    ) async {
      await tester.pumpWidget(_app('confirmed'));

      for (final label in const [
        'Réservation créée',
        'Paiement confirmé',
        'Consultation confirmée',
        'Consultation à venir',
        'Consultation terminée',
        'Avis',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(find.text('Prochaine étape'), findsOneWidget);
      expect(find.text('Temps restant'), findsOneWidget);
      expect(find.text('Bientôt disponible'), findsOneWidget);
    });
  });
}

void _expectSteps(
  WidgetTester tester, {
  required int done,
  required String current,
}) {
  expect(find.byIcon(Icons.check_circle), findsNWidgets(done));
  expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);

  // The current step label is rendered bold.
  final currentText = tester
      .widgetList<Text>(find.text(current))
      .map((text) => text.style?.fontWeight)
      .toList();
  expect(currentText, contains(FontWeight.bold));
}

Widget _app(String status) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: ConsultationTimeline(
          booking: BookingOverview(
            bookingId: 'b1',
            status: status,
            clientId: 'client_1',
            expertId: 'expert_1',
            expertName: 'Awa',
            bookingDate: '2026-08-03',
            bookingTime: '09:00',
            durationMinutes: 60,
            amountMinor: 50000,
            currency: 'XOF',
            expertTimezone: 'Africa/Bamako',
            aiSummary: '',
            raw: const <String, dynamic>{},
          ),
        ),
      ),
    ),
  );
}
