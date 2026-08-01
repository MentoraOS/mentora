import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_brief/consultation_brief_application_service.dart';
import 'package:mentora/application/consultation_brief/consultation_brief_failure.dart';
import 'package:mentora/domain/consultation_brief/consultation_brief.dart';
import 'package:mentora/screens/consultation_brief_screen.dart';
import 'package:mentora/widgets/consultation_brief_card.dart';
import 'package:provider/provider.dart';

void main() {
  group('ConsultationBriefApplicationService', () {
    test('saves the client brief for their booking', () async {
      final repository = _Repository();
      final service = _service(repository);

      await service.save(
        bookingId: 'booking_1',
        objective: 'Structurer mon activité',
        description: 'Je lance une fintech au Mali.',
        questions: 'Quelles étapes ?',
        expectedOutcome: 'Un plan d’action',
      );

      final saved = repository.saved.single;
      expect(saved.$1, 'booking_1');
      expect(saved.$2, 'client_1');
      expect(saved.$3.objective, 'Structurer mon activité');
      expect(saved.$3.questions, 'Quelles étapes ?');
    });

    test('reads the brief back, null when none exists', () async {
      final stored = ConsultationBrief(
        objective: 'Objectif',
        description: 'Description',
        questions: '',
        expectedOutcome: '',
      );
      expect(
        await _service(_Repository(stored: stored)).loadByBookingId('b1'),
        stored,
      );
      expect(await _service(_Repository()).loadByBookingId('b1'), isNull);
    });

    test('missing required fields fail closed, nothing persisted', () async {
      final repository = _Repository();
      final service = _service(repository);

      for (final (objective, description) in const [
        ('', 'Description'),
        ('Objectif', '  '),
      ]) {
        await expectLater(
          service.save(
            bookingId: 'booking_1',
            objective: objective,
            description: description,
            questions: '',
            expectedOutcome: '',
          ),
          throwsA(isA<ConsultationBriefInvalidFailure>()),
        );
      }
      expect(repository.saved, isEmpty);
    });

    test('a missing booking fails closed', () {
      final service = _service(
        _Repository(error: const ConsultationBriefBookingNotFoundException()),
      );

      expect(
        () => service.save(
          bookingId: 'missing',
          objective: 'Objectif',
          description: 'Description',
          questions: '',
          expectedOutcome: '',
        ),
        throwsA(isA<ConsultationBriefBookingNotFoundFailure>()),
      );
    });

    test('an unauthenticated session is rejected', () {
      final service = _service(_Repository(), userId: null);

      expect(
        () => service.save(
          bookingId: 'booking_1',
          objective: 'Objectif',
          description: 'Description',
          questions: '',
          expectedOutcome: '',
        ),
        throwsA(isA<ConsultationBriefUnauthenticatedFailure>()),
      );
    });
  });

  group('Consultation brief — adapter contract', () {
    final source = File(
      'lib/infrastructure/consultation_brief/'
      'firestore_consultation_brief_repository.dart',
    ).readAsStringSync();

    test('verifies the booking transactionally and never touches it', () {
      expect(source, contains('runTransaction<void>'));
      expect(source, contains("data['clientId'] != clientId"));
      expect(source, contains("collection('consultation_briefs')"));
      // The booking document is read for the guard, never written.
      expect(source, contains('transaction.get(bookingDocument)'));
      expect(source, isNot(contains('transaction.update')));
      expect(source, isNot(contains('.delete(')));
    });
  });

  group('ConsultationBriefCard', () {
    testWidgets('shows the brief content to the expert', (tester) async {
      final stored = ConsultationBrief(
        objective: 'Structurer mon activité',
        description: 'Je lance une fintech.',
        questions: 'Quelles étapes ?',
        expectedOutcome: 'Un plan',
      );
      await tester.pumpWidget(
        _card(_Repository(stored: stored), isExpert: true),
      );
      await tester.pumpAndSettle();

      expect(find.text('Objectif'), findsOneWidget);
      expect(find.text('Structurer mon activité'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Questions'), findsOneWidget);
      expect(find.text('Résultat attendu'), findsOneWidget);
      expect(find.text('Préparer votre consultation'), findsNothing);
    });

    testWidgets('a legacy booking without a brief shows the empty state', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_Repository(), isExpert: true));
      await tester.pumpAndSettle();

      expect(find.text('Aucun brief renseigné.'), findsOneWidget);
      // The expert never gets the fill-in action.
      expect(find.text('Préparer votre consultation'), findsNothing);
    });

    testWidgets('the client can fill the brief in when none exists', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_Repository()));
      await tester.pumpAndSettle();

      expect(find.text('Aucun brief renseigné.'), findsOneWidget);
      expect(find.text('Préparer votre consultation'), findsOneWidget);
    });
  });

  group('ConsultationBriefScreen', () {
    testWidgets('required fields gate the save', (tester) async {
      final repository = _Repository();
      await tester.pumpWidget(_form(repository));

      await tester.ensureVisible(find.text('Continuer'));
      await tester.tap(find.text('Continuer'));
      await tester.pump();

      expect(
        find.text('L’objectif et la description sont obligatoires.'),
        findsOneWidget,
      );
      expect(repository.saved, isEmpty);
    });

    testWidgets('a complete form saves the snapshot and closes', (
      tester,
    ) async {
      final repository = _Repository();
      await tester.pumpWidget(_form(repository));

      await tester.enterText(
        find.byType(TextField).at(0),
        'Structurer mon activité',
      );
      await tester.enterText(
        find.byType(TextField).at(1),
        'Je lance une fintech.',
      );
      await tester.ensureVisible(find.text('Continuer'));
      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      final saved = repository.saved.single;
      expect(saved.$1, 'booking_1');
      expect(saved.$3.objective, 'Structurer mon activité');
      expect(find.byType(ConsultationBriefScreen), findsNothing);
    });

    testWidgets('the documents placeholder is present', (tester) async {
      await tester.pumpWidget(_form(_Repository()));

      await tester.ensureVisible(find.text('Documents à préparer'));
      expect(find.text('Documents à préparer'), findsOneWidget);
      expect(find.text('Bientôt disponible'), findsOneWidget);
    });
  });
}

ConsultationBriefApplicationService _service(
  _Repository repository, {
  String? userId = 'client_1',
}) {
  return ConsultationBriefApplicationService(
    session: _Session(userId),
    repository: repository,
  );
}

Widget _card(_Repository repository, {bool isExpert = false}) {
  return MultiProvider(
    providers: [
      Provider<AuthenticationSession>.value(
        value: _Session(isExpert ? 'expert_1' : 'client_1', isExpert: isExpert),
      ),
      Provider<ConsultationBriefApplicationService>.value(
        value: _service(repository),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ConsultationBriefCard(
            bookingId: 'booking_1',
            onFillIn: _noFillIn,
          ),
        ),
      ),
    ),
  );
}

Widget _form(_Repository repository) {
  return Provider<ConsultationBriefApplicationService>.value(
    value: _service(repository),
    child: const MaterialApp(
      home: ConsultationBriefScreen(bookingId: 'booking_1'),
    ),
  );
}

Future<bool?> _noFillIn() async => false;

final class _Repository implements ConsultationBriefRepository {
  _Repository({this.stored, this.error});

  final ConsultationBrief? stored;
  final Object? error;
  final List<(String, String, ConsultationBrief)> saved = [];

  @override
  Future<void> save({
    required String bookingId,
    required String clientId,
    required ConsultationBrief brief,
  }) async {
    if (error case final cause?) throw cause;
    saved.add((bookingId, clientId, brief));
  }

  @override
  Future<ConsultationBrief?> loadByBookingId(String bookingId) async {
    if (error case final cause?) throw cause;
    return stored;
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
