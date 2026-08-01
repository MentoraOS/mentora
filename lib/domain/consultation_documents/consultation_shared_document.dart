/// One shared consultation file: upload, list, open. Nothing else.
final class ConsultationSharedDocument {
  final String bookingId;
  final String uploadedBy;

  /// `client` or `expert` — which side of the reservation shared the file.
  final String uploaderRole;
  final String fileName;
  final int fileSize;
  final String fileUrl;

  const ConsultationSharedDocument({
    required this.bookingId,
    required this.uploadedBy,
    required this.uploaderRole,
    required this.fileName,
    required this.fileSize,
    required this.fileUrl,
  });
}

/// Port for sharing documents on a reservation.
///
/// Every operation is guarded by the reservation participants: only the
/// booking's client and expert may upload or list, anyone else — and a
/// missing booking — fails closed as not-found. Nothing is invented.
abstract interface class ConsultationSharedDocumentRepository {
  Future<void> upload({
    required String bookingId,
    required String userId,
    required String fileName,
    required List<int> bytes,
  });

  Future<List<ConsultationSharedDocument>> listByBookingId({
    required String bookingId,
    required String userId,
  });
}

final class ConsultationDocumentBookingNotFoundException implements Exception {
  const ConsultationDocumentBookingNotFoundException();
}

final class ConsultationDocumentRepositoryException implements Exception {
  const ConsultationDocumentRepositoryException({required this.cause});

  final Object cause;
}
