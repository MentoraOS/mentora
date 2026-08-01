import '../../domain/transcript/transcript_chunk.dart';
import '../../domain/translation/translated_transcript_chunk.dart';
import '../../domain/translation/translation_provider.dart';
import '../authentication/authentication_session.dart';

/// Orchestrates the real-time translation of one consultation transcript.
///
/// The ONLY authorized pipeline is fixed by governance: the transcript
/// chunks feed this service, which delegates to the TranslationProvider
/// port, whose implementation routes through the AI gateway to the engine
/// registered for the translation task. The transcript is never modified
/// — the translation is a living projection, never persisted here.
final class RealtimeTranslationApplicationService {
  RealtimeTranslationApplicationService({
    required AuthenticationSession session,
    required TranslationProvider provider,
  }) : _session = session,
       _provider = provider;

  final AuthenticationSession _session;
  final TranslationProvider _provider;

  TranslationStream? _active;

  /// Starts the living translated projection; one at a time, ever.
  /// Languages are injected values — no list exists anywhere.
  Future<TranslationStream> start({
    required Stream<TranscriptChunk> transcript,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    _requireAuthenticated();
    if (sourceLanguage.trim().isEmpty || targetLanguage.trim().isEmpty) {
      throw const TranslationInvalidLanguagesFailure();
    }
    if (_active != null) {
      throw const TranslationAlreadyActiveFailure();
    }

    try {
      final stream = await _provider.start(
        transcript: transcript,
        sourceLanguage: sourceLanguage.trim(),
        targetLanguage: targetLanguage.trim(),
      );
      _active = stream;
      return stream;
    } on TranslationFailure {
      rethrow;
    } catch (error) {
      throw TranslationUnavailableFailure(cause: error);
    }
  }

  /// The live translated chunks of the active projection.
  Stream<TranslatedTranscriptChunk> chunks() {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const TranslationUnavailableFailure(
        cause: 'No translation is running.',
      );
    }
    return active.chunks;
  }

  /// Seals the active projection and returns its outcome.
  Future<TranslationResult> stop() async {
    _requireAuthenticated();
    final active = _active;
    if (active == null) {
      throw const TranslationUnavailableFailure(
        cause: 'No translation is running.',
      );
    }

    try {
      final result = await active.stop();
      _active = null;
      return result;
    } on TranslationFailure {
      rethrow;
    } catch (error) {
      _active = null;
      throw TranslationUnavailableFailure(cause: error);
    }
  }

  void _requireAuthenticated() {
    final userId = _session.currentUserId?.trim();
    if (!_session.isAuthenticated || userId == null || userId.isEmpty) {
      throw const TranslationUnauthenticatedFailure();
    }
  }
}
