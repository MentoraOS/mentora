import '../../domain/ai_gateway/ai_provider.dart';

/// Simulated AI engine: acknowledges the transported envelope with a
/// deterministic simulated response. It produces NO content of any kind —
/// real engines implement [AIProvider] in their own future waves and this
/// class never gains logic.
final class SimulatedAIProvider implements AIProvider {
  const SimulatedAIProvider();

  @override
  AIProviderType get providerType => AIProviderType.simulated;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    return AIResponse(
      providerType: AIProviderType.simulated,
      responseId: 'simulated_${request.requestId}',
      status: AIResponseStatus.accepted,
    );
  }

  @override
  Future<bool> health() async => true;
}
