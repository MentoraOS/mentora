import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_engine.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_registry.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_result.dart';
import 'package:mentora/application/pre_consultation/microphone/microphone_readiness.dart';
import 'package:mentora/application/pre_consultation/microphone/microphone_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/microphone/microphone_readiness_failure.dart';
import 'package:mentora/application/pre_consultation/microphone/microphone_readiness_provider.dart';

void main() {
  group('MicrophoneReadiness — pure state, frozen', () {
    test('is const-constructible with exactly three fields and a '
        'four-value status', () {
      final readiness = MicrophoneReadiness(
        available: true,
        status: MicrophoneStatus.available,
        checkedAt: DateTime.utc(2026, 8, 2),
      );
      expect(readiness.available, isTrue);

      final source = File(
        'lib/application/pre_consultation/microphone/'
        'microphone_readiness.dart',
      ).readAsStringSync();
      expect(source, contains('const MicrophoneReadiness({'));
      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final bool available;',
        'final MicrophoneStatus status;',
        'final DateTime checkedAt;',
      ]);
      expect(MicrophoneStatus.values.map((value) => value.name).toList(), [
        'unknown',
        'unavailable',
        'available',
        'busy',
      ]);
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('=> ')));
    });
  });

  group('MicrophoneReadinessProvider — pure contract', () {
    test('exposes exactly one method', () {
      final source = File(
        'lib/application/pre_consultation/microphone/'
        'microphone_readiness_provider.dart',
      ).readAsStringSync();

      final contract = source.substring(
        source.indexOf('abstract interface class MicrophoneReadinessProvider'),
        source.indexOf('}'),
      );
      final methods = RegExp(r'(\w+)\(\);')
          .allMatches(contract)
          .map((match) => match.group(1))
          .toList();
      expect(methods, ['check']);
    });

    test('the simulated stand-in answers fail closed — nothing probed, '
        'nothing invented', () async {
      const provider = SimulatedMicrophoneReadinessProvider();

      final readiness = await provider.check();

      expect(readiness.available, isFalse);
      expect(readiness.status, MicrophoneStatus.unknown);
    });
  });

  group('MicrophoneReadinessChecker — transform only', () {
    test('delegates to the provider and transforms the verdict '
        'verbatim', () async {
      final checked = DateTime.utc(2026, 8, 2, 9);
      final checker = MicrophoneReadinessChecker(
        provider: _Provider(
          MicrophoneReadiness(
            available: true,
            status: MicrophoneStatus.available,
            checkedAt: checked,
          ),
        ),
      );

      final result = await checker.check();

      expect(result.checkerId, 'microphone');
      expect(result.ready, isTrue);
      expect(result.checkedAt, checked);
    });

    test('its identity can never drift from the engine identity', () {
      expect(
        MicrophoneReadinessChecker.checkerId,
        ConsultationReadinessEngine.microphoneCheckerId,
      );
    });

    test('unavailable and timeout PROPAGATE untouched — the engine fail '
        'closes', () async {
      for (final failure in const [
        MicrophoneUnavailableFailure(),
        MicrophoneTimeoutFailure(),
      ]) {
        final checker = MicrophoneReadinessChecker(
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
        'lib/application/pre_consultation/microphone/'
        'microphone_readiness_failure.dart',
      ).readAsStringSync();

      final failures = RegExp(r'final class (\w+)')
          .allMatches(source)
          .map((match) => match.group(1))
          .toList();
      expect(failures, [
        'MicrophoneUnavailableFailure',
        'MicrophoneTimeoutFailure',
      ]);
    });
  });

  group('Engine — one more registered checker, same logic', () {
    test('the microphone checker runs in order and its verdict lands on '
        'the microphone fact', () async {
      final order = <String>[];
      final registry = ConsultationReadinessRegistry()
        ..register(_OrderSpy('first', order))
        ..register(
          MicrophoneReadinessChecker(
            provider: _Provider(
              MicrophoneReadiness(
                available: true,
                status: MicrophoneStatus.available,
                checkedAt: DateTime.utc(2026, 8, 2),
              ),
              order: order,
            ),
          ),
        );
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(order, ['first', 'microphone']);
      expect(readiness.microphoneReady, isTrue);
      // The other facts are untouched by the microphone checker.
      expect(readiness.networkReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.aiReady, isFalse);
    });

    test('the standard engine registers exactly in the frozen order: '
        'network, permissions, camera, microphone', () {
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
      ];
      expect(positions.every((position) => position > 0), isTrue);
      expect(List.of(positions)..sort(), positions);
    });

    test('the standard engine registers the microphone checker over the '
        'simulated provider — fail closed today', () async {
      final engine = ConsultationReadinessEngine.standard();

      final readiness = await engine.prepare(bookingId: 'b1');

      // Simulated sources: nothing proven, so nothing is ready.
      expect(readiness.microphoneReady, isFalse);
      expect(readiness.networkReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.cameraReady, isFalse);
    });
  });

  group('Governance — the microphone foundation is blind', () {
    test('zero platform, zero plugin, zero hardware, zero vendor, zero '
        'storage in the microphone layer', () {
      for (final path in const [
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness.dart',
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness_checker.dart',
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness_provider.dart',
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness_failure.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'MicrophoneRecorder',
          'AudioRecord',
          'MediaRecorder',
          'flutter_sound',
          'package:record',
          'audio_session',
          'permission_handler',
          'Android',
          'iOS',
          'PlatformChannel',
          'MethodChannel',
          'Platform.',
          'dart:io',
          'livekit',
          'LiveKit',
          'Gateway',
          'openai',
          'OpenAI',
          'Gemini',
          'gemini',
          'Deepgram',
          'deepgram',
          'Firestore',
          'FirebaseStorage',
          'HttpClient',
          'AIProvider',
          'infrastructure',
        ]) {
          expect(
            source,
            isNot(contains(forbidden)),
            reason: '$path must not know $forbidden',
          );
        }
      }
    });

    test('the microphone surface is confined to the preparation '
        'platform', () {
      const allowedSurface = [
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness.dart',
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness_checker.dart',
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness_provider.dart',
        'lib/application/pre_consultation/microphone/'
            'microphone_readiness_failure.dart',
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('MicrophoneReadinessChecker') ||
                source.contains('MicrophoneReadinessProvider') ||
                source.contains('MicrophoneReadiness(') ||
                source.contains('MicrophoneStatus')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

final class _Provider implements MicrophoneReadinessProvider {
  _Provider(this.readiness, {this.order}) : failure = null;

  _Provider.failing(this.failure)
    : readiness = null,
      order = null;

  final MicrophoneReadiness? readiness;
  final Object? failure;
  final List<String>? order;

  @override
  Future<MicrophoneReadiness> check() async {
    order?.add('microphone');
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
