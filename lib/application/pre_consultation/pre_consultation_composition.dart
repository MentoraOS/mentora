import 'pre_consultation_readiness.dart';

/// THE single composition of a consultation's preparation state.
///
/// Exactly three verbs: build, assemble, return a
/// [PreConsultationReadiness] from facts it RECEIVES — it verifies
/// nothing itself, waits for nothing, computes nothing. Every flag it
/// is not given stays FALSE (fail closed). It never starts, stops,
/// generates, records, translates, transcribes, recommends, summarizes
/// or executes anything, and knows no provider, adapter, engine, media
/// vendor or storage.
final class PreConsultationComposition {
  const PreConsultationComposition();

  PreConsultationReadiness compose({
    required String bookingId,
    required DateTime createdAt,
    bool networkReady = false,
    bool microphoneReady = false,
    bool cameraReady = false,
    bool permissionsReady = false,
    bool aiReady = false,
    bool recordingReady = false,
  }) {
    return PreConsultationReadiness(
      bookingId: bookingId,
      networkReady: networkReady,
      microphoneReady: microphoneReady,
      cameraReady: cameraReady,
      permissionsReady: permissionsReady,
      aiReady: aiReady,
      recordingReady: recordingReady,
      createdAt: createdAt,
    );
  }
}
