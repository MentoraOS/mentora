import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The files introduced by AD-022 Wave B.
const List<String> _waveBFiles = [
  'lib/core/scheduling/models/civil_date_time.dart',
  'lib/core/scheduling/models/reservation_occurrence.dart',
  'lib/core/scheduling/domains/occurrence_interpreter.dart',
];

String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

String get _waveBSources => _waveBFiles.map(_read).join('\n');

void main() {
  group('AD-022 Wave B — occurrence interpretation boundary', () {
    test('interpretation is pure Scheduling, free of outer layers', () {
      for (final forbidden in const [
        'package:flutter/',
        'package:firebase_',
        'package:cloud_firestore/',
        'package:timezone/',
        'dart:io',
        'dart:ui',
        '/screens/',
        '/widgets/',
        '/presentation/',
        '/infrastructure/',
        '/application/',
        '/core/routing/',
      ]) {
        expect(_waveBSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('interpretation does not reach into other domains', () {
      for (final forbidden in const [
        '/domain/booking/',
        '/domain/expert_catalog/',
        'BookingCreation',
        'ExpertCatalogEntry',
        'ExpertBookingOccupancy',
        'CountryEngine',
        'CountryRegistry',
        'country_registry',
        '/core/engines/country/',
        '/core/financial/',
        '/core/escrow/',
        '/core/payment/',
        'PaymentEngine',
        'LedgerJournal',
      ]) {
        expect(_waveBSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('interpretation reads no ambient clock or device timezone', () {
      for (final forbidden in const [
        'DateTime.now(',
        '.toLocal(',
        'timeZoneName',
        'timeZoneOffset',
      ]) {
        expect(_waveBSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Wave B applies no Scheduling policy beyond interpretation', () {
      for (final forbidden in const [
        'slotGranularity',
        'breakBetweenMeetings',
        'AvailabilityRule',
        'WorkingHours',
        'BlockedPeriod',
        'protectedEnd',
        'overlaps',
      ]) {
        expect(_waveBSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Wave B introduces no later-wave concept', () {
      // Precise markers: the interpreter's documentation names these concerns
      // in order to disclaim them, so only concrete symbols are forbidden.
      for (final forbidden in const [
        'AuthoritativeClock',
        'reservationExpiresAt',
        'idempotencyKey',
        'IdempotencyClaim',
        'slotIdentity',
        'conflictIdentity',
        'ConflictException',
        'BookingCreationConflict',
      ]) {
        expect(_waveBSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the interpreter depends on the Scheduling port, not an adapter', () {
      final interpreter = _read(
        'lib/core/scheduling/domains/occurrence_interpreter.dart',
      );

      expect(interpreter, contains('TimezoneResolver resolver'));
      expect(interpreter, isNot(contains('LaunchMarketTimezoneResolver')));
      expect(interpreter, contains("import '../ports/timezone_resolver.dart'"));
    });

    test('the frozen Scheduling engine is untouched by Wave B', () {
      expect(_waveBSources, isNot(contains('SchedulingEngine')));
      expect(_waveBSources, isNot(contains('scheduling_engine.dart')));
      expect(_waveBSources, isNot(contains('TimezoneEngine')));
      expect(_waveBSources, isNot(contains('TimezoneInfo')));
    });

    test('Wave B types are exposed through the public facade', () {
      final facade = _read('lib/core/scheduling/scheduling.dart');

      expect(facade, contains("export 'models/civil_date_time.dart';"));
      expect(facade, contains("export 'models/reservation_occurrence.dart';"));
      expect(facade, contains("export 'domains/occurrence_interpreter.dart';"));
    });

    test('Booking remains untouched by Wave B', () {
      final booking = _read('lib/domain/booking/booking_creation.dart');

      for (final forbidden in const [
        'startUtc',
        'endUtc',
        'expertTimezone',
        'reservationExpiresAt',
        'ReservationOccurrence',
        'CivilDateTime',
      ]) {
        expect(booking, isNot(contains(forbidden)), reason: forbidden);
      }
      // The ARCH-008 conflict identity is unchanged.
      expect(
        booking,
        contains("String get slotIdentity => '\$expertId|\$bookingDate|"),
      );
    });

    test('no timezone package dependency was introduced', () {
      final pubspec = _read('pubspec.yaml');

      expect(pubspec, isNot(contains('timezone:')));
      expect(pubspec, isNot(contains('package:timezone')));
    });
  });
}
