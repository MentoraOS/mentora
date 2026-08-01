sealed class ConsultationBriefFailure implements Exception {
  const ConsultationBriefFailure();
}

final class ConsultationBriefUnauthenticatedFailure
    extends ConsultationBriefFailure {
  const ConsultationBriefUnauthenticatedFailure();
}

/// A required field is missing; nothing is persisted.
final class ConsultationBriefInvalidFailure extends ConsultationBriefFailure {
  const ConsultationBriefInvalidFailure({required this.cause});

  final Object cause;
}

/// No booking with this identity exists for this client; the brief never
/// attaches to nothing.
final class ConsultationBriefBookingNotFoundFailure
    extends ConsultationBriefFailure {
  const ConsultationBriefBookingNotFoundFailure();
}

final class ConsultationBriefRepositoryFailure
    extends ConsultationBriefFailure {
  const ConsultationBriefRepositoryFailure({required this.cause});

  final Object cause;
}
