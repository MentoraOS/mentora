import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/scheduling/scheduling.dart';

CivilTimeOfDay time(int hour, int minute) {
  return CivilTimeOfDay(hour: hour, minute: minute);
}

RecurringStartTick tick(WeekDay weekday, int hour, int minute) {
  return RecurringStartTick(weekday: weekday, timeOfDay: time(hour, minute));
}

void main() {
  group('AD-022 Wave C2A — CivilTimeOfDay', () {
    test('accepts the boundaries of the civil day', () {
      expect(time(0, 0).hour, 0);
      expect(time(0, 0).minute, 0);
      expect(time(23, 59).hour, 23);
      expect(time(23, 59).minute, 59);
    });

    test('rejects out-of-range components', () {
      expect(() => time(-1, 0), throwsArgumentError);
      expect(() => time(24, 0), throwsArgumentError);
      expect(() => time(0, -1), throwsArgumentError);
      expect(() => time(0, 60), throwsArgumentError);
    });

    test('has value equality', () {
      expect(time(9, 30), time(9, 30));
      expect(time(9, 30).hashCode, time(9, 30).hashCode);
      expect(time(9, 30), isNot(time(9, 31)));
      expect(time(9, 30), isNot(time(10, 30)));
    });

    test('orders by hour then minute', () {
      expect(time(9, 0).compareTo(time(9, 0)), 0);
      expect(time(8, 59).compareTo(time(9, 0)), isNegative);
      expect(time(9, 1).compareTo(time(9, 0)), isPositive);
      expect(time(23, 0).compareTo(time(9, 59)), isPositive);
    });

    test('carries no date, zone or length', () {
      // The value is exactly hour + minute: constructing it requires nothing
      // else, and its equality is exhausted by those two components.
      expect(time(9, 0), CivilTimeOfDay(hour: 9, minute: 0));
    });
  });

  group('AD-022 Wave C2A — RecurringStartTick', () {
    test('has value equality', () {
      expect(tick(WeekDay.monday, 9, 0), tick(WeekDay.monday, 9, 0));
      expect(
        tick(WeekDay.monday, 9, 0).hashCode,
        tick(WeekDay.monday, 9, 0).hashCode,
      );
    });

    test('a different weekday is a different tick', () {
      expect(tick(WeekDay.monday, 9, 0), isNot(tick(WeekDay.tuesday, 9, 0)));
    });

    test('a different time is a different tick', () {
      expect(tick(WeekDay.monday, 9, 0), isNot(tick(WeekDay.monday, 10, 0)));
    });

    test('orders by weekday then time', () {
      final monday10 = tick(WeekDay.monday, 10, 0);
      final tuesday9 = tick(WeekDay.tuesday, 9, 0);
      final monday9 = tick(WeekDay.monday, 9, 0);

      expect(monday9.compareTo(monday10), isNegative);
      expect(monday10.compareTo(tuesday9), isNegative);
      expect(tuesday9.compareTo(tuesday9), 0);
    });

    test('identical ticks collapse in a set', () {
      final ticks = {tick(WeekDay.monday, 9, 0), tick(WeekDay.monday, 9, 0)};

      expect(ticks, hasLength(1));
    });
  });

  group('AD-022 Wave C2A — RecurringAvailability', () {
    test('empty availability is valid', () {
      final availability = RecurringAvailability(ticks: const []);

      expect(availability.isEmpty, isTrue);
      expect(availability.length, 0);
      expect(availability.sortedTicks, isEmpty);
    });

    test('holds a single tick', () {
      final availability = RecurringAvailability(
        ticks: [tick(WeekDay.wednesday, 14, 0)],
      );

      expect(availability.length, 1);
      expect(availability.sortedTicks.single, tick(WeekDay.wednesday, 14, 0));
    });

    test('holds several weekdays and several times per weekday', () {
      final availability = RecurringAvailability(
        ticks: [
          tick(WeekDay.monday, 9, 0),
          tick(WeekDay.monday, 10, 0),
          tick(WeekDay.friday, 16, 30),
        ],
      );

      expect(availability.length, 3);
    });

    test('duplicate identical ticks are one semantic availability', () {
      final availability = RecurringAvailability(
        ticks: [tick(WeekDay.monday, 9, 0), tick(WeekDay.monday, 9, 0)],
      );

      expect(availability.length, 1);
      expect(
        availability,
        RecurringAvailability(ticks: [tick(WeekDay.monday, 9, 0)]),
      );
    });

    test('sortedTicks is deterministic: weekday first, then time', () {
      final availability = RecurringAvailability(
        ticks: [
          tick(WeekDay.sunday, 8, 0),
          tick(WeekDay.monday, 10, 0),
          tick(WeekDay.monday, 9, 0),
          tick(WeekDay.wednesday, 14, 0),
        ],
      );

      expect(availability.sortedTicks, [
        tick(WeekDay.monday, 9, 0),
        tick(WeekDay.monday, 10, 0),
        tick(WeekDay.wednesday, 14, 0),
        tick(WeekDay.sunday, 8, 0),
      ]);
    });

    test('value equality ignores declaration order', () {
      final left = RecurringAvailability(
        ticks: [tick(WeekDay.monday, 9, 0), tick(WeekDay.friday, 16, 0)],
      );
      final right = RecurringAvailability(
        ticks: [tick(WeekDay.friday, 16, 0), tick(WeekDay.monday, 9, 0)],
      );

      expect(left, right);
      expect(left.hashCode, right.hashCode);
      expect(
        left,
        isNot(RecurringAvailability(ticks: [tick(WeekDay.monday, 9, 0)])),
      );
    });

    test('the tick set cannot be mutated', () {
      final availability = RecurringAvailability(
        ticks: [tick(WeekDay.monday, 9, 0)],
      );

      expect(
        () => availability.ticks.add(tick(WeekDay.tuesday, 9, 0)),
        throwsUnsupportedError,
      );
      expect(
        () => availability.sortedTicks.add(tick(WeekDay.tuesday, 9, 0)),
        throwsUnsupportedError,
      );
    });
  });
}
