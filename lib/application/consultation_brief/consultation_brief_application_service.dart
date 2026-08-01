import '../../domain/consultation_brief/consultation_brief.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import 'consultation_brief_failure.dart';

/// Saves and reads the client's consultation brief.
///
/// A plain persistent snapshot keyed by the booking identity: no AI, no
/// summary, no workflow. Saving fails closed when the booking does not exist
/// for the session client.
final class ConsultationBriefApplicationService {
  const ConsultationBriefApplicationService({
    required AuthenticationSession session,
    required ConsultationBriefRepository repository,
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final ConsultationBriefRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

  Future<void> save({
    required String bookingId,
    required String objective,
    required String description,
    required String questions,
    required String expectedOutcome,
  }) async {
    final clientId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || clientId == null || clientId.isEmpty) {
      throw const ConsultationBriefUnauthenticatedFailure();
    }

    final ConsultationBrief brief;
    try {
      brief = ConsultationBrief(
        objective: objective,
        description: description,
        questions: questions,
        expectedOutcome: expectedOutcome,
      );
    } on ArgumentError catch (error) {
      throw ConsultationBriefInvalidFailure(cause: error);
    }

    try {
      await _repository.save(
        bookingId: bookingId,
        clientId: clientId,
        brief: brief,
      );
    } on ConsultationBriefBookingNotFoundException {
      throw const ConsultationBriefBookingNotFoundFailure();
    } on ConsultationBriefRepositoryException catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error);
    }

    await _recordFact(bookingId, MemoryEntryType.consultationBrief, {
      'objective': objective,
      'description': description,
      'questions': questions,
      'expectedOutcome': expectedOutcome,
    });
  }

  Future<ConsultationBrief?> loadByBookingId(String bookingId) async {
    try {
      return await _repository.loadByBookingId(bookingId);
    } on ConsultationBriefRepositoryException catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConsultationBriefRepositoryFailure(cause: error);
    }
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
