import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/assistant/assistant_provider.dart';
import 'package:mentora/domain/assistant/assistant_suggestion.dart';
import 'package:mentora/domain/consultation_memory/consultation_memory.dart';
import 'package:mentora/widgets/assistant_controller.dart';
import 'package:mentora/widgets/assistant_overlay.dart';
import 'package:mentora/widgets/assistant_suggestion_card.dart';

void main() {
  group('AssistantController', () {
    test('follows the assistant stream, keeping only the last three', () async {
      final stream = _AssistantStream();
      final controller = AssistantController(assistant: stream);
      addTearDown(controller.dispose);

      for (var index = 1; index <= 5; index++) {
        stream.push(_suggestion('Titre $index', index));
      }
      await Future<void>.delayed(Duration.zero);

      expect(controller.visible, hasLength(3));
      expect(
        controller.visible.map((suggestion) => suggestion.title).toList(),
        ['Titre 3', 'Titre 4', 'Titre 5'],
      );
      expect(
        () => controller.visible.add(_suggestion('x', 9)),
        throwsUnsupportedError,
      );
    });

    test('a failed flux stops producing — nothing invented', () async {
      final stream = _AssistantStream();
      final controller = AssistantController(assistant: stream);
      addTearDown(controller.dispose);

      stream.push(_suggestion('Un', 1));
      await Future<void>.delayed(Duration.zero);
      stream.pushError(StateError('engine down'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.visible, hasLength(1));
    });
  });

  group('AssistantOverlay', () {
    testWidgets('shows priority, title and content — the three priorities '
        'visually distinct', (tester) async {
      final stream = _AssistantStream();
      final controller = AssistantController(assistant: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      stream.push(
        _suggestion('Point budget', 1, priority: AssistantPriority.high),
      );
      stream.push(
        _suggestion('Question délais', 2, priority: AssistantPriority.normal),
      );
      stream.push(
        _suggestion('Rappel contexte', 3, priority: AssistantPriority.low),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Point budget'), findsOneWidget);
      expect(find.text('Contenu 1'), findsOneWidget);
      expect(find.text('Important'), findsOneWidget);
      expect(find.text('Suggestion'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });

    testWidgets('only the last three suggestions stay on screen, '
        'passively', (tester) async {
      final stream = _AssistantStream();
      final controller = AssistantController(assistant: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      for (var index = 1; index <= 4; index++) {
        stream.push(_suggestion('Titre $index', index));
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Titre 1'), findsNothing);
      expect(find.byType(AssistantSuggestionCard), findsNWidgets(3));
      // Passive and unobtrusive: no dialog, no scroll, cards inert.
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(Scrollable), findsNothing);
    });

    testWidgets('the overlay retracts to its compact chip and expands '
        'back', (tester) async {
      final stream = _AssistantStream();
      final controller = AssistantController(assistant: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      stream.push(_suggestion('Visible', 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Visible'), findsOneWidget);

      await tester.tap(find.text('Copilote'));
      await tester.pump();
      expect(find.text('Visible'), findsNothing);
      expect(find.text('Copilote'), findsOneWidget);

      await tester.tap(find.text('Copilote'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Visible'), findsOneWidget);
    });

    testWidgets('the consultation underneath keeps receiving taps', (
      tester,
    ) async {
      final stream = _AssistantStream();
      final controller = AssistantController(assistant: stream);
      addTearDown(controller.dispose);
      var tapped = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => tapped++,
                    child: const ColoredBox(color: Colors.black),
                  ),
                ),
                Positioned.fill(
                  child: AssistantOverlay(controller: controller),
                ),
              ],
            ),
          ),
        ),
      );
      stream.push(_suggestion('Discret', 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // A tap in the middle of the video reaches the video, not the
      // copilot: the consultation is never interrupted.
      await tester.tapAt(const Offset(100, 400));
      expect(tapped, 1);
    });
  });

  group('Governance — the copilot UI is a projection', () {
    test('the assistant UI components know only the assistant stream', () {
      for (final path in const [
        'lib/widgets/assistant_controller.dart',
        'lib/widgets/assistant_suggestion_card.dart',
        'lib/widgets/assistant_overlay.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'AssistantProvider',
          'AIGateway',
          'openai',
          'OpenAI',
          'ConsultationAssistantApplicationService',
          'ConsultationMemory',
          'cloud_firestore',
          'Firestore',
          'HttpClient',
          'showDialog',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
      final controller = File(
        'lib/widgets/assistant_controller.dart',
      ).readAsStringSync();
      expect(controller, contains('AssistantStream'));
    });

    test('the copilot surface in the live screen is expert-only, fail '
        'closed', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('isExpert'));
      expect(source, contains('AssistantController'));
      // Without an expert session the overlay never appears.
      expect(source, contains('isExpert = false'));
    });
  });
}

AssistantSuggestion _suggestion(
  String title,
  int n, {
  AssistantPriority priority = AssistantPriority.normal,
}) {
  return AssistantSuggestion(
    sessionId: 's1',
    suggestionId: 'sg_$n',
    title: title,
    content: 'Contenu $n',
    priority: priority,
    createdAt: DateTime.utc(2026, 8, 1, 9, 0, n),
  );
}

Widget _app(AssistantController controller) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: Colors.black)),
          Positioned.fill(child: AssistantOverlay(controller: controller)),
        ],
      ),
    ),
  );
}

final class _AssistantStream implements AssistantStream {
  final StreamController<AssistantSuggestion> _suggestions =
      StreamController<AssistantSuggestion>.broadcast(sync: true);

  void push(AssistantSuggestion suggestion) => _suggestions.add(suggestion);

  void pushError(Object error) => _suggestions.addError(error);

  @override
  Stream<AssistantSuggestion> get suggestions => _suggestions.stream;

  @override
  AssistantStatus get status => AssistantStatus.assisting;

  @override
  Future<void> refresh(ConsultationMemory memory) async {}

  @override
  Future<AssistantResult> stop() async {
    return const AssistantResult(
      sessionId: 's1',
      status: AssistantStatus.stopped,
    );
  }
}
