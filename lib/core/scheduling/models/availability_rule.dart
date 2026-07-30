class AvailabilityRule {
  final Duration consultationDuration;

  final Duration breakBetweenMeetings;

  final int maximumBookingsPerDay;

  final Duration minimumNotice;

  final Duration maximumAdvanceBooking;

  const AvailabilityRule({
    required this.consultationDuration,
    required this.breakBetweenMeetings,
    required this.maximumBookingsPerDay,
    required this.minimumNotice,
    required this.maximumAdvanceBooking,
  });
}
