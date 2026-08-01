import '../../domain/conversation/conversation.dart';
import '../../domain/conversation/conversation_repository.dart';
import '../authentication/authentication_session.dart';
import '../consultation_memory/consultation_memory_application_service.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import 'conversation_failure.dart';

/// Real-time consultation messaging between the client and the expert.
///
/// Session-scoped: the caller is always the authenticated user, and the
/// repository verifies participation and the reservation state
/// transactionally. Text only, no notification, no presence — the strict
/// communication foundation the future intelligence layers build upon.
final class ConversationApplicationService {
  const ConversationApplicationService({
    required AuthenticationSession session,
    required ConversationRepository repository,
    ConsultationMemoryApplicationService? memory,
  }) : _session = session,
       _repository = repository,
       _memory = memory;

  final AuthenticationSession _session;
  final ConversationRepository _repository;

  /// Optional memory producer; absent means no fact is recorded.
  final ConsultationMemoryApplicationService? _memory;

  Future<void> sendMessage({
    required String bookingId,
    required String content,
  }) async {
    final userId = _requireUserId();
    final text = content.trim();
    if (text.isEmpty) {
      throw const ConversationEmptyMessageFailure();
    }

    try {
      await _repository.sendMessage(
        bookingId: bookingId,
        senderId: userId,
        content: text,
      );
    } on ConversationNotFoundException {
      throw const ConversationNotFoundFailure();
    } on ConversationStateException catch (error) {
      throw ConversationInvalidStateFailure(
        currentStatus: error.currentStatus,
      );
    } on ConversationRepositoryException catch (error) {
      throw ConversationRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConversationRepositoryFailure(cause: error);
    }

    await _recordFact(bookingId, MemoryEntryType.chatMessage, {
      'content': text,
    });
  }

  Stream<List<Message>> watchMessages(String bookingId) async* {
    final userId = _requireUserId();

    try {
      // await-for (not yield*) so inner stream errors are translatable.
      await for (final messages in _repository.watchMessages(
        bookingId: bookingId,
        userId: userId,
      )) {
        yield messages;
      }
    } on ConversationNotFoundException {
      throw const ConversationNotFoundFailure();
    } on ConversationStateException catch (error) {
      throw ConversationInvalidStateFailure(
        currentStatus: error.currentStatus,
      );
    } on ConversationRepositoryException catch (error) {
      throw ConversationRepositoryFailure(cause: error.cause);
    } catch (error) {
      throw ConversationRepositoryFailure(cause: error);
    }
  }

  String _requireUserId() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const ConversationUnauthenticatedFailure();
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
