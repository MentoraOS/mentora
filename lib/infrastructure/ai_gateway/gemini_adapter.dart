import 'dart:convert';
import 'dart:io';

import '../../domain/ai_gateway/ai_provider.dart';

/// Every Gemini deployment value is INJECTED — never a key, secret, URL
/// or model hard-coded. The composition root reads them from the
/// environment so every environment deploys without a code change.
final class GeminiConfiguration {
  final String apiKey;
  final String endpoint;
  final String model;

  const GeminiConfiguration({
    required this.apiKey,
    this.endpoint = 'https://generativelanguage.googleapis.com/v1beta/models',
    this.model = 'gemini-1.5-flash',
  });

  /// Without a key the engine is NOT configured and fails closed.
  bool get isConfigured => apiKey.trim().isNotEmpty;
}

/// The Gemini engine — the ONLY place in Mentora that knows Gemini.
///
/// A plain, interchangeable [AIProvider]: it relays `request.text`
/// verbatim to the generateContent API and returns the engine's answer
/// verbatim in the response envelope. It builds no prompt (prompts
/// belong to the task providers), reads no business module, and fails
/// closed — unconfigured or failing means a typed error, never a fake
/// answer. Adding another engine (or replacing this one) means
/// registering another [AIProvider] on the gateway; nothing else in the
/// application changes.
final class GeminiAdapter implements AIProvider {
  const GeminiAdapter({required this.configuration});

  final GeminiConfiguration configuration;

  @override
  AIProviderType get providerType => AIProviderType.gemini;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (!configuration.isConfigured) {
      throw const AIUnavailableFailure(
        cause:
            'The Gemini engine is not configured: inject an API key '
            'through the environment (never hard-code one).',
      );
    }
    final prompt = request.text?.trim();
    if (prompt == null || prompt.isEmpty) {
      throw const AIUnavailableFailure(
        cause: 'The Gemini engine requires a text payload to relay.',
      );
    }

    final client = HttpClient();
    try {
      final uri = Uri.parse(
        '${configuration.endpoint}/${configuration.model}:generateContent',
      );
      final httpRequest = await client.postUrl(uri);
      httpRequest.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/json')
        ..set('x-goog-api-key', configuration.apiKey);
      httpRequest.write(
        jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
        }),
      );

      final httpResponse = await httpRequest.close();
      final body = await utf8.decodeStream(httpResponse);
      if (httpResponse.statusCode != HttpStatus.ok) {
        throw AIUnavailableFailure(
          cause: 'Gemini answered HTTP ${httpResponse.statusCode}.',
        );
      }

      final decoded = jsonDecode(body);
      final text = decoded is Map<String, dynamic>
          ? _candidateText(decoded)
          : null;
      if (text == null || text.trim().isEmpty) {
        throw const AIUnavailableFailure(
          cause: 'Gemini returned no candidate text.',
        );
      }

      return AIResponse(
        providerType: AIProviderType.gemini,
        responseId: 'gemini_${request.requestId}',
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

  static String? _candidateText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final first = candidates.first;
    if (first is! Map) return null;
    final content = first['content'];
    if (content is! Map) return null;
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return null;
    final part = parts.first;
    if (part is! Map) return null;
    final text = part['text'];
    return text is String ? text : null;
  }
}
