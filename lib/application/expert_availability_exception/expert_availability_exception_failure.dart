sealed class ExpertAvailabilityExceptionFailure implements Exception {
  const ExpertAvailabilityExceptionFailure();
}

final class ExpertAvailabilityExceptionUnauthenticatedFailure
    extends ExpertAvailabilityExceptionFailure {
  const ExpertAvailabilityExceptionUnauthenticatedFailure();
}

final class ExpertAvailabilityExceptionForbiddenFailure
    extends ExpertAvailabilityExceptionFailure {
  const ExpertAvailabilityExceptionForbiddenFailure();
}

/// Malformed dates, an inverted window or a blank reason; nothing persisted.
final class ExpertAvailabilityExceptionInvalidFailure
    extends ExpertAvailabilityExceptionFailure {
  const ExpertAvailabilityExceptionInvalidFailure({required this.cause});

  final Object cause;
}

final class ExpertAvailabilityExceptionNotFoundFailure
    extends ExpertAvailabilityExceptionFailure {
  const ExpertAvailabilityExceptionNotFoundFailure();
}

final class ExpertAvailabilityExceptionRepositoryFailure
    extends ExpertAvailabilityExceptionFailure {
  const ExpertAvailabilityExceptionRepositoryFailure({required this.cause});

  final Object cause;
}
