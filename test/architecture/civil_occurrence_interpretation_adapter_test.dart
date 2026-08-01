import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/application/scheduling/civil_selection.dart';
import 'package:mentora/application/scheduling/selectable_occurrence_failure.dart';
import 'package:mentora/infrastructure/scheduling/civil_occurrence_interpretation_adapter.dart';
import 'package:mentora/infrastructure/scheduling/launch_market_timezone_resolver.dart';

const adapter = CivilOccurrenceInterpretationAdapter(
  resolver: LaunchMarketTimezoneResolver(),
);

CivilSelection selection({
  int year = 2026,
  int month = 8,
  int day = 3,
  int hour = 9,
  int minute = 0,
  int duration = 60,
}) {
  return CivilSelection(
    year: year,
    month: month,
    day: day,
    hour: hour,
    minute: minute,
    durationMinutes: duration,
  );
}

void main() {
  group('AD-022 C3 — civil occurrence interpretation', () {
    test('interprets the canonical example exactly', () {
      // Monday 3 August 2026, 09:00 Africa/Bamako, 60 minutes.
      final snapshot = adapter.interpret(
        selection: selection(),
        expertTimezone: 'Africa/Bamako',
      );

      expect(snapshot.startUtc, DateTime.utc(2026, 8, 3, 9, 0));
      expect(snapshot.endUtc, DateTime.utc(2026, 8, 3, 10, 0));
      expect(snapshot.startUtc.isUtc, isTrue);
      expect(snapshot.endUtc.isUtc, isTrue);
      // Identity preserved verbatim — never collapsed to UTC or an offset
      // even while the offsets coincide.
      expect(snapshot.expertTimezone, 'Africa/Bamako');
      expect(snapshot.expertTimezone, isNot('UTC'));
    });

    test('the offer duration defines the end exactly', () {
      final thirty = adapter.interpret(
        selection: selection(duration: 30),
        expertTimezone: 'Africa/Dakar',
      );
      final twoHours = adapter.interpret(
        selection: selection(duration: 120),
        expertTimezone: 'Africa/Abidjan',
      );

      expect(thirty.endUtc, DateTime.utc(2026, 8, 3, 9, 30));
      expect(twoHours.endUtc, DateTime.utc(2026, 8, 3, 11, 0));
    });

    test('a late start crosses midnight into the next civil day', () {
      final snapshot = adapter.interpret(
        selection: selection(hour: 23, minute: 30, duration: 60),
        expertTimezone: 'Africa/Bamako',
      );

      expect(snapshot.startUtc, DateTime.utc(2026, 8, 3, 23, 30));
      expect(snapshot.endUtc, DateTime.utc(2026, 8, 4, 0, 30));
    });

    test('a year-boundary occurrence lands in the next year', () {
      final snapshot = adapter.interpret(
        selection: selection(month: 12, day: 31, hour: 23, minute: 30),
        expertTimezone: 'Africa/Bamako',
      );

      expect(snapshot.startUtc, DateTime.utc(2026, 12, 31, 23, 30));
      expect(snapshot.endUtc, DateTime.utc(2027, 1, 1, 0, 30));
    });

    test('a malformed identity fails closed', () {
      for (final malformed in const ['+00:00', 'Not A Zone', ' ']) {
        expect(
          () => adapter.interpret(
            selection: selection(),
            expertTimezone: malformed,
          ),
          throwsA(isA<SelectableOccurrenceTimezoneUnavailableFailure>()),
          reason: malformed,
        );
      }
    });

    test('an identity unsupported by the production resolver fails closed', () {
      expect(
        () => adapter.interpret(
          selection: selection(),
          expertTimezone: 'Europe/Paris',
        ),
        throwsA(isA<SelectableOccurrenceTimezoneUnavailableFailure>()),
      );
    });

    test('an impossible civil value fails closed', () {
      // CivilSelection bounds are structural; 30 February passes them but is
      // no real date, so interpretation refuses it.
      expect(
        () => adapter.interpret(
          selection: selection(month: 2, day: 30),
          expertTimezone: 'Africa/Bamako',
        ),
        throwsA(isA<SelectableOccurrenceInterpretationFailure>()),
      );
    });
  });
}
