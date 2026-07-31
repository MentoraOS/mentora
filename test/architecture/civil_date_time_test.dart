import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/scheduling/scheduling.dart';

CivilDateTime civil({
  int year = 2026,
  int month = 7,
  int day = 25,
  int hour = 9,
  int minute = 0,
}) {
  return CivilDateTime(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
  );
}

void main() {
  group('AD-022 Wave B — civil components', () {
    test('accepts a valid civil date and time', () {
      final value = civil();

      expect(value.year, 2026);
      expect(value.month, 7);
      expect(value.day, 25);
      expect(value.hour, 9);
      expect(value.minute, 0);
    });

    test('requires an explicit year at construction', () {
      // The year is a required parameter: there is no default and no value is
      // taken from the current date.
      final value = CivilDateTime(
        year: 1999,
        month: 1,
        day: 1,
        hour: 0,
        minute: 0,
      );

      expect(value.year, 1999);
    });

    test('accepts the day and minute extremes', () {
      expect(civil(month: 1, day: 31, hour: 23, minute: 59).day, 31);
      expect(civil(month: 12, day: 31, hour: 0, minute: 0).month, 12);
    });

    test('is a value object', () {
      expect(civil(), civil());
      expect(civil().hashCode, civil().hashCode);
      expect(civil(), isNot(civil(minute: 1)));
      expect(civil().toString(), contains('2026-07-25 09:00'));
    });
  });

  group('AD-022 Wave B — structural validation', () {
    test('rejects an out-of-range month', () {
      expect(() => civil(month: 0), throwsArgumentError);
      expect(() => civil(month: 13), throwsArgumentError);
      expect(() => civil(month: -1), throwsArgumentError);
    });

    test('rejects an out-of-range day', () {
      expect(() => civil(day: 0), throwsArgumentError);
      expect(() => civil(month: 7, day: 32), throwsArgumentError);
    });

    test('rejects a day beyond the length of its month', () {
      expect(() => civil(month: 4, day: 31), throwsArgumentError);
      expect(() => civil(month: 6, day: 31), throwsArgumentError);
      expect(() => civil(month: 9, day: 31), throwsArgumentError);
      expect(() => civil(month: 11, day: 31), throwsArgumentError);
    });

    test('rejects an out-of-range hour', () {
      expect(() => civil(hour: -1), throwsArgumentError);
      expect(() => civil(hour: 24), throwsArgumentError);
    });

    test('rejects an out-of-range minute', () {
      expect(() => civil(minute: -1), throwsArgumentError);
      expect(() => civil(minute: 60), throwsArgumentError);
    });
  });

  group('AD-022 Wave B — leap-year handling', () {
    test('accepts 29 February in a leap year', () {
      expect(civil(year: 2028, month: 2, day: 29).day, 29);
      expect(civil(year: 2000, month: 2, day: 29).day, 29);
    });

    test('rejects 29 February in a non-leap year', () {
      // DateTime would silently roll this to 1 March; construction must fail.
      expect(() => civil(year: 2027, month: 2, day: 29), throwsArgumentError);
      expect(() => civil(year: 1900, month: 2, day: 29), throwsArgumentError);
    });

    test('rejects 30 February in every year', () {
      expect(() => civil(year: 2028, month: 2, day: 30), throwsArgumentError);
    });

    test('exposes the calendar rules it enforces', () {
      expect(CivilDateTime.isLeapYear(2028), isTrue);
      expect(CivilDateTime.isLeapYear(2027), isFalse);
      expect(CivilDateTime.isLeapYear(2000), isTrue);
      expect(CivilDateTime.isLeapYear(1900), isFalse);

      expect(CivilDateTime.daysInMonth(year: 2028, month: 2), 29);
      expect(CivilDateTime.daysInMonth(year: 2027, month: 2), 28);
      expect(CivilDateTime.daysInMonth(year: 2026, month: 4), 30);
      expect(CivilDateTime.daysInMonth(year: 2026, month: 12), 31);
    });
  });
}
