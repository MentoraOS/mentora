/// The consultation conversation and its text messages.
///
/// One reservation owns EXACTLY one conversation, identified by the
/// booking id itself — a second conversation is structurally impossible.
/// Only the reservation's client and expert participate; text is the only
/// supported content. This model is deliberately minimal and decoupled:
/// future layers (translation, transcription, consultation memory, AI
/// assistance) consume the same message stream through their own ports
/// without this foundation changing.
final class Conversation {
  /// Also the conversation identity: conversationId == bookingId.
  final String bookingId;

  /// The client and expert identities — never anyone else.
  final List<String> participants;

  final DateTime? createdAt;

  const Conversation({
    required this.bookingId,
    required this.participants,
    required this.createdAt,
  });
}

enum ConversationRole { client, expert }

final class Message {
  final String id;
  final String bookingId;
  final String senderId;
  final ConversationRole senderRole;

  /// Plain text only — no media, no reactions, no edits.
  final String content;

  /// Server-side instant; null only during server-timestamp latency.
  final DateTime? createdAt;

  factory Message({
    required String id,
    required String bookingId,
    required String senderId,
    required ConversationRole senderRole,
    required String content,
    required DateTime? createdAt,
  }) {
    if (content.trim().isEmpty) {
      throw ArgumentError.value(content, 'content', 'must not be empty');
    }

    return Message._(
      id: id,
      bookingId: bookingId,
      senderId: senderId,
      senderRole: senderRole,
      content: content,
      createdAt: createdAt,
    );
  }

  const Message._({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
  });
}
