import '../../domain/consultation_documents/consultation_shared_document.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
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
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final ConsultationSharedDocumentRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

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

    await _recordFact(bookingId, MemoryEntryType.sharedDocument, {
      'fileName': fileName.trim(),
      'fileSize': bytes.length,
    });
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

  /// Best-effort memory producer (ARC-MEM01): the business fact is recorded
  /// through the single memory door AFTER the operation succeeded; a memory
  /// failure never fails the business flow.
  Future<void> _recordFact(
    String bookingId,
    MemoryEntryType type,
    Map<String, Object?> payload,
  ) async {
    try {
      await _memory?.record(bookingId: bookingId, type: type, payload: payload);
    } catch (_) {
      // Best-effort by contract.
    }
  }
}
