/// Consultation extension hooks — DELIBERATELY EMPTY.
///
/// These abstract contracts are the ONLY prepared extension points for the
/// future consultation intelligence waves. They carry no logic, no members,
/// no dependencies and no runtime impact today; each future wave implements
/// exactly one of them in Infrastructure without touching the video layer.
///
/// Nothing in the current codebase may implement or reference them.
library;

/// Future access to the consultation's audio streams (translation,
/// transcription). Defined by its own wave; empty until then.
abstract interface class ConversationAudioStream {}

/// Future observation of raw video frames. Defined by its own wave.
abstract interface class VideoFrameObserver {}

/// Future live transcript source. Defined by its own wave.
abstract interface class LiveTranscriptProvider {}

/// Future consultation recording contract. Defined by its own wave.
abstract interface class ConsultationRecordingProvider {}

/// Future realtime translation contract. Defined by its own wave.
abstract interface class RealtimeTranslationProvider {}
