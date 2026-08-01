import 'consultation_review.dart';

/// Port for consultation reviews: submit one review per completed
/// reservation, and read reviews back — nothing else.
abstract interface class ConsultationReviewRepository {
  /// Persists the client's single review of their completed reservation.
  ///
  /// The authoritative expert identity is taken from the reservation itself.
  /// Throws [ConsultationReviewBookingNotFoundException] when no such booking
  /// belongs to [clientId], [ConsultationReviewStateException] when the
  /// reservation is not completed, and
  /// [ConsultationReviewAlreadyExistsException] on a second submission.
  Future<void> submit({
    required String bookingId,
    required String clientId,
    required int rating,
    required String comment,
  });

  /// The reservation's review, or null when none was published.
  Future<ConsultationReview?> findByBookingId(String bookingId);

  /// Every review published for this expert.
  Future<List<ConsultationReview>> listByExpertId(String expertId);
}

final class ConsultationReviewBookingNotFoundException implements Exception {
  const ConsultationReviewBookingNotFoundException();
}

final class ConsultationReviewStateException implements Exception {
  const ConsultationReviewStateException({required this.currentStatus});

  final String currentStatus;
}

final class ConsultationReviewAlreadyExistsException implements Exception {
  const ConsultationReviewAlreadyExistsException();
}

final class ConsultationReviewRepositoryException implements Exception {
  const ConsultationReviewRepositoryException({required this.cause});

  final Object cause;
}
