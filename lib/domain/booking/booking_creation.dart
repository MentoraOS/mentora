/// The immutable facts required to persist an initial Booking.
///
/// ARCH-008 deliberately preserves the legacy date, time, status and
/// payment-status representations. It does not interpret them as Scheduling,
/// Payment, or lifecycle policy.
///
/// ARCH-009B adds the reservation-level commercial snapshot required by
/// AD-021 decision 7. The snapshot is copied by value from the selected
/// Consultation Offer, so a later Expert Catalog edit cannot mutate an
/// existing Booking's commercial truth. There is no hardcoded duration or
/// amount default: missing commercial truth is an explicit failure.
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
    required String offerId,
    required int durationMinutes,
    required int amountMinor,
    required String currency,
  }) {
    _requireNonBlank(clientId, 'clientId');
    _requireNonBlank(expertId, 'expertId');
    _requireNonBlank(expertName, 'expertName');
    _requireNonBlank(bookingDate, 'bookingDate');
    _requireNonBlank(bookingTime, 'bookingTime');
    _requireNonBlank(agoraChannel, 'agoraChannel');
    _requireNonBlank(offerId, 'offerId');
    _requireNonBlank(currency, 'currency');

    if (durationMinutes <= 0) {
      throw ArgumentError.value(
        durationMinutes,
        'durationMinutes',
        'must be strictly positive',
      );
    }
    if (amountMinor < 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'must not be negative',
      );
    }

    return BookingCreation._(
      clientId: clientId,
      expertId: expertId,
      expertName: expertName,
      bookingDate: bookingDate,
      bookingTime: bookingTime,
      agoraChannel: agoraChannel,
      clientNeed: clientNeed,
      aiSummary: aiSummary,
      offerId: offerId,
      durationMinutes: durationMinutes,
      amountMinor: amountMinor,
      currency: currency,
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
    required this.offerId,
    required this.durationMinutes,
    required this.amountMinor,
    required this.currency,
  });

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

  /// Commercial snapshot copied from the selected Consultation Offer.
  final String offerId;
  final int durationMinutes;
  final int amountMinor;
  final String currency;

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
            other.aiSummary == aiSummary &&
            other.offerId == offerId &&
            other.durationMinutes == durationMinutes &&
            other.amountMinor == amountMinor &&
            other.currency == currency;
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
    offerId,
    durationMinutes,
    amountMinor,
    currency,
  );
}

void _requireNonBlank(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
