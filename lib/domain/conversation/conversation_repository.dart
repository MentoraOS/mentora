import 'conversation.dart';

/// Port for the consultation conversation: send a text message and watch
/// the message stream in real time — nothing else.
abstract interface class ConversationRepository {
  /// Appends the sender's text message to the reservation's single
  /// conversation.
  ///
  /// The reservation must exist, [senderId] must be its client or expert
  /// (anything else reads as not-found) and the reservation must be in a
  /// conversational state (confirmed, paid or completed).
  Future<void> sendMessage({
    required String bookingId,
    required String senderId,
    required String content,
  });

  /// Live message stream of the reservation's conversation, oldest first.
  ///
  /// Real time comes exclusively from the backing store's own streams —
  /// never from polling. The same guards as [sendMessage] apply to
  /// [userId].
  Stream<List<Message>> watchMessages({
    required String bookingId,
    required String userId,
  });
}

final class ConversationNotFoundException implements Exception {
  const ConversationNotFoundException();
}

final class ConversationStateException implements Exception {
  const ConversationStateException({required this.currentStatus});

  final String currentStatus;
}

final class ConversationRepositoryException implements Exception {
  const ConversationRepositoryException({required this.cause});

  final Object cause;
}
