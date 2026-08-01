import '../../domain/consultation_memory/consultation_memory.dart';
import '../../domain/consultation_summary/consultation_summary.dart';
import '../../domain/consultation_summary/summary_provider.dart';
import '../../domain/consultation_summary/summary_repository.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';

/// Orchestrates the consultation summary lifecycle — the FIRST official
/// consumer of the consultation memory.
///
/// The only business source it may read is the memory, through
/// ConsultationMemoryApplicationService (ARC-SUM01): never any other
/// business module directly. Generation runs (today:
/// simulates) behind the SummaryProvider port and only summary METADATA
/// is ever persisted — no text, no engine content. A provider failure is
/// persisted as FAILED and surfaces typed: never a fake success.
final class ConsultationSummaryApplicationService {
  const ConsultationSummaryApplicationService({
    required AuthenticationSession session,
    required ConsultationMemoryApplicationService memory,
    required SummaryProvider provider,
    required SummaryRepository repository,
  }) : _session = session,
       _memory = memory,
       _provider = provider,
       _repository = repository;

  final AuthenticationSession _session;
  final ConsultationMemoryApplicationService _memory;
  final SummaryProvider _provider;
  final SummaryRepository _repository;

  /// Generates (today: simulates) the reservation's summary and returns
  /// its resulting state.
  Future<ConsultationSummary> generate(String bookingId) async {
    final userId = _requireUserId();

    // The memory read is the single business source AND the fail-closed
    // gate: a foreign user or unknown reservation stops here.
    final ConsultationMemory memory;
    try {
      memory = await _memory.read(bookingId);
    } on MemoryNotFoundFailure {
      throw const SummaryNotFoundFailure();
    } on MemoryUnauthenticatedFailure {
      throw const SummaryUnauthenticatedFailure();
    } catch (error) {
      throw SummaryUnavailableFailure(cause: error);
    }

    await _saveStatus(bookingId, userId, SummaryStatus.generating);

    SummaryStatus status;
    try {
      status = await _provider.generate(bookingId: bookingId, memory: memory);
    } catch (error) {
      // Never a fake success: the failure is durable and typed.
      await _saveStatusBestEffort(bookingId, userId, SummaryStatus.failed);
      throw SummaryUnavailableFailure(cause: error);
    }

    await _saveStatus(bookingId, userId, status);
    return getSummary(bookingId);
  }

  /// The reservation's summary state; never generated reads as
  /// [SummaryStatus.notGenerated], never as an error.
  Future<ConsultationSummary> getSummary(String bookingId) async {
    final userId = _requireUserId();

    try {
      final summary = await _repository.findByBookingId(
        bookingId: bookingId,
        userId: userId,
      );
      return summary ??
          ConsultationSummary(
            bookingId: bookingId,
            status: SummaryStatus.notGenerated,
            createdAt: null,
            updatedAt: null,
          );
    } on SummaryStateNotFoundException {
      throw const SummaryNotFoundFailure();
    } on SummaryStateRepositoryException catch (error) {
      throw SummaryUnavailableFailure(cause: error.cause);
    } catch (error) {
      throw SummaryUnavailableFailure(cause: error);
    }
  }

  Future<void> _saveStatus(
    String bookingId,
    String userId,
    SummaryStatus status,
  ) async {
    try {
      await _repository.saveStatus(
        bookingId: bookingId,
        userId: userId,
        status: status,
      );
    } on SummaryStateNotFoundException {
      throw const SummaryNotFoundFailure();
    } on SummaryStateRepositoryException catch (error) {
      throw SummaryUnavailableFailure(cause: error.cause);
    } catch (error) {
      throw SummaryUnavailableFailure(cause: error);
    }
  }

  Future<void> _saveStatusBestEffort(
    String bookingId,
    String userId,
    SummaryStatus status,
  ) async {
    try {
      await _repository.saveStatus(
        bookingId: bookingId,
        userId: userId,
        status: status,
      );
    } catch (_) {
      // The provider error is about to surface; keep it primary.
    }
  }

  String _requireUserId() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const SummaryUnauthenticatedFailure();
    }
    return userId;
  }
}
