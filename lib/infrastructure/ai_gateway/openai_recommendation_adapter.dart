import '../../domain/ai_gateway/ai_provider.dart';
import 'openai_ai_provider.dart';

/// The OpenAI engine registered for the recommendation task.
///
/// It delegates to the generic OpenAI relay — same injected
/// configuration discipline, no key, secret or URL in code — and exists
/// as its own registration so the recommendation engine can be swapped
/// (to any other vendor) independently of the summary, assistant and
/// action-items engines, by simply registering another [AIProvider] on
/// the gateway's recommendation task.
final class OpenAIRecommendationAdapter implements AIProvider {
  const OpenAIRecommendationAdapter({required this.configuration});

  final OpenAIConfiguration configuration;

  OpenAIProvider get _delegate => OpenAIProvider(configuration: configuration);

  @override
  AIProviderType get providerType => _delegate.providerType;

  @override
  Future<AIResponse> execute(AIRequest request) => _delegate.execute(request);

  @override
  Future<bool> health() => _delegate.health();
}
