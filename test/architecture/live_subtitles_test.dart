import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/domain/translation/translated_transcript_chunk.dart';
import 'package:mentora/domain/translation/translation_provider.dart';
import 'package:mentora/widgets/live_subtitle_overlay.dart';
import 'package:mentora/widgets/subtitle_bubble.dart';
import 'package:mentora/widgets/subtitle_controller.dart';

void main() {
  group('SubtitleController', () {
    test('follows the translation stream, keeping only the last three', () async {
      final stream = _TranslationStream();
      final controller = SubtitleController(translation: stream);
      addTearDown(controller.dispose);

      for (var index = 1; index <= 5; index++) {
        stream.push(_chunk('Texte $index', 'Text $index', index));
      }
      await Future<void>.delayed(Duration.zero);

      expect(controller.visible, hasLength(3));
      expect(
        controller.visible.map((chunk) => chunk.originalText).toList(),
        ['Texte 3', 'Texte 4', 'Texte 5'],
      );
      // The visible list is a sealed projection.
      expect(
        () => controller.visible.add(_chunk('x', 'y', 9)),
        throwsUnsupportedError,
      );
    });

    test('a failed flux stops producing subtitles — nothing invented', () async {
      final stream = _TranslationStream();
      final controller = SubtitleController(translation: stream);
      addTearDown(controller.dispose);

      stream.push(_chunk('Bonjour', 'Hello', 1));
      await Future<void>.delayed(Duration.zero);
      stream.pushError(StateError('engine down'));
      await Future<void>.delayed(Duration.zero);

      expect(controller.visible, hasLength(1));
      expect(controller.visible.single.originalText, 'Bonjour');
    });
  });

  group('LiveSubtitleOverlay', () {
    testWidgets('always shows the original AND the translation, each in '
        'its own color', (tester) async {
      final stream = _TranslationStream();
      final controller = SubtitleController(translation: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      stream.push(_chunk('Bonjour docteur.', 'Hello doctor.', 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Bonjour docteur.'), findsOneWidget);
      expect(find.text('Hello doctor.'), findsOneWidget);
      expect(find.text('FR'), findsOneWidget);
      expect(find.text('EN'), findsOneWidget);

      Color colorOf(String text) {
        return (tester.widget<Text>(find.text(text)).style!).color!;
      }

      // Original and translation never share a color.
      expect(
        colorOf('Bonjour docteur.'),
        isNot(colorOf('Hello doctor.')),
      );
    });

    testWidgets('only the last three subtitles stay on screen', (
      tester,
    ) async {
      final stream = _TranslationStream();
      final controller = SubtitleController(translation: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      for (var index = 1; index <= 4; index++) {
        stream.push(_chunk('Original $index', 'Translated $index', index));
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Original 1'), findsNothing);
      expect(find.text('Original 2'), findsOneWidget);
      expect(find.text('Original 3'), findsOneWidget);
      expect(find.text('Original 4'), findsOneWidget);
      expect(find.byType(SubtitleBubble), findsNWidgets(3));
      // The overlay never scrolls and never blocks the video.
      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(IgnorePointer), findsWidgets);
    });

    testWidgets('subtitles appear softly as the flux lives', (tester) async {
      final stream = _TranslationStream();
      final controller = SubtitleController(translation: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(_app(controller));
      expect(find.byType(SubtitleBubble), findsNothing);

      stream.push(_chunk('Bonjour', 'Hello', 1));
      await tester.pump();
      // Mid-animation the bubble exists; after the switcher settles it is
      // fully shown.
      await tester.pump(const Duration(milliseconds: 120));
      expect(find.byType(SubtitleBubble), findsWidgets);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Bonjour'), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });

    testWidgets('the position adapts without a redesign', (tester) async {
      final stream = _TranslationStream();
      final controller = SubtitleController(translation: stream);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LiveSubtitleOverlay(
              controller: controller,
              position: SubtitlePosition.top,
            ),
          ),
        ),
      );

      final align = tester.widget<Align>(
        find
            .descendant(
              of: find.byType(LiveSubtitleOverlay),
              matching: find.byType(Align),
            )
            .first,
      );
      expect(align.alignment, Alignment.topCenter);
    });
  });

  group('Governance — subtitles are a projection of the projection', () {
    test('the subtitle components know only the translation stream', () {
      for (final path in const [
        'lib/widgets/subtitle_controller.dart',
        'lib/widgets/subtitle_bubble.dart',
        'lib/widgets/live_subtitle_overlay.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'TranslationProvider',
          'AIGateway',
          'Gemini',
          'gemini',
          'RealtimeTranslationApplicationService',
          'cloud_firestore',
          'Firestore',
          'HttpClient',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
      // The controller consumes the stream contract alone.
      final controller = File(
        'lib/widgets/subtitle_controller.dart',
      ).readAsStringSync();
      expect(controller, contains('TranslationStream'));
    });
  });
}

TranslatedTranscriptChunk _chunk(String original, String translated, int n) {
  return TranslatedTranscriptChunk(
    sessionId: 's1',
    participantIdentity: 'b1_client_userA',
    originalText: original,
    translatedText: translated,
    sourceLanguage: 'fr',
    targetLanguage: 'en',
    isFinal: true,
    createdAt: DateTime.utc(2026, 8, 1, 9, 0, n),
  );
}

Widget _app(SubtitleController controller) {
  return MaterialApp(
    home: Scaffold(
      body: Stack(
        children: [
          const ColoredBox(color: Colors.black),
          LiveSubtitleOverlay(controller: controller),
        ],
      ),
    ),
  );
}

final class _TranslationStream implements TranslationStream {
  final StreamController<TranslatedTranscriptChunk> _chunks =
      StreamController<TranslatedTranscriptChunk>.broadcast(sync: true);

  void push(TranslatedTranscriptChunk chunk) => _chunks.add(chunk);

  void pushError(Object error) => _chunks.addError(error);

  @override
  Stream<TranslatedTranscriptChunk> get chunks => _chunks.stream;

  @override
  TranslationStatus get status => TranslationStatus.translating;

  @override
  Future<TranslationResult> stop() async {
    return const TranslationResult(status: TranslationStatus.stopped);
  }
}
