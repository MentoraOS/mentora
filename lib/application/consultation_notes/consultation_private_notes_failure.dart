sealed class ConsultationPrivateNotesFailure implements Exception {
  const ConsultationPrivateNotesFailure();
}

final class ConsultationPrivateNotesUnauthenticatedFailure
    extends ConsultationPrivateNotesFailure {
  const ConsultationPrivateNotesUnauthenticatedFailure();
}

/// Private notes are expert-only: a client session never reads or writes
/// them.
final class ConsultationPrivateNotesForbiddenFailure
    extends ConsultationPrivateNotesFailure {
  const ConsultationPrivateNotesForbiddenFailure();
}

/// Empty notes are not persisted.
final class ConsultationPrivateNotesInvalidFailure
    extends ConsultationPrivateNotesFailure {
  const ConsultationPrivateNotesInvalidFailure();
}

/// No booking with this identity exists for this expert.
final class ConsultationPrivateNotesBookingNotFoundFailure
    extends ConsultationPrivateNotesFailure {
  const ConsultationPrivateNotesBookingNotFoundFailure();
}

final class ConsultationPrivateNotesRepositoryFailure
    extends ConsultationPrivateNotesFailure {
  const ConsultationPrivateNotesRepositoryFailure({required this.cause});

  final Object cause;
}
