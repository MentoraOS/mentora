import '../../domain/assistant/assistant_provider.dart';
import '../../domain/assistant/assistant_suggestion.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';

/// Orchestrates the consultation copilot.
///
/// The only business source it may read is the memory, through
/// ConsultationMemoryApplicationService — never any other module. It
/// delegates to the AssistantProvider port, whose implementation routes
/// through the AI gateway to the engine registered for the assistant
/// task. The copilot proposes, never decides, never acts, never
/// persists: the suggestions stay a living flux.
final class ConsultationAssistantApplicationService {
  ConsultationAssistantApplicationService({
    required AuthenticationSession session,
    required ConsultationMemoryApplicationService memory,
    required AssistantProvider provider,
  }) : _session = session,
       _memory = memory,
       _provider = provider;

  final AuthenticationSession _session;
  final ConsultationMemoryApplicationService _memory;
  final AssistantProvider _provider;

  AssistantStream? _active;

  /// Starts the session's living copilot; one at a time, ever.
  Future<AssistantStream> start(String bookingId) async {
    _requireAuthenticated();
    if (_active != null) {
      throw const AssistantAlreadyActiveFailure();
    }

    final memory = await _readMemory(bookingId);
    try {
      final stream = await _provider.start(
        sessionId: bookingId,
        memory: memory,
      );
      _active = stream;
      return stream;
    } on AssistantFailure {
      rethrow;
    } catch (error) {
      throw AssistantUnavailableFailure(cause: error);
    }
  }

  /// The live suggestions of the active copilot.
  Stream<AssistantSuggestion> suggestions() {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const AssistantUnavailableFailure(
        cause: 'No copilot is running.',
      );
    }
    return active.suggestions;
  }

  /// Re-reads the memory and asks the copilot to look again.
  Future<void> refresh(String bookingId) async {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const AssistantUnavailableFailure(
        cause: 'No copilot is running.',
      );
    }

    final memory = await _readMemory(bookingId);
    try {
      await active.refresh(memory);
    } on AssistantFailure {
      rethrow;
    } catch (error) {
      throw AssistantUnavailableFailure(cause: error);
    }
  }

  /// Seals the active copilot and returns its outcome.
  Future<AssistantResult> stop() async {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const AssistantUnavailableFailure(
        cause: 'No copilot is running.',
      );
    }

    try {
      final result = await active.stop();
      _active = null;
      return result;
    } on AssistantFailure {
      rethrow;
    } catch (error) {
      _active = null;
      throw AssistantUnavailableFailure(cause: error);
    }
  }

  /// The memory read is the single business source AND the fail-closed
  /// gate: a foreign user or unknown reservation stops here.
  Future<ConsultationMemory> _readMemory(String bookingId) async {
    try {
      return await _memory.read(bookingId);
    } on MemoryNotFoundFailure {
      throw const AssistantNotFoundFailure();
    } on MemoryUnauthenticatedFailure {
      throw const AssistantUnauthenticatedFailure();
    } catch (error) {
      throw AssistantUnavailableFailure(cause: error);
    }
  }

  void _requireAuthenticated() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const AssistantUnauthenticatedFailure();
    }
  }
}
