import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_notes/consultation_private_notes_application_service.dart';
import 'package:mentora/application/consultation_notes/consultation_private_notes_failure.dart';
import 'package:mentora/domain/consultation_notes/consultation_private_notes_repository.dart';
import 'package:mentora/widgets/consultation_private_notes_card.dart';
import 'package:provider/provider.dart';

void main() {
  group('ConsultationPrivateNotesApplicationService', () {
    test('creates and overwrites the expert notes', () async {
      final repository = _Repository();
      final service = _service(repository);

      await service.save(bookingId: 'booking_1', notes: 'Première note');
      await service.save(bookingId: 'booking_1', notes: 'Note mise à jour');

      expect(repository.saved, [
        ('booking_1', 'expert_1', 'Première note'),
        ('booking_1', 'expert_1', 'Note mise à jour'),
      ]);
    });

    test('reads the notes back, null when none exist', () async {
      expect(
        await _service(
          _Repository(stored: 'Mes notes'),
        ).loadByBookingId('booking_1'),
        'Mes notes',
      );
      expect(
        await _service(_Repository()).loadByBookingId('booking_1'),
        isNull,
      );
    });

    test('a client session is forbidden for reads and writes', () async {
      final repository = _Repository();
      final service = _service(repository, isExpert: false);

      await expectLater(
        service.save(bookingId: 'booking_1', notes: 'note'),
        throwsA(isA<ConsultationPrivateNotesForbiddenFailure>()),
      );
      await expectLater(
        service.loadByBookingId('booking_1'),
        throwsA(isA<ConsultationPrivateNotesForbiddenFailure>()),
      );
      expect(repository.saved, isEmpty);
      expect(repository.reads, isEmpty);
    });

    test('empty notes are never persisted', () async {
      final repository = _Repository();

      await expectLater(
        _service(repository).save(bookingId: 'booking_1', notes: '   '),
        throwsA(isA<ConsultationPrivateNotesInvalidFailure>()),
      );
      expect(repository.saved, isEmpty);
    });

    test('a missing booking fails closed', () {
      final service = _service(
        _Repository(
          error: const ConsultationPrivateNotesBookingNotFoundException(),
        ),
      );

      expect(
        () => service.save(bookingId: 'missing', notes: 'note'),
        throwsA(isA<ConsultationPrivateNotesBookingNotFoundFailure>()),
      );
    });

    test('an unauthenticated session is rejected', () {
      final service = _service(_Repository(), userId: null);

      expect(
        () => service.save(bookingId: 'booking_1', notes: 'note'),
        throwsA(isA<ConsultationPrivateNotesUnauthenticatedFailure>()),
      );
    });
  });

  group('Private notes — adapter contract', () {
    final source = File(
      'lib/infrastructure/consultation_notes/'
      'firestore_consultation_private_notes_repository.dart',
    ).readAsStringSync();

    test('guards the expert identity on write and read', () {
      expect(source, contains('runTransaction<void>'));
      expect(source, contains("data['expertId'] != expertId"));
      expect(source, contains("collection('consultation_private_notes')"));
      // The booking document is read for the guard, never written.
      expect(source, contains('transaction.get(bookingDocument)'));
      expect(source, isNot(contains('transaction.update')));
      expect(source, isNot(contains('.delete(')));
    });
  });

  group('ConsultationPrivateNotesCard', () {
    testWidgets('shows stored notes and saves an update', (tester) async {
      final repository = _Repository(stored: 'Ancienne note');
      await tester.pumpWidget(_card(repository));
      await tester.pumpAndSettle();

      expect(find.text('Ancienne note'), findsOneWidget);
      expect(find.text('Aucune note privée.'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Nouvelle note');
      await tester.tap(find.text('Enregistrer'));
      await tester.pumpAndSettle();

      expect(repository.saved.single.$3, 'Nouvelle note');
      expect(find.text('Notes enregistrées'), findsOneWidget);
    });

    testWidgets('no stored notes shows the empty state and the field', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_Repository()));
      await tester.pumpAndSettle();

      expect(find.text('Aucune note privée.'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Visible uniquement par vous.'), findsOneWidget);
    });

    testWidgets('empty input is blocked before the service', (tester) async {
      final repository = _Repository();
      await tester.pumpWidget(_card(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Enregistrer'));
      await tester.pump();

      expect(
        find.text('Écrivez une note avant d’enregistrer.'),
        findsOneWidget,
      );
      expect(repository.saved, isEmpty);
    });
  });
}

ConsultationPrivateNotesApplicationService _service(
  _Repository repository, {
  String? userId = 'expert_1',
  bool isExpert = true,
}) {
  return ConsultationPrivateNotesApplicationService(
    session: _Session(userId, isExpert: isExpert),
    repository: repository,
  );
}

Widget _card(_Repository repository) {
  return Provider<ConsultationPrivateNotesApplicationService>.value(
    value: _service(repository),
    child: const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ConsultationPrivateNotesCard(bookingId: 'booking_1'),
        ),
      ),
    ),
  );
}

final class _Repository implements ConsultationPrivateNotesRepository {
  _Repository({this.stored, this.error});

  final String? stored;
  final Object? error;
  final List<(String, String, String)> saved = [];
  final List<(String, String)> reads = [];

  @override
  Future<void> save({
    required String bookingId,
    required String expertId,
    required String notes,
  }) async {
    if (error case final cause?) throw cause;
    saved.add((bookingId, expertId, notes));
  }

  @override
  Future<String?> loadByBookingId({
    required String bookingId,
    required String expertId,
  }) async {
    if (error case final cause?) throw cause;
    reads.add((bookingId, expertId));
    return stored;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId, {required this.isExpert});

  @override
  final String? currentUserId;

  @override
  final bool isExpert;

  @override
  bool get isAuthenticated => currentUserId != null;
}
