import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

Iterable<File> _dartFilesUnder(String directory) {
  final dir = Directory(directory);
  if (!dir.existsSync()) return const <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

void main() {
  group('AD-022 Wave C1 — Catalog lookup boundary', () {
    test('the lookup performs no Scheduling interpretation', () {
      final sources = <String>[
        _read('lib/domain/expert_catalog/expert_catalog_repository.dart'),
        _read(
          'lib/application/expert_catalog/expert_catalog_application_service.dart',
        ),
        _read(
          'lib/infrastructure/expert_catalog/firestore_expert_catalog_repository.dart',
        ),
      ].join('\n');

      for (final forbidden in const [
        'TimezoneId',
        'TimezoneResolver',
        'LaunchMarketTimezoneResolver',
        'CivilDateTime',
        'ReservationOccurrence',
        'OccurrenceInterpreter',
        'toUtc',
        'fromUtc',
        'startUtc',
        'endUtc',
        '/core/scheduling/',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the lookup never infers a timezone from a country', () {
      final sources = <String>[
        _read(
          'lib/infrastructure/expert_catalog/firestore_expert_catalog_repository.dart',
        ),
        _read(
          'lib/application/expert_catalog/expert_catalog_application_service.dart',
        ),
      ].join('\n');

      for (final forbidden in const [
        'CountryEngine',
        'CountryRegistry',
        'country_registry',
        '/core/engines/country/',
        '.country',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the adapter reuses the existing mapper and looks up by document', () {
      final adapter = _read(
        'lib/infrastructure/expert_catalog/firestore_expert_catalog_repository.dart',
      );

      expect(adapter, contains('ExpertCatalogFirestoreMapper'));
      expect(adapter, contains(".doc(expertId)"));
      expect(adapter, contains('documentId: document.id'));
      // A single Catalog collection and a single mapper.
      expect(RegExp("collection\\('experts'\\)").allMatches(adapter).length, 2);
      expect(adapter, isNot(contains('collection(\'expert\')')));
    });

    test('exactly one Catalog repository and one Catalog mapper exist', () {
      final catalogSources = <File>[
        ..._dartFilesUnder('lib/domain/expert_catalog'),
        ..._dartFilesUnder('lib/infrastructure/expert_catalog'),
        ..._dartFilesUnder('lib/application/expert_catalog'),
      ];
      final joined = catalogSources
          .map((file) => file.readAsStringSync())
          .join('\n');

      expect(
        RegExp('implements ExpertCatalogRepository').allMatches(joined).length,
        1,
      );
      expect(
        RegExp('class ExpertCatalogFirestoreMapper').allMatches(joined).length,
        1,
      );
      expect(
        RegExp('final class ExpertCatalogEntry').allMatches(joined).length,
        1,
      );
    });

    test('Booking does not consume the Catalog lookup yet', () {
      final booking = <File>[
        ..._dartFilesUnder('lib/domain/booking'),
        ..._dartFilesUnder('lib/application/booking'),
        ..._dartFilesUnder('lib/infrastructure/booking'),
      ].map((file) => file.readAsStringSync()).join('\n');

      // AD-022 C3 later authorized the Booking snapshot fields
      // (startUtc/endUtc/expertTimezone); the Catalog lookup itself and the
      // Scheduling interpretation types remain outside Booking.
      for (final forbidden in const [
        'findById',
        'ExpertCatalogApplicationService',
        'ExpertCatalogRepository',
        'reservationExpiresAt',
        'AuthoritativeClock',
        'CivilDateTime',
        'ReservationOccurrence',
        'OccurrenceInterpreter',
      ]) {
        expect(booking, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Booking Domain and Application keep no Firestore dependency', () {
      // Booking Infrastructure legitimately adapts Firestore; the inner
      // layers must not.
      final inner = <File>[
        ..._dartFilesUnder('lib/domain/booking'),
        ..._dartFilesUnder('lib/application/booking'),
      ].map((file) => file.readAsStringSync()).join('\n');

      expect(inner, isNot(contains('package:cloud_firestore/')));
      expect(inner, isNot(contains('/infrastructure/')));
    });

    test('C1 introduces no later-wave concept', () {
      final sources = <String>[
        _read('lib/domain/expert_catalog/expert_catalog_repository.dart'),
        _read(
          'lib/application/expert_catalog/expert_catalog_application_service.dart',
        ),
        _read(
          'lib/infrastructure/expert_catalog/firestore_expert_catalog_repository.dart',
        ),
      ].join('\n');

      for (final forbidden in const [
        'reservationExpiresAt',
        'AuthoritativeClock',
        'idempotencyKey',
        'IdempotencyClaim',
        'slotIdentity',
        'conflictIdentity',
        'availableDays',
        'horizon',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the ARCH-008 conflict identity is untouched', () {
      final booking = _read('lib/domain/booking/booking_creation.dart');

      expect(
        booking,
        contains("String get slotIdentity => '\$expertId|\$bookingDate|"),
      );
    });

    test('no dependency was introduced', () {
      final pubspec = _read('pubspec.yaml');

      expect(pubspec, isNot(contains('timezone:')));
      expect(pubspec, contains('cloud_firestore: ^5.6.9'));
    });
  });
}
