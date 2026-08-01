import '../../domain/consultation_memory/consultation_memory.dart';
import '../../domain/consultation_memory/memory_repository.dart';
import '../authentication/authentication_session.dart';

/// THE single door into the consultation memory.
///
/// Session-scoped: only an authenticated participant records or reads,
/// and the repository verifies participation against the reservation.
/// It records BUSINESS FACTS only — never the output of any AI engine
/// (ARC-MEM01) — and interprets nothing.
final class ConsultationMemoryApplicationService {
  const ConsultationMemoryApplicationService({
    required AuthenticationSession session,
    required MemoryRepository repository,
  }) : _session = session,
       _repository = repository;

  final AuthenticationSession _session;
  final MemoryRepository _repository;

  Future<void> record({
    required String bookingId,
    required MemoryEntryType type,
    Map<String, Object?> payload = const {},
  }) async {
    final userId = _requireUserId();

    try {
      await _repository.record(
        bookingId: bookingId,
        userId: userId,
        type: type,
        payload: payload,
      );
    } on MemoryEntryNotFoundException {
      throw const MemoryNotFoundFailure();
    } on MemoryEntryRepositoryException catch (error) {
      throw MemoryUnavailableFailure(cause: error.cause);
    } catch (error) {
      throw MemoryUnavailableFailure(cause: error);
    }
  }

  Future<ConsultationMemory> read(String bookingId) async {
    final userId = _requireUserId();

    try {
      return await _repository.read(bookingId: bookingId, userId: userId);
    } on MemoryEntryNotFoundException {
      throw const MemoryNotFoundFailure();
    } on MemoryEntryRepositoryException catch (error) {
      throw MemoryUnavailableFailure(cause: error.cause);
    } catch (error) {
      throw MemoryUnavailableFailure(cause: error);
    }
  }

  String _requireUserId() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const MemoryUnauthenticatedFailure();
    }
    return userId;
  }
}
