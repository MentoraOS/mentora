/// Port for the Booking-owned confirmation transition (AD-022 decision 12).
///
/// Booking CONSUMES the payment outcome through this boundary; Payment never
/// owns reservation state. Only a confirmed payment outcome reaches
/// [confirmPaid] — ambiguity, timeouts and unknown outcomes never do
/// (AD-022 decision 11), so this port has no failure-release operation yet.
abstract interface class BookingConfirmationRepository {
  /// Transitions the client's `pending_payment` reservation to confirmed.
  ///
  /// Throws [BookingConfirmationNotFoundException] when no such booking
  /// exists for [clientId], and [BookingConfirmationStateException] when the
  /// reservation is not awaiting payment.
  Future<void> confirmPaid({
    required String bookingId,
    required String clientId,
  });
}

final class BookingConfirmationNotFoundException implements Exception {
  const BookingConfirmationNotFoundException();
}

final class BookingConfirmationStateException implements Exception {
  const BookingConfirmationStateException({required this.currentStatus});

  final String currentStatus;
}

final class BookingConfirmationRepositoryException implements Exception {
  const BookingConfirmationRepositoryException({required this.cause});

  final Object cause;
}
