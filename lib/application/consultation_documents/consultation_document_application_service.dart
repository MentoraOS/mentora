import '../../domain/consultation_documents/consultation_shared_document.dart';
import '../authentication/authentication_session.dart';
import 'consultation_document_failure.dart';

/// Uploads and lists shared consultation documents for the session user.
///
/// Access is participant-only: the repository verifies the session user is
/// the booking's client or expert, so foreign users and missing bookings
/// fail closed. Plain upload/list/open — no OCR, previews or versioning.
final class ConsultationDocumentApplicationService {
  const ConsultationDocumentApplicationService({
    required AuthenticationSession session,
    required ConsultationSharedDocumentRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final ConsultationSharedDocumentRepository _repository;

  Future<void> upload({
    required String bookingId,
    required String fileName,
    required List<int> bytes,
  }) async {
    final userId = _requireUserId();

    if (fileName.trim().isEmpty || bytes.isEmpty) {
      throw const ConsultationDocumentInvalidFailure();
    }

    try {
      await _repository.upload(
        bookingId: bookingId,
        userId: userId,
        fileName: fileName.trim(),
        bytes: bytes,
      );
    } on ConsultationDocumentBookingNotFoundException {
      throw const ConsultationDocumentBookingNotFoundFailure();
    } on ConsultationDocumentRepositoryException catch (error) {
      throw ConsultationDocumentRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationDocumentRepositoryFailure(cause: error);
    }
  }

  Future<List<ConsultationSharedDocument>> listByBookingId(
    String bookingId,
  ) async {
    final userId = _requireUserId();

    try {
      return await _repository.listByBookingId(
        bookingId: bookingId,
        userId: userId,
      );
    } on ConsultationDocumentBookingNotFoundException {
      throw const ConsultationDocumentBookingNotFoundFailure();
    } on ConsultationDocumentRepositoryException catch (error) {
      throw ConsultationDocumentRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationDocumentRepositoryFailure(cause: error);
    }
  }

  String _requireUserId() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const ConsultationDocumentUnauthenticatedFailure();
    }
    return userId;
  }
}
