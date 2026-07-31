import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

Iterable<File> _dartFilesUnder(String directory) {
  final dir = Directory(directory);
  if (!dir.existsSync()) {
    return const <File>[];
  }
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

void main() {
  group('AD-022 Wave A — expert timezone boundary', () {
    test('Expert Catalog stores identity but performs no conversion', () {
      final sources = <String>[
        _read('lib/domain/expert_catalog/expert_catalog_entry.dart'),
        _read(
          'lib/infrastructure/expert_catalog/expert_catalog_firestore_mapper.dart',
        ),
      ].join('\n');

      for (final forbidden in const [
        'TimezoneResolver',
        // Construction of the Scheduling identity type, not the word itself.
        'TimezoneId(',
        'ports/timezone_resolver.dart',
        'toUtc',
        'fromUtc',
        'CountryEngine',
        'CountryRegistry',
        'country_registry',
        '/core/scheduling/',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
      expect(sources, contains('expertTimezone'));
    });

    test('the resolver never infers a timezone from a country', () {
      final resolver = _read(
        'lib/infrastructure/scheduling/launch_market_timezone_resolver.dart',
      );

      for (final forbidden in const [
        'CountryEngine',
        'CountryRegistry',
        'country_registry',
        // Reading a country value, as opposed to naming the prohibition.
        '.country',
        "'ML'",
        "'SN'",
        "'CI'",
        '/core/engines/country/',
        '/domain/expert_catalog/',
      ]) {
        expect(resolver, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the resolver uses no device clock and no device timezone', () {
      final resolver = _read(
        'lib/infrastructure/scheduling/launch_market_timezone_resolver.dart',
      );

      for (final forbidden in const [
        'DateTime.now()',
        '.toLocal()',
        'timeZoneName',
        'timeZoneOffset',
      ]) {
        expect(resolver, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the resolver depends only on the Scheduling port', () {
      final resolver = _read(
        'lib/infrastructure/scheduling/launch_market_timezone_resolver.dart',
      );

      for (final forbidden in const [
        'package:flutter/',
        'package:timezone/',
        'package:cloud_firestore/',
        'package:firebase_',
        '/domain/booking/',
        '/application/',
        '/screens/',
        '/core/financial/',
        '/core/escrow/',
        '/core/payment/',
        'scheduling_engine.dart',
        'TimezoneEngine',
        'TimezoneInfo',
      ]) {
        expect(resolver, isNot(contains(forbidden)), reason: forbidden);
      }
      expect(resolver, contains('implements TimezoneResolver'));
      // ARC-C02: external modules import the Scheduling public facade, never
      // a module internal.
      expect(
        resolver,
        contains("import '../../core/scheduling/scheduling.dart'"),
      );
    });

    test('Booking does not interpret timezones', () {
      final sources = <File>[
        ..._dartFilesUnder('lib/domain/booking'),
        ..._dartFilesUnder('lib/application/booking'),
        ..._dartFilesUnder('lib/infrastructure/booking'),
      ].map((file) => file.readAsStringSync()).join('\n');

      for (final forbidden in const [
        'TimezoneResolver',
        'LaunchMarketTimezoneResolver',
        'TimezoneId',
        'toUtc',
        'fromUtc',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Presentation does not interpret timezones', () {
      final sources = _dartFilesUnder(
        'lib/screens',
      ).map((file) => file.readAsStringSync()).join('\n');

      for (final forbidden in const [
        'TimezoneResolver',
        'LaunchMarketTimezoneResolver',
        'TimezoneId',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the resolver is exposed only as the Scheduling port', () {
      final dependencies = _read('lib/composition/mentora_dependencies.dart');
      final compositionRoot = _read(
        'lib/composition/mentora_composition_root.dart',
      );

      // The port is the declared type; the implementation is constructed only
      // in the canonical composition root.
      expect(dependencies, contains('final TimezoneResolver timezoneResolver'));
      expect(dependencies, isNot(contains('LaunchMarketTimezoneResolver')));
      expect(compositionRoot, contains('LaunchMarketTimezoneResolver()'));
    });

    test('no timezone package dependency was introduced', () {
      final pubspec = _read('pubspec.yaml');

      expect(pubspec, isNot(contains('timezone:')));
      expect(pubspec, isNot(contains('package:timezone')));
    });

    test('Wave A introduces no Booking lifecycle or conflict work', () {
      final sources = <String>[
        _read(
          'lib/infrastructure/scheduling/launch_market_timezone_resolver.dart',
        ),
        _read('lib/core/scheduling/ports/timezone_resolver.dart'),
        _read('lib/domain/expert_catalog/expert_catalog_entry.dart'),
      ].join('\n');

      for (final forbidden in const [
        'reservationExpiresAt',
        'AuthoritativeClock',
        'idempotenc',
        'startUtc',
        'endUtc',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });
  });
}
