import 'dart:async';

import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../../domain/assistant/assistant_provider.dart';
import '../../domain/assistant/assistant_suggestion.dart';
import '../../domain/consultation_memory/consultation_memory.dart';

/// The real copilot provider: turns the memory's recorded facts into a
/// living suggestion flux by routing through the AI GATEWAY ONLY — never
/// an engine SDK, never a network call, never a business module. The
/// gateway routes [AITask.assistant] to whichever engine is registered
/// for it; this class never knows which.
final class AIAssistantProvider implements AssistantProvider {
  const AIAssistantProvider({required AIGateway gateway})
    : _gateway = gateway;

  final AIGateway _gateway;

  @override
  Future<AssistantStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
    final stream = _GatewayAssistantStream(
      gateway: _gateway,
      sessionId: sessionId,
    );
    // The first look at the memory runs one tick later so subscribers
    // attached right after start() always precede the first suggestions.
    unawaited(
      Future<void>.delayed(Duration.zero).then((_) => stream.refresh(memory)),
    );
    return stream;
  }

  /// THE copilot prompt — it belongs HERE, in Infrastructure, and
  /// nowhere else. Replace this method to change what the copilot looks
  /// for; future capabilities (reminders, uncovered points, resources,
  /// interim syntheses…) are variants of this builder, without touching
  /// any other layer. The engine must answer one suggestion per line as
  /// `PRIORITE;TITRE;CONTENU` (priority LOW, NORMAL or HIGH); anything
  /// else is dropped, never guessed.
  static String buildPrompt(ConsultationMemory memory) {
    final buffer = StringBuffer()
      ..writeln(
        'Tu es le copilote de consultation de Mentora. Tu assistes '
        'l’expert : tu ne décides jamais, tu n’agis jamais, tu ne parles '
        'jamais au client. Tu proposes uniquement des suggestions '
        'contextuelles.',
      )
      ..writeln(
        'Voici, dans l’ordre chronologique, les faits enregistrés de la '
        'consultation ${memory.bookingId} :',
      )
      ..writeln();

    for (final entry in memory.entries) {
      buffer.writeln(
        '- [${entry.type.name}] '
        '${entry.payload.isEmpty ? '(sans contenu)' : entry.payload}',
      );
    }

    buffer
      ..writeln()
      ..writeln(
        'Propose au plus 3 suggestions utiles à l’expert. Réponds '
        'UNIQUEMENT avec une suggestion par ligne, au format exact : '
        'PRIORITE;TITRE;CONTENU — où PRIORITE vaut LOW, NORMAL ou HIGH. '
        'Aucun autre texte.',
      );
    return buffer.toString();
  }

  /// Parses one engine line into a suggestion; unparseable lines are
  /// dropped — the copilot never invents structure.
  static AssistantSuggestion? parseLine({
    required String sessionId,
    required String suggestionId,
    required String line,
    required DateTime createdAt,
  }) {
    final parts = line.split(';');
    if (parts.length < 3) return null;

    final priority = switch (parts.first.trim().toUpperCase()) {
      'LOW' => AssistantPriority.low,
      'NORMAL' => AssistantPriority.normal,
      'HIGH' => AssistantPriority.high,
      _ => null,
    };
    final title = parts[1].trim();
    final content = parts.sublist(2).join(';').trim();
    if (priority == null || title.isEmpty || content.isEmpty) return null;

    return AssistantSuggestion(
      sessionId: sessionId,
      suggestionId: suggestionId,
      title: title,
      content: content,
      priority: priority,
      createdAt: createdAt,
    );
  }
}

final class _GatewayAssistantStream implements AssistantStream {
  _GatewayAssistantStream({required AIGateway gateway, required this.sessionId})
    : _gateway = gateway;

  final AIGateway _gateway;
  final String sessionId;

  final StreamController<AssistantSuggestion> _suggestions =
      StreamController<AssistantSuggestion>.broadcast();

  AssistantStatus _status = AssistantStatus.assisting;
  int _sequence = 0;

  @override
  AssistantStatus get status => _status;

  @override
  Stream<AssistantSuggestion> get suggestions => _suggestions.stream;

  @override
  Future<void> refresh(ConsultationMemory memory) async {
    if (_status != AssistantStatus.assisting) return;

    try {
      final response = await _gateway.execute(
        AIRequest(
          requestId: 'assistant_${sessionId}_${_sequence++}',
          task: AITask.assistant,
          text: AIAssistantProvider.buildPrompt(memory),
          context: {'sessionId': sessionId},
        ),
      );

      final text = response.text?.trim();
      if (response.status != AIResponseStatus.accepted) {
        throw StateError('The copilot engine rejected the request.');
      }
      // An engine with nothing to propose proposes nothing.
      if (text == null || text.isEmpty || _suggestions.isClosed) return;

      var lineIndex = 0;
      for (final line in text.split('\n')) {
        if (line.trim().isEmpty) continue;
        final suggestion = AIAssistantProvider.parseLine(
          sessionId: sessionId,
          suggestionId: '${sessionId}_${_sequence}_${lineIndex++}',
          line: line,
          createdAt: DateTime.now(),
        );
        if (suggestion != null && !_suggestions.isClosed) {
          _suggestions.add(suggestion);
        }
      }
    } catch (error) {
      // Fail closed and visibly: the flux carries the error, the copilot
      // is marked failed, and nothing pretends to have suggested.
      _status = AssistantStatus.failed;
      if (!_suggestions.isClosed) _suggestions.addError(error);
    }
  }

  @override
  Future<AssistantResult> stop() async {
    if (_status == AssistantStatus.assisting) {
      _status = AssistantStatus.stopped;
    }
    await _suggestions.close();
    return AssistantResult(sessionId: sessionId, status: _status);
  }
}
