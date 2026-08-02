/// The preparation state of one consultation — PURE STATE, nothing else.
///
/// Immutable, exactly these eight facts, no computation and no business
/// method. Every readiness flag is FALSE until a future verification
/// wave proves otherwise — fail closed: nothing unverified ever reads
/// as ready. Future checks (network, camera, microphone, permissions,
/// AI, consents, checklist, onboarding) fill these facts through their
/// own waves without this model changing.
final class PreConsultationReadiness {
  final String bookingId;
  final bool networkReady;
  final bool microphoneReady;
  final bool cameraReady;
  final bool permissionsReady;
  final bool aiReady;
  final bool recordingReady;
  final DateTime createdAt;

  const PreConsultationReadiness({
    required this.bookingId,
    required this.networkReady,
    required this.microphoneReady,
    required this.cameraReady,
    required this.permissionsReady,
    required this.aiReady,
    required this.recordingReady,
    required this.createdAt,
  });
}
