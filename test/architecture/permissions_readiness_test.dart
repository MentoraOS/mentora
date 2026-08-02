import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_engine.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_registry.dart';
import 'package:mentora/application/pre_consultation/consultation_readiness_result.dart';
import 'package:mentora/application/pre_consultation/permissions/permissions_readiness.dart';
import 'package:mentora/application/pre_consultation/permissions/permissions_readiness_checker.dart';
import 'package:mentora/application/pre_consultation/permissions/permissions_readiness_failure.dart';
import 'package:mentora/application/pre_consultation/permissions/permissions_readiness_provider.dart';

void main() {
  group('PermissionsReadiness — pure state, frozen', () {
    test('is const-constructible with exactly three fields and a '
        'four-value status', () {
      final readiness = PermissionsReadiness(
        granted: true,
        status: PermissionsStatus.granted,
        checkedAt: DateTime.utc(2026, 8, 2),
      );
      expect(readiness.granted, isTrue);

      final source = File(
        'lib/application/pre_consultation/permissions/'
        'permissions_readiness.dart',
      ).readAsStringSync();
      expect(source, contains('const PermissionsReadiness({'));
      final fields = RegExp(r'final \w+\??' r' \w+;')
          .allMatches(source)
          .map((match) => match.group(0))
          .toList();
      expect(fields, [
        'final bool granted;',
        'final PermissionsStatus status;',
        'final DateTime checkedAt;',
      ]);
      expect(PermissionsStatus.values.map((value) => value.name).toList(), [
        'unknown',
        'denied',
        'limited',
        'granted',
      ]);
      expect(source, isNot(contains('void ')));
      expect(source, isNot(contains('=> ')));
    });
  });

  group('PermissionsReadinessProvider — pure contract', () {
    test('exposes exactly one method', () {
      final source = File(
        'lib/application/pre_consultation/permissions/'
        'permissions_readiness_provider.dart',
      ).readAsStringSync();

      final contract = source.substring(
        source.indexOf(
          'abstract interface class PermissionsReadinessProvider',
        ),
        source.indexOf('}'),
      );
      final methods = RegExp(r'(\w+)\(\);')
          .allMatches(contract)
          .map((match) => match.group(1))
          .toList();
      expect(methods, ['check']);
    });

    test('the simulated stand-in answers fail closed — nothing granted '
        'until proven', () async {
      const provider = SimulatedPermissionsReadinessProvider();

      final readiness = await provider.check();

      expect(readiness.granted, isFalse);
      expect(readiness.status, PermissionsStatus.unknown);
    });
  });

  group('PermissionsReadinessChecker — transform only', () {
    test('delegates to the provider and transforms the verdict '
        'verbatim', () async {
      final checked = DateTime.utc(2026, 8, 2, 9);
      final checker = PermissionsReadinessChecker(
        provider: _Provider(
          PermissionsReadiness(
            granted: true,
            status: PermissionsStatus.granted,
            checkedAt: checked,
          ),
        ),
      );

      final result = await checker.check();

      expect(result.checkerId, 'permissions');
      expect(result.ready, isTrue);
      expect(result.checkedAt, checked);
    });

    test('its identity can never drift from the engine identity', () {
      expect(
        PermissionsReadinessChecker.checkerId,
        ConsultationReadinessEngine.permissionsCheckerId,
      );
    });

    test('unavailable and timeout PROPAGATE untouched — the engine fail '
        'closes', () async {
      for (final failure in const [
        PermissionsUnavailableFailure(),
        PermissionsTimeoutFailure(),
      ]) {
        final checker = PermissionsReadinessChecker(
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
        'lib/application/pre_consultation/permissions/'
        'permissions_readiness_failure.dart',
      ).readAsStringSync();

      final failures = RegExp(r'final class (\w+)')
          .allMatches(source)
          .map((match) => match.group(1))
          .toList();
      expect(failures, [
        'PermissionsUnavailableFailure',
        'PermissionsTimeoutFailure',
      ]);
    });
  });

  group('Engine — one more registered checker, same logic', () {
    test('the permissions checker runs in order and its verdict lands on '
        'the permissions fact', () async {
      final order = <String>[];
      final registry = ConsultationReadinessRegistry()
        ..register(_OrderSpy('first', order))
        ..register(
          PermissionsReadinessChecker(
            provider: _Provider(
              PermissionsReadiness(
                granted: true,
                status: PermissionsStatus.granted,
                checkedAt: DateTime.utc(2026, 8, 2),
              ),
              order: order,
            ),
          ),
        );
      final engine = ConsultationReadinessEngine(registry: registry);

      final readiness = await engine.prepare(bookingId: 'b1');

      expect(order, ['first', 'permissions']);
      expect(readiness.permissionsReady, isTrue);
      // The other facts are untouched by the permissions checker.
      expect(readiness.networkReady, isFalse);
      expect(readiness.aiReady, isFalse);
    });

    test('the standard engine registers the permissions checker over the '
        'simulated provider — fail closed today', () async {
      final engine = ConsultationReadinessEngine.standard();

      final readiness = await engine.prepare(bookingId: 'b1');

      // Simulated sources: nothing proven, so nothing is ready.
      expect(readiness.permissionsReady, isFalse);
      expect(readiness.networkReady, isFalse);
    });
  });

  group('Governance — the permissions foundation is blind', () {
    test('zero platform, zero system permission, zero vendor, zero '
        'storage in the permissions layer', () {
      for (final path in const [
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness.dart',
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness_checker.dart',
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness_provider.dart',
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness_failure.dart',
      ]) {
        final source = File(path).readAsStringSync();
        for (final forbidden in const [
          'Android',
          'iOS',
          'PermissionHandler',
          'permission_handler',
          'Camera',
          'Microphone',
          'Notifications',
          'Bluetooth',
          'GPS',
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

    test('the permissions surface is confined to the preparation '
        'platform', () {
      const allowedSurface = [
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness.dart',
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness_checker.dart',
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness_provider.dart',
        'lib/application/pre_consultation/permissions/'
            'permissions_readiness_failure.dart',
        'lib/application/pre_consultation/consultation_readiness_engine.dart',
      ];

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final normalized = entity.path.replaceAll('\\', '/');
        final source = entity.readAsStringSync();
        if ((source.contains('PermissionsReadinessChecker') ||
                source.contains('PermissionsReadinessProvider') ||
                source.contains('PermissionsReadiness(') ||
                source.contains('PermissionsStatus')) &&
            !allowedSurface.contains(normalized)) {
          offenders.add(normalized);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}

final class _Provider implements PermissionsReadinessProvider {
  _Provider(this.readiness, {this.order}) : failure = null;

  _Provider.failing(this.failure)
    : readiness = null,
      order = null;

  final PermissionsReadiness? readiness;
  final Object? failure;
  final List<String>? order;

  @override
  Future<PermissionsReadiness> check() async {
    order?.add('permissions');
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
