/// One candidate consultation interval.
///
/// AD-020: the interval is half-open `[start, end)`.
class CalendarSlot {
  final DateTime start;

  final DateTime end;

  final bool available;

  const CalendarSlot({
    required this.start,
    required this.end,
    this.available = true,
  });

  Duration get duration => end.difference(start);

  /// Half-open `[start, end)` membership: [start] is contained, [end] is not.
  bool contains(DateTime value) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  /// Canonical overlap rule (AD-020): `a.start < b.end && a.end > b.start`.
  ///
  /// Adjacent intervals such as 09:00–10:00 and 10:00–11:00 do not overlap.
  bool overlaps(DateTime otherStart, DateTime otherEnd) {
    return start.isBefore(otherEnd) && end.isAfter(otherStart);
  }

  /// End of the protected scheduling interval `[start, end + buffer)`.
  ///
  /// AD-020: the consultation itself still ends at [end]. The buffer is
  /// scheduling protection during which another consultation for the same
  /// expert may not begin; it is not billable consultation time, it does not
  /// define candidate-start granularity and it does not change duration.
  ///
  /// Enforcing this buffer against occupied meetings requires Booking
  /// occupancy information and is deferred to a later Scheduling/Occupancy
  /// wave. Pure candidate generation must not fabricate occupancy.
  DateTime protectedEnd(Duration breakBetweenMeetings) {
    return end.add(breakBetweenMeetings);
  }
}
