import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Scheduling files introduced by AD-022 Wave C2.
const List<String> _c2SchedulingFiles = [
  'lib/core/scheduling/models/civil_date.dart',
  'lib/core/scheduling/models/civil_date_range.dart',
  'lib/core/scheduling/models/selectable_occurrence.dart',
  'lib/core/scheduling/domains/occurrence_materializer.dart',
];

/// The Application files introduced by AD-022 Wave C2.
const List<String> _c2ApplicationFiles = [
  'lib/application/scheduling/selectable_occurrence_application_service.dart',
  'lib/application/scheduling/selectable_occurrence_failure.dart',
  'lib/application/scheduling/civil_selection.dart',
  'lib/application/scheduling/civil_occurrence_materialization.dart',
];

const String _adapterFile =
    'lib/infrastructure/scheduling/civil_occurrence_materialization_adapter.dart';

String _read(String path) {
  final file = File(path);
  expect(file.existsSync(), isTrue, reason: 'missing $path');
  return file.readAsStringSync();
}

String get _schedulingSources => _c2SchedulingFiles.map(_read).join('\n');
String get _applicationSources => _c2ApplicationFiles.map(_read).join('\n');

Iterable<File> _dartFilesUnder(String directory) {
  final dir = Directory(directory);
  if (!dir.existsSync()) return const <File>[];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
}

void main() {
  group('AD-022 Wave C2 — selectable occurrence boundary', () {
    test('C2 Scheduling is pure, free of outer layers', () {
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
        '/domain/',
        '/core/routing/',
      ]) {
        expect(
          _schedulingSources,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('C2 Scheduling reads no clock and no device time', () {
      for (final forbidden in const [
        'DateTime.now(',
        '.toLocal(',
        'timeZoneOffset',
        'timeZoneName',
        'AuthoritativeClock',
        'serverTimestamp',
        'request.time',
      ]) {
        expect(
          _schedulingSources,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('C2 Scheduling interprets no timezone and produces no UTC truth', () {
      for (final forbidden in const [
        'TimezoneId',
        'TimezoneResolver',
        'toUtc',
        'fromUtc',
        'expertTimezone',
        'startUtc',
        'endUtc',
        'ReservationOccurrence',
        'OccurrenceInterpreter',
      ]) {
        expect(
          _schedulingSources,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('C2 Scheduling introduces no lifecycle or conflict concept', () {
      for (final forbidden in const [
        'slotIdentity',
        'conflictIdentity',
        'idempotencyKey',
        'IdempotencyClaim',
        'reservationExpiresAt',
        'BookingCreation',
        'ExpertBookingOccupancy',
        '_booking_creation_slots',
        'runTransaction',
      ]) {
        expect(
          _schedulingSources,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('C2 activates no booking horizon or deferred policy', () {
      final sources = '$_schedulingSources\n$_applicationSources';

      for (final forbidden in const [
        'bookingHorizon',
        'minimumNotice',
        'maximumAdvanceBooking',
        'maximumBookingsPerDay',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the frozen engines are untouched by C2 Scheduling', () {
      for (final forbidden in const [
        'SchedulingEngine',
        'scheduling_engine.dart',
        'TimezoneEngine',
        'TimezoneInfo',
        'AvailabilityEngine',
      ]) {
        expect(
          _schedulingSources,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('Application depends on its port, never on the Scheduling module', () {
      // The frozen legacy engine keeps `core/scheduling` inside the legacy
      // module dependency graph of `core/booking`. Application and
      // Presentation therefore consume materialization through the
      // Application-owned port; importing `core/scheduling` here would create
      // a module cycle (ARC-013).
      expect(_applicationSources, isNot(contains('/core/scheduling/')));
      expect(_applicationSources, isNot(contains('core/scheduling')));

      final service = _read(_c2ApplicationFiles.first);
      expect(service, contains('CivilOccurrenceMaterialization'));
      expect(service, contains('revalidate('));

      for (final forbidden in const [
        'package:cloud_firestore/',
        'FirebaseFirestore',
        '/infrastructure/',
        '/screens/',
        'DateTime.now(',
        '.toLocal(',
        'toUtc',
        'fromUtc',
        'startUtc',
        'endUtc',
        'TimezoneId',
        'TimezoneResolver',
        'LaunchMarketTimezoneResolver',
        'ReservationOccurrence',
        'OccurrenceInterpreter',
        'AuthoritativeClock',
        'reservationExpiresAt',
      ]) {
        expect(
          _applicationSources,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('the Application never derives a timezone from country', () {
      for (final forbidden in const [
        'CountryEngine',
        'CountryRegistry',
        'country_registry',
        '/core/engines/country/',
        '.country',
      ]) {
        expect(
          _applicationSources,
          isNot(contains(forbidden)),
          reason: forbidden,
        );
      }
    });

    test('the adapter bridges the port to Scheduling and nothing else', () {
      final adapter = _read(_adapterFile);

      // ARC-C02: the Scheduling module is consumed through its facade.
      expect(
        adapter,
        contains("import '../../core/scheduling/scheduling.dart'"),
      );
      expect(adapter, contains('implements CivilOccurrenceMaterialization'));
      expect(adapter, contains('LegacyAvailabilityGrammar'));
      expect(adapter, contains('OccurrenceMaterializer'));

      for (final forbidden in const [
        'package:flutter/',
        'package:cloud_firestore/',
        'package:firebase_',
        'package:timezone/',
        'FirebaseFirestore',
        '/screens/',
        '/domain/booking/',
        'DateTime.now(',
        '.toLocal(',
        'CountryEngine',
        'CountryRegistry',
        'country_registry',
        '.country',
        'SchedulingEngine',
        'TimezoneEngine',
        'LaunchMarketTimezoneResolver',
        'runTransaction',
      ]) {
        expect(adapter, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Presentation manufactures no temporal truth', () {
      final sources = <String>[
        _read('lib/screens/expert_detail_screen.dart'),
        _read('lib/screens/pre_consultation_screen.dart'),
        _read('lib/core/routing/app_router.dart'),
      ].join('\n');

      for (final forbidden in const [
        // The module-cycle guard: Presentation and routing never import the
        // Scheduling module (see the Application port test above).
        'core/scheduling',
        'toUtc',
        'fromUtc',
        'startUtc',
        'endUtc',
        'TimezoneResolver',
        'TimezoneId',
        'ReservationOccurrence',
        'OccurrenceInterpreter',
        'LegacyAvailabilityGrammar',
        'parseRecurringAvailability',
        'OccurrenceMaterializer',
        'CivilOccurrenceMaterialization',
        'DateTime.parse',
        'DateFormat(',
        'reservationExpiresAt',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('the selection travels structured, and the dead calendar is gone', () {
      final router = _read('lib/core/routing/app_router.dart');
      final preConsultation = _read('lib/screens/pre_consultation_screen.dart');
      final expertDetail = _read('lib/screens/expert_detail_screen.dart');

      expect(router, contains('required CivilSelection occurrence'));
      expect(preConsultation, contains('final CivilSelection occurrence'));
      expect(expertDetail, contains('.revalidate('));

      expect(expertDetail, isNot(contains('_showAvailabilityCalendar')));
      expect(expertDetail, isNot(contains('availableDays')));
    });

    test('device time reaches no screen other than calendar navigation', () {
      // Pre-consultation and routing never read the device clock; the expert
      // profile uses it only to pick the initially visible month page.
      final preConsultation = _read('lib/screens/pre_consultation_screen.dart');
      final router = _read('lib/core/routing/app_router.dart');

      expect(preConsultation, isNot(contains('DateTime.now(')));
      expect(router, isNot(contains('DateTime.now(')));
    });

    test('Booking does not consume C2', () {
      final booking = <File>[
        ..._dartFilesUnder('lib/domain/booking'),
        ..._dartFilesUnder('lib/application/booking'),
        ..._dartFilesUnder('lib/infrastructure/booking'),
      ].map((file) => file.readAsStringSync()).join('\n');

      for (final forbidden in const [
        'SelectableOccurrence',
        'OccurrenceMaterializer',
        'CivilOccurrenceMaterialization',
        'CivilSelection',
        'CivilDate',
        'RecurringAvailability',
        'expertTimezone',
        'startUtc',
        'endUtc',
      ]) {
        expect(booking, isNot(contains(forbidden)), reason: forbidden);
      }

      // The ARCH-008 conflict identity is unchanged.
      final creation = _read('lib/domain/booking/booking_creation.dart');
      expect(
        creation,
        contains("String get slotIdentity => '\$expertId|\$bookingDate|"),
      );
    });

    test('C2 types are exposed through the public facade', () {
      final facade = _read('lib/core/scheduling/scheduling.dart');

      expect(facade, contains("export 'models/civil_date.dart';"));
      expect(facade, contains("export 'models/civil_date_range.dart';"));
      expect(facade, contains("export 'models/selectable_occurrence.dart';"));
      expect(
        facade,
        contains("export 'domains/occurrence_materializer.dart';"),
      );
    });

    test('no dependency was introduced', () {
      final pubspec = _read('pubspec.yaml');

      expect(pubspec, isNot(contains('timezone:')));
      expect(pubspec, contains('cloud_firestore: ^5.6.9'));
    });
  });
}
