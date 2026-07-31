import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/scheduling/domains/availability_domain.dart';
import 'package:mentora/core/scheduling/models/availability_rule.dart';
import 'package:mentora/core/scheduling/models/blocked_period.dart';
import 'package:mentora/core/scheduling/models/calendar_slot.dart';
import 'package:mentora/core/scheduling/models/working_hours.dart';
import 'package:mentora/core/scheduling/ports/timezone_resolver.dart';

/// A Monday.
final DateTime monday = DateTime(2026, 7, 6);

AvailabilityRule ruleOf({
  required Duration duration,
  required Duration granularity,
  Duration breakBetweenMeetings = Duration.zero,
  int maximumBookingsPerDay = 10,
  Duration minimumNotice = const Duration(hours: 1),
  Duration maximumAdvanceBooking = const Duration(days: 30),
}) {
  return AvailabilityRule(
    consultationDuration: duration,
    slotGranularity: granularity,
    breakBetweenMeetings: breakBetweenMeetings,
    maximumBookingsPerDay: maximumBookingsPerDay,
    minimumNotice: minimumNotice,
    maximumAdvanceBooking: maximumAdvanceBooking,
  );
}

List<Duration> startsOf(List<CalendarSlot> slots) {
  return slots
      .map(
        (slot) => Duration(hours: slot.start.hour, minutes: slot.start.minute),
      )
      .toList();
}

void main() {
  const domain = AvailabilityDomain();

  group('AD-020 — WorkingHours invariant', () {
    test('rejects end equal to start', () {
      expect(
        () => WorkingHours(
          day: WeekDay.monday,
          start: const Duration(hours: 9),
          end: const Duration(hours: 9),
        ),
        throwsArgumentError,
      );
    });

    test('rejects end before start', () {
      expect(
        () => WorkingHours(
          day: WeekDay.monday,
          start: const Duration(hours: 12),
          end: const Duration(hours: 9),
        ),
        throwsArgumentError,
      );
    });

    test('accepts a valid range', () {
      final hours = WorkingHours(
        day: WeekDay.monday,
        start: const Duration(hours: 9),
        end: const Duration(hours: 12),
      );

      expect(hours.totalDuration, const Duration(hours: 3));
      expect(hours.enabled, isTrue);
    });

    test('supports multiple non-overlapping ranges on the same weekday', () {
      final result = domain.generateSlots(
        date: monday,
        workingHours: [
          WorkingHours(
            day: WeekDay.monday,
            start: const Duration(hours: 9),
            end: const Duration(hours: 12),
          ),
          WorkingHours(
            day: WeekDay.monday,
            start: const Duration(hours: 14),
            end: const Duration(hours: 17),
          ),
        ],
        blockedPeriods: const [],
        rule: ruleOf(
          duration: const Duration(hours: 1),
          granularity: const Duration(hours: 1),
        ),
      );

      expect(startsOf(result.slots), const [
        Duration(hours: 9),
        Duration(hours: 10),
        Duration(hours: 11),
        Duration(hours: 14),
        Duration(hours: 15),
        Duration(hours: 16),
      ]);
    });

    test('a disabled range produces no slots', () {
      final result = domain.generateSlots(
        date: monday,
        workingHours: [
          WorkingHours(
            day: WeekDay.monday,
            start: const Duration(hours: 9),
            end: const Duration(hours: 12),
            enabled: false,
          ),
        ],
        blockedPeriods: const [],
        rule: ruleOf(
          duration: const Duration(hours: 1),
          granularity: const Duration(hours: 1),
        ),
      );

      expect(result.available, isFalse);
      expect(result.slots, isEmpty);
    });
  });

  group('AD-020 — half-open [start, end) semantics', () {
    final slot = CalendarSlot(
      start: DateTime(2026, 7, 6, 9),
      end: DateTime(2026, 7, 6, 10),
    );

    test('contains start', () {
      expect(slot.contains(DateTime(2026, 7, 6, 9)), isTrue);
    });

    test('excludes end', () {
      expect(slot.contains(DateTime(2026, 7, 6, 10)), isFalse);
    });

    test('contains an interior instant', () {
      expect(slot.contains(DateTime(2026, 7, 6, 9, 30)), isTrue);
    });

    test('adjacent intervals do not overlap', () {
      expect(
        slot.overlaps(DateTime(2026, 7, 6, 10), DateTime(2026, 7, 6, 11)),
        isFalse,
      );
      expect(
        slot.overlaps(DateTime(2026, 7, 6, 8), DateTime(2026, 7, 6, 9)),
        isFalse,
      );
    });

    test('genuinely overlapping intervals conflict', () {
      expect(
        slot.overlaps(
          DateTime(2026, 7, 6, 9, 30),
          DateTime(2026, 7, 6, 10, 30),
        ),
        isTrue,
      );
    });

    test('BlockedPeriod applies the same half-open rule', () {
      final blocked = BlockedPeriod(
        start: DateTime(2026, 7, 6, 10),
        end: DateTime(2026, 7, 6, 11),
        reason: 'Internal meeting',
      );

      expect(blocked.contains(DateTime(2026, 7, 6, 10)), isTrue);
      expect(blocked.contains(DateTime(2026, 7, 6, 11)), isFalse);
      expect(
        blocked.overlaps(DateTime(2026, 7, 6, 11), DateTime(2026, 7, 6, 12)),
        isFalse,
      );
    });

    test('a candidate touching a blocked boundary is still generated', () {
      final result = domain.generateSlots(
        date: monday,
        workingHours: [
          WorkingHours(
            day: WeekDay.monday,
            start: const Duration(hours: 9),
            end: const Duration(hours: 12),
          ),
        ],
        blockedPeriods: [
          BlockedPeriod(
            start: DateTime(2026, 7, 6, 10),
            end: DateTime(2026, 7, 6, 11),
            reason: 'Internal meeting',
          ),
        ],
        rule: ruleOf(
          duration: const Duration(hours: 1),
          granularity: const Duration(hours: 1),
        ),
      );

      // 09:00 ends exactly at 10:00 and 11:00 begins exactly at the blocked
      // end; boundary contact alone is not conflict.
      expect(startsOf(result.slots), const [
        Duration(hours: 9),
        Duration(hours: 11),
      ]);
    });
  });

  group('AD-020 — granularity, duration and range are distinct', () {
    test(
      '09:00-12:00 with granularity 60 and duration 120 yields 09:00, 10:00',
      () {
        final result = domain.generateSlots(
          date: monday,
          workingHours: [
            WorkingHours(
              day: WeekDay.monday,
              start: const Duration(hours: 9),
              end: const Duration(hours: 12),
            ),
          ],
          blockedPeriods: const [],
          rule: ruleOf(
            duration: const Duration(minutes: 120),
            granularity: const Duration(minutes: 60),
          ),
        );

        expect(startsOf(result.slots), const [
          Duration(hours: 9),
          Duration(hours: 10),
        ]);
        expect(result.slots.first.end, DateTime(2026, 7, 6, 11));
        expect(result.slots.last.end, DateTime(2026, 7, 6, 12));
      },
    );

    test('no candidate exceeds the availability range', () {
      final result = domain.generateSlots(
        date: monday,
        workingHours: [
          WorkingHours(
            day: WeekDay.monday,
            start: const Duration(hours: 9),
            end: const Duration(hours: 12),
          ),
        ],
        blockedPeriods: const [],
        rule: ruleOf(
          duration: const Duration(minutes: 90),
          granularity: const Duration(minutes: 30),
        ),
      );

      final rangeEnd = DateTime(2026, 7, 6, 12);
      for (final slot in result.slots) {
        expect(slot.end.isAfter(rangeEnd), isFalse);
      }
      expect(startsOf(result.slots), const [
        Duration(hours: 9),
        Duration(hours: 9, minutes: 30),
        Duration(hours: 10),
        Duration(hours: 10, minutes: 30),
      ]);
    });

    test('granularity varies independently of duration', () {
      List<Duration> startsFor(Duration granularity) {
        return startsOf(
          domain
              .generateSlots(
                date: monday,
                workingHours: [
                  WorkingHours(
                    day: WeekDay.monday,
                    start: const Duration(hours: 9),
                    end: const Duration(hours: 12),
                  ),
                ],
                blockedPeriods: const [],
                rule: ruleOf(
                  duration: const Duration(minutes: 120),
                  granularity: granularity,
                ),
              )
              .slots,
        );
      }

      expect(startsFor(const Duration(minutes: 30)), const [
        Duration(hours: 9),
        Duration(hours: 9, minutes: 30),
        Duration(hours: 10),
      ]);
      expect(startsFor(const Duration(minutes: 60)), const [
        Duration(hours: 9),
        Duration(hours: 10),
      ]);
    });

    test('duration varies independently of granularity', () {
      List<Duration> startsFor(Duration duration) {
        return startsOf(
          domain
              .generateSlots(
                date: monday,
                workingHours: [
                  WorkingHours(
                    day: WeekDay.monday,
                    start: const Duration(hours: 9),
                    end: const Duration(hours: 12),
                  ),
                ],
                blockedPeriods: const [],
                rule: ruleOf(
                  duration: duration,
                  granularity: const Duration(minutes: 60),
                ),
              )
              .slots,
        );
      }

      expect(startsFor(const Duration(minutes: 60)), const [
        Duration(hours: 9),
        Duration(hours: 10),
        Duration(hours: 11),
      ]);
      expect(startsFor(const Duration(minutes: 120)), const [
        Duration(hours: 9),
        Duration(hours: 10),
      ]);
    });

    test('rejects non-positive granularity', () {
      expect(
        () => ruleOf(
          duration: const Duration(minutes: 60),
          granularity: Duration.zero,
        ),
        throwsArgumentError,
      );
      expect(
        () => ruleOf(
          duration: const Duration(minutes: 60),
          granularity: const Duration(minutes: -30),
        ),
        throwsArgumentError,
      );
    });

    test('rejects non-positive consultation duration', () {
      expect(
        () => ruleOf(
          duration: Duration.zero,
          granularity: const Duration(minutes: 60),
        ),
        throwsArgumentError,
      );
      expect(
        () => ruleOf(
          duration: const Duration(minutes: -60),
          granularity: const Duration(minutes: 60),
        ),
        throwsArgumentError,
      );
    });
  });

  group('AD-020 — break buffer', () {
    List<Duration> startsWithBreak(Duration breakBetweenMeetings) {
      return startsOf(
        domain
            .generateSlots(
              date: monday,
              workingHours: [
                WorkingHours(
                  day: WeekDay.monday,
                  start: const Duration(hours: 9),
                  end: const Duration(hours: 12),
                ),
              ],
              blockedPeriods: const [],
              rule: ruleOf(
                duration: const Duration(minutes: 60),
                granularity: const Duration(minutes: 60),
                breakBetweenMeetings: breakBetweenMeetings,
              ),
            )
            .slots,
      );
    }

    test('does not alter candidate-start spacing', () {
      const expected = [
        Duration(hours: 9),
        Duration(hours: 10),
        Duration(hours: 11),
      ];

      expect(startsWithBreak(Duration.zero), expected);
      expect(startsWithBreak(const Duration(minutes: 15)), expected);
      expect(startsWithBreak(const Duration(minutes: 45)), expected);
    });

    test('protects scheduling space without extending the consultation', () {
      final slot = CalendarSlot(
        start: DateTime(2026, 7, 6, 9),
        end: DateTime(2026, 7, 6, 10),
      );

      expect(slot.duration, const Duration(hours: 1));
      expect(slot.end, DateTime(2026, 7, 6, 10));
      expect(
        slot.protectedEnd(const Duration(minutes: 15)),
        DateTime(2026, 7, 6, 10, 15),
      );
      expect(slot.protectedEnd(Duration.zero), slot.end);
    });
  });

  group('AD-020 — deferred policies are not enforced', () {
    test('maximumBookingsPerDay, minimumNotice and maximumAdvanceBooking '
        'do not affect candidate generation', () {
      final result = domain.generateSlots(
        date: monday,
        workingHours: [
          WorkingHours(
            day: WeekDay.monday,
            start: const Duration(hours: 9),
            end: const Duration(hours: 12),
          ),
        ],
        blockedPeriods: const [],
        rule: ruleOf(
          duration: const Duration(minutes: 60),
          granularity: const Duration(minutes: 60),
          // Values that would suppress every candidate if these deferred
          // policies were silently enforced.
          maximumBookingsPerDay: 1,
          minimumNotice: const Duration(days: 3650),
          maximumAdvanceBooking: Duration.zero,
        ),
      );

      expect(startsOf(result.slots), const [
        Duration(hours: 9),
        Duration(hours: 10),
        Duration(hours: 11),
      ]);
    });
  });

  group('AD-020 — timezone identity', () {
    test('accepts IANA identifiers', () {
      expect(TimezoneId('Africa/Bamako').value, 'Africa/Bamako');
      expect(TimezoneId('Africa/Abidjan').value, 'Africa/Abidjan');
      expect(TimezoneId('Europe/Paris').value, 'Europe/Paris');
      expect(TimezoneId('UTC').value, 'UTC');
    });

    test('rejects UTC offsets, which are not identity', () {
      for (final offset in const ['+00:00', '-05:00', 'UTC+1', '+1']) {
        expect(() => TimezoneId(offset), throwsArgumentError, reason: offset);
      }
    });

    test('rejects empty identifiers', () {
      expect(() => TimezoneId(''), throwsArgumentError);
      expect(() => TimezoneId('   '), throwsArgumentError);
    });

    test('is a value object', () {
      expect(TimezoneId('Europe/Paris'), TimezoneId('Europe/Paris'));
      expect(
        TimezoneId('Europe/Paris').hashCode,
        TimezoneId('Europe/Paris').hashCode,
      );
      expect(TimezoneId('Europe/Paris'), isNot(TimezoneId('Africa/Bamako')));
      expect(TimezoneId('  Europe/Paris  ').value, 'Europe/Paris');
    });

    test('the resolver contract reasons from identity, not offset', () {
      final resolver = _RecordingTimezoneResolver();
      final zone = TimezoneId('Africa/Bamako');

      resolver.toUtc(localDateTime: DateTime(2026, 7, 6, 9), zone: zone);

      expect(resolver.lastZone, zone);
      expect(resolver.lastZone!.value, 'Africa/Bamako');
    });
  });
}

/// A test double proving the port surface is implementable from identity
/// alone. ARCH-009A defines the port only; no production resolver exists.
final class _RecordingTimezoneResolver implements TimezoneResolver {
  TimezoneId? lastZone;

  @override
  DateTime toUtc({required DateTime localDateTime, required TimezoneId zone}) {
    lastZone = zone;
    return localDateTime;
  }

  @override
  DateTime fromUtc({required DateTime utcDateTime, required TimezoneId zone}) {
    lastZone = zone;
    return utcDateTime;
  }
}
