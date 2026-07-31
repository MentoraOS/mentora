import 'package:flutter_test/flutter_test.dart';
import 'package:mentora/core/scheduling/scheduling.dart';

void main() {
  const grammar = LegacyAvailabilityGrammar();

  group('AD-022 Wave C2A — strict weekday grammar', () {
    test('maps exactly the seven legacy French values', () {
      expect(grammar.parseWeekday('Lundi'), WeekDay.monday);
      expect(grammar.parseWeekday('Mardi'), WeekDay.tuesday);
      expect(grammar.parseWeekday('Mercredi'), WeekDay.wednesday);
      expect(grammar.parseWeekday('Jeudi'), WeekDay.thursday);
      expect(grammar.parseWeekday('Vendredi'), WeekDay.friday);
      expect(grammar.parseWeekday('Samedi'), WeekDay.saturday);
      expect(grammar.parseWeekday('Dimanche'), WeekDay.sunday);
    });

    test('fails closed on every non-canonical representation', () {
      for (final malformed in const [
        'Monday',
        'lundi',
        'LUNDI',
        ' Lundi',
        'Lundi ',
        'lun.',
        'Mon',
        '1',
        '',
        '   ',
      ]) {
        expect(
          () => grammar.parseWeekday(malformed),
          throwsA(isA<MalformedWeekdayException>()),
          reason: "'$malformed'",
        );
      }
    });
  });

  group('AD-022 Wave C2A — strict HH:mm grammar', () {
    test('accepts strict two-digit HH:mm values', () {
      expect(
        grammar.parseTimeOfDay('00:00'),
        CivilTimeOfDay(hour: 0, minute: 0),
      );
      expect(
        grammar.parseTimeOfDay('08:00'),
        CivilTimeOfDay(hour: 8, minute: 0),
      );
      expect(
        grammar.parseTimeOfDay('09:30'),
        CivilTimeOfDay(hour: 9, minute: 30),
      );
      expect(
        grammar.parseTimeOfDay('14:05'),
        CivilTimeOfDay(hour: 14, minute: 5),
      );
      expect(
        grammar.parseTimeOfDay('23:59'),
        CivilTimeOfDay(hour: 23, minute: 59),
      );
    });

    test('fails closed on every malformed representation', () {
      for (final malformed in const [
        '0:00',
        '9:00',
        '09:0',
        '09',
        '0900',
        '09h00',
        '9h',
        '09:00 ',
        ' 09:00',
        '09:00:00',
        '-1:00',
        'AA:BB',
        '',
        '   ',
      ]) {
        expect(
          () => grammar.parseTimeOfDay(malformed),
          throwsA(isA<MalformedTimeOfDayException>()),
          reason: "'$malformed'",
        );
      }
    });

    test('fails closed on semantically out-of-range values', () {
      expect(
        () => grammar.parseTimeOfDay('24:00'),
        throwsA(isA<MalformedTimeOfDayException>()),
      );
      expect(
        () => grammar.parseTimeOfDay('23:60'),
        throwsA(isA<MalformedTimeOfDayException>()),
      );
      expect(
        () => grammar.parseTimeOfDay('99:99'),
        throwsA(isA<MalformedTimeOfDayException>()),
      );
    });
  });

  group('AD-022 Wave C2A — recurring availability conversion', () {
    test('converts the persisted shape into recurring start ticks', () {
      final availability = grammar.parseRecurringAvailability({
        'Lundi': ['09:00', '10:00'],
        'Mercredi': ['14:00'],
      });

      expect(availability.sortedTicks, [
        RecurringStartTick(
          weekday: WeekDay.monday,
          timeOfDay: CivilTimeOfDay(hour: 9, minute: 0),
        ),
        RecurringStartTick(
          weekday: WeekDay.monday,
          timeOfDay: CivilTimeOfDay(hour: 10, minute: 0),
        ),
        RecurringStartTick(
          weekday: WeekDay.wednesday,
          timeOfDay: CivilTimeOfDay(hour: 14, minute: 0),
        ),
      ]);
    });

    test('an empty rule converts to empty availability', () {
      expect(grammar.parseRecurringAvailability(const {}).isEmpty, isTrue);
    });

    test('a weekday with no times contributes no tick', () {
      final availability = grammar.parseRecurringAvailability({
        'Lundi': const [],
      });

      expect(availability.isEmpty, isTrue);
    });

    test('duplicate persisted ticks collapse to one', () {
      final availability = grammar.parseRecurringAvailability({
        'Lundi': ['09:00', '09:00'],
      });

      expect(availability.length, 1);
    });

    test('one malformed weekday fails the whole conversion', () {
      expect(
        () => grammar.parseRecurringAvailability({
          'Lundi': ['09:00'],
          'Monday': ['10:00'],
        }),
        throwsA(isA<MalformedWeekdayException>()),
      );
    });

    test('one malformed time fails the whole conversion', () {
      expect(
        () => grammar.parseRecurringAvailability({
          'Lundi': ['09:00', '9:00'],
        }),
        throwsA(isA<MalformedTimeOfDayException>()),
      );
    });

    test('malformed entries are never silently dropped', () {
      // The lunch-gap fixture below is valid; adding a single malformed value
      // must not yield the valid remainder.
      final valid = {
        'Lundi': ['09:00', '10:00', '11:00', '14:00'],
      };
      expect(grammar.parseRecurringAvailability(valid).length, 4);

      expect(
        () => grammar.parseRecurringAvailability({
          ...valid,
          'Mardi': ['09h00'],
        }),
        throwsA(isA<MalformedTimeOfDayException>()),
      );
    });

    test('both failures share the sealed grammar exception type', () {
      expect(
        () => grammar.parseWeekday('Monday'),
        throwsA(isA<LegacyAvailabilityGrammarException>()),
      );
      expect(
        () => grammar.parseTimeOfDay('9h'),
        throwsA(isA<LegacyAvailabilityGrammarException>()),
      );
    });

    test('the offending persisted value is carried verbatim', () {
      try {
        grammar.parseWeekday(' Lundi');
        fail('expected MalformedWeekdayException');
      } on MalformedWeekdayException catch (exception) {
        expect(exception.value, ' Lundi');
      }

      try {
        grammar.parseTimeOfDay('09:00 ');
        fail('expected MalformedTimeOfDayException');
      } on MalformedTimeOfDayException catch (exception) {
        expect(exception.value, '09:00 ');
      }
    });

    test('conversion infers nothing beyond weekday and time of day', () {
      // A tick is a start point: the converted model exposes exactly the
      // weekday and the time of day, and nothing that could encode an end,
      // a date, a zone or an offer.
      final availability = grammar.parseRecurringAvailability({
        'Lundi': ['18:00'],
      });
      final single = availability.sortedTicks.single;

      expect(single.weekday, WeekDay.monday);
      expect(single.timeOfDay, CivilTimeOfDay(hour: 18, minute: 0));
    });
  });
}
