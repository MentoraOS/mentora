import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/conversation/conversation_application_service.dart';
import 'package:mentora/application/conversation/conversation_failure.dart';
import 'package:mentora/domain/conversation/conversation.dart';
import 'package:mentora/domain/conversation/conversation_repository.dart';
import 'package:mentora/screens/conversation_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('ConversationApplicationService — sending', () {
    test('a participant sends trimmed text to their conversation', () async {
      final repository = _ConversationRepository();
      final service = _service(repository);

      await service.sendMessage(bookingId: 'b1', content: '  Bonjour !  ');

      expect(repository.sent, [('b1', 'client_1', 'Bonjour !')]);
    });

    test('an empty message never reaches the repository', () async {
      final repository = _ConversationRepository();
      final service = _service(repository);

      await expectLater(
        service.sendMessage(bookingId: 'b1', content: '   '),
        throwsA(isA<ConversationEmptyMessageFailure>()),
      );
      expect(repository.sent, isEmpty);
    });

    test('an unauthenticated session fails typed', () {
      final repository = _ConversationRepository();
      final service = ConversationApplicationService(
        session: _Session(null),
        repository: repository,
      );

      expect(
        () => service.sendMessage(bookingId: 'b1', content: 'Bonjour'),
        throwsA(isA<ConversationUnauthenticatedFailure>()),
      );
      expect(repository.sent, isEmpty);
    });

    test('a foreign user or unknown booking reads as not-found', () {
      final service = _service(
        _ConversationRepository(
          error: const ConversationNotFoundException(),
        ),
      );

      expect(
        () => service.sendMessage(bookingId: 'b1', content: 'Bonjour'),
        throwsA(isA<ConversationNotFoundFailure>()),
      );
    });

    test('non-conversational states are refused with their status', () async {
      for (final status in const ['pending_payment', 'pending', 'cancelled']) {
        final service = _service(
          _ConversationRepository(
            error: ConversationStateException(currentStatus: status),
          ),
        );

        await expectLater(
          service.sendMessage(bookingId: 'b1', content: 'Bonjour'),
          throwsA(
            isA<ConversationInvalidStateFailure>().having(
              (failure) => failure.currentStatus,
              'currentStatus',
              status,
            ),
          ),
          reason: status,
        );
      }
    });

    test('infrastructure errors surface as repository failures', () {
      final service = _service(
        _ConversationRepository(error: StateError('offline')),
      );

      expect(
        () => service.sendMessage(bookingId: 'b1', content: 'Bonjour'),
        throwsA(isA<ConversationRepositoryFailure>()),
      );
    });
  });

  group('ConversationApplicationService — watching', () {
    test('a participant receives the live message stream', () async {
      final repository = _ConversationRepository();
      final service = _service(repository);

      final future = service.watchMessages('b1').first;
      // Let the stream chain subscribe before the first emission.
      await Future<void>.delayed(Duration.zero);
      repository.push([
        _message(id: 'm1', senderId: 'client_1', content: 'Bonjour'),
      ]);

      final messages = await future;
      expect(messages.single.content, 'Bonjour');
      expect(repository.watched, [('b1', 'client_1')]);
    });

    test('an unauthenticated watcher fails typed', () {
      final service = ConversationApplicationService(
        session: _Session(null),
        repository: _ConversationRepository(),
      );

      expect(
        service.watchMessages('b1').first,
        throwsA(isA<ConversationUnauthenticatedFailure>()),
      );
    });

    test('a foreign watcher fails closed as not-found', () {
      final service = _service(
        _ConversationRepository(
          error: const ConversationNotFoundException(),
        ),
      );

      expect(
        service.watchMessages('b1').first,
        throwsA(isA<ConversationNotFoundFailure>()),
      );
    });
  });

  group('Conversation — adapter contract', () {
    final source = File(
      'lib/infrastructure/conversation/firestore_conversation_repository.dart',
    ).readAsStringSync();

    test('dedicated collection keyed by booking, booking never written', () {
      expect(source, contains("collection('consultation_conversations')"));
      expect(source, contains('_conversations.doc(bookingId)'));
      expect(source, contains('runTransaction'));
      // Ownership and state guards read the booking, never write it.
      expect(source, contains("collection('bookings')"));
      expect(source, isNot(contains('transaction.update')));
      expect(source, contains('_conversationalStatuses'));
      expect(source, contains("'confirmed',"));
      expect(source, contains("'paid',"));
      expect(source, contains("'completed',"));
      expect(source, contains("'createdAt': FieldValue.serverTimestamp()"));
    });

    test('real time is Firestore streams only — no polling', () {
      expect(source, contains('.snapshots()'));
      expect(source, isNot(contains('Timer')));
      expect(source, isNot(contains('periodic')));
      expect(source, isNot(contains('while (')));
    });
  });

  group('ConversationScreen', () {
    testWidgets('messages stream in live and bubbles sit on both sides', (
      tester,
    ) async {
      final repository = _ConversationRepository();

      await tester.pumpWidget(_app(repository));
      await tester.pump();

      repository.push([
        _message(id: 'm1', senderId: 'client_1', content: 'Bonjour !'),
        _message(
          id: 'm2',
          senderId: 'expert_1',
          content: 'Bienvenue.',
          role: ConversationRole.expert,
        ),
      ]);
      await tester.pump();

      expect(find.text('Bonjour !'), findsOneWidget);
      expect(find.text('Bienvenue.'), findsOneWidget);
      // Timestamps are visible on the bubbles.
      expect(find.text('09:05'), findsNWidgets(2));

      // A new message appears instantly — stream only, no reload.
      repository.push([
        _message(id: 'm1', senderId: 'client_1', content: 'Bonjour !'),
        _message(
          id: 'm2',
          senderId: 'expert_1',
          content: 'Bienvenue.',
          role: ConversationRole.expert,
        ),
        _message(id: 'm3', senderId: 'client_1', content: 'Merci beaucoup.'),
      ]);
      await tester.pump();
      expect(find.text('Merci beaucoup.'), findsOneWidget);

      final mine = tester.widget<Align>(
        find.ancestor(
          of: find.text('Bonjour !'),
          matching: find.byType(Align),
        ).first,
      );
      final theirs = tester.widget<Align>(
        find.ancestor(
          of: find.text('Bienvenue.'),
          matching: find.byType(Align),
        ).first,
      );
      expect(mine.alignment, Alignment.centerRight);
      expect(theirs.alignment, Alignment.centerLeft);
    });

    testWidgets('sending goes through the application service and clears '
        'the composer', (tester) async {
      final repository = _ConversationRepository();

      await tester.pumpWidget(_app(repository));
      await tester.pump();
      repository.push(const []);
      await tester.pump();

      await tester.enterText(find.byType(TextField), '  Bonjour !  ');
      await tester.tap(find.byTooltip('Envoyer'));
      await tester.pump();

      expect(repository.sent, [('b1', 'client_1', 'Bonjour !')]);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
    });

    testWidgets('an empty composer sends nothing', (tester) async {
      final repository = _ConversationRepository();

      await tester.pumpWidget(_app(repository));
      await tester.pump();
      repository.push(const []);
      await tester.pump();

      await tester.tap(find.byTooltip('Envoyer'));
      await tester.pump();

      expect(repository.sent, isEmpty);
    });

    testWidgets('a closed conversation surfaces the failure on send', (
      tester,
    ) async {
      final repository = _ConversationRepository(
        sendError: const ConversationStateException(
          currentStatus: 'cancelled',
        ),
      );

      await tester.pumpWidget(_app(repository));
      await tester.pump();
      repository.push(const []);
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Bonjour');
      await tester.tap(find.byTooltip('Envoyer'));
      await tester.pumpAndSettle();

      expect(
        find.text('Cette conversation n’est plus ouverte.'),
        findsOneWidget,
      );
    });

    testWidgets('an empty conversation invites the first message', (
      tester,
    ) async {
      final repository = _ConversationRepository();

      await tester.pumpWidget(_app(repository));
      await tester.pump();
      repository.push(const []);
      await tester.pump();

      expect(find.text('Aucun message. Écrivez le premier !'), findsOneWidget);
    });
  });
}

Message _message({
  required String id,
  required String senderId,
  required String content,
  ConversationRole role = ConversationRole.client,
}) {
  return Message(
    id: id,
    bookingId: 'b1',
    senderId: senderId,
    senderRole: role,
    content: content,
    createdAt: DateTime(2026, 8, 3, 9, 5),
  );
}

ConversationApplicationService _service(_ConversationRepository repository) {
  return ConversationApplicationService(
    session: _Session('client_1'),
    repository: repository,
  );
}

Widget _app(_ConversationRepository repository) {
  return MultiProvider(
    providers: [
      Provider<AuthenticationSession>.value(value: _Session('client_1')),
      Provider<ConversationApplicationService>.value(
        value: _service(repository),
      ),
    ],
    child: const MaterialApp(
      home: ConversationScreen(bookingId: 'b1', title: 'Awa'),
    ),
  );
}

final class _ConversationRepository implements ConversationRepository {
  _ConversationRepository({this.error, this.sendError});

  final Object? error;
  final Object? sendError;
  final StreamController<List<Message>> _messages =
      StreamController<List<Message>>.broadcast();
  final List<(String, String, String)> sent = [];
  final List<(String, String)> watched = [];

  void push(List<Message> messages) => _messages.add(messages);

  @override
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String content,
  }) async {
    if (sendError case final cause?) throw cause;
    if (error case final cause?) throw cause;
    sent.add((bookingId, senderId, content));
  }

  @override
  Stream<List<Message>> watchMessages({
    required String bookingId,
    required String userId,
  }) async* {
    if (error case final cause?) throw cause;
    watched.add((bookingId, userId));
    yield* _messages.stream;
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
