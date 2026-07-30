/// The immutable facts required to persist an initial Booking.
///
/// ARCH-008 deliberately preserves the legacy date, time, amount, duration,
/// status, and payment-status representations. It does not interpret them as
/// Scheduling, Payment, or lifecycle policy.
final class BookingCreation {
  factory BookingCreation({
    required String clientId,
    required String expertId,
    required String expertName,
    required String bookingDate,
    required String bookingTime,
    required String agoraChannel,
    required String clientNeed,
    required String aiSummary,
  }) {
    _requireNonBlank(clientId, 'clientId');
    _requireNonBlank(expertId, 'expertId');
    _requireNonBlank(expertName, 'expertName');
    _requireNonBlank(bookingDate, 'bookingDate');
    _requireNonBlank(bookingTime, 'bookingTime');
    _requireNonBlank(agoraChannel, 'agoraChannel');

    return BookingCreation._(
      clientId: clientId,
      expertId: expertId,
      expertName: expertName,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      agoraChannel: agoraChannel,
      clientNeed: clientNeed,
      aiSummary: aiSummary,
    );
  }

  const BookingCreation._({
    required this.clientId,
    required this.expertId,
    required this.expertName,
    required this.bookingDate,
    required this.bookingTime,
    required this.agoraChannel,
    required this.clientNeed,
    required this.aiSummary,
  });

  static const int durationMinutes = 30;
  static const int amount = 15000;
  static const String paymentStatus = 'pending';
  static const String initialStatus = 'pending_payment';

  final String clientId;
  final String expertId;
  final String expertName;
  final String bookingDate;
  final String bookingTime;
  final String agoraChannel;
  final String clientNeed;
  final String aiSummary;

  String get slotIdentity => '$expertId|$bookingDate|$bookingTime';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BookingCreation &&
            other.clientId == clientId &&
            other.expertId == expertId &&
            other.expertName == expertName &&
            other.bookingDate == bookingDate &&
            other.bookingTime == bookingTime &&
            other.agoraChannel == agoraChannel &&
            other.clientNeed == clientNeed &&
            other.aiSummary == aiSummary;
  }

  @override
  int get hashCode => Object.hash(
    clientId,
    expertId,
    expertName,
    bookingDate,
    bookingTime,
    agoraChannel,
    clientNeed,
    aiSummary,
  );
}

void _requireNonBlank(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
