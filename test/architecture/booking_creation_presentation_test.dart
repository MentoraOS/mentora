import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/booking/booking_creation_application_service.dart';
import 'package:mentora/application/expert_catalog/expert_catalog_application_service.dart';
import 'package:mentora/application/notification/booking_notification_application_service.dart';
import 'package:mentora/application/scheduling/civil_selection.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_application_service.dart';
import 'package:mentora/domain/booking/booking_creation.dart';
import 'package:mentora/domain/booking/booking_creation_repository.dart';
import 'package:mentora/domain/expert_catalog/consultation_offer.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_entry.dart';
import 'package:mentora/domain/expert_catalog/expert_catalog_repository.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';
import 'package:mentora/infrastructure/notification/simulated_notification_provider.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';
import 'package:mentora/screens/payment_screen.dart';
import 'package:mentora/screens/pre_consultation_screen.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('successful authoritative creation forwards returned ID', (
    tester,
  ) async {
    final repository = _Repository(result: 'booking_returned');
    await tester.pumpWidget(_app(repository));

    await _tapCreate(tester);
    await tester.pumpAndSettle();

    final payment = tester.widget<PaymentScreen>(find.byType(PaymentScreen));
    expect(payment.bookingId, 'booking_returned');
    expect(repository.calls, 1);
  });

  testWidgets('conflict remains on PreConsultationScreen', (tester) async {
    await tester.pumpWidget(
      _app(_Repository(error: const BookingCreationConflictException())),
    );

    await _tapCreate(tester);
    await tester.pump();

    expect(find.byType(PreConsultationScreen), findsOneWidget);
    expect(find.byType(PaymentScreen), findsNothing);
    expect(find.textContaining('vient d’être réservé'), findsOneWidget);
  });

  testWidgets('persistence failure does not navigate', (tester) async {
    await tester.pumpWidget(
      _app(
        _Repository(
          error: BookingCreationRepositoryException(
            cause: StateError('offline'),
            infrastructureUnavailable: true,
          ),
        ),
      ),
    );

    await _tapCreate(tester);
    await tester.pump();

    expect(find.byType(PreConsultationScreen), findsOneWidget);
    expect(find.byType(PaymentScreen), findsNothing);
    expect(find.textContaining('indisponible'), findsOneWidget);
  });

  testWidgets('double submission is disabled while creation is pending', (
    tester,
  ) async {
    final completer = Completer<String>();
    final repository = _Repository(pending: completer);
    await tester.pumpWidget(_app(repository));

    await _tapCreate(tester);
    await tester.pump();
    expect(find.text('Création en cours...'), findsOneWidget);
    expect(repository.calls, 1);

    await tester.tap(find.text('Création en cours...'));
    await tester.pump();
    expect(repository.calls, 1);

    completer.complete('booking_1');
    await tester.pumpAndSettle();
  });
}

Future<void> _tapCreate(WidgetTester tester) async {
  final button = find.text('Continuer vers le paiement');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
}

Widget _app(_Repository repository) {
  final service = BookingCreationApplicationService(
    session: _Session(),
    repository: repository,
    selectableOccurrences: SelectableOccurrenceApplicationService(
      expertCatalog: ExpertCatalogApplicationService(
        repository: const _CatalogRepository(),
      ),
      materialization: const CivilOccurrenceMaterializationAdapter(),
    ),
    interpretation: const CivilOccurrenceInterpretationAdapter(
      resolver: LaunchMarketTimezoneResolver(),
    ),
    channelFactory: () => 'mentora_test',
  );
  final notifications = BookingNotificationApplicationService(
    session: _Session(),
    provider: SimulatedNotificationProvider(),
  );
  return MultiProvider(
    providers: [
      Provider<BookingCreationApplicationService>.value(value: service),
      Provider<BookingNotificationApplicationService>.value(
        value: notifications,
      ),
    ],
    child: MaterialApp(
      home: PreConsultationScreen(
        expertName: 'Expert',
        expertId: 'expert_1',
        offer: _offer(),
        // AD-022 C2: the revalidated structured selection replaces the
        // legacy 'Lundi'/'09:00' transport. Monday 3 August 2026, 09:00.
        occurrence: CivilSelection(
          year: 2026,
          month: 8,
          day: 3,
          hour: 9,
          minute: 0,
          durationMinutes: 60,
        ),
      ),
    ),
  );
}

ConsultationOffer _offer() {
  return ConsultationOffer(
    offerId: 'expert:expert_1:consultation:60m',
    expertId: 'expert_1',
    durationMinutes: 60,
    amountMinor: 50000,
    currency: 'XOF',
    clientSelectable: true,
  );
}

final class _Repository implements BookingCreationRepository {
  _Repository({this.result = 'booking_1', this.error, this.pending});

  final String result;
  final Object? error;
  final Completer<String>? pending;
  int calls = 0;

  @override
  Future<String> create(BookingCreation booking) async {
    calls++;
    if (error case final cause?) throw cause;
    if (pending case final completer?) return completer.future;
    return result;
  }
}

final class _CatalogRepository implements ExpertCatalogRepository {
  const _CatalogRepository();

  static final ExpertCatalogEntry _expert = ExpertCatalogEntry(
    id: 'expert_1',
    name: 'Expert',
    job: 'Coach',
    country: 'ML',
    rating: '5',
    online: true,
    availability: const {
      'Lundi': ['09:00'],
    },
    expertTimezone: 'Africa/Bamako',
  );

  @override
  Stream<List<ExpertCatalogEntry>> watchExperts() {
    return Stream.value([_expert]);
  }

  @override
  Future<ExpertCatalogEntry?> findById(String expertId) async {
    return _expert.id == expertId ? _expert : null;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  @override
  String get currentUserId => 'client_1';

  @override
  bool get isAuthenticated => true;
}
