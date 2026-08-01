/// One piece of the LIVING transcription flux — exactly these five
/// facts, nothing else. Chunks belong to one continuous session stream;
/// they are never persisted by this layer (the memory joins in its own
/// future wave) and never enriched.
final class TranscriptChunk {
  final String sessionId;
  final String participantIdentity;
  final String text;
  final bool isFinal;
  final DateTime createdAt;

  factory TranscriptChunk({
    required String sessionId,
    required String participantIdentity,
    required String text,
    required bool isFinal,
    required DateTime createdAt,
  }) {
    if (text.trim().isEmpty) {
      throw ArgumentError.value(text, 'text', 'must not be empty');
    }

    return TranscriptChunk._(
      sessionId: sessionId,
      participantIdentity: participantIdentity,
      text: text,
      isFinal: isFinal,
      createdAt: createdAt,
    );
  }

  const TranscriptChunk._({
    required this.sessionId,
    required this.participantIdentity,
    required this.text,
    required this.isFinal,
    required this.createdAt,
  });
}
