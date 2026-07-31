import 'civil_date.dart';

/// An explicit, finite civil date range: the materialization range input.
///
/// AD-022 Clarification C decision 6: this range is an INPUT to Scheduling,
/// telling it which dates to materialize. It is NOT a booking horizon, not a
/// minimum-notice or maximum-advance policy, not a reservation lifetime and
/// not the current time. Scheduling never derives it from a clock.
///
/// Both endpoint dates are included: the range denotes whole civil days, not
/// instants, so AD-020's half-open instant semantics do not apply to it.
final class CivilDateRange {
  final CivilDate start;
  final CivilDate end;

  factory CivilDateRange({required CivilDate start, required CivilDate end}) {
    if (end.compareTo(start) < 0) {
      throw ArgumentError.value(end, 'end', 'must not precede start');
    }

    return CivilDateRange._(start: start, end: end);
  }

  const CivilDateRange._({required this.start, required this.end});

  /// Every civil date in the range, ascending, both endpoints included.
  List<CivilDate> get days {
    final result = <CivilDate>[];
    var cursor = DateTime.utc(start.year, start.month, start.day);
    final last = DateTime.utc(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      result.add(
        CivilDate(year: cursor.year, month: cursor.month, day: cursor.day),
      );
      cursor = cursor.add(const Duration(days: 1));
    }

    return List.unmodifiable(result);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CivilDateRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'CivilDateRange($start → $end)';
}
