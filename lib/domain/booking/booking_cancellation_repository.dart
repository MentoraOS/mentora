/// Port for the Booking-owned cancellation transition.
///
/// Booking owns its reservation lifecycle: cancellation verifies ownership
/// and current state before transitioning, keeps every reservation fact
/// (nothing is deleted), and records who cancelled and when. Refunds, slot
/// release and rescheduling are separate future contracts.
abstract interface class BookingCancellationRepository {
  /// Cancels the client's reservation.
  ///
  /// Throws [BookingCancellationNotFoundException] when no such booking
  /// exists for [clientId], and [BookingCancellationStateException] when the
  /// reservation is not in a cancellable state.
  Future<void> cancel({required String bookingId, required String clientId});
}

final class BookingCancellationNotFoundException implements Exception {
  const BookingCancellationNotFoundException();
}

final class BookingCancellationStateException implements Exception {
  const BookingCancellationStateException({required this.currentStatus});

  final String currentStatus;
}

final class BookingCancellationRepositoryException implements Exception {
  const BookingCancellationRepositoryException({required this.cause});

  final Object cause;
}
