import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/authentication/authentication_session.dart';
import 'package:mentora/application/consultation_memory/consultation_memory_application_service.dart';
import 'package:mentora/application/consultation_summary/consultation_summary_application_service.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/domain/consultation_memory/memory_repository.dart';
import 'package:mentora/domain/consultation_summary/ai_summary_provider.dart';
import 'package:mentora/domain/consultation_summary/consultation_summary.dart';
import 'package:mentora/domain/consultation_summary/summary_repository.dart';
import 'package:mentora/widgets/consultation_summary_card.dart';
import 'package:provider/provider.dart';

void main() {
  group('ConsultationSummaryCard — the four states', () {
    testWidgets('NOT_GENERATED invites the first generation', (tester) async {
      await tester.pumpWidget(_app(_SummaryRepository()));
      await tester.pumpAndSettle();

      expect(find.text('Aucun résumé disponible.'), findsOneWidget);
      expect(find.text('Générer le résumé'), findsOneWidget);
      expect(find.text('Copier'), findsNothing);
    });

    testWidgets('GENERATING shows the loader and no action', (tester) async {
      await tester.pumpWidget(
        _app(_SummaryRepository(stored: _summary(SummaryStatus.generating))),
      );
      // The loader animates forever: bounded pumps instead of settle.
      await tester.pump();
      await tester.pump();

      expect(find.text('Génération en cours...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Générer le résumé'), findsNothing);
      expect(find.text('Régénérer'), findsNothing);
    });

    testWidgets('AVAILABLE shows the full text, the date, the engine and '
        'the actions', (tester) async {
      await tester.pumpWidget(
        _app(
          _SummaryRepository(
            stored: _summary(
              SummaryStatus.available,
              text: 'Résumé complet de la consultation.',
              provider: 'openAI',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Résumé complet de la consultation.'),
        findsOneWidget,
      );
      expect(find.textContaining('Généré le 01/08/2026'), findsOneWidget);
      expect(find.text('Moteur : openAI'), findsOneWidget);
      expect(find.text('Copier'), findsOneWidget);
      expect(find.text('Régénérer'), findsOneWidget);
    });

    testWidgets('FAILED offers a retry and shows no text', (tester) async {
      await tester.pumpWidget(
        _app(
          _SummaryRepository(
            stored: _summary(SummaryStatus.failed, text: 'jamais montré'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('La génération du résumé a échoué.'),
        findsOneWidget,
      );
      expect(find.text('Réessayer'), findsOneWidget);
      // The text appears ONLY in AVAILABLE.
      expect(find.text('jamais montré'), findsNothing);
    });
  });

  group('ConsultationSummaryCard — actions', () {
    testWidgets('Générer goes through the application service only', (
      tester,
    ) async {
      final engine = _Engine();
      final states = _SummaryRepository();
      await tester.pumpWidget(_app(states, engine: engine));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Générer le résumé'));
      await tester.pumpAndSettle();

      expect(engine.calls, ['b1']);
      expect(find.text('Résumé généré par le moteur.'), findsOneWidget);
    });

    testWidgets('Régénérer re-runs the same governed path', (tester) async {
      final engine = _Engine();
      await tester.pumpWidget(
        _app(
          _SummaryRepository(
            stored: _summary(SummaryStatus.available, text: 'Ancien résumé.'),
          ),
          engine: engine,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Régénérer'));
      await tester.pumpAndSettle();

      expect(engine.calls, ['b1']);
      expect(find.text('Résumé généré par le moteur.'), findsOneWidget);
      expect(find.text('Ancien résumé.'), findsNothing);
    });

    testWidgets('Copier sends exactly the summary text to the clipboard', (
      tester,
    ) async {
      final copied = <String?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String?);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );

      await tester.pumpWidget(
        _app(
          _SummaryRepository(
            stored: _summary(
              SummaryStatus.available,
              text: 'Texte exact du résumé.',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copier'));
      await tester.pumpAndSettle();

      expect(copied, ['Texte exact du résumé.']);
      expect(find.text('Résumé copié.'), findsOneWidget);
    });

    testWidgets('a failing generation lands on the durable FAILED state', (
      tester,
    ) async {
      final states = _SummaryRepository();
      await tester.pumpWidget(
        _app(states, engine: _Engine(error: StateError('down'))),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Générer le résumé'));
      await tester.pumpAndSettle();

      expect(
        find.text('La génération du résumé a échoué.'),
        findsNWidgets(2), // the card state and the snackbar
      );
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });

  group('Governance — no intelligence in the UI layer', () {
    test('the card knows only the summary application service', () {
      final source = File(
        'lib/widgets/consultation_summary_card.dart',
      ).readAsStringSync();

      expect(source, contains('ConsultationSummaryApplicationService'));
      for (final forbidden in const [
        'AIGateway',
        'AISummaryProvider',
        'AIProvider',
        'openai',
        'OpenAI',
        'HttpClient',
        'cloud_firestore',
        'consultation_memory',
      ]) {
        expect(
          source,
          isNot(contains(forbidden)),
          reason: 'the summary card must not know $forbidden',
        );
      }
    });
  });
}

ConsultationSummary _summary(
  SummaryStatus status, {
  String? text,
  String? provider,
}) {
  return ConsultationSummary(
    bookingId: 'b1',
    status: status,
    summaryText: text,
    provider: provider,
    createdAt: DateTime.utc(2026, 8, 1, 9),
    updatedAt: DateTime.utc(2026, 8, 1, 9),
  );
}

Widget _app(_SummaryRepository states, {_Engine? engine}) {
  final session = _Session('client_1');
  final service = ConsultationSummaryApplicationService(
    session: session,
    memory: ConsultationMemoryApplicationService(
      session: session,
      repository: _MemoryRepository(),
    ),
    provider: engine ?? _Engine(),
    repository: states,
  );
  return Provider<ConsultationSummaryApplicationService>.value(
    value: service,
    child: const MaterialApp(
      home: Scaffold(body: ConsultationSummaryCard(bookingId: 'b1')),
    ),
  );
}

final class _Engine implements AISummaryProvider {
  _Engine({this.error});

  final Object? error;
  final List<String> calls = [];

  @override
  Future<SummaryGenerationResult> generate({
    required String bookingId,
    required ConsultationMemory memory,
  }) async {
    if (error case final cause?) throw cause;
    calls.add(bookingId);
    return SummaryGenerationResult(
      summaryText: 'Résumé généré par le moteur.',
      provider: 'openAI',
      generatedAt: DateTime.utc(2026, 8, 1, 12),
    );
  }
}

final class _SummaryRepository implements SummaryRepository {
  _SummaryRepository({ConsultationSummary? stored}) : _stored = stored;

  ConsultationSummary? _stored;

  @override
  Future<void> saveStatus({
    required String bookingId,
    required String userId,
    required SummaryStatus status,
    String? summaryText,
    String? provider,
  }) async {
    _stored = ConsultationSummary(
      bookingId: bookingId,
      status: status,
      summaryText: summaryText ?? _stored?.summaryText,
      provider: provider ?? _stored?.provider,
      createdAt: _stored?.createdAt ?? DateTime.utc(2026, 8, 1, 9),
      updatedAt: DateTime.utc(2026, 8, 1, 9),
    );
  }

  @override
  Future<ConsultationSummary?> findByBookingId({
    required String bookingId,
    required String userId,
  }) async {
    return _stored;
  }
}

final class _MemoryRepository implements MemoryRepository {
  @override
  Future<void> record({
    required String bookingId,
    required String userId,
    required MemoryEntryType type,
    required Map<String, Object?> payload,
  }) async {}

  @override
  Future<ConsultationMemory> read({
    required String bookingId,
    required String userId,
  }) async {
    return ConsultationMemory(
      bookingId: bookingId,
      entries: const [],
      createdAt: null,
    );
  }
}

final class _Session extends Fake implements AuthenticationSession {
  _Session(this.currentUserId);

  @override
  final String? currentUserId;

  @override
  bool get isAuthenticated => currentUserId != null;
}
