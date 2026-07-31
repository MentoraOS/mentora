import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The files introduced by AD-022 Wave C2A.
const List<String> _c2aFiles = [
  'lib/core/scheduling/models/civil_time_of_day.dart',
  'lib/core/scheduling/models/recurring_start_tick.dart',
  'lib/core/scheduling/models/recurring_availability.dart',
  'lib/core/scheduling/domains/legacy_availability_grammar.dart',
];

String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

String get _c2aSources => _c2aFiles.map(_read).join('\n');

Iterable<File> _dartFilesUnder(String directory) {
  final dir = Directory(directory);
  if (!dir.existsSync()) return const <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

void main() {
  group('AD-022 Wave C2A — recurring availability boundary', () {
    test('C2A is pure Scheduling, free of outer layers', () {
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
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A reaches into no other domain', () {
      for (final forbidden in const [
        '/domain/booking/',
        '/domain/expert_catalog/',
        '/domain/expert_availability/',
        'BookingCreation',
        'ExpertCatalogEntry',
        'ExpertAvailability',
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
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A consumes no clock and no device time', () {
      for (final forbidden in const [
        'DateTime',
        '.toLocal(',
        'timeZoneOffset',
        'timeZoneName',
        'AuthoritativeClock',
        'serverTimestamp',
        'request.time',
      ]) {
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A consumes no timezone concept', () {
      for (final forbidden in const [
        'TimezoneId',
        'TimezoneResolver',
        'LaunchMarketTimezoneResolver',
        'timezone_resolver.dart',
        'expertTimezone',
        'toUtc',
        'fromUtc',
      ]) {
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A consumes no offer and no commercial truth', () {
      for (final forbidden in const [
        'ConsultationOffer',
        'durationMinutes',
        'amountMinor',
        'offerId',
        'currency',
        'rate30',
        'rate60',
        'rate120',
      ]) {
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A infers no interval end and fabricates no range', () {
      // A tick is a start point. Nothing in C2A may construct a range,
      // measure a length or produce UTC boundaries.
      for (final forbidden in const [
        'WorkingHours(',
        'totalDuration',
        'Duration(',
        'startUtc',
        'endUtc',
        'protectedEnd',
        'overlaps',
        'slotGranularity',
        'breakBetweenMeetings',
        'AvailabilityRule',
        'BlockedPeriod',
        'CalendarSlot',
      ]) {
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A introduces no later-wave concept', () {
      for (final forbidden in const [
        'SelectableOccurrence',
        'ReservationOccurrence',
        'CivilDateRange',
        'MaterializationRange',
        'CivilDateTime',
        'OccurrenceInterpreter',
        'reservationExpiresAt',
        'idempotencyKey',
        'IdempotencyClaim',
        'slotIdentity',
        'conflictIdentity',
        'ConflictException',
        'BookingCreationConflict',
        'bookingDate',
        'bookingTime',
        'horizon',
      ]) {
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the frozen engines are not referenced by C2A', () {
      for (final forbidden in const [
        'SchedulingEngine',
        'scheduling_engine.dart',
        'TimezoneEngine',
        'TimezoneInfo',
        'AvailabilityEngine',
      ]) {
        expect(_c2aSources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A reuses the canonical WeekDay instead of duplicating it', () {
      final tickSource = _read(
        'lib/core/scheduling/models/recurring_start_tick.dart',
      );
      final grammarSource = _read(
        'lib/core/scheduling/domains/legacy_availability_grammar.dart',
      );

      expect(tickSource, contains("import 'working_hours.dart';"));
      expect(grammarSource, contains("import '../models/working_hours.dart';"));
      // Exactly one WeekDay declaration exists in the whole Scheduling module.
      final schedulingSources = _dartFilesUnder(
        'lib/core/scheduling',
      ).map((file) => file.readAsStringSync()).join('\n');
      expect(RegExp('enum WeekDay').allMatches(schedulingSources).length, 1);
    });

    test('the strict grammar accepts exactly the canonical vocabulary', () {
      final grammarSource = _read(
        'lib/core/scheduling/domains/legacy_availability_grammar.dart',
      );

      for (final weekday in const [
        "'Lundi'",
        "'Mardi'",
        "'Mercredi'",
        "'Jeudi'",
        "'Vendredi'",
        "'Samedi'",
        "'Dimanche'",
      ]) {
        expect(grammarSource, contains(weekday), reason: weekday);
      }
      // No normalization pathway exists: exact map lookup, strict syntax.
      for (final forbidden in const [
        '.trim(',
        '.toLowerCase(',
        '.toUpperCase(',
        'tryParse',
        'DateFormat',
        'Intl',
      ]) {
        expect(grammarSource, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('C2A types are exposed through the public facade', () {
      final facade = _read('lib/core/scheduling/scheduling.dart');

      expect(facade, contains("export 'models/civil_time_of_day.dart';"));
      expect(facade, contains("export 'models/recurring_start_tick.dart';"));
      expect(facade, contains("export 'models/recurring_availability.dart';"));
      expect(
        facade,
        contains("export 'domains/legacy_availability_grammar.dart';"),
      );
    });

    test('Booking does not consume C2A', () {
      final booking = <File>[
        ..._dartFilesUnder('lib/domain/booking'),
        ..._dartFilesUnder('lib/application/booking'),
        ..._dartFilesUnder('lib/infrastructure/booking'),
      ].map((file) => file.readAsStringSync()).join('\n');

      for (final forbidden in const [
        'RecurringStartTick',
        'RecurringAvailability',
        'LegacyAvailabilityGrammar',
        'CivilTimeOfDay',
      ]) {
        expect(booking, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Presentation does not consume C2A', () {
      final screens = _dartFilesUnder(
        'lib/screens',
      ).map((file) => file.readAsStringSync()).join('\n');

      for (final forbidden in const [
        'RecurringStartTick',
        'RecurringAvailability(',
        'LegacyAvailabilityGrammar',
        'CivilTimeOfDay',
      ]) {
        expect(screens, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the tolerant Catalog and Availability read paths are unchanged', () {
      // C2A strictness lives in the Scheduling compatibility grammar, not in
      // the persistence mappers (AD-022 Clarification C keeps legacy reads
      // tolerant).
      final catalogMapper = _read(
        'lib/infrastructure/expert_catalog/expert_catalog_firestore_mapper.dart',
      );
      final availabilityMapper = _read(
        'lib/infrastructure/expert_availability/'
        'expert_availability_firestore_mapper.dart',
      );

      for (final forbidden in const [
        'LegacyAvailabilityGrammar',
        'RecurringStartTick',
        'RecurringAvailability',
        'CivilTimeOfDay',
        'MalformedWeekdayException',
        'MalformedTimeOfDayException',
      ]) {
        expect(catalogMapper, isNot(contains(forbidden)), reason: forbidden);
        expect(
          availabilityMapper,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('no dependency was introduced', () {
      final pubspec = _read('pubspec.yaml');

      expect(pubspec, isNot(contains('timezone:')));
      expect(pubspec, contains('cloud_firestore: ^5.6.9'));
    });
  });
}
