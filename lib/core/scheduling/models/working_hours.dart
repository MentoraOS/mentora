enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

/// A recurring expert-local availability range.
///
/// AD-020 establishes this as the canonical representation of recurring
/// availability. No synonymous domain type may be introduced.
///
/// Temporal reasoning is half-open `[start, end)`, so [end] must be strictly
/// after [start]. Several non-overlapping ranges may exist for the same
/// weekday, for example Monday 09:00–12:00 and Monday 14:00–17:00.
///
/// [start] and [end] are measured from the start of the expert-local day. They
/// are civil time, not instants.
class WorkingHours {
  final WeekDay day;

  final Duration start;

  final Duration end;

  final bool enabled;

  factory WorkingHours({
    required WeekDay day,
    required Duration start,
    required Duration end,
    bool enabled = true,
  }) {
    if (end <= start) {
      throw ArgumentError.value(end, 'end', 'must be strictly after start');
    }

    return WorkingHours._(day: day, start: start, end: end, enabled: enabled);
  }

  const WorkingHours._({
    required this.day,
    required this.start,
    required this.end,
    required this.enabled,
  });

  Duration get totalDuration => end - start;
}
