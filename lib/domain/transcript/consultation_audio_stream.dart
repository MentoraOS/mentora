/// Consultation audio transport boundary.
///
/// Carries the consultation's live audio OPAQUELY from the video layer
/// towards a future transcription engine. Nothing here — or anywhere in
/// Mentora today — converts, interprets, translates, summarizes or stores
/// the audio: it only circulates. Any real transcription engine will
/// consume these frames through its own Infrastructure adapter without
/// this contract, LiveKit, Booking, Payment, Chat or Scheduling changing.
abstract interface class ConsultationAudioStream {
  /// The live opaque audio frames of one consultation session.
  Stream<ConsultationAudioFrame> get frames;
}

/// One opaque unit of consultation audio.
final class ConsultationAudioFrame {
  /// The room/session the audio belongs to.
  final String sessionId;

  /// Identity of the speaking participant.
  final String participantIdentity;

  /// The vendor-native audio handle. Deliberately opaque: no layer above
  /// the consuming Infrastructure adapter may interpret it.
  final Object payload;

  const ConsultationAudioFrame({
    required this.sessionId,
    required this.participantIdentity,
    required this.payload,
  });
}
