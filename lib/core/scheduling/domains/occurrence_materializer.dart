import '../models/civil_date_range.dart';
import '../models/civil_date_time.dart';
import '../models/civil_time_of_day.dart';
import '../models/recurring_availability.dart';
import '../models/selectable_occurrence.dart';
import '../models/working_hours.dart';

/// Materializes recurring start ticks into selectable civil occurrences.
///
/// AD-022 Clarification C decision 9: Scheduling owns this transformation.
/// For every civil date in the explicit range, each recurring tick whose
/// weekday matches becomes one candidate occurrence carrying the structured
/// civil start and the offer-supplied length.
///
/// A tick remains a START. No end is inferred from a neighbouring tick, from
/// an end-of-day rule or from any default: a late tick with a long offer
/// simply extends past the last declared tick, which is the expert's own
/// declaration.
///
/// The materializer is pure. It reads no clock, no persistence, no catalog
/// and no occupancy, interprets no zone, produces no UTC boundary and detects
/// no conflict. The range is an explicit input, never a policy it owns.
final class OccurrenceMaterializer {
  const OccurrenceMaterializer();

  /// Deterministically materializes [availability] over [range].
  ///
  /// Results are ordered by date, then time of day. [durationMinutes] comes
  /// from the selected offer and must be strictly positive.
  List<SelectableOccurrence> materialize({
    required RecurringAvailability availability,
    required CivilDateRange range,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'must be strictly positive',
      );
    }
    if (availability.isEmpty) {
      return const [];
    }

    final ticksByWeekday = <WeekDay, List<CivilTimeOfDay>>{};
    for (final tick in availability.sortedTicks) {
      ticksByWeekday.putIfAbsent(tick.weekday, () => []).add(tick.timeOfDay);
    }

    final occurrences = <SelectableOccurrence>[];
    for (final date in range.days) {
      final times = ticksByWeekday[date.weekday];
      if (times == null) continue;
      for (final time in times) {
        occurrences.add(
          SelectableOccurrence(
            start: CivilDateTime(
              year: date.year,
              month: date.month,
              day: date.day,
              hour: time.hour,
              minute: time.minute,
            ),
            durationMinutes: durationMinutes,
          ),
        );
      }
    }

    return List.unmodifiable(occurrences);
  }
}
