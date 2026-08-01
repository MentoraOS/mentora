import '../../domain/ai_gateway/ai_provider.dart';
import 'openai_ai_provider.dart';

/// The OpenAI engine registered for the action-items task.
///
/// It delegates to the generic OpenAI relay — same injected
/// configuration discipline, no key, secret or URL in code — and exists
/// as its own registration so the action-items engine can be swapped (to
/// any other vendor) independently of the summary and assistant engines,
/// by simply registering another [AIProvider] on the gateway's
/// action-items task.
final class OpenAIActionItemsAdapter implements AIProvider {
  const OpenAIActionItemsAdapter({required this.configuration});

  final OpenAIConfiguration configuration;

  OpenAIProvider get _delegate => OpenAIProvider(configuration: configuration);

  @override
  AIProviderType get providerType => _delegate.providerType;

  @override
  Future<AIResponse> execute(AIRequest request) => _delegate.execute(request);

  @override
  Future<bool> health() => _delegate.health();
}
