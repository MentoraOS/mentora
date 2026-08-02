import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_engine.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_registry.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_result.dart';
import 'package:mentora/application/pre_consultation/network/network_readiness.dart';
import 'package:mentora/application/pre_consultation/network/network_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/network/network_readiness_failure.dart';
import 'package:mentora/application/pre_consultation/network/network_readiness_provider.dart';

void main() {
  group('NetworkReadiness — pure state, frozen', () {
    test('is const-constructible with exactly three fields and a '
        'four-value quality', () {
      final readiness = NetworkReadiness(
        available: true,
        quality: NetworkQuality.excellent,
        checkedAt: DateTime.utc(2026, 8, 2),
      );
      expect(readiness.available, isTrue);

      final source = File(
        'lib/application/pre_consultation/network/network_readiness.dart',
      ).readAsStringSync();
      expect(source, contains('const NetworkReadiness({'));
      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final bool available;',
        'final NetworkQuality quality;',
        'final DateTime checkedAt;',
      ]);
      expect(NetworkQuality.values.map((value) => value.name).toList(), [
        'unknown',
        'poor',
        'acceptable',
        'excellent',
      ]);
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('=> ')));
    });
  });

  group('NetworkReadinessProvider — pure contract', () {
    test('exposes exactly one method', () {
      final source = File(
        'lib/application/pre_consultation/network/'
        'network_readiness_provider.dart',
      ).readAsStringSync();

      final contract = source.substring(
        source.indexOf('abstract interface class NetworkReadinessProvider'),
        source.indexOf('}'),
      );
      final methods = RegExp(r'(\w+)\(\);')
          .allMatches(contract)
          .map((match) => match.group(1))
          .toList();
      expect(methods, ['check']);
    });

    test('the simulated stand-in answers fail closed — nothing measured, '
        'nothing invented', () async {
      const provider = SimulatedNetworkReadinessProvider();

      final readiness = await provider.check();

      expect(readiness.available, isFalse);
      expect(readiness.quality, NetworkQuality.unknown);
    });
  });

  group('NetworkReadinessChecker — transform only', () {
    test('delegates to the provider and transforms the verdict '
        'verbatim', () async {
      final checked = DateTime.utc(2026, 8, 2, 9);
      final checker = NetworkReadinessChecker(
        provider: _Provider(
          NetworkReadiness(
            available: true,
            quality: NetworkQuality.acceptable,
            checkedAt: checked,
          ),
        ),
      );

      final result = await checker.check();

      expect(result.checkerId, 'network');
      expect(result.ready, isTrue);
      expect(result.checkedAt, checked);
    });

    test('its identity can never drift from the engine identity', () {
      expect(
        NetworkReadinessChecker.checkerId,
        ConsultationReadinessEngine.networkCheckerId,
      );
    });

    test('unavailable and timeout PROPAGATE untouched — the engine fail '
        'closes', () async {
      for (final failure in const [
        NetworkUnavailableFailure(),
        NetworkTimeoutFailure(),
      ]) {
        final checker = NetworkReadinessChecker(
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
        'lib/application/pre_consultation/network/'
        'network_readiness_failure.dart',
      ).readAsStringSync();

      final failures = RegExp(r'final class (\w+)')
          .allMatches(source)
          .map((match) => match.group(1))
          .toList();
      expect(failures, ['NetworkUnavailableFailure', 'NetworkTimeoutFailure']);
    });
  });

  group('Engine — one more registered checker, same logic', () {
    test('the network checker runs in order and its verdict lands on the '
        'network fact', () async {
      final order = <String>[];
      final registry = ConsultationReadinessRegistry()
        ..register(_OrderSpy('first', order))
        ..register(
          NetworkReadinessChecker(
            provider: _Provider(
              NetworkReadiness(
                available: true,
                quality: NetworkQuality.excellent,
                checkedAt: DateTime.utc(2026, 8, 2),
              ),
              order: order,
            ),
          ),
        );
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(order, ['first', 'network']);
      expect(readiness.networkReady, isTrue);
      // The other facts are untouched by the network checker.
      expect(readiness.cameraReady, isFalse);
      expect(readiness.aiReady, isFalse);
    });

    test('the standard engine registers the network checker over the '
        'simulated provider — fail closed today', () async {
      final engine = ConsultationReadinessEngine.standard();

      final readiness = await engine.prepare(bookingId: 'b1');

      // Simulated source: nothing measured, so nothing is ready.
      expect(readiness.networkReady, isFalse);
      expect(readiness.cameraReady, isFalse);
    });
  });

  group('Governance — the network foundation is blind', () {
    test('zero platform, zero vendor, zero storage in the network '
        'layer', () {
      for (final path in const [
        'lib/application/pre_consultation/network/network_readiness.dart',
        'lib/application/pre_consultation/network/'
            'network_readiness_checker.dart',
        'lib/application/pre_consultation/network/'
            'network_readiness_provider.dart',
        'lib/application/pre_consultation/network/'
            'network_readiness_failure.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'Android',
          'Connectivity',
          'livekit',
          'LiveKit',
          'Firestore',
          'HttpClient',
          'AIGateway',
          'AIProvider',
          'infrastructure',
          'dart:io',
          'Platform.',
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

    test('the network surface is confined to the preparation '
        'platform', () {
      const allowedSurface = [
        'lib/application/pre_consultation/network/network_readiness.dart',
        'lib/application/pre_consultation/network/'
            'network_readiness_checker.dart',
        'lib/application/pre_consultation/network/'
            'network_readiness_provider.dart',
        'lib/application/pre_consultation/network/'
            'network_readiness_failure.dart',
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('NetworkReadinessChecker') ||
                source.contains('NetworkReadinessProvider') ||
                source.contains('NetworkReadiness(') ||
                source.contains('NetworkQuality')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

final class _Provider implements NetworkReadinessProvider {
  _Provider(this.readiness, {this.order}) : failure = null;

  _Provider.failing(this.failure)
    : readiness = null,
      order = null;

  final NetworkReadiness? readiness;
  final Object? failure;
  final List<String>? order;

  @override
  Future<NetworkReadiness> check() async {
    order?.add('network');
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
