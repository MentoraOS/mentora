sealed class ConsultationCompletionFailure implements Exception {
  const ConsultationCompletionFailure();
}

final class ConsultationCompletionUnauthenticatedFailure
    extends ConsultationCompletionFailure {
  const ConsultationCompletionUnauthenticatedFailure();
}

/// No reservation with this identity involves this user.
final class ConsultationCompletionNotFoundFailure
    extends ConsultationCompletionFailure {
  const ConsultationCompletionNotFoundFailure();
}

/// Only a confirmed (or legacy paid) reservation can be completed.
final class ConsultationCompletionInvalidStateFailure
    extends ConsultationCompletionFailure {
  const ConsultationCompletionInvalidStateFailure({
    required this.currentStatus,
  });

  final String currentStatus;
}

final class ConsultationCompletionRepositoryFailure
    extends ConsultationCompletionFailure {
  const ConsultationCompletionRepositoryFailure({required this.cause});

  final Object cause;
}
