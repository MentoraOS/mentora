/// Port for the Booking-owned completion transition.
///
/// Officially closes a consultation: only a confirmed (or legacy paid)
/// reservation may become completed, the transition records `completedAt`,
/// and every other reservation fact — temporal snapshot, commercial
/// snapshot, history — is kept untouched.
abstract interface class ConsultationCompletionRepository {
  /// Completes the consultation on behalf of one of its participants.
  ///
  /// Throws [ConsultationCompletionNotFoundException] when no such booking
  /// involves [userId], and [ConsultationCompletionStateException] when the
  /// reservation is not in a completable state.
  Future<void> complete({required String bookingId, required String userId});
}

final class ConsultationCompletionNotFoundException implements Exception {
  const ConsultationCompletionNotFoundException();
}

final class ConsultationCompletionStateException implements Exception {
  const ConsultationCompletionStateException({required this.currentStatus});

  final String currentStatus;
}

final class ConsultationCompletionRepositoryException implements Exception {
  const ConsultationCompletionRepositoryException({required this.cause});

  final Object cause;
}
