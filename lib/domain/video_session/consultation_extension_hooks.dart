/// Consultation extension hooks — DELIBERATELY EMPTY.
///
/// These abstract contracts are the ONLY prepared extension points for the
/// future consultation intelligence waves. They carry no logic, no members,
/// no dependencies and no runtime impact today; each future wave implements
/// exactly one of them in Infrastructure without touching the video layer.
///
/// Nothing in the current codebase may implement or reference them.
///
/// Realized so far (removed from this file): the consultation audio
/// stream and the transcript provider (domain/transcript), and the
/// realtime translation provider (domain/translation).
library;

/// Future observation of raw video frames. Defined by its own wave.
abstract interface class VideoFrameObserver {}

/// Future consultation recording contract. Defined by its own wave.
abstract interface class ConsultationRecordingProvider {}
