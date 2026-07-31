import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Files forming the ARCH-009A Scheduling temporal domain (AD-020).
const List<String> _temporalDomainFiles = [
  'core/scheduling/domains/availability_domain.dart',
  'core/scheduling/engine/availability_engine.dart',
  'core/scheduling/models/availability.dart',
  'core/scheduling/models/availability_result.dart',
  'core/scheduling/models/availability_rule.dart',
  'core/scheduling/models/blocked_period.dart',
  'core/scheduling/models/calendar_slot.dart',
  'core/scheduling/models/working_hours.dart',
  'core/scheduling/ports/timezone_resolver.dart',
];

void main() {
  group('Scheduling temporal domain boundary — ARCH-009A / AD-020', () {
    test('is pure Dart, free of framework and outer-layer dependencies', () {
      final sources = _temporalDomainFiles.map(_readLib).join('\n');

      for (final forbidden in const [
        'package:flutter/',
        'package:flutter_test/',
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
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('does not depend on Booking, Payment, Consultation or Financial', () {
      final sources = _temporalDomainFiles.map(_readLib).join('\n');

      for (final forbidden in const [
        '../../booking/',
        '../../consultation/',
        '../../payment/',
        '../../financial/',
        '../../escrow/',
        '/domain/booking/',
        'BookingEngine',
        'ConsultationEngine',
        'PaymentEngine',
        'FinancialLedger',
        'Settlement',
        'EscrowEngine',
        'ExpertBookingOccupancy',
      ]) {
        expect(sources, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('does not depend on the frozen legacy SchedulingEngine', () {
      final sources = _temporalDomainFiles.map(_readLib).join('\n');

      expect(sources, isNot(contains('scheduling_engine.dart')));
      expect(sources, isNot(contains('SchedulingEngine')));
    });

    test('candidate generation ignores the deferred policies', () {
      final source = _readLib(
        'core/scheduling/domains/availability_domain.dart',
      );

      // AD-020 decisions 13-15: declared but not enforced by this wave.
      for (final deferred in const [
        'maximumBookingsPerDay',
        'minimumNotice',
        'maximumAdvanceBooking',
      ]) {
        expect(source, isNot(contains(deferred)), reason: deferred);
      }
    });

    test('candidate generation advances by granularity, not by duration '
        'or by the break buffer', () {
      final source = _readLib(
        'core/scheduling/domains/availability_domain.dart',
      );

      expect(source, contains('cursor = cursor.add(rule.slotGranularity)'));
      // AD-020 decision 7: the buffer must not participate in cursor advance.
      expect(source, isNot(contains('breakBetweenMeetings')));
    });

    test('the timezone port expresses identity, not a UTC offset', () {
      final source = _readLib('core/scheduling/ports/timezone_resolver.dart');

      expect(source, contains('abstract interface class TimezoneResolver'));
      expect(source, contains('TimezoneId'));
      // A fixed offset must not appear in the canonical contract.
      expect(source, isNot(contains('Duration offset')));
      expect(source, isNot(contains('offsetInMinutes')));
      expect(source, isNot(contains('TimezoneInfo')));
    });

    test('the module facade exports the new port', () {
      final source = _readLib('core/scheduling/scheduling.dart');

      expect(source, contains("export 'ports/timezone_resolver.dart';"));
    });
  });
}

String _readLib(String relativePath) {
  final file = File('lib/$relativePath');
  expect(file.existsSync(), isTrue, reason: 'missing lib/$relativePath');
  return file.readAsStringSync();
}
