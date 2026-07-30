sealed class ExpertAvailabilityFailure implements Exception {
  const ExpertAvailabilityFailure();
}

final class ExpertAvailabilityUnauthenticatedFailure
    extends ExpertAvailabilityFailure {
  const ExpertAvailabilityUnauthenticatedFailure();
}

final class ExpertAvailabilityForbiddenFailure
    extends ExpertAvailabilityFailure {
  const ExpertAvailabilityForbiddenFailure();
}

final class ExpertAvailabilityMalformedDataFailure
    extends ExpertAvailabilityFailure {
  const ExpertAvailabilityMalformedDataFailure({required this.cause});

  final Object cause;
}

final class ExpertAvailabilityRepositoryFailure
    extends ExpertAvailabilityFailure {
  const ExpertAvailabilityRepositoryFailure({required this.cause});

  final Object cause;
}

final class ExpertAvailabilityConcurrencyConflictFailure
    extends ExpertAvailabilityFailure {
  const ExpertAvailabilityConcurrencyConflictFailure({
    required this.expectedRevision,
    required this.actualRevision,
  });

  final String? expectedRevision;
  final String? actualRevision;
}
