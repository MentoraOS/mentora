import 'dart:async';

import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../../domain/transcript/transcript_chunk.dart';
import '../../domain/translation/translated_transcript_chunk.dart';
import '../../domain/translation/translation_provider.dart';

/// The real translation provider: projects every transcript chunk into
/// the target language by routing through the AI GATEWAY ONLY — never an
/// engine SDK, never a network call, never a business module. The
/// gateway routes [AITask.translation] to whichever engine is registered
/// for it; this class never knows which. The transcript chunk is carried
/// VERBATIM into the projection: the truth is never modified.
final class AITranslationProvider implements TranslationProvider {
  const AITranslationProvider({required AIGateway gateway})
    : _gateway = gateway;

  final AIGateway _gateway;

  @override
  Future<TranslationStream> start({
    required Stream<TranscriptChunk> transcript,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    return _GatewayTranslationStream(
      gateway: _gateway,
      transcript: transcript,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
    );
  }

  /// THE translation prompt — it belongs HERE, in Infrastructure, and
  /// nowhere else. Replace this method to change how translations are
  /// asked for (specialized domains — legal, medical, business — arrive
  /// as prompt variants here, without touching any other layer).
  static String buildPrompt({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    return 'Traduis le texte suivant de "$sourceLanguage" vers '
        '"$targetLanguage". Réponds UNIQUEMENT par la traduction, sans '
        'commentaire ni guillemets.\n\n$text';
  }
}

final class _GatewayTranslationStream implements TranslationStream {
  _GatewayTranslationStream({
    required AIGateway gateway,
    required Stream<TranscriptChunk> transcript,
    required this.sourceLanguage,
    required this.targetLanguage,
  }) : _gateway = gateway {
    _subscription = transcript.listen(
      _translate,
      onError: (Object error) {
        _status = TranslationStatus.failed;
        if (!_chunks.isClosed) _chunks.addError(error);
      },
    );
  }

  final AIGateway _gateway;
  final String sourceLanguage;
  final String targetLanguage;

  final StreamController<TranslatedTranscriptChunk> _chunks =
      StreamController<TranslatedTranscriptChunk>.broadcast();

  StreamSubscription<TranscriptChunk>? _subscription;
  TranslationStatus _status = TranslationStatus.translating;
  int _sequence = 0;

  @override
  TranslationStatus get status => _status;

  @override
  Stream<TranslatedTranscriptChunk> get chunks => _chunks.stream;

  @override
  Future<TranslationResult> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    if (_status == TranslationStatus.translating) {
      _status = TranslationStatus.stopped;
    }
    await _chunks.close();
    return TranslationResult(status: _status);
  }

  Future<void> _translate(TranscriptChunk chunk) async {
    try {
      final response = await _gateway.execute(
        AIRequest(
          requestId: 'translation_${chunk.sessionId}_${_sequence++}',
          task: AITask.translation,
          text: AITranslationProvider.buildPrompt(
            text: chunk.text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
          ),
          context: {
            'sessionId': chunk.sessionId,
            'participantIdentity': chunk.participantIdentity,
            'sourceLanguage': sourceLanguage,
            'targetLanguage': targetLanguage,
          },
        ),
      );

      final translated = response.text?.trim();
      if (response.status != AIResponseStatus.accepted) {
        throw StateError('The translation engine rejected the chunk.');
      }
      // An engine with nothing to say projects nothing — at most one
      // projection per chunk, never an invented one.
      if (translated == null || translated.isEmpty) return;
      if (_chunks.isClosed) return;

      _chunks.add(
        TranslatedTranscriptChunk(
          sessionId: chunk.sessionId,
          participantIdentity: chunk.participantIdentity,
          originalText: chunk.text,
          translatedText: translated,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          isFinal: chunk.isFinal,
          createdAt: DateTime.now(),
        ),
      );
    } catch (error) {
      // Fail closed and visibly: the flux carries the error, the stream
      // is marked failed, and nothing pretends to have translated.
      _status = TranslationStatus.failed;
      if (!_chunks.isClosed) _chunks.addError(error);
    }
  }
}
