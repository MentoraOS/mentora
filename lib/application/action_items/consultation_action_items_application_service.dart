import '../../domain/action_items/action_item.dart';
import '../../domain/action_items/action_items_provider.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';

/// Orchestrates the consultation's action recommendations.
///
/// The only business source it may read is the memory, through
/// ConsultationMemoryApplicationService — never any other module. It
/// delegates to the ActionItemsProvider port, whose implementation
/// routes through the AI gateway to the engine registered for the
/// action-items task. Proposals only: no automation, no workflow, no
/// notification, no persistence — the flux stays alive and the expert
/// alone decides.
final class ConsultationActionItemsApplicationService {
  ConsultationActionItemsApplicationService({
    required AuthenticationSession session,
    required ConsultationMemoryApplicationService memory,
    required ActionItemsProvider provider,
  }) : _session = session,
       _memory = memory,
       _provider = provider;

  final AuthenticationSession _session;
  final ConsultationMemoryApplicationService _memory;
  final ActionItemsProvider _provider;

  ActionItemsStream? _active;

  /// Starts the session's living proposal flux; one at a time, ever.
  Future<ActionItemsStream> start(String bookingId) async {
    _requireAuthenticated();
    if (_active != null) {
      throw const ActionItemsAlreadyActiveFailure();
    }

    final memory = await _readMemory(bookingId);
    try {
      final stream = await _provider.start(
        sessionId: bookingId,
        memory: memory,
      );
      _active = stream;
      return stream;
    } on ActionItemsFailure {
      rethrow;
    } catch (error) {
      throw ActionItemsUnavailableFailure(cause: error);
    }
  }

  /// The live proposals of the active flux.
  Stream<ActionItem> items() {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const ActionItemsUnavailableFailure(
        cause: 'No action-items flux is running.',
      );
    }
    return active.items;
  }

  /// Re-reads the memory and asks for proposals again.
  Future<void> refresh(String bookingId) async {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const ActionItemsUnavailableFailure(
        cause: 'No action-items flux is running.',
      );
    }

    final memory = await _readMemory(bookingId);
    try {
      await active.refresh(memory);
    } on ActionItemsFailure {
      rethrow;
    } catch (error) {
      throw ActionItemsUnavailableFailure(cause: error);
    }
  }

  /// Seals the active flux and returns its outcome.
  Future<ActionItemsResult> stop() async {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const ActionItemsUnavailableFailure(
        cause: 'No action-items flux is running.',
      );
    }

    try {
      final result = await active.stop();
      _active = null;
      return result;
    } on ActionItemsFailure {
      rethrow;
    } catch (error) {
      _active = null;
      throw ActionItemsUnavailableFailure(cause: error);
    }
  }

  /// The memory read is the single business source AND the fail-closed
  /// gate: a foreign user or unknown reservation stops here.
  Future<ConsultationMemory> _readMemory(String bookingId) async {
    try {
      return await _memory.read(bookingId);
    } on MemoryNotFoundFailure {
      throw const ActionItemsNotFoundFailure();
    } on MemoryUnauthenticatedFailure {
      throw const ActionItemsUnauthenticatedFailure();
    } catch (error) {
      throw ActionItemsUnavailableFailure(cause: error);
    }
  }

  void _requireAuthenticated() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const ActionItemsUnauthenticatedFailure();
    }
  }
}
