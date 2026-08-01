/// The canonical reservation temporal truth produced for a validated
/// selection (AD-022 decisions 1 and 3).
///
/// [startUtc] and [endUtc] are absolute UTC instants interpreted by
/// Scheduling from the expert-local civil selection; [expertTimezone] is the
/// named identity used for that interpretation, preserved verbatim — never
/// replaced by `UTC` or an offset, even when the offset is identical.
///
/// The value is a snapshot: Booking copies it at creation and it is never
/// reinterpreted from later Catalog, availability or offer changes.
final class ReservationTemporalSnapshot {
  final DateTime startUtc;
  final DateTime endUtc;
  final String expertTimezone;

  factory ReservationTemporalSnapshot({
    required DateTime startUtc,
    required DateTime endUtc,
    required String expertTimezone,
  }) {
    if (!startUtc.isUtc) {
      throw ArgumentError.value(startUtc, 'startUtc', 'must be UTC');
    }
    if (!endUtc.isUtc) {
      throw ArgumentError.value(endUtc, 'endUtc', 'must be UTC');
    }
    if (!endUtc.isAfter(startUtc)) {
      throw ArgumentError.value(endUtc, 'endUtc', 'must be after startUtc');
    }
    if (expertTimezone.trim().isEmpty) {
      throw ArgumentError.value(
        expertTimezone,
        'expertTimezone',
        'must not be empty',
      );
    }

    return ReservationTemporalSnapshot._(
      startUtc: startUtc,
      endUtc: endUtc,
      expertTimezone: expertTimezone,
    );
  }

  const ReservationTemporalSnapshot._({
    required this.startUtc,
    required this.endUtc,
    required this.expertTimezone,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReservationTemporalSnapshot &&
            other.startUtc == startUtc &&
            other.endUtc == endUtc &&
            other.expertTimezone == expertTimezone;
  }

  @override
  int get hashCode => Object.hash(startUtc, endUtc, expertTimezone);

  @override
  String toString() {
    return 'ReservationTemporalSnapshot($startUtc → $endUtc, $expertTimezone)';
  }
}
