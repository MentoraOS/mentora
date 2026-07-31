import 'civil_date_time.dart';

/// A candidate civil occurrence that may legitimately be offered.
///
/// AD-022 Clarification C decisions 10 and 11: a selectable occurrence is
/// offerability truth only. It is NOT proof of atomic reservability, it is not
/// Booking truth, and it is distinct from the accepted reservation occurrence
/// that carries UTC boundaries. UTC interpretation happens later, when a
/// selection is accepted toward Booking.
///
/// The start is a structured civil value. [durationMinutes] is consumed from
/// the client's selected offer (AD-021); Scheduling does not own it and never
/// derives it from availability ticks.
final class SelectableOccurrence {
  final CivilDateTime start;
  final int durationMinutes;

  factory SelectableOccurrence({
    required CivilDateTime start,
    required int durationMinutes,
  }) {
    if (durationMinutes <= 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'must be strictly positive',
      );
    }

    return SelectableOccurrence._(
      start: start,
      durationMinutes: durationMinutes,
    );
  }

  const SelectableOccurrence._({
    required this.start,
    required this.durationMinutes,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SelectableOccurrence &&
            other.start == start &&
            other.durationMinutes == durationMinutes;
  }

  @override
  int get hashCode => Object.hash(start, durationMinutes);

  @override
  String toString() => 'SelectableOccurrence($start, ${durationMinutes}m)';
}
