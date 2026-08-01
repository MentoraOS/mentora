import '../transcript/transcript_chunk.dart';
import 'translated_transcript_chunk.dart';

/// Real-time translation boundary.
///
/// The provider attaches to a living transcript flux and returns the
/// LIVING translated projection. The transcript is the truth: nothing
/// here ever modifies it, and the translation can always be rebuilt from
/// it. Languages are injected per session — never a hard-coded list —
/// which is what later allows several simultaneous target languages,
/// bidirectional pairs and mid-consultation language changes: each is
/// simply another started stream. The implementation routes through the
/// AI gateway; engines are added by registering another gateway adapter
/// and nothing in the business layers changes.
abstract interface class TranslationProvider {
  Future<TranslationStream> start({
    required Stream<TranscriptChunk> transcript,
    required String sourceLanguage,
    required String targetLanguage,
  });
}

/// One continuous translated projection of a transcript flux.
abstract interface class TranslationStream {
  TranslationStatus get status;

  /// The live translated chunks, in transcript order. Errors surface ON
  /// this stream — fail closed, never silently swallowed.
  Stream<TranslatedTranscriptChunk> get chunks;

  /// Detaches from the transcript and seals the projection.
  Future<TranslationResult> stop();
}

/// The lifecycle of one living projection. Nothing else.
enum TranslationStatus { translating, stopped, failed }

/// The sealed outcome of one translation session.
final class TranslationResult {
  final TranslationStatus status;

  const TranslationResult({required this.status});
}

sealed class TranslationFailure implements Exception {
  const TranslationFailure();
}

final class TranslationUnauthenticatedFailure extends TranslationFailure {
  const TranslationUnauthenticatedFailure();
}

/// One live translation at a time, ever.
final class TranslationAlreadyActiveFailure extends TranslationFailure {
  const TranslationAlreadyActiveFailure();
}

/// Languages are required, injected values — an empty one fails closed.
final class TranslationInvalidLanguagesFailure extends TranslationFailure {
  const TranslationInvalidLanguagesFailure();
}

final class TranslationUnavailableFailure extends TranslationFailure {
  const TranslationUnavailableFailure({required this.cause});

  final Object cause;
}
