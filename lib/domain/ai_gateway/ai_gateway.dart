import 'ai_provider.dart';

/// The single doorway to every future intelligence capability of Mentora.
///
/// Every AI-shaped feature — transcription, translation, consultation
/// memory, summaries, realtime assistance, analysis, recommendations,
/// semantic search, classification — will call THIS contract and nothing
/// else. No screen and no business service ever knows which engine runs
/// behind it. Automatic provider selection (best engine per task) is a
/// future concern of the implementation; no selection logic exists today.
abstract interface class AIGateway {
  Future<AIResponse> execute(AIRequest request);
}
