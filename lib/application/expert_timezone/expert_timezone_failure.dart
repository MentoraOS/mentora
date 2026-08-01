sealed class ExpertTimezoneFailure implements Exception {
  const ExpertTimezoneFailure();
}

final class ExpertTimezoneUnauthenticatedFailure extends ExpertTimezoneFailure {
  const ExpertTimezoneUnauthenticatedFailure();
}

final class ExpertTimezoneForbiddenFailure extends ExpertTimezoneFailure {
  const ExpertTimezoneForbiddenFailure();
}

/// The requested identity is not one of the launch-market supported zones.
///
/// AD-022 Clarification A: no fallback and no silent substitution — an
/// unsupported declaration fails closed.
final class ExpertTimezoneUnsupportedFailure extends ExpertTimezoneFailure {
  const ExpertTimezoneUnsupportedFailure(this.timezone);

  final String timezone;
}

final class ExpertTimezoneRepositoryFailure extends ExpertTimezoneFailure {
  const ExpertTimezoneRepositoryFailure({required this.cause});

  final Object cause;
}
