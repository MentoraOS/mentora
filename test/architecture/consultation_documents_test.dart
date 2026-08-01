import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_documents/consultation_document_application_service.dart';
import 'package:mentora/application/consultation_documents/consultation_document_failure.dart';
import 'package:mentora/domain/consultation_documents/consultation_shared_document.dart';
import 'package:mentora/widgets/consultation_documents_card.dart';
import 'package:provider/provider.dart';

void main() {
  group('ConsultationDocumentApplicationService', () {
    test('uploads a document for the session user', () async {
      final repository = _Repository();
      final service = _service(repository);

      await service.upload(
        bookingId: 'booking_1',
        fileName: 'business_plan.pdf',
        bytes: [1, 2, 3],
      );

      final uploaded = repository.uploads.single;
      expect(uploaded.$1, 'booking_1');
      expect(uploaded.$2, 'client_1');
      expect(uploaded.$3, 'business_plan.pdf');
      expect(uploaded.$4, [1, 2, 3]);
    });

    test('lists documents, empty when none exist', () async {
      final stored = [
        _document(fileName: 'cv.pdf', uploaderRole: 'client'),
        _document(fileName: 'contrat.pdf', uploaderRole: 'expert'),
      ];
      expect(
        await _service(
          _Repository(stored: stored),
        ).listByBookingId('booking_1'),
        stored,
      );
      expect(
        await _service(_Repository()).listByBookingId('booking_1'),
        isEmpty,
      );
    });

    test('a foreign user or missing booking fails closed', () async {
      final service = _service(
        _Repository(
          error: const ConsultationDocumentBookingNotFoundException(),
        ),
      );

      await expectLater(
        service.upload(bookingId: 'b', fileName: 'f.pdf', bytes: [1]),
        throwsA(isA<ConsultationDocumentBookingNotFoundFailure>()),
      );
      await expectLater(
        service.listByBookingId('b'),
        throwsA(isA<ConsultationDocumentBookingNotFoundFailure>()),
      );
    });

    test('empty name or content is never uploaded', () async {
      final repository = _Repository();
      final service = _service(repository);

      await expectLater(
        service.upload(bookingId: 'b', fileName: ' ', bytes: [1]),
        throwsA(isA<ConsultationDocumentInvalidFailure>()),
      );
      await expectLater(
        service.upload(bookingId: 'b', fileName: 'f.pdf', bytes: const []),
        throwsA(isA<ConsultationDocumentInvalidFailure>()),
      );
      expect(repository.uploads, isEmpty);
    });

    test('an unauthenticated session is rejected', () {
      final service = _service(_Repository(), userId: null);

      expect(
        () => service.listByBookingId('booking_1'),
        throwsA(isA<ConsultationDocumentUnauthenticatedFailure>()),
      );
    });
  });

  group('Shared documents — adapter contract', () {
    final source = File(
      'lib/infrastructure/consultation_documents/'
      'firebase_consultation_document_repository.dart',
    ).readAsStringSync();

    test('participant-guards every operation, stores metadata only', () {
      expect(source, contains('_requireParticipantRole'));
      expect(source, contains("data['clientId'] == userId"));
      expect(source, contains("data['expertId'] == userId"));
      expect(source, contains('ConsultationDocumentBookingNotFoundException'));
      expect(source, contains("collection('consultation_documents')"));
      expect(source, contains('getDownloadURL'));
      // No deletion pathway exists.
      expect(source, isNot(contains('.delete(')));
    });
  });

  group('ConsultationDocumentsCard', () {
    testWidgets('lists both sections and opens a document', (tester) async {
      final opened = <String>[];
      await tester.pumpWidget(
        _card(
          _Repository(
            stored: [
              _document(
                fileName: 'cv.pdf',
                uploaderRole: 'client',
                fileUrl: 'https://files/cv.pdf',
              ),
              _document(fileName: 'contrat.pdf', uploaderRole: 'expert'),
            ],
          ),
          openUrl: (url) async => opened.add(url),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Documents du client'), findsOneWidget);
      expect(find.text('Documents de l’expert'), findsOneWidget);
      expect(find.text('cv.pdf'), findsOneWidget);
      expect(find.text('contrat.pdf'), findsOneWidget);
      expect(find.text('3 o'), findsNWidgets(2));

      await tester.tap(find.text('Ouvrir').first);
      await tester.pump();
      expect(opened, ['https://files/cv.pdf']);
    });

    testWidgets('no documents shows the empty message', (tester) async {
      await tester.pumpWidget(_card(_Repository()));
      await tester.pumpAndSettle();

      expect(find.text('Aucun document partagé.'), findsOneWidget);
    });

    testWidgets('a client uploads into their own section only', (tester) async {
      final repository = _Repository();
      await tester.pumpWidget(
        _card(
          repository,
          pick: () async => (fileName: 'facture.pdf', bytes: <int>[9, 9]),
        ),
      );
      await tester.pumpAndSettle();

      // One add button (the client's own section).
      expect(find.text('Ajouter un document'), findsOneWidget);

      await tester.tap(find.text('Ajouter un document'));
      await tester.pumpAndSettle();

      final uploaded = repository.uploads.single;
      expect(uploaded.$2, 'client_1');
      expect(uploaded.$3, 'facture.pdf');
      expect(find.text('Document ajouté'), findsOneWidget);
    });

    testWidgets('an expert gets the add action on the expert section', (
      tester,
    ) async {
      final repository = _Repository();
      await tester.pumpWidget(
        _card(
          repository,
          isExpert: true,
          pick: () async => (fileName: 'contrat.pdf', bytes: <int>[1]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ajouter un document'), findsOneWidget);
      await tester.tap(find.text('Ajouter un document'));
      await tester.pumpAndSettle();

      expect(repository.uploads.single.$2, 'expert_1');
    });
  });
}

ConsultationSharedDocument _document({
  required String fileName,
  required String uploaderRole,
  String fileUrl = 'https://files/doc',
}) {
  return ConsultationSharedDocument(
    bookingId: 'booking_1',
    uploadedBy: uploaderRole == 'expert' ? 'expert_1' : 'client_1',
    uploaderRole: uploaderRole,
    fileName: fileName,
    fileSize: 3,
    fileUrl: fileUrl,
  );
}

ConsultationDocumentApplicationService _service(
  _Repository repository, {
  String? userId = 'client_1',
  bool isExpert = false,
}) {
  return ConsultationDocumentApplicationService(
    session: _Session(userId, isExpert: isExpert),
    repository: repository,
  );
}

Widget _card(
  _Repository repository, {
  bool isExpert = false,
  Future<PickedDocument?> Function()? pick,
  Future<void> Function(String url)? openUrl,
}) {
  return MultiProvider(
    providers: [
      Provider<AuthenticationSession>.value(
        value: _Session(isExpert ? 'expert_1' : 'client_1', isExpert: isExpert),
      ),
      Provider<ConsultationDocumentApplicationService>.value(
        value: ConsultationDocumentApplicationService(
          session: _Session(
            isExpert ? 'expert_1' : 'client_1',
            isExpert: isExpert,
          ),
          repository: repository,
        ),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ConsultationDocumentsCard(
            bookingId: 'booking_1',
            pickDocument: pick ?? () async => null,
            openUrl: openUrl ?? (_) async {},
          ),
        ),
      ),
    ),
  );
}

final class _Repository implements ConsultationSharedDocumentRepository {
  _Repository({this.stored = const [], this.error});

  final List<ConsultationSharedDocument> stored;
  final Object? error;
  final List<(String, String, String, List<int>)> uploads = [];

  @override
  Future<void> upload({
    required String bookingId,
    required String userId,
    required String fileName,
    required List<int> bytes,
  }) async {
    if (error case final cause?) throw cause;
    uploads.add((bookingId, userId, fileName, bytes));
  }

  @override
  Future<List<ConsultationSharedDocument>> listByBookingId({
    required String bookingId,
    required String userId,
  }) async {
    if (error case final cause?) throw cause;
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
