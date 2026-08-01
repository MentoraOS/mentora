import '../../domain/ai_gateway/ai_gateway.dart';
import '../../domain/ai_gateway/ai_provider.dart';
import '../../domain/consultation_memory/consultation_memory.dart';
import '../../domain/consultation_summary/ai_summary_provider.dart';

/// The real summary provider: builds the summary prompt from the
/// consultation memory and routes it through the AI GATEWAY ONLY —
/// never an engine SDK, never an HTTP call, never another business
/// module. The gateway routes [AITask.summary] to whichever engine is
/// registered for it; this class never knows which.
final class GatewayAISummaryProvider implements AISummaryProvider {
  const GatewayAISummaryProvider({required AIGateway gateway})
    : _gateway = gateway;

  final AIGateway _gateway;

  @override
  Future<SummaryGenerationResult> generate({
    required String bookingId,
    required ConsultationMemory memory,
  }) async {
    final response = await _gateway.execute(
      AIRequest(
        requestId: 'summary_$bookingId',
        task: AITask.summary,
        text: buildPrompt(memory),
        context: {'bookingId': bookingId},
      ),
    );

    final text = response.text?.trim();
    if (response.status != AIResponseStatus.accepted ||
        text == null ||
        text.isEmpty) {
      // Fail closed: an engine that answers nothing is a failure, never
      // an empty official summary.
      throw StateError('The summary engine returned no usable text.');
    }

    return SummaryGenerationResult(
      summaryText: text,
      provider: response.providerType.name,
      generatedAt: DateTime.now(),
    );
  }

  /// THE summary prompt — it belongs HERE, in Infrastructure, and nowhere
  /// else. Replace this method to change how summaries are asked for; no
  /// other layer is involved. It renders the memory's recorded business
  /// facts chronologically and asks for a short professional summary in
  /// French. Facts are rendered verbatim; private-note facts carry no
  /// content by design and therefore leak nothing.
  static String buildPrompt(ConsultationMemory memory) {
    final buffer = StringBuffer()
      ..writeln(
        'Tu es l’assistant de Mentora, une plateforme de consultation '
        'entre clients et experts.',
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
        'Rédige un résumé professionnel, factuel et concis de cette '
        'consultation en français (5 à 8 phrases). N’invente aucun fait.',
      );
    return buffer.toString();
  }
}
