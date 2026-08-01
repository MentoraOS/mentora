/// The client's consultation preparation brief: a simple persistent
/// snapshot, one per booking. No versioning, no drafts, no workflow.
final class ConsultationBrief {
  final String objective;
  final String description;
  final String questions;
  final String expectedOutcome;

  factory ConsultationBrief({
    required String objective,
    required String description,
    required String questions,
    required String expectedOutcome,
  }) {
    if (objective.trim().isEmpty) {
      throw ArgumentError.value(objective, 'objective', 'must not be empty');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'must not be empty',
      );
    }

    return ConsultationBrief._(
      objective: objective.trim(),
      description: description.trim(),
      questions: questions.trim(),
      expectedOutcome: expectedOutcome.trim(),
    );
  }

  const ConsultationBrief._({
    required this.objective,
    required this.description,
    required this.questions,
    required this.expectedOutcome,
  });
}

/// Port persisting and reading the brief. The brief is keyed by the booking
/// identity — that key IS the Booking reference, so the booking engine
/// itself is untouched.
abstract interface class ConsultationBriefRepository {
  /// Persists the client's brief for their booking.
  ///
  /// Throws [ConsultationBriefBookingNotFoundException] when no such booking
  /// exists for [clientId] (fail closed: a brief never attaches to nothing).
  Future<void> save({
    required String bookingId,
    required String clientId,
    required ConsultationBrief brief,
  });

  /// The brief for [bookingId], or `null` when none was filled in.
  Future<ConsultationBrief?> loadByBookingId(String bookingId);
}

final class ConsultationBriefBookingNotFoundException implements Exception {
  const ConsultationBriefBookingNotFoundException();
}

final class ConsultationBriefRepositoryException implements Exception {
  const ConsultationBriefRepositoryException({required this.cause});

  final Object cause;
}
