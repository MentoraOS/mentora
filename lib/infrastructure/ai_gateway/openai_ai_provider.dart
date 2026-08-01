import 'dart:convert';
import 'dart:io';

import '../../domain/ai_gateway/ai_provider.dart';

/// Every OpenAI deployment value is INJECTED — never a key, secret, URL
/// or model hard-coded in business code. The composition root reads them
/// from the environment so development, staging and production deploy
/// without touching a single line.
final class OpenAIConfiguration {
  final String apiKey;
  final String endpoint;
  final String model;
  final String? organization;

  const OpenAIConfiguration({
    required this.apiKey,
    this.endpoint = 'https://api.openai.com/v1/chat/completions',
    this.model = 'gpt-4o-mini',
    this.organization,
  });

  /// Without a key the engine is NOT configured and fails closed.
  bool get isConfigured => apiKey.trim().isNotEmpty;
}

/// The OpenAI engine — the ONLY place in Mentora that knows OpenAI.
///
/// It is a plain, interchangeable [AIProvider]: it receives the gateway's
/// transport envelope, relays `request.text` to the chat-completions API
/// verbatim and returns the engine's answer verbatim in the response
/// envelope. It builds no prompt (prompts belong to the task providers),
/// reads no business module, and fails closed — an
/// unconfigured or failing engine is a typed error, never a fake
/// success. Swapping engines means registering another [AIProvider] on
/// the gateway; nothing else in the application changes.
final class OpenAIProvider implements AIProvider {
  const OpenAIProvider({required this.configuration});

  final OpenAIConfiguration configuration;

  @override
  AIProviderType get providerType => AIProviderType.openAI;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (!configuration.isConfigured) {
      throw const AIUnavailableFailure(
        cause:
            'The OpenAI engine is not configured: inject an API key '
            'through the environment (never hard-code one).',
      );
    }
    final prompt = request.text?.trim();
    if (prompt == null || prompt.isEmpty) {
      throw const AIUnavailableFailure(
        cause: 'The OpenAI engine requires a text payload to relay.',
      );
    }

    final client = HttpClient();
    try {
      final httpRequest = await client.postUrl(
        Uri.parse(configuration.endpoint),
      );
      httpRequest.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set(
          HttpHeaders.authorizationHeader,
          'Bearer ${configuration.apiKey}',
        );
      if (configuration.organization case final organization?) {
        httpRequest.headers.set('OpenAI-Organization', organization);
      }
      httpRequest.write(
        jsonEncode({
          'model': configuration.model,
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
        }),
      );

      final httpResponse = await httpRequest.close();
      final body = await utf8.decodeStream(httpResponse);
      if (httpResponse.statusCode != HttpStatus.ok) {
        throw AIUnavailableFailure(
          cause: 'OpenAI answered HTTP ${httpResponse.statusCode}.',
        );
      }

      final decoded = jsonDecode(body);
      final text = decoded is Map<String, dynamic>
          ? _completionText(decoded)
          : null;
      if (text == null || text.trim().isEmpty) {
        throw const AIUnavailableFailure(
          cause: 'OpenAI returned no completion text.',
        );
      }

      return AIResponse(
        providerType: AIProviderType.openAI,
        responseId: decoded['id'] is String
            ? decoded['id'] as String
            : 'openai_${request.requestId}',
        status: AIResponseStatus.accepted,
        text: text,
      );
    } on AIFailure {
      rethrow;
    } catch (error) {
      throw AIUnavailableFailure(cause: error);
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<bool> health() async => configuration.isConfigured;

  static String? _completionText(Map<String, dynamic> decoded) {
    final choices = decoded['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map) return null;
    final message = first['message'];
    if (message is! Map) return null;
    final content = message['content'];
    return content is String ? content : null;
  }
}
