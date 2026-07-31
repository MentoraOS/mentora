/// Scheduling policy applied when generating candidate consultation slots.
///
/// AD-020 distinguishes three temporal concepts that are not interchangeable:
/// the availability range (see `WorkingHours`), the slot-start granularity
/// ([slotGranularity]) and the consultation duration ([consultationDuration]).
class AvailabilityRule {
  /// Temporal space a consultation occupies, as `[start, start + duration)`.
  final Duration consultationDuration;

  /// Spacing between candidate starts.
  ///
  /// Candidate generation advances by this value, never by
  /// [consultationDuration] and never by [breakBetweenMeetings].
  final Duration slotGranularity;

  /// Post-consultation scheduling buffer.
  ///
  /// AD-020: a consultation occupies `[start, end)` while its protected
  /// scheduling interval is `[start, end + breakBetweenMeetings)`. The buffer
  /// is scheduling protection, not billable consultation time. It does not
  /// define granularity and does not change duration.
  ///
  /// Enforcement requires Booking occupancy information and is deferred.
  final Duration breakBetweenMeetings;

  /// DEFERRED — not canonicalized (AD-020). Declared but not enforced.
  final int maximumBookingsPerDay;

  /// DEFERRED — not canonicalized (AD-020). Declared but not enforced.
  final Duration minimumNotice;

  /// DEFERRED — not canonicalized (AD-020). Declared but not enforced.
  final Duration maximumAdvanceBooking;

  factory AvailabilityRule({
    required Duration consultationDuration,
    required Duration slotGranularity,
    required Duration breakBetweenMeetings,
    required int maximumBookingsPerDay,
    required Duration minimumNotice,
    required Duration maximumAdvanceBooking,
  }) {
    if (consultationDuration <= Duration.zero) {
      throw ArgumentError.value(
        consultationDuration,
        'consultationDuration',
        'must be strictly positive',
      );
    }
    if (slotGranularity <= Duration.zero) {
      throw ArgumentError.value(
        slotGranularity,
        'slotGranularity',
        'must be strictly positive',
      );
    }

    return AvailabilityRule._(
      consultationDuration: consultationDuration,
      slotGranularity: slotGranularity,
      breakBetweenMeetings: breakBetweenMeetings,
      maximumBookingsPerDay: maximumBookingsPerDay,
      minimumNotice: minimumNotice,
      maximumAdvanceBooking: maximumAdvanceBooking,
    );
  }

  const AvailabilityRule._({
    required this.consultationDuration,
    required this.slotGranularity,
    required this.breakBetweenMeetings,
    required this.maximumBookingsPerDay,
    required this.minimumNotice,
    required this.maximumAdvanceBooking,
  });
}
