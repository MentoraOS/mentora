import '../models/civil_time_of_day.dart';
import '../models/recurring_availability.dart';
import '../models/recurring_start_tick.dart';
import '../models/working_hours.dart';

/// A grammar violation in persisted legacy availability.
///
/// AD-022 Clarification C: malformed persisted availability MUST fail closed
/// for modern selectable occurrence generation. Nothing here repairs,
/// normalizes or partially accepts an authoritative availability rule.
sealed class LegacyAvailabilityGrammarException implements Exception {
  const LegacyAvailabilityGrammarException(this.value);

  /// The offending persisted value, verbatim.
  final String value;
}

/// The persisted weekday is not one of the seven compatibility values.
final class MalformedWeekdayException
    extends LegacyAvailabilityGrammarException {
  const MalformedWeekdayException(super.value);

  @override
  String toString() {
    return "MalformedWeekdayException: '$value' is not a supported legacy "
        'weekday value.';
  }
}

/// The persisted time is not strict `HH:mm` with a valid hour and minute.
final class MalformedTimeOfDayException
    extends LegacyAvailabilityGrammarException {
  const MalformedTimeOfDayException(super.value);

  @override
  String toString() {
    return "MalformedTimeOfDayException: '$value' is not a supported legacy "
        'HH:mm time value.';
  }
}

/// Strict compatibility parser for persisted legacy availability.
///
/// AD-022 Clarification C decisions 3 and 4: the current persisted
/// representation uses the French weekday vocabulary `Lundi`..`Dimanche` and
/// the time syntax `HH:mm`. Both are compatibility grammar for existing
/// persisted data — not Presentation authority and not a localization
/// facility. This parser converts that representation into locale-independent
/// Scheduling semantics and fails closed on anything else.
///
/// There is no trimming, no case folding, no locale translation and no
/// defaulting. One malformed value fails the entire conversion: a rule that
/// cannot be fully trusted is not partially trusted.
///
/// The parser is pure. It reads no persistence, no catalog, no clock and no
/// zone identity, and it infers no calendar date, no interval end and no
/// consultation length.
final class LegacyAvailabilityGrammar {
  const LegacyAvailabilityGrammar();

  /// The exact legacy weekday vocabulary. Nothing else is accepted.
  static const Map<String, WeekDay> _weekdays = {
    'Lundi': WeekDay.monday,
    'Mardi': WeekDay.tuesday,
    'Mercredi': WeekDay.wednesday,
    'Jeudi': WeekDay.thursday,
    'Vendredi': WeekDay.friday,
    'Samedi': WeekDay.saturday,
    'Dimanche': WeekDay.sunday,
  };

  /// Exactly two digits, a colon, exactly two digits.
  static final RegExp _timeSyntax = RegExp(r'^[0-9]{2}:[0-9]{2}$');

  /// Parses one exact legacy weekday value.
  ///
  /// Throws [MalformedWeekdayException] for any other representation,
  /// including other locales, other casings, surrounding whitespace,
  /// abbreviations and blank values.
  WeekDay parseWeekday(String value) {
    final weekday = _weekdays[value];
    if (weekday == null) {
      throw MalformedWeekdayException(value);
    }

    return weekday;
  }

  /// Parses one strict `HH:mm` value with `HH` in 00..23 and `mm` in 00..59.
  ///
  /// Throws [MalformedTimeOfDayException] for any other representation,
  /// including single-digit hours, missing colons, `09h00`-style syntax,
  /// AM/PM forms, surrounding whitespace, seconds and out-of-range values.
  CivilTimeOfDay parseTimeOfDay(String value) {
    if (!_timeSyntax.hasMatch(value)) {
      throw MalformedTimeOfDayException(value);
    }

    final hour = int.parse(value.substring(0, 2));
    final minute = int.parse(value.substring(3, 5));
    if (hour > 23 || minute > 59) {
      throw MalformedTimeOfDayException(value);
    }

    return CivilTimeOfDay(hour: hour, minute: minute);
  }

  /// Converts a persisted `weekday → times` rule into validated Scheduling
  /// semantics.
  ///
  /// Every weekday key and every time value must satisfy the strict grammar;
  /// the first violation aborts the whole conversion. Malformed entries are
  /// never silently dropped, because a partially trusted availability rule is
  /// not authoritative availability.
  RecurringAvailability parseRecurringAvailability(
    Map<String, List<String>> slotsByWeekday,
  ) {
    final ticks = <RecurringStartTick>{};
    for (final entry in slotsByWeekday.entries) {
      final weekday = parseWeekday(entry.key);
      for (final time in entry.value) {
        ticks.add(
          RecurringStartTick(weekday: weekday, timeOfDay: parseTimeOfDay(time)),
        );
      }
    }

    return RecurringAvailability(ticks: ticks);
  }
}
