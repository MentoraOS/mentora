import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/scheduling/scheduling.dart';

RecurringStartTick tick(WeekDay weekday, int hour, int minute) {
  return RecurringStartTick(
    weekday: weekday,
    timeOfDay: CivilTimeOfDay(hour: hour, minute: minute),
  );
}

RecurringAvailability availability(List<RecurringStartTick> ticks) {
  return RecurringAvailability(ticks: ticks);
}

CivilDate date(int year, int month, int day) {
  return CivilDate(year: year, month: month, day: day);
}

CivilDateRange range(CivilDate start, CivilDate end) {
  return CivilDateRange(start: start, end: end);
}

CivilDateTime start(int year, int month, int day, int hour, int minute) {
  return CivilDateTime(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
  );
}

void main() {
  const materializer = OccurrenceMaterializer();

  group('AD-022 Wave C2 — CivilDate', () {
    test('computes the weekday from explicit civil components', () {
      // 3 August 2026 is a Monday (the canonical mission example).
      expect(date(2026, 8, 3).weekday, WeekDay.monday);
      expect(date(2026, 8, 4).weekday, WeekDay.tuesday);
      expect(date(2026, 8, 9).weekday, WeekDay.sunday);
      // 29 February 2024 exists and is a Thursday.
      expect(date(2024, 2, 29).weekday, WeekDay.thursday);
    });

    test('rejects impossible dates instead of normalizing them', () {
      expect(() => date(2026, 2, 29), throwsArgumentError);
      expect(() => date(2026, 4, 31), throwsArgumentError);
      expect(() => date(2026, 1, 0), throwsArgumentError);
      expect(() => date(2026, 13, 1), throwsArgumentError);
    });
  });

  group('AD-022 Wave C2 — CivilDateRange', () {
    test('is inclusive of both endpoints', () {
      expect(range(date(2026, 8, 1), date(2026, 8, 1)).days, hasLength(1));
      expect(range(date(2026, 8, 1), date(2026, 8, 7)).days, hasLength(7));
    });

    test('rejects an end before the start', () {
      expect(
        () => range(date(2026, 8, 2), date(2026, 8, 1)),
        throwsArgumentError,
      );
    });

    test('crosses month and year boundaries', () {
      final days = range(date(2026, 12, 30), date(2027, 1, 2)).days;

      expect(days, [
        date(2026, 12, 30),
        date(2026, 12, 31),
        date(2027, 1, 1),
        date(2027, 1, 2),
      ]);
    });
  });

  group('AD-022 Wave C2 — OccurrenceMaterializer', () {
    test('a Monday tick materializes on every Monday in the range', () {
      final occurrences = materializer.materialize(
        availability: availability([tick(WeekDay.monday, 9, 0)]),
        range: range(date(2026, 8, 1), date(2026, 8, 31)),
        durationMinutes: 60,
      );

      expect(occurrences, [
        SelectableOccurrence(
          start: start(2026, 8, 3, 9, 0),
          durationMinutes: 60,
        ),
        SelectableOccurrence(
          start: start(2026, 8, 10, 9, 0),
          durationMinutes: 60,
        ),
        SelectableOccurrence(
          start: start(2026, 8, 17, 9, 0),
          durationMinutes: 60,
        ),
        SelectableOccurrence(
          start: start(2026, 8, 24, 9, 0),
          durationMinutes: 60,
        ),
        SelectableOccurrence(
          start: start(2026, 8, 31, 9, 0),
          durationMinutes: 60,
        ),
      ]);
    });

    test('year, month, day, hour and minute are preserved verbatim', () {
      final occurrence = materializer
          .materialize(
            availability: availability([tick(WeekDay.monday, 14, 30)]),
            range: range(date(2026, 8, 3), date(2026, 8, 3)),
            durationMinutes: 30,
          )
          .single;

      expect(occurrence.start.year, 2026);
      expect(occurrence.start.month, 8);
      expect(occurrence.start.day, 3);
      expect(occurrence.start.hour, 14);
      expect(occurrence.start.minute, 30);
    });

    test('multiple ticks and weekdays materialize deterministically', () {
      final occurrences = materializer.materialize(
        availability: availability([
          tick(WeekDay.wednesday, 14, 0),
          tick(WeekDay.monday, 14, 0),
          tick(WeekDay.monday, 9, 0),
        ]),
        // Monday 3 → Wednesday 5 August 2026.
        range: range(date(2026, 8, 3), date(2026, 8, 5)),
        durationMinutes: 60,
      );

      expect(occurrences.map((o) => o.start), [
        start(2026, 8, 3, 9, 0),
        start(2026, 8, 3, 14, 0),
        start(2026, 8, 5, 14, 0),
      ]);
    });

    test('materialization crosses a month boundary', () {
      final occurrences = materializer.materialize(
        availability: availability([
          tick(WeekDay.monday, 9, 0),
          tick(WeekDay.tuesday, 9, 0),
        ]),
        // Sunday 30 August → Wednesday 2 September 2026.
        range: range(date(2026, 8, 30), date(2026, 9, 2)),
        durationMinutes: 60,
      );

      expect(occurrences.map((o) => o.start), [
        start(2026, 8, 31, 9, 0),
        start(2026, 9, 1, 9, 0),
      ]);
    });

    test('materialization crosses a year boundary', () {
      final occurrences = materializer.materialize(
        availability: availability([tick(WeekDay.monday, 9, 0)]),
        range: range(date(2026, 12, 28), date(2027, 1, 4)),
        durationMinutes: 60,
      );

      expect(occurrences.map((o) => o.start), [
        start(2026, 12, 28, 9, 0),
        start(2027, 1, 4, 9, 0),
      ]);
    });

    test('the offer duration is preserved exactly', () {
      for (final duration in const [30, 60, 120]) {
        final occurrences = materializer.materialize(
          availability: availability([tick(WeekDay.monday, 9, 0)]),
          range: range(date(2026, 8, 3), date(2026, 8, 3)),
          durationMinutes: duration,
        );

        expect(
          occurrences.single.durationMinutes,
          duration,
          reason: '$duration',
        );
      }
    });

    test('a late tick with a long offer remains a candidate', () {
      // 18:00 + 120 minutes extends past the last declared tick. That is the
      // expert's declaration; no end-of-day rule exists to reject it.
      final occurrences = materializer.materialize(
        availability: availability([tick(WeekDay.monday, 18, 0)]),
        range: range(date(2026, 8, 3), date(2026, 8, 3)),
        durationMinutes: 120,
      );

      expect(occurrences.single.start, start(2026, 8, 3, 18, 0));
      expect(occurrences.single.durationMinutes, 120);
    });

    test('no interval is inferred from neighbouring ticks', () {
      // Adjacent 09:00 and 10:00 ticks with a 120-minute offer: both remain
      // candidates. Overlap exclusion is conflict policy, not offerability.
      final occurrences = materializer.materialize(
        availability: availability([
          tick(WeekDay.monday, 9, 0),
          tick(WeekDay.monday, 10, 0),
        ]),
        range: range(date(2026, 8, 3), date(2026, 8, 3)),
        durationMinutes: 120,
      );

      expect(occurrences.map((o) => o.start), [
        start(2026, 8, 3, 9, 0),
        start(2026, 8, 3, 10, 0),
      ]);
    });

    test('the result is deterministic across calls', () {
      List<SelectableOccurrence> run() => materializer.materialize(
        availability: availability([
          tick(WeekDay.sunday, 8, 0),
          tick(WeekDay.monday, 10, 0),
          tick(WeekDay.monday, 9, 0),
        ]),
        range: range(date(2026, 8, 1), date(2026, 8, 31)),
        durationMinutes: 60,
      );

      expect(run(), run());
    });

    test('empty availability materializes to nothing', () {
      final occurrences = materializer.materialize(
        availability: availability(const []),
        range: range(date(2026, 8, 1), date(2026, 8, 31)),
        durationMinutes: 60,
      );

      expect(occurrences, isEmpty);
    });

    test('a non-positive duration fails closed', () {
      expect(
        () => materializer.materialize(
          availability: availability([tick(WeekDay.monday, 9, 0)]),
          range: range(date(2026, 8, 3), date(2026, 8, 3)),
          durationMinutes: 0,
        ),
        throwsArgumentError,
      );
    });

    test('the result list cannot be mutated', () {
      final occurrences = materializer.materialize(
        availability: availability([tick(WeekDay.monday, 9, 0)]),
        range: range(date(2026, 8, 3), date(2026, 8, 3)),
        durationMinutes: 60,
      );

      expect(
        () => occurrences.add(
          SelectableOccurrence(
            start: start(2026, 8, 3, 9, 0),
            durationMinutes: 60,
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
