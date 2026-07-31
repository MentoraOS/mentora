import '../../application/scheduling/civil_occurrence_materialization.dart';
import '../../application/scheduling/civil_selection.dart';
import '../../application/scheduling/selectable_occurrence_failure.dart';
import '../../core/scheduling/scheduling.dart';

/// Infrastructure adapter implementing the Application materialization port
/// over the Scheduling module.
///
/// AD-022 Clarification C decision 9: Scheduling owns the materialization of
/// recurring start ticks into selectable civil occurrences. This adapter only
/// bridges: it applies the Scheduling-owned strict legacy grammar, validates
/// the timezone identity through the Scheduling-owned [TimezoneId], invokes
/// the Scheduling-owned [OccurrenceMaterializer], and converts the result to
/// the Application transport value. No policy lives here.
///
/// The adapter is pure and reads no clock, no persistence and no country. It
/// exists so that Application and Presentation never import the Scheduling
/// module directly, which would drag the frozen legacy engine's module
/// dependencies into their dependency graph.
final class CivilOccurrenceMaterializationAdapter
    implements CivilOccurrenceMaterialization {
  const CivilOccurrenceMaterializationAdapter();

  static const LegacyAvailabilityGrammar _grammar = LegacyAvailabilityGrammar();
  static const OccurrenceMaterializer _materializer = OccurrenceMaterializer();

  @override
  List<CivilSelection> materializeMonth({
    required Map<String, List<String>> persistedAvailability,
    required String expertTimezone,
    required int durationMinutes,
    required int year,
    required int month,
  }) {
    return _materialize(
      persistedAvailability: persistedAvailability,
      expertTimezone: expertTimezone,
      durationMinutes: durationMinutes,
      start: CivilDate(year: year, month: month, day: 1),
      end: CivilDate(
        year: year,
        month: month,
        day: CivilDateTime.daysInMonth(year: year, month: month),
      ),
    );
  }

  @override
  List<CivilSelection> materializeDay({
    required Map<String, List<String>> persistedAvailability,
    required String expertTimezone,
    required int durationMinutes,
    required int year,
    required int month,
    required int day,
  }) {
    final date = CivilDate(year: year, month: month, day: day);
    return _materialize(
      persistedAvailability: persistedAvailability,
      expertTimezone: expertTimezone,
      durationMinutes: durationMinutes,
      start: date,
      end: date,
    );
  }

  List<CivilSelection> _materialize({
    required Map<String, List<String>> persistedAvailability,
    required String expertTimezone,
    required int durationMinutes,
    required CivilDate start,
    required CivilDate end,
  }) {
    _requireAuthoritativeTimezone(expertTimezone);

    final RecurringAvailability availability;
    try {
      availability = _grammar.parseRecurringAvailability(persistedAvailability);
    } on LegacyAvailabilityGrammarException catch (exception) {
      throw SelectableOccurrenceMalformedAvailabilityFailure(cause: exception);
    }

    final occurrences = _materializer.materialize(
      availability: availability,
      range: CivilDateRange(start: start, end: end),
      durationMinutes: durationMinutes,
    );

    return List.unmodifiable(
      occurrences.map(
        (occurrence) => CivilSelection(
          year: occurrence.start.year,
          month: occurrence.start.month,
          day: occurrence.start.day,
          hour: occurrence.start.hour,
          minute: occurrence.start.minute,
          durationMinutes: occurrence.durationMinutes,
        ),
      ),
    );
  }

  /// AD-022 Clarification A: the modern path requires an authoritative named
  /// timezone identity. A malformed identity fails closed; no fallback to
  /// UTC, device, country, server or a hardcoded launch-market zone.
  void _requireAuthoritativeTimezone(String identity) {
    try {
      TimezoneId(identity);
    } on ArgumentError {
      throw const SelectableOccurrenceTimezoneUnavailableFailure();
    }
  }
}
