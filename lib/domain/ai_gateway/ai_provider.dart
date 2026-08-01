/// AI engine boundary — CONTRACT ONLY, no engine exists in Mentora today.
///
/// A concrete engine implements this port in its own Infrastructure
/// adapter, in its own future wave. The gateway depends on the port,
/// never on an engine.
abstract interface class AIProvider {
  AIProviderType get providerType;

  /// Transports the request to the engine and returns its (today:
  /// simulated) response envelope.
  Future<AIResponse> execute(AIRequest request);

  /// Whether the engine can currently serve requests.
  Future<bool> health();
}

/// The engines the gateway can route to. Today only the simulated one
/// exists; real engine kinds are ADDED here by their own waves — no name
/// is reserved in advance.
enum AIProviderType { simulated }

/// Generic transport envelope for every future AI usage.
///
/// It can CARRY text, a conversation, audio, documents and arbitrary
/// context — all opaquely. Nothing parses, analyses or interprets these
/// payloads today; they only travel.
final class AIRequest {
  final String requestId;

  /// Optional plain text to transport.
  final String? text;

  /// Opaque conversation payload (e.g. domain messages).
  final List<Object> conversation;

  /// Opaque audio payload (e.g. a consultation audio handle).
  final Object? audio;

  /// Opaque document payloads.
  final List<Object> documents;

  /// Opaque contextual values keyed by name.
  final Map<String, Object> context;

  factory AIRequest({
    required String requestId,
    String? text,
    List<Object> conversation = const [],
    Object? audio,
    List<Object> documents = const [],
    Map<String, Object> context = const {},
  }) {
    if (requestId.trim().isEmpty) {
      throw ArgumentError.value(requestId, 'requestId', 'must not be empty');
    }

    return AIRequest._(
      requestId: requestId,
      text: text,
      conversation: List.unmodifiable(conversation),
      audio: audio,
      documents: List.unmodifiable(documents),
      context: Map.unmodifiable(context),
    );
  }

  const AIRequest._({
    required this.requestId,
    required this.text,
    required this.conversation,
    required this.audio,
    required this.documents,
    required this.context,
  });

  /// Whether the envelope transports anything at all.
  bool get isEmpty =>
      (text == null || text!.trim().isEmpty) &&
      conversation.isEmpty &&
      audio == null &&
      documents.isEmpty &&
      context.isEmpty;
}

/// Generic response envelope. Deliberately WITHOUT any generated content:
/// future waves extend it additively when real engines exist.
final class AIResponse {
  final AIProviderType providerType;
  final String responseId;
  final AIResponseStatus status;

  const AIResponse({
    required this.providerType,
    required this.responseId,
    required this.status,
  });
}

enum AIResponseStatus { accepted, rejected }

sealed class AIFailure implements Exception {
  const AIFailure();
}

final class AIUnauthenticatedFailure extends AIFailure {
  const AIUnauthenticatedFailure();
}

/// The envelope transports nothing — refused before any provider.
final class AIInvalidRequestFailure extends AIFailure {
  const AIInvalidRequestFailure();
}

final class AIUnavailableFailure extends AIFailure {
  const AIUnavailableFailure({required this.cause});

  final Object cause;
}
