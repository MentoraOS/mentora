import '../../domain/consultation_notes/consultation_private_notes_repository.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import 'consultation_private_notes_failure.dart';

/// Writes and reads the expert's private consultation notes.
///
/// Strictly expert-only: a client session fails closed before any read or
/// write, so note content can never leak to the client side. Plain save and
/// read — no versions, drafts, autosave or AI.
final class ConsultationPrivateNotesApplicationService {
  const ConsultationPrivateNotesApplicationService({
    required AuthenticationSession session,
    required ConsultationPrivateNotesRepository repository,
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final ConsultationPrivateNotesRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

  Future<void> save({required String bookingId, required String notes}) async {
    final expertId = _requireExpertId();

    if (notes.trim().isEmpty) {
      throw const ConsultationPrivateNotesInvalidFailure();
    }

    try {
      await _repository.save(
        bookingId: bookingId,
        expertId: expertId,
        notes: notes.trim(),
      );
    } on ConsultationPrivateNotesBookingNotFoundException {
      throw const ConsultationPrivateNotesBookingNotFoundFailure();
    } on ConsultationPrivateNotesRepositoryException catch (error) {
      throw ConsultationPrivateNotesRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationPrivateNotesRepositoryFailure(cause: error);
    }

    // Fact only, NEVER the note content: the memory is participant-
    // readable while private notes are strictly expert-only.
    await _recordFact(bookingId, MemoryEntryType.privateNote, const {});
  }

  Future<String?> loadByBookingId(String bookingId) async {
    final expertId = _requireExpertId();

    try {
      return await _repository.loadByBookingId(
        bookingId: bookingId,
        expertId: expertId,
      );
    } on ConsultationPrivateNotesRepositoryException catch (error) {
      throw ConsultationPrivateNotesRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationPrivateNotesRepositoryFailure(cause: error);
    }
  }

  String _requireExpertId() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const ConsultationPrivateNotesUnauthenticatedFailure();
    }
    if (!_session.isExpert) {
      throw const ConsultationPrivateNotesForbiddenFailure();
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
