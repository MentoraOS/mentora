import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/pre_consultation/ai/ai_readiness.dart';
import 'package:mentora/application/pre_consultation/ai/ai_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/ai/ai_readiness_failure.dart';
import 'package:mentora/application/pre_consultation/ai/ai_readiness_provider.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_engine.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_registry.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_result.dart';

void main() {
  group('AIReadiness — pure state, frozen', () {
    test('is const-constructible with exactly three fields and a '
        'four-value status', () {
      final readiness = AIReadiness(
        available: true,
        status: AIReadinessStatus.available,
        checkedAt: DateTime.utc(2026, 8, 2),
      );
      expect(readiness.available, isTrue);

      final source = File(
        'lib/application/pre_consultation/ai/ai_readiness.dart',
      ).readAsStringSync();
      expect(source, contains('const AIReadiness({'));
      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final bool available;',
        'final AIReadinessStatus status;',
        'final DateTime checkedAt;',
      ]);
      expect(AIReadinessStatus.values.map((value) => value.name).toList(), [
        'unknown',
        'unavailable',
        'available',
        'degraded',
      ]);
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('=> ')));
    });
  });

  group('AIReadinessProvider — pure contract', () {
    test('exposes exactly one method', () {
      final source = File(
        'lib/application/pre_consultation/ai/ai_readiness_provider.dart',
      ).readAsStringSync();

      final contract = source.substring(
        source.indexOf('abstract interface class AIReadinessProvider'),
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
      const provider = SimulatedAIReadinessProvider();

      final readiness = await provider.check();

      expect(readiness.available, isFalse);
      expect(readiness.status, AIReadinessStatus.unknown);
    });
  });

  group('AIReadinessChecker — transform only', () {
    test('delegates to the provider and transforms the verdict '
        'verbatim', () async {
      final checked = DateTime.utc(2026, 8, 2, 9);
      final checker = AIReadinessChecker(
        provider: _Provider(
          AIReadiness(
            available: true,
            status: AIReadinessStatus.available,
            checkedAt: checked,
          ),
        ),
      );

      final result = await checker.check();

      expect(result.checkerId, 'ai');
      expect(result.ready, isTrue);
      expect(result.checkedAt, checked);
    });

    test('its identity can never drift from the engine identity', () {
      expect(
        AIReadinessChecker.checkerId,
        ConsultationReadinessEngine.aiCheckerId,
      );
    });

    test('unavailable and timeout PROPAGATE untouched — the engine fail '
        'closes', () async {
      for (final failure in const [
        AIUnavailableFailure(),
        AITimeoutFailure(),
      ]) {
        final checker = AIReadinessChecker(
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
        'lib/application/pre_consultation/ai/ai_readiness_failure.dart',
      ).readAsStringSync();

      final failures = RegExp(r'final class (\w+)')
          .allMatches(source)
          .map((match) => match.group(1))
          .toList();
      expect(failures, ['AIUnavailableFailure', 'AITimeoutFailure']);
    });
  });

  group('Engine — one more registered checker, same logic', () {
    test('the AI checker runs in order and its verdict lands on the AI '
        'fact', () async {
      final order = <String>[];
      final registry = ConsultationReadinessRegistry()
        ..register(_OrderSpy('first', order))
        ..register(
          AIReadinessChecker(
            provider: _Provider(
              AIReadiness(
                available: true,
                status: AIReadinessStatus.available,
                checkedAt: DateTime.utc(2026, 8, 2),
              ),
              order: order,
            ),
          ),
        );
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(order, ['first', 'ai']);
      expect(readiness.aiReady, isTrue);
      // The other facts are untouched by the AI checker.
      expect(readiness.networkReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.microphoneReady, isFalse);
      expect(readiness.recordingReady, isFalse);
    });

    test('the standard engine registers exactly in the frozen order: '
        'network, permissions, camera, microphone, ai', () {
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
      ];
      expect(positions.every((position) => position > 0), isTrue);
      expect(List.of(positions)..sort(), positions);
    });

    test('the standard engine registers the AI checker over the '
        'simulated provider — fail closed today', () async {
      final engine = ConsultationReadinessEngine.standard();

      final readiness = await engine.prepare(bookingId: 'b1');

      // Simulated sources: nothing proven, so nothing is ready.
      expect(readiness.aiReady, isFalse);
      expect(readiness.networkReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.microphoneReady, isFalse);
    });
  });

  group('Governance — the AI readiness foundation is blind', () {
    test('zero AI dependency, zero network, zero platform, zero '
        'storage in the AI readiness layer', () {
      for (final path in const [
        'lib/application/pre_consultation/ai/ai_readiness.dart',
        'lib/application/pre_consultation/ai/ai_readiness_checker.dart',
        'lib/application/pre_consultation/ai/ai_readiness_provider.dart',
        'lib/application/pre_consultation/ai/ai_readiness_failure.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'AIGateway',
          'AIOrchestrator',
          'AIProvider',
          'openai',
          'OpenAI',
          'Gemini',
          'gemini',
          'Deepgram',
          'deepgram',
          'Anthropic',
          'anthropic',
          'Claude',
          'Mistral',
          'Llama',
          'execute(',
          'HttpClient',
          'dart:io',
          'Firestore',
          'FirebaseStorage',
          'livekit',
          'LiveKit',
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

    test('the AI readiness surface is confined to the preparation '
        'platform', () {
      const allowedSurface = [
        'lib/application/pre_consultation/ai/ai_readiness.dart',
        'lib/application/pre_consultation/ai/ai_readiness_checker.dart',
        'lib/application/pre_consultation/ai/ai_readiness_provider.dart',
        'lib/application/pre_consultation/ai/ai_readiness_failure.dart',
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('AIReadinessChecker') ||
                source.contains('AIReadinessProvider') ||
                source.contains('AIReadiness(') ||
                source.contains('AIReadinessStatus')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

final class _Provider implements AIReadinessProvider {
  _Provider(this.readiness, {this.order}) : failure = null;

  _Provider.failing(this.failure)
    : readiness = null,
      order = null;

  final AIReadiness? readiness;
  final Object? failure;
  final List<String>? order;

  @override
  Future<AIReadiness> check() async {
    order?.add('ai');
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
