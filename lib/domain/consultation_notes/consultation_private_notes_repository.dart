/// Port for the expert's private consultation notes.
///
/// One plain document per booking, owned by the expert alone: the client
/// never reads it, notifications never carry it, no AI ever consumes it.
/// Every operation is guarded by the expert identity — a foreign expert or a
/// missing booking fails closed and nothing is invented.
abstract interface class ConsultationPrivateNotesRepository {
  /// Persists the expert's notes for their booking (create or overwrite).
  ///
  /// Throws [ConsultationPrivateNotesBookingNotFoundException] when no such
  /// booking exists for [expertId].
  Future<void> save({
    required String bookingId,
    required String expertId,
    required String notes,
  });

  /// The expert's notes for [bookingId], or `null` when none exist or the
  /// stored notes belong to another expert.
  Future<String?> loadByBookingId({
    required String bookingId,
    required String expertId,
  });
}

final class ConsultationPrivateNotesBookingNotFoundException
    implements Exception {
  const ConsultationPrivateNotesBookingNotFoundException();
}

final class ConsultationPrivateNotesRepositoryException implements Exception {
  const ConsultationPrivateNotesRepositoryException({required this.cause});

  final Object cause;
}
