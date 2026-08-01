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
///
/// AD-022 C3 adds the canonical reservation occurrence snapshot (decisions
/// 1, 3 and 6): [startUtc], [endUtc] and [expertTimezone] are the temporal
/// truth accepted at creation, interpreted by Scheduling. They are immutable:
/// later Catalog, availability, offer or device changes never reinterpret an
/// existing reservation. Booking stores the accepted result and never
/// performs timezone interpretation itself.
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
    required DateTime startUtc,
    required DateTime endUtc,
    required String expertTimezone,
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

    _requireNonBlank(expertTimezone, 'expertTimezone');
    if (!startUtc.isUtc) {
      throw ArgumentError.value(startUtc, 'startUtc', 'must be a UTC instant');
    }
    if (!endUtc.isUtc) {
      throw ArgumentError.value(endUtc, 'endUtc', 'must be a UTC instant');
    }
    if (!endUtc.isAfter(startUtc)) {
      throw ArgumentError.value(endUtc, 'endUtc', 'must be after startUtc');
    }
    if (endUtc.difference(startUtc) != Duration(minutes: durationMinutes)) {
      throw ArgumentError.value(
        endUtc,
        'endUtc',
        'must equal startUtc plus the authoritative offer duration',
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
      startUtc: startUtc,
      endUtc: endUtc,
      expertTimezone: expertTimezone,
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
    required this.startUtc,
    required this.endUtc,
    required this.expertTimezone,
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

  /// Canonical reservation occurrence snapshot (AD-022 C3).
  final DateTime startUtc;
  final DateTime endUtc;

  /// The named timezone identity used for interpretation, preserved
  /// verbatim. Never replaced by `UTC` or an offset, even when the current
  /// offset is identical: identity and offset are distinct concepts.
  final String expertTimezone;

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
            other.currency == currency &&
            other.startUtc == startUtc &&
            other.endUtc == endUtc &&
            other.expertTimezone == expertTimezone;
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
    startUtc,
    endUtc,
    expertTimezone,
  );
}

void _requireNonBlank(String value, String name) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, name, 'must not be empty');
  }
}
