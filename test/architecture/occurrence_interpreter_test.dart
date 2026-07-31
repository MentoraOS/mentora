import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/scheduling/scheduling.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';

const interpreter = OccurrenceInterpreter(
  resolver: LaunchMarketTimezoneResolver(),
);

ReservationOccurrence interpret({
  int year = 2026,
  int month = 7,
  int day = 25,
  int hour = 9,
  int minute = 0,
  String zone = 'Africa/Bamako',
  int durationMinutes = 60,
}) {
  return interpreter.interpret(
    civilDateTime: CivilDateTime(
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
    ),
    timezone: TimezoneId(zone),
    durationMinutes: durationMinutes,
  );
}

void main() {
  group('AD-022 Wave B — interpretation per launch zone', () {
    test('Africa/Bamako civil 09:00 becomes the expected instant', () {
      final occurrence = interpret(zone: 'Africa/Bamako');

      expect(occurrence.startUtc, DateTime.utc(2026, 7, 25, 9));
      expect(occurrence.endUtc, DateTime.utc(2026, 7, 25, 10));
      expect(occurrence.expertTimezone, TimezoneId('Africa/Bamako'));
    });

    test(
      'Africa/Dakar produces the same boundaries for the same civil time',
      () {
        final occurrence = interpret(zone: 'Africa/Dakar');

        expect(occurrence.startUtc, DateTime.utc(2026, 7, 25, 9));
        expect(occurrence.expertTimezone.value, 'Africa/Dakar');
      },
    );

    test('Africa/Abidjan preserves its own identity', () {
      final occurrence = interpret(zone: 'Africa/Abidjan');

      expect(occurrence.startUtc, DateTime.utc(2026, 7, 25, 9));
      expect(occurrence.expertTimezone.value, 'Africa/Abidjan');
    });

    test('UTC is interpretable and keeps its identity', () {
      final occurrence = interpret(zone: 'UTC');

      expect(occurrence.startUtc, DateTime.utc(2026, 7, 25, 9));
      expect(occurrence.expertTimezone.value, 'UTC');
    });

    test('the named identity is never replaced by an offset', () {
      final occurrence = interpret(zone: 'Africa/Bamako');

      expect(occurrence.expertTimezone.value, 'Africa/Bamako');
      expect(occurrence.expertTimezone.value, isNot('UTC'));
      expect(occurrence.expertTimezone.value, isNot('+00:00'));
    });
  });

  group('AD-022 Wave B — duration is consumed, never defaulted', () {
    test('honours each duration exactly', () {
      for (final minutes in const [30, 60, 120, 45, 15, 240]) {
        final occurrence = interpret(durationMinutes: minutes);

        expect(
          occurrence.endUtc.difference(occurrence.startUtc),
          Duration(minutes: minutes),
          reason: '$minutes minutes',
        );
        expect(occurrence.duration.inMinutes, minutes);
      }
    });

    test('a 120-minute request never collapses to a shorter default', () {
      final occurrence = interpret(durationMinutes: 120);

      expect(occurrence.endUtc, DateTime.utc(2026, 7, 25, 11));
      expect(occurrence.duration, isNot(const Duration(minutes: 30)));
      expect(occurrence.duration, isNot(const Duration(minutes: 60)));
    });

    test('rejects a non-positive duration', () {
      expect(() => interpret(durationMinutes: 0), throwsArgumentError);
      expect(() => interpret(durationMinutes: -60), throwsArgumentError);
    });

    test('does not extend the occurrence with any scheduling protection', () {
      // A 60-minute offer occupies exactly 10:00 -> 11:00. Any protective
      // interval belongs elsewhere and must not lengthen commercial truth.
      final occurrence = interpret(hour: 10, durationMinutes: 60);

      expect(occurrence.startUtc, DateTime.utc(2026, 7, 25, 10));
      expect(occurrence.endUtc, DateTime.utc(2026, 7, 25, 11));
      expect(occurrence.endUtc, isNot(DateTime.utc(2026, 7, 25, 11, 15)));
    });
  });

  group('AD-022 Wave B — UTC discipline', () {
    test('both boundaries are UTC instants', () {
      final occurrence = interpret();

      expect(occurrence.startUtc.isUtc, isTrue);
      expect(occurrence.endUtc.isUtc, isTrue);
    });

    test('the occurrence rejects non-UTC boundaries', () {
      expect(
        () => ReservationOccurrence(
          startUtc: DateTime(2026, 7, 25, 9),
          endUtc: DateTime.utc(2026, 7, 25, 10),
          expertTimezone: TimezoneId('Africa/Bamako'),
        ),
        throwsArgumentError,
      );
      expect(
        () => ReservationOccurrence(
          startUtc: DateTime.utc(2026, 7, 25, 9),
          endUtc: DateTime(2026, 7, 25, 10),
          expertTimezone: TimezoneId('Africa/Bamako'),
        ),
        throwsArgumentError,
      );
    });

    test('the occurrence rejects a non-positive interval', () {
      final instant = DateTime.utc(2026, 7, 25, 9);

      expect(
        () => ReservationOccurrence(
          startUtc: instant,
          endUtc: instant,
          expertTimezone: TimezoneId('UTC'),
        ),
        throwsArgumentError,
      );
      expect(
        () => ReservationOccurrence(
          startUtc: instant,
          endUtc: DateTime.utc(2026, 7, 25, 8),
          expertTimezone: TimezoneId('UTC'),
        ),
        throwsArgumentError,
      );
    });
  });

  group('AD-022 Wave B — calendar boundaries', () {
    test('crosses midnight into the next day', () {
      final occurrence = interpret(hour: 23, minute: 30, durationMinutes: 60);

      expect(occurrence.startUtc, DateTime.utc(2026, 7, 25, 23, 30));
      expect(occurrence.endUtc, DateTime.utc(2026, 7, 26, 0, 30));
    });

    test('crosses a month boundary', () {
      final occurrence = interpret(
        month: 7,
        day: 31,
        hour: 23,
        minute: 30,
        durationMinutes: 60,
      );

      expect(occurrence.endUtc, DateTime.utc(2026, 8, 1, 0, 30));
    });

    test('crosses a year boundary', () {
      final occurrence = interpret(
        month: 12,
        day: 31,
        hour: 23,
        minute: 30,
        durationMinutes: 60,
      );

      expect(occurrence.endUtc, DateTime.utc(2027, 1, 1, 0, 30));
    });

    test('crosses a leap-day boundary', () {
      final occurrence = interpret(
        year: 2028,
        month: 2,
        day: 29,
        hour: 23,
        minute: 30,
        durationMinutes: 60,
      );

      expect(occurrence.startUtc, DateTime.utc(2028, 2, 29, 23, 30));
      expect(occurrence.endUtc, DateTime.utc(2028, 3, 1, 0, 30));
    });
  });

  group('AD-022 Wave B — unsupported and invalid input fails closed', () {
    test('Europe/Paris fails closed rather than resolving to UTC', () {
      expect(
        () => interpret(zone: 'Europe/Paris'),
        throwsA(isA<UnsupportedTimezoneException>()),
      );
    });

    test('other DST zones fail closed', () {
      for (final zone in const ['America/New_York', 'Europe/London']) {
        expect(
          () => interpret(zone: zone),
          throwsA(isA<UnsupportedTimezoneException>()),
          reason: zone,
        );
      }
    });

    test('an invalid timezone identity fails at the identity boundary', () {
      expect(() => TimezoneId('+00:00'), throwsArgumentError);
      expect(() => TimezoneId('Bamako'), throwsArgumentError);
      expect(() => TimezoneId(''), throwsArgumentError);
    });

    test('an impossible civil value fails at the civil boundary', () {
      expect(
        () => interpret(year: 2027, month: 2, day: 29),
        throwsArgumentError,
      );
    });
  });

  group('AD-022 Wave B — device independence', () {
    test('the same civil input and zone always yield the same occurrence', () {
      expect(interpret(), interpret());
      expect(interpret().hashCode, interpret().hashCode);
    });

    test('interpretation does not depend on any ambient clock', () {
      final first = interpret();
      final second = interpret();

      expect(first.startUtc, second.startUtc);
      expect(first.endUtc, second.endUtc);
      expect(first.startUtc, DateTime.utc(2026, 7, 25, 9));
    });

    test('a past civil date interprets exactly like a future one', () {
      final past = interpret(year: 2001);
      final future = interpret(year: 2099);

      expect(past.startUtc, DateTime.utc(2001, 7, 25, 9));
      expect(future.startUtc, DateTime.utc(2099, 7, 25, 9));
    });
  });
}
