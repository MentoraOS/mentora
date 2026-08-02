import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_engine.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_registry.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_result.dart';
import 'package:mentora/application/pre_consultation/recording/recording_readiness.dart';
import 'package:mentora/application/pre_consultation/recording/recording_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/recording/recording_readiness_failure.dart';
import 'package:mentora/application/pre_consultation/recording/recording_readiness_provider.dart';

void main() {
  group('RecordingReadiness — pure state, frozen', () {
    test('is const-constructible with exactly three fields and a '
        'four-value status', () {
      final readiness = RecordingReadiness(
        available: true,
        status: RecordingReadinessStatus.available,
        checkedAt: DateTime.utc(2026, 8, 2),
      );
      expect(readiness.available, isTrue);

      final source = File(
        'lib/application/pre_consultation/recording/'
        'recording_readiness.dart',
      ).readAsStringSync();
      expect(source, contains('const RecordingReadiness({'));
      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final bool available;',
        'final RecordingReadinessStatus status;',
        'final DateTime checkedAt;',
      ]);
      expect(
        RecordingReadinessStatus.values.map((value) => value.name).toList(),
        ['unknown', 'unavailable', 'available', 'unavailableByConsent'],
      );
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('=> ')));
    });
  });

  group('RecordingReadinessProvider — pure contract', () {
    test('exposes exactly one method', () {
      final source = File(
        'lib/application/pre_consultation/recording/'
        'recording_readiness_provider.dart',
      ).readAsStringSync();

      final contract = source.substring(
        source.indexOf('abstract interface class RecordingReadinessProvider'),
        source.indexOf('}'),
      );
      final methods = RegExp(r'(\w+)\(\);')
          .allMatches(contract)
          .map((match) => match.group(1))
          .toList();
      expect(methods, ['check']);
    });

    test('the simulated stand-in answers fail closed — nothing contacted, '
        'nothing invented', () async {
      const provider = SimulatedRecordingReadinessProvider();

      final readiness = await provider.check();

      expect(readiness.available, isFalse);
      expect(readiness.status, RecordingReadinessStatus.unknown);
    });
  });

  group('RecordingReadinessChecker — transform only', () {
    test('delegates to the provider and transforms the verdict '
        'verbatim', () async {
      final checked = DateTime.utc(2026, 8, 2, 9);
      final checker = RecordingReadinessChecker(
        provider: _Provider(
          RecordingReadiness(
            available: true,
            status: RecordingReadinessStatus.available,
            checkedAt: checked,
          ),
        ),
      );

      final result = await checker.check();

      expect(result.checkerId, 'recording');
      expect(result.ready, isTrue);
      expect(result.checkedAt, checked);
    });

    test('its identity can never drift from the engine identity', () {
      expect(
        RecordingReadinessChecker.checkerId,
        ConsultationReadinessEngine.recordingCheckerId,
      );
    });

    test('unavailable and timeout PROPAGATE untouched — the engine fail '
        'closes', () async {
      for (final failure in const [
        RecordingUnavailableFailure(),
        RecordingTimeoutFailure(),
      ]) {
        final checker = RecordingReadinessChecker(
          provider: _Provider.failing(failure),
        );

        Object? caught;
        try {
          await checker.check();
        } catch (error) {
          caught = error;
        }
        expect(caught, same(failure));
      }
    });

    test('exactly the two typed failures exist', () {
      final source = File(
        'lib/application/pre_consultation/recording/'
        'recording_readiness_failure.dart',
      ).readAsStringSync();

      final failures = RegExp(r'final class (\w+)')
          .allMatches(source)
          .map((match) => match.group(1))
          .toList();
      expect(failures, [
        'RecordingUnavailableFailure',
        'RecordingTimeoutFailure',
      ]);
    });
  });

  group('Engine — one more registered checker, same logic', () {
    test('the recording checker runs in order and its verdict lands on '
        'the recording fact', () async {
      final order = <String>[];
      final registry = ConsultationReadinessRegistry()
        ..register(_OrderSpy('first', order))
        ..register(
          RecordingReadinessChecker(
            provider: _Provider(
              RecordingReadiness(
                available: true,
                status: RecordingReadinessStatus.available,
                checkedAt: DateTime.utc(2026, 8, 2),
              ),
              order: order,
            ),
          ),
        );
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(order, ['first', 'recording']);
      expect(readiness.recordingReady, isTrue);
      // The other facts are untouched by the recording checker.
      expect(readiness.networkReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.microphoneReady, isFalse);
      expect(readiness.aiReady, isFalse);
    });

    test('the standard engine registers exactly in the frozen order: '
        'network, permissions, camera, microphone, ai, recording', () {
      final source = File(
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
      ).readAsStringSync();
      final factory = source.substring(
        source.indexOf('factory ConsultationReadinessEngine.standard()'),
      );

      final positions = [
        factory.indexOf('NetworkReadinessChecker('),
        factory.indexOf('PermissionsReadinessChecker('),
        factory.indexOf('CameraReadinessChecker('),
        factory.indexOf('MicrophoneReadinessChecker('),
        factory.indexOf('AIReadinessChecker('),
        factory.indexOf('RecordingReadinessChecker('),
      ];
      expect(positions.every((position) => position > 0), isTrue);
      expect(List.of(positions)..sort(), positions);
    });

    test('the standard engine registers the recording checker over the '
        'simulated provider — fail closed today', () async {
      final engine = ConsultationReadinessEngine.standard();

      final readiness = await engine.prepare(bookingId: 'b1');

      // Simulated sources: nothing proven, so nothing is ready.
      expect(readiness.recordingReady, isFalse);
      expect(readiness.networkReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.microphoneReady, isFalse);
      expect(readiness.aiReady, isFalse);
    });
  });

  group('Governance — the recording readiness foundation is blind', () {
    test('zero recording dependency, zero media, zero network, zero '
        'platform, zero storage in the recording readiness layer', () {
      for (final path in const [
        'lib/application/pre_consultation/recording/'
            'recording_readiness.dart',
        'lib/application/pre_consultation/recording/'
            'recording_readiness_checker.dart',
        'lib/application/pre_consultation/recording/'
            'recording_readiness_provider.dart',
        'lib/application/pre_consultation/recording/'
            'recording_readiness_failure.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'livekit',
          'LiveKit',
          'RecordingProvider',
          'RecordingSession',
          'RecordingOrchestrator',
          'ConsultationRecordingApplicationService',
          'MediaRecorder',
          'Storage',
          'Firestore',
          'HttpClient',
          'dart:io',
          'Gateway',
          'openai',
          'OpenAI',
          'Gemini',
          'gemini',
          'Deepgram',
          'deepgram',
          'infrastructure',
          'PlatformChannel',
          'MethodChannel',
          'Platform.',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
    });

    test('the recording readiness surface is confined to the preparation '
        'platform', () {
      const allowedSurface = [
        'lib/application/pre_consultation/recording/'
            'recording_readiness.dart',
        'lib/application/pre_consultation/recording/'
            'recording_readiness_checker.dart',
        'lib/application/pre_consultation/recording/'
            'recording_readiness_provider.dart',
        'lib/application/pre_consultation/recording/'
            'recording_readiness_failure.dart',
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('RecordingReadinessChecker') ||
                source.contains('RecordingReadinessProvider') ||
                source.contains('RecordingReadiness(') ||
                source.contains('RecordingReadinessStatus')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

final class _Provider implements RecordingReadinessProvider {
  _Provider(this.readiness, {this.order}) : failure = null;

  _Provider.failing(this.failure)
    : readiness = null,
      order = null;

  final RecordingReadiness? readiness;
  final Object? failure;
  final List<String>? order;

  @override
  Future<RecordingReadiness> check() async {
    order?.add('recording');
    if (failure case final cause?) throw cause;
    return readiness!;
  }
}

final class _OrderSpy implements ConsultationReadinessChecker {
  _OrderSpy(this.id, this.order);

  final String id;
  final List<String> order;

  @override
  Future<ConsultationReadinessResult> check() async {
    order.add(id);
    return ConsultationReadinessResult(
      checkerId: id,
      ready: false,
      checkedAt: DateTime.utc(2026, 8, 2),
    );
  }
}
