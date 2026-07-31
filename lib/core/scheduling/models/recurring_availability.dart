import 'recurring_start_tick.dart';

/// A validated set of recurring weekly candidate starts.
///
/// AD-022 Clarification C: this is the canonical Scheduling representation of
/// an expert's recurring availability rule. It answers exactly one question —
/// which weekday/time-of-day starts the expert has declared — and nothing
/// else. It owns no consultation length, no calendar range, no zone identity,
/// no expert identity and no occupancy or conflict state.
///
/// Duplicate identical ticks collapse: declaring Monday 09:00 twice is the
/// same availability as declaring it once. Empty availability is valid — an
/// expert who has declared no start simply has none.
final class RecurringAvailability {
  /// The declared ticks, deduplicated. Unmodifiable.
  final Set<RecurringStartTick> ticks;

  RecurringAvailability({required Iterable<RecurringStartTick> ticks})
    : ticks = Set.unmodifiable(ticks);

  bool get isEmpty => ticks.isEmpty;

  int get length => ticks.length;

  /// The ticks in deterministic order: weekday first, then time of day.
  List<RecurringStartTick> get sortedTicks {
    return List.unmodifiable(ticks.toList()..sort());
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is RecurringAvailability &&
            other.ticks.length == ticks.length &&
            other.ticks.containsAll(ticks);
  }

  @override
  int get hashCode => Object.hashAllUnordered(ticks);

  @override
  String toString() => 'RecurringAvailability($sortedTicks)';
}
