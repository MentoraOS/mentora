import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/domain/booking/booking_overview.dart';
import 'package:mentora/screens/consultation_dashboard_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows every reservation fact of the confirmed booking', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking()));

    expect(find.text('Espace consultation'), findsOneWidget);
    expect(find.text('Awa'), findsOneWidget);
    expect(find.text('Votre expert'), findsOneWidget);
    expect(find.text('Confirmée'), findsOneWidget);
    expect(find.text('2026-08-03'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    expect(find.text('60 minutes'), findsOneWidget);
    expect(find.text('Africa/Bamako'), findsOneWidget);
    expect(find.text('Préparé ✓'), findsOneWidget);
  });

  testWidgets('shows the preparation placeholders', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking()));

    expect(find.text('Informations de consultation'), findsOneWidget);
    expect(find.text('Notes privées'), findsOneWidget);
    expect(find.text('Documents partagés'), findsOneWidget);
    expect(find.text('Messages'), findsOneWidget);
    expect(find.text('Consultation vidéo'), findsOneWidget);
  });

  testWidgets('joining stays disabled until the video flow exists', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking()));

    await tester.ensureVisible(find.text('Rejoindre la consultation'));
    // ElevatedButton.icon builds a private subtype, so match by predicate.
    final button = tester.widget<ElevatedButton>(
      find.byWidgetPredicate((widget) => widget is ElevatedButton),
    );
    expect(button.onPressed, isNull);
    expect(find.text('Disponible prochainement'), findsOneWidget);
  });

  testWidgets('an expert session sees the client framing', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(_booking(), isExpert: true));

    expect(find.text('Avec votre client'), findsOneWidget);
  });

  testWidgets('legacy bookings without modern fields stay readable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _app(
        const BookingOverview(
          bookingId: 'b_legacy',
          status: 'paid',
          clientId: 'client_1',
          expertId: '',
          expertName: 'Expert',
          bookingDate: 'Lundi',
          bookingTime: '09:00',
          durationMinutes: null,
          amountMinor: null,
          currency: null,
          expertTimezone: null,
          aiSummary: '',
          raw: <String, dynamic>{},
        ),
      ),
    );

    expect(find.text('Payée'), findsOneWidget);
    expect(find.text('Lundi'), findsOneWidget);
    expect(find.textContaining('minutes'), findsNothing);
    expect(find.text('Fuseau horaire'), findsNothing);
  });
}

BookingOverview _booking() {
  return const BookingOverview(
    bookingId: 'b1',
    status: 'confirmed',
    clientId: 'client_1',
    expertId: 'expert_1',
    expertName: 'Awa',
    bookingDate: '2026-08-03',
    bookingTime: '09:00',
    durationMinutes: 60,
    amountMinor: 50000,
    currency: 'XOF',
    expertTimezone: 'Africa/Bamako',
    aiSummary: 'Résumé',
    raw: <String, dynamic>{},
  );
}

Widget _app(BookingOverview booking, {bool isExpert = false}) {
  return Provider<AuthenticationSession>.value(
    value: _Session(isExpert: isExpert),
    child: MaterialApp(home: ConsultationDashboardScreen(booking: booking)),
  );
}

final class _Session extends Fake implements AuthenticationSession {
  _Session({required this.isExpert});

  @override
  final bool isExpert;

  @override
  String get currentUserId => isExpert ? 'expert_1' : 'client_1';

  @override
  bool get isAuthenticated => true;
}
