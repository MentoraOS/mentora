/// One translated piece of the living transcript — a PROJECTION.
///
/// The TranscriptChunk is the truth; this object never replaces it, never
/// modifies it and can always be rebuilt from it. Exactly these eight
/// facts, nothing else. Languages are plain injected values — no list is
/// ever hard-coded anywhere.
final class TranslatedTranscriptChunk {
  final String sessionId;
  final String participantIdentity;

  /// The transcript text, carried VERBATIM — never altered.
  final String originalText;

  /// The projection of [originalText] into [targetLanguage].
  final String translatedText;

  final String sourceLanguage;
  final String targetLanguage;
  final bool isFinal;
  final DateTime createdAt;

  factory TranslatedTranscriptChunk({
    required String sessionId,
    required String participantIdentity,
    required String originalText,
    required String translatedText,
    required String sourceLanguage,
    required String targetLanguage,
    required bool isFinal,
    required DateTime createdAt,
  }) {
    if (originalText.trim().isEmpty) {
      throw ArgumentError.value(
        originalText,
        'originalText',
        'must not be empty',
      );
    }
    if (translatedText.trim().isEmpty) {
      throw ArgumentError.value(
        translatedText,
        'translatedText',
        'must not be empty',
      );
    }

    return TranslatedTranscriptChunk._(
      sessionId: sessionId,
      participantIdentity: participantIdentity,
      originalText: originalText,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      isFinal: isFinal,
      createdAt: createdAt,
    );
  }

  const TranslatedTranscriptChunk._({
    required this.sessionId,
    required this.participantIdentity,
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.isFinal,
    required this.createdAt,
  });
}
