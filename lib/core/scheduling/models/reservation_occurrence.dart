import '../ports/timezone_resolver.dart';

/// A concrete occurrence in time, produced by Scheduling interpretation.
///
/// AD-022: `startUtc` and `endUtc` are the canonical temporal authority, and
/// [expertTimezone] preserves the exact named identity used to interpret the
/// expert-local civil values. The interval is half-open `[startUtc, endUtc)`
/// as defined by AD-020 decision 5; this type carries the boundaries and does
/// not compare them.
///
/// This is Scheduling output only. It is not a Booking aggregate, not a Booking
/// entity, not a persistence document, not an occupancy record, not a conflict
/// guard and not a payment object. Booking snapshots its values in a later
/// authorized wave.
final class ReservationOccurrence {
  final DateTime startUtc;
  final DateTime endUtc;
  final TimezoneId expertTimezone;

  factory ReservationOccurrence({
    required DateTime startUtc,
    required DateTime endUtc,
    required TimezoneId expertTimezone,
  }) {
    if (!startUtc.isUtc) {
      throw ArgumentError.value(startUtc, 'startUtc', 'must be a UTC instant');
    }
    if (!endUtc.isUtc) {
      throw ArgumentError.value(endUtc, 'endUtc', 'must be a UTC instant');
    }
    if (!endUtc.isAfter(startUtc)) {
      throw ArgumentError.value(
        endUtc,
        'endUtc',
        'must be strictly after startUtc',
      );
    }

    return ReservationOccurrence._(
      startUtc: startUtc,
      endUtc: endUtc,
      expertTimezone: expertTimezone,
    );
  }

  const ReservationOccurrence._({
    required this.startUtc,
    required this.endUtc,
    required this.expertTimezone,
  });

  /// The temporal length of the occurrence.
  Duration get duration => endUtc.difference(startUtc);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReservationOccurrence &&
            other.startUtc == startUtc &&
            other.endUtc == endUtc &&
            other.expertTimezone == expertTimezone;
  }

  @override
  int get hashCode => Object.hash(startUtc, endUtc, expertTimezone);

  @override
  String toString() {
    return 'ReservationOccurrence([${startUtc.toIso8601String()}, '
        '${endUtc.toIso8601String()}) $expertTimezone)';
  }
}
