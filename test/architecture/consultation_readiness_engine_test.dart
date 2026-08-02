import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_engine.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_registry.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_result.dart';
import 'package:mentora/application/pre_consultation/pre_consultation_coordinator.dart';

void main() {
  group('ConsultationReadinessRegistry', () {
    test('registers, lists in registration order, unregisters', () {
      final registry = ConsultationReadinessRegistry();
      final first = _Checker('network', ready: true);
      final second = _Checker('camera', ready: true);

      registry.register(first);
      registry.register(second);
      expect(registry.checkers(), [first, second]);

      registry.unregister(first);
      expect(registry.checkers(), [second]);
    });

    test('refuses duplicates', () {
      final registry = ConsultationReadinessRegistry();
      final checker = _Checker('network', ready: true);
      registry.register(checker);

      expect(() => registry.register(checker), throwsArgumentError);
    });

    test('exposes an immutable view', () {
      final registry = ConsultationReadinessRegistry();

      expect(
        () => registry.checkers().add(_Checker('x', ready: true)),
        throwsUnsupportedError,
      );
    });
  });

  group('ConsultationReadinessResult — pure state', () {
    test('is const-constructible with exactly three frozen fields', () {
      final result = ConsultationReadinessResult(
        checkerId: 'network',
        ready: true,
        checkedAt: DateTime.utc(2026, 8, 2),
      );
      expect(result.checkerId, 'network');
      expect(result.ready, isTrue);

      final source = File(
        'lib/application/pre_consultation/consultation_readiness_result.dart',
      ).readAsStringSync();
      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final String checkerId;',
        'final bool ready;',
        'final DateTime checkedAt;',
      ]);
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('=> ')));
      // The constructor itself is const.
      expect(source, contains('const ConsultationReadinessResult({'));
    });
  });

  group('ConsultationReadinessEngine — orchestrate, aggregate, build', () {
    test('no checker registered: every fact stays FALSE — fail closed', () async {
      final engine = ConsultationReadinessEngine(
        registry: ConsultationReadinessRegistry(),
      );

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(readiness.bookingId, 'b1');
      expect(readiness.networkReady, isFalse);
      expect(readiness.microphoneReady, isFalse);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.aiReady, isFalse);
      expect(readiness.recordingReady, isFalse);
    });

    test('one TRUE checker fills exactly its fact', () async {
      final registry = ConsultationReadinessRegistry()
        ..register(
          _Checker(ConsultationReadinessEngine.networkCheckerId, ready: true),
        );
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(readiness.networkReady, isTrue);
      expect(readiness.cameraReady, isFalse);
      expect(readiness.aiReady, isFalse);
    });

    test('several checkers run in registration order and aggregate', () async {
      final order = <String>[];
      final registry = ConsultationReadinessRegistry()
        ..register(_Checker(
          ConsultationReadinessEngine.networkCheckerId,
          ready: true,
          order: order,
        ))
        ..register(_Checker(
          ConsultationReadinessEngine.cameraCheckerId,
          ready: true,
          order: order,
        ))
        ..register(_Checker(
          ConsultationReadinessEngine.aiCheckerId,
          ready: false,
          order: order,
        ));
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(order, ['network', 'camera', 'ai']);
      expect(readiness.networkReady, isTrue);
      expect(readiness.cameraReady, isTrue);
      expect(readiness.aiReady, isFalse);
    });

    test('a failing checker invents nothing and never blocks the '
        'others', () async {
      final registry = ConsultationReadinessRegistry()
        ..register(_Checker(
          ConsultationReadinessEngine.networkCheckerId,
          ready: true,
        ))
        ..register(_Checker(
          ConsultationReadinessEngine.cameraCheckerId,
          ready: true,
          error: StateError('device probe crashed'),
        ))
        ..register(_Checker(
          ConsultationReadinessEngine.microphoneCheckerId,
          ready: true,
        ));
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(readiness.networkReady, isTrue);
      // The failed fact stays FALSE — never guessed.
      expect(readiness.cameraReady, isFalse);
      // The checkers after the failure still ran.
      expect(readiness.microphoneReady, isTrue);
    });

    test('an unknown checker identity is ignored — never guessed', () async {
      final registry = ConsultationReadinessRegistry()
        ..register(_Checker('battery', ready: true));
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(readiness.networkReady, isFalse);
      expect(readiness.recordingReady, isFalse);
    });

    test('no shared state: every preparation is a fresh instance', () async {
      final engine = ConsultationReadinessEngine(
        registry: ConsultationReadinessRegistry(),
      );

      final first = await engine.prepare(bookingId: 'b1');
      final second = await engine.prepare(bookingId: 'b1');

      expect(identical(first, second), isFalse);
    });
  });

  group('PreConsultationCoordinator — delegates to the engine only', () {
    test('the coordinator hands the whole preparation to the engine', () async {
      final registry = ConsultationReadinessRegistry()
        ..register(
          _Checker(ConsultationReadinessEngine.aiCheckerId, ready: true),
        );
      final coordinator = PreConsultationCoordinator(
        bookingId: 'b1',
        engine: ConsultationReadinessEngine(registry: registry),
      );

      final readiness = await coordinator.prepare();

      expect(readiness.aiReady, isTrue);
      expect(readiness.networkReady, isFalse);
    });

    test('the coordinator adds no logic of its own — delegation only', () {
      final source = File(
        'lib/application/pre_consultation/pre_consultation_coordinator.dart',
      ).readAsStringSync();

      expect(source, contains('_engine.prepare('));
      // It no longer assembles a readiness itself.
      expect(source, isNot(contains('.compose(')));
      expect(source, isNot(contains('networkReady')));
    });
  });

  group('Governance — the engine is blind to everything but its own '
      'contracts', () {
    test('the engine layer knows no vendor, platform, provider or '
        'storage', () {
      for (final path in const [
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
        'lib/application/pre_consultation/consultation_readiness_checker.dart',
        'lib/application/pre_consultation/consultation_readiness_result.dart',
        'lib/application/pre_consultation/'
            'consultation_readiness_registry.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'livekit',
          'LiveKit',
          'Firestore',
          'HttpClient',
          'AIGateway',
          'AIProvider',
          'RecordingProvider',
          'TranscriptProvider',
          'TranslationProvider',
          'AssistantProvider',
          'SummaryProvider',
          'RecommendationProvider',
          'ActionItemsProvider',
          'permission_handler',
          'connectivity',
          'Platform.',
          'dart:io',
          'infrastructure',
          'Android',
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

    test('the engine surface is confined to the preparation platform', () {
      const allowedSurface = [
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
        'lib/application/pre_consultation/consultation_readiness_checker.dart',
        'lib/application/pre_consultation/consultation_readiness_result.dart',
        'lib/application/pre_consultation/'
            'consultation_readiness_registry.dart',
        'lib/application/pre_consultation/pre_consultation_coordinator.dart',
        'lib/application/pre_consultation/network/'
            'network_readiness_checker.dart',
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness_checker.dart',
        'lib/application/pre_consultation/camera/'
            'camera_readiness_checker.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('ConsultationReadinessEngine') ||
                source.contains('ConsultationReadinessChecker') ||
                source.contains('ConsultationReadinessResult') ||
                source.contains('ConsultationReadinessRegistry')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

final class _Checker implements ConsultationReadinessChecker {
  _Checker(this.checkerId, {required this.ready, this.error, this.order});

  final String checkerId;
  final bool ready;
  final Object? error;
  final List<String>? order;

  @override
  Future<ConsultationReadinessResult> check() async {
    order?.add(checkerId);
    if (error case final cause?) throw cause;
    return ConsultationReadinessResult(
      checkerId: checkerId,
      ready: ready,
      checkedAt: DateTime.utc(2026, 8, 2),
    );
  }
}

