import 'dart:convert';
import 'dart:io';

import '../../domain/ai_gateway/ai_provider.dart';

/// Every Deepgram deployment value is INJECTED — never a key, secret,
/// URL, model or language hard-coded. The composition root reads them
/// from the environment so every environment deploys without a code
/// change.
final class DeepgramConfiguration {
  final String apiKey;
  final String endpoint;
  final String model;
  final String language;

  const DeepgramConfiguration({
    required this.apiKey,
    this.endpoint = 'https://api.deepgram.com/v1/listen',
    this.model = 'nova-2',
    this.language = 'fr',
  });

  /// Without a key the engine is NOT configured and fails closed.
  bool get isConfigured => apiKey.trim().isNotEmpty;
}

/// The Deepgram engine — the ONLY place in Mentora that knows Deepgram.
///
/// A plain, interchangeable [AIProvider]: it receives the gateway's
/// envelope carrying raw audio bytes, relays them to the transcription
/// API and returns the transcript verbatim in the response envelope. It
/// reads no business module and fails closed — unconfigured, unsupported
/// payload or engine error is a typed failure, never a fake transcript.
/// Adding another engine (or replacing this one) means registering
/// another [AIProvider] on the gateway's transcription task; nothing
/// else in the application changes.
final class DeepgramAdapter implements AIProvider {
  const DeepgramAdapter({required this.configuration});

  final DeepgramConfiguration configuration;

  @override
  AIProviderType get providerType => AIProviderType.deepgram;

  @override
  Future<AIResponse> execute(AIRequest request) async {
    if (!configuration.isConfigured) {
      throw const AIUnavailableFailure(
        cause:
            'The Deepgram engine is not configured: inject an API key '
            'through the environment (never hard-code one).',
      );
    }
    final audio = request.audio;
    if (audio is! List<int>) {
      throw const AIUnavailableFailure(
        cause:
            'The Deepgram engine requires raw audio bytes; this audio '
            'payload is not transcribable.',
      );
    }

    final client = HttpClient();
    try {
      final uri = Uri.parse(configuration.endpoint).replace(
        queryParameters: {
          'model': configuration.model,
          'language': configuration.language,
        },
      );
      final httpRequest = await client.postUrl(uri);
      httpRequest.headers
        ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
        ..set(
          HttpHeaders.authorizationHeader,
          'Token ${configuration.apiKey}',
        );
      httpRequest.add(audio);

      final httpResponse = await httpRequest.close();
      final body = await utf8.decodeStream(httpResponse);
      if (httpResponse.statusCode != HttpStatus.ok) {
        throw AIUnavailableFailure(
          cause: 'Deepgram answered HTTP ${httpResponse.statusCode}.',
        );
      }

      final decoded = jsonDecode(body);
      final transcript = decoded is Map<String, dynamic>
          ? _transcriptText(decoded)
          : null;
      if (transcript == null) {
        throw const AIUnavailableFailure(
          cause: 'Deepgram returned no readable transcript.',
        );
      }

      return AIResponse(
        providerType: AIProviderType.deepgram,
        responseId: 'deepgram_${request.requestId}',
        status: AIResponseStatus.accepted,
        // Possibly empty for silence — the caller decides, verbatim.
        text: transcript,
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

  static String? _transcriptText(Map<String, dynamic> decoded) {
    final results = decoded['results'];
    if (results is! Map) return null;
    final channels = results['channels'];
    if (channels is! List || channels.isEmpty) return null;
    final first = channels.first;
    if (first is! Map) return null;
    final alternatives = first['alternatives'];
    if (alternatives is! List || alternatives.isEmpty) return null;
    final alternative = alternatives.first;
    if (alternative is! Map) return null;
    final transcript = alternative['transcript'];
    return transcript is String ? transcript : null;
  }
}
