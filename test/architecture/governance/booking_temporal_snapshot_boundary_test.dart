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

String get _bookingSources => <File>[
  ..._dartFilesUnder('lib/domain/booking'),
  ..._dartFilesUnder('lib/application/booking'),
  ..._dartFilesUnder('lib/infrastructure/booking'),
].map((file) => file.readAsStringSync()).join('\n');

void main() {
  group('AD-022 C3 — booking temporal snapshot boundary', () {
    test('Booking owns the snapshot but interprets no timezone', () {
      final domain = _read('lib/domain/booking/booking_creation.dart');

      expect(domain, contains('final DateTime startUtc;'));
      expect(domain, contains('final DateTime endUtc;'));
      expect(domain, contains('final String expertTimezone;'));
      // Invariants: UTC boundaries, ordering, offer-duration consistency.
      expect(domain, contains('startUtc.isUtc'));
      expect(domain, contains('endUtc.isUtc'));
      expect(domain, contains('endUtc.isAfter(startUtc)'));
      expect(
        domain,
        contains('endUtc.difference(startUtc) != Duration(minutes:'),
      );

      // Booking never becomes a timezone engine (AD-022 decision 2).
      for (final forbidden in const [
        'TimezoneResolver',
        'TimezoneId',
        'LaunchMarketTimezoneResolver',
        'toUtc',
        'fromUtc',
        'OccurrenceInterpreter',
        'CivilDateTime',
        'ReservationOccurrence',
        '/core/scheduling/',
      ]) {
        expect(_bookingSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('creation revalidates and interprets through Application ports', () {
      final service = _read(
        'lib/application/booking/booking_creation_application_service.dart',
      );

      expect(service, contains('revalidateForReservation'));
      expect(service, contains('CivilOccurrenceInterpretation'));
      expect(service, contains('snapshot.startUtc'));
      // Client-supplied UTC boundaries are never accepted: create() takes
      // the structured civil selection only.
      expect(service, isNot(contains('required DateTime startUtc')));
      expect(service, isNot(contains('required String bookingDate')));
    });

    test('no clock authority and no expiration entered Booking', () {
      for (final forbidden in const [
        'AuthoritativeClock',
        'reservationExpiresAt',
        'DateTime.now().toUtc',
        'serverTimestamp()',
      ]) {
        expect(
          _read('lib/domain/booking/booking_creation.dart'),
          isNot(contains(forbidden)),
          reason: forbidden,
        );
        expect(
          _read(
            'lib/application/booking/booking_creation_application_service.dart',
          ),
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('the ARCH-008 conflict contract is unchanged', () {
      final domain = _read('lib/domain/booking/booking_creation.dart');
      final repository = _read(
        'lib/infrastructure/booking/firestore_booking_creation_repository.dart',
      );

      expect(
        domain,
        contains("String get slotIdentity => '\$expertId|\$bookingDate|"),
      );
      expect(repository, contains("collection('_booking_creation_slots')"));
      // startUtc/endUtc did not become a new conflict identity in this wave.
      expect(repository, isNot(contains('startUtc')));
      expect(repository, isNot(contains('endUtc')));
      expect(repository, isNot(contains('overlap')));
    });

    test('the snapshot persists as Timestamps with verbatim identity', () {
      final mapper = _read(
        'lib/infrastructure/booking/booking_creation_firestore_mapper.dart',
      );

      expect(mapper, contains("'startUtc': Timestamp.fromDate("));
      expect(mapper, contains("'endUtc': Timestamp.fromDate("));
      expect(mapper, contains("'expertTimezone': booking.expertTimezone"));
      // No ISO-string persistence and no derived end at read time.
      expect(mapper, isNot(contains('toIso8601String')));
    });

    test('legacy occupancy reads stay independent of the snapshot', () {
      final occupancy = <String>[
        _read(
          'lib/infrastructure/booking/expert_booking_occupancy_firestore_mapper.dart',
        ),
        _read(
          'lib/infrastructure/booking/firestore_expert_booking_occupancy_repository.dart',
        ),
        _read('lib/domain/booking/expert_booking_occupancy.dart'),
      ].join('\n');

      for (final forbidden in const [
        'startUtc',
        'endUtc',
        'expertTimezone',
        'ReservationTemporalSnapshot',
      ]) {
        expect(occupancy, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Presentation manufactures no UTC and no interpretation', () {
      final sources = <String>[
        _read('lib/screens/expert_detail_screen.dart'),
        _read('lib/screens/pre_consultation_screen.dart'),
        _read('lib/core/routing/app_router.dart'),
      ].join('\n');

      for (final forbidden in const [
        'startUtc',
        'endUtc',
        'toUtc',
        'fromUtc',
        'TimezoneId',
        'TimezoneResolver',
        'CivilOccurrenceInterpretation',
        'ReservationTemporalSnapshot',
        'OccurrenceInterpreter',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('country never determines the snapshot timezone', () {
      final sources = <String>[
        _read(
          'lib/application/booking/booking_creation_application_service.dart',
        ),
        _read(
          'lib/infrastructure/scheduling/'
          'civil_occurrence_interpretation_adapter.dart',
        ),
        _read('lib/application/scheduling/reservation_temporal_snapshot.dart'),
        _read(
          'lib/application/scheduling/civil_occurrence_interpretation.dart',
        ),
      ].join('\n');

      for (final forbidden in const [
        'CountryEngine',
        'CountryRegistry',
        'country_registry',
        '/core/engines/country/',
        '.country',
        "'ML'",
        "'SN'",
        "'CI'",
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the interpretation adapter bridges Wave B and nothing else', () {
      final adapter = _read(
        'lib/infrastructure/scheduling/'
        'civil_occurrence_interpretation_adapter.dart',
      );

      // ARC-C02 + ARC-013: the Scheduling module is consumed through its
      // facade, from Infrastructure only.
      expect(
        adapter,
        contains("import '../../core/scheduling/scheduling.dart'"),
      );
      expect(adapter, contains('implements CivilOccurrenceInterpretation'));
      expect(adapter, contains('OccurrenceInterpreter'));
      expect(adapter, contains('.value'));

      for (final forbidden in const [
        'package:cloud_firestore/',
        'package:firebase_',
        'package:flutter/',
        'DateTime.now(',
        '.toLocal(',
        'SchedulingEngine',
        'TimezoneEngine',
        'LaunchMarketTimezoneResolver',
        '/screens/',
        '/domain/booking/',
      ]) {
        expect(adapter, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the Application scheduling seam still avoids the module cycle', () {
      final applicationSources = <String>[
        _read(
          'lib/application/scheduling/civil_occurrence_interpretation.dart',
        ),
        _read('lib/application/scheduling/reservation_temporal_snapshot.dart'),
        _read(
          'lib/application/booking/booking_creation_application_service.dart',
        ),
      ].join('\n');

      expect(applicationSources, isNot(contains('core/scheduling')));
    });

    test('no dependency was introduced', () {
      final pubspec = _read('pubspec.yaml');

      expect(pubspec, isNot(contains('timezone:')));
      expect(pubspec, contains('cloud_firestore: ^5.6.9'));
    });
  });
}
