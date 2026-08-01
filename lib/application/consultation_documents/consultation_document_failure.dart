sealed class ConsultationDocumentFailure implements Exception {
  const ConsultationDocumentFailure();
}

final class ConsultationDocumentUnauthenticatedFailure
    extends ConsultationDocumentFailure {
  const ConsultationDocumentUnauthenticatedFailure();
}

/// Empty file name or content; nothing is uploaded.
final class ConsultationDocumentInvalidFailure
    extends ConsultationDocumentFailure {
  const ConsultationDocumentInvalidFailure();
}

/// No booking with this identity involves this user — foreign users and
/// missing bookings fail closed identically, without leaking existence.
final class ConsultationDocumentBookingNotFoundFailure
    extends ConsultationDocumentFailure {
  const ConsultationDocumentBookingNotFoundFailure();
}

final class ConsultationDocumentRepositoryFailure
    extends ConsultationDocumentFailure {
  const ConsultationDocumentRepositoryFailure({required this.cause});

  final Object cause;
}
