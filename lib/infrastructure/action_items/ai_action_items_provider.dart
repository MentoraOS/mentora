import 'dart:async';

import '../../domain/action_items/action_item.dart';
import '../../domain/action_items/action_items_provider.dart';
import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../../domain/consultation_memory/consultation_memory.dart';

/// The real action-items provider: turns the memory's recorded facts
/// into a living flux of INDIVIDUAL action proposals by routing through
/// the AI GATEWAY ONLY — never an engine SDK, never a network call,
/// never a business module. The gateway routes [AITask.actionItems] to
/// whichever engine is registered for it; this class never knows which.
final class AIActionItemsProvider implements ActionItemsProvider {
  const AIActionItemsProvider({required AIGateway gateway})
    : _gateway = gateway;

  final AIGateway _gateway;

  @override
  Future<ActionItemsStream> start({
    required String sessionId,
    required ConsultationMemory memory,
  }) async {
    final stream = _GatewayActionItemsStream(
      gateway: _gateway,
      sessionId: sessionId,
    );
    // The first look at the memory runs one tick later so subscribers
    // attached right after start() always precede the first proposals.
    unawaited(
      Future<void>.delayed(Duration.zero).then((_) => stream.refresh(memory)),
    );
    return stream;
  }

  /// THE action-items prompt — it belongs HERE, in Infrastructure, and
  /// nowhere else. The engine must answer ONE action per line as
  /// `PRIORITE;TITRE;DESCRIPTION` (priority LOW, NORMAL or HIGH) — never
  /// a list packed into one line; anything else is dropped, never
  /// guessed.
  static String buildPrompt(ConsultationMemory memory) {
    final buffer = StringBuffer()
      ..writeln(
        'Tu recommandes les prochaines étapes d’une consultation Mentora. '
        'Tu proposes uniquement : tu ne décides rien, tu n’exécutes rien, '
        'l’expert reste seul décisionnaire.',
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
        'Propose au plus 5 actions concrètes. Réponds UNIQUEMENT avec UNE '
        'action par ligne, au format exact : PRIORITE;TITRE;DESCRIPTION — '
        'où PRIORITE vaut LOW, NORMAL ou HIGH. Jamais plusieurs actions '
        'sur une même ligne. Aucun autre texte.',
      );
    return buffer.toString();
  }

  /// Parses one engine line into ONE action; unparseable lines are
  /// dropped — proposals are never guessed.
  static ActionItem? parseLine({
    required String sessionId,
    required String actionId,
    required String line,
    required DateTime createdAt,
  }) {
    final parts = line.split(';');
    if (parts.length < 3) return null;

    final priority = switch (parts.first.trim().toUpperCase()) {
      'LOW' => ActionItemPriority.low,
      'NORMAL' => ActionItemPriority.normal,
      'HIGH' => ActionItemPriority.high,
      _ => null,
    };
    final title = parts[1].trim();
    final description = parts.sublist(2).join(';').trim();
    if (priority == null || title.isEmpty || description.isEmpty) return null;

    return ActionItem(
      sessionId: sessionId,
      actionId: actionId,
      title: title,
      description: description,
      priority: priority,
      createdAt: createdAt,
    );
  }
}

final class _GatewayActionItemsStream implements ActionItemsStream {
  _GatewayActionItemsStream({
    required AIGateway gateway,
    required this.sessionId,
  }) : _gateway = gateway;

  final AIGateway _gateway;
  final String sessionId;

  final StreamController<ActionItem> _items =
      StreamController<ActionItem>.broadcast();

  ActionItemsStatus _status = ActionItemsStatus.proposing;
  int _sequence = 0;

  @override
  ActionItemsStatus get status => _status;

  @override
  Stream<ActionItem> get items => _items.stream;

  @override
  Future<void> refresh(ConsultationMemory memory) async {
    if (_status != ActionItemsStatus.proposing) return;

    try {
      final response = await _gateway.execute(
        AIRequest(
          requestId: 'action_items_${sessionId}_${_sequence++}',
          task: AITask.actionItems,
          text: AIActionItemsProvider.buildPrompt(memory),
          context: {'sessionId': sessionId},
        ),
      );

      final text = response.text?.trim();
      if (response.status != AIResponseStatus.accepted) {
        throw StateError('The action-items engine rejected the request.');
      }
      // An engine with nothing to propose proposes nothing.
      if (text == null || text.isEmpty || _items.isClosed) return;

      var lineIndex = 0;
      for (final line in text.split('\n')) {
        if (line.trim().isEmpty) continue;
        final item = AIActionItemsProvider.parseLine(
          sessionId: sessionId,
          actionId: '${sessionId}_${_sequence}_${lineIndex++}',
          line: line,
          createdAt: DateTime.now(),
        );
        if (item != null && !_items.isClosed) {
          _items.add(item);
        }
      }
    } catch (error) {
      // Fail closed and visibly: the flux carries the error, the stream
      // is marked failed, and nothing pretends to have proposed.
      _status = ActionItemsStatus.failed;
      if (!_items.isClosed) _items.addError(error);
    }
  }

  @override
  Future<ActionItemsResult> stop() async {
    if (_status == ActionItemsStatus.proposing) {
      _status = ActionItemsStatus.stopped;
    }
    await _items.close();
    return ActionItemsResult(sessionId: sessionId, status: _status);
  }
}
