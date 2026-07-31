/// A concrete period during which an expert is not schedulable.
///
/// AD-020: the interval is half-open `[start, end)`.
class BlockedPeriod {
  final DateTime start;

  final DateTime end;

  final String reason;

  const BlockedPeriod({
    required this.start,
    required this.end,
    required this.reason,
  });

  /// Half-open `[start, end)` membership: [start] is contained, [end] is not.
  bool contains(DateTime value) {
    return !value.isBefore(start) && value.isBefore(end);
  }

  /// Canonical overlap rule (AD-020): `a.start < b.end && a.end > b.start`.
  ///
  /// Boundary contact alone is not conflict, so a period ending exactly when
  /// another begins does not overlap it.
  bool overlaps(DateTime otherStart, DateTime otherEnd) {
    return start.isBefore(otherEnd) && end.isAfter(otherStart);
  }
}
