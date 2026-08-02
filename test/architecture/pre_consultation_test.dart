import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/pre_consultation/pre_consultation_composition.dart';
import 'package:mentora/application/pre_consultation/pre_consultation_coordinator.dart';
import 'package:mentora/application/pre_consultation/pre_consultation_readiness.dart';

void main() {
  group('PreConsultationReadiness — pure state, frozen', () {
    test('carries exactly the eight facts, all final, no method', () {
      final source = File(
        'lib/application/pre_consultation/pre_consultation_readiness.dart',
      ).readAsStringSync();

      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String bookingId;',
        'final bool networkReady;',
        'final bool microphoneReady;',
        'final bool cameraReady;',
        'final bool permissionsReady;',
        'final bool aiReady;',
        'final bool recordingReady;',
        'final DateTime createdAt;',
      ]);
      // Pure state: no computation, no business method.
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('Future<')));
      expect(source, isNot(contains('=> ')));
      expect(source, contains('const PreConsultationReadiness({'));
    });
  });

  group('PreConsultationComposition — assemble only, fail closed', () {
    test('assembles the readiness it is GIVEN; unverified flags stay '
        'false', () {
      const composition = PreConsultationComposition();

      final partial = composition.compose(
        bookingId: 'b1',
        createdAt: DateTime.utc(2026, 8, 2),
        networkReady: true,
        cameraReady: true,
      );

      expect(partial.bookingId, 'b1');
      expect(partial.networkReady, isTrue);
      expect(partial.cameraReady, isTrue);
      // Everything not proven stays false — fail closed.
      expect(partial.microphoneReady, isFalse);
      expect(partial.permissionsReady, isFalse);
      expect(partial.aiReady, isFalse);
      expect(partial.recordingReady, isFalse);
    });

    test('the composition never starts, waits, or touches an engine — '
        'verified at the source', () {
      for (final path in const [
        'lib/application/pre_consultation/pre_consultation_composition.dart',
        'lib/application/pre_consultation/pre_consultation_readiness.dart',
        'lib/application/pre_consultation/pre_consultation_coordinator.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          '.start(',
          '.stop(',
          '.generate(',
          '.record(',
          '.translate(',
          '.transcribe(',
          '.recommend(',
          '.summarize(',
          '.execute(',
          'Timer',
          'Future.delayed',
          'AIGateway',
          'AIProvider',
          'RecordingProvider',
          'TranscriptProvider',
          'TranslationProvider',
          'AssistantProvider',
          'SummaryProvider',
          'RecommendationProvider',
          'ActionItemsProvider',
          'livekit',
          'LiveKit',
          'Firestore',
          'HttpClient',
          'infrastructure',
          'openai',
          'OpenAI',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
    });
  });

  group('PreConsultationCoordinator — prepare and dispose only', () {
    test('prepare assembles once, fail closed to all-false readiness', () {
      final coordinator = PreConsultationCoordinator(bookingId: 'b1');

      expect(coordinator.readiness, isNull);
      final readiness = coordinator.prepare();

      expect(readiness.bookingId, 'b1');
      expect(readiness.networkReady, isFalse);
      expect(readiness.microphoneReady, isFalse);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.aiReady, isFalse);
      expect(readiness.recordingReady, isFalse);
      // Idempotent preparation: the same assembled state.
      expect(coordinator.prepare(), same(readiness));
      expect(coordinator.readiness, same(readiness));
    });

    test('a released coordinator prepares nothing — fail closed', () {
      final coordinator = PreConsultationCoordinator(bookingId: 'b1');
      coordinator.prepare();

      coordinator.dispose();

      expect(coordinator.readiness, isNull);
      expect(() => coordinator.prepare(), throwsStateError);
    });

    test('the coordinator exposes exactly prepare and dispose', () {
      final source = File(
        'lib/application/pre_consultation/pre_consultation_coordinator.dart',
      ).readAsStringSync();

      final methods = RegExp(r'\n  \w[\w<>? ]* (\w+)\(')
          .allMatches(source)
          .map((match) => match.group(1))
          .toList();
      expect(methods, ['prepare', 'dispose']);
    });
  });

  group('Governance — the preparation platform stays sealed', () {
    test('the platform is confined to its files and the live screen', () {
      const allowedSurface = [
        'lib/application/pre_consultation/pre_consultation_readiness.dart',
        'lib/application/pre_consultation/pre_consultation_composition.dart',
        'lib/application/pre_consultation/pre_consultation_coordinator.dart',
        'lib/screens/live_consultation_screen.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('PreConsultationReadiness') ||
                source.contains('PreConsultationComposition') ||
                source.contains('PreConsultationCoordinator')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });

    test('the live screen only calls prepare before entering and dispose '
        'on the way out', () {
      final source = File(
        'lib/screens/live_consultation_screen.dart',
      ).readAsStringSync();

      expect(source, contains('preConsultation?.prepare()'));
      expect(source, contains('preConsultation?.dispose()'));
      // Nothing else of the platform is touched by the screen.
      expect(source, isNot(contains('preConsultation?.readiness')));
      expect(source, isNot(contains('PreConsultationComposition')));
      expect(source, isNot(contains('PreConsultationReadiness')));
    });
  });
}
