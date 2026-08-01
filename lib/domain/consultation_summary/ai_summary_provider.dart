import '../consultation_memory/consultation_memory.dart';

/// Real summary engine boundary.
///
/// The provider receives ONLY the consultation memory — never any other
/// business module — and returns the generated summary. The mandatory
/// chain behind it is fixed by governance: the summary application
/// service -> this port -> the AI gateway -> the engine adapter. The
/// Application layer never knows which engine answered.
abstract interface class AISummaryProvider {
  Future<SummaryGenerationResult> generate({
    required String bookingId,
    required ConsultationMemory memory,
  });
}

/// The generated summary — exactly these three facts, nothing else.
final class SummaryGenerationResult {
  final String summaryText;

  /// The engine kind that produced the text (e.g. an [Enum] name).
  final String provider;

  final DateTime generatedAt;

  factory SummaryGenerationResult({
    required String summaryText,
    required String provider,
    required DateTime generatedAt,
  }) {
    if (summaryText.trim().isEmpty) {
      throw ArgumentError.value(
        summaryText,
        'summaryText',
        'must not be empty',
      );
    }

    return SummaryGenerationResult._(
      summaryText: summaryText,
      provider: provider,
      generatedAt: generatedAt,
    );
  }

  const SummaryGenerationResult._({
    required this.summaryText,
    required this.provider,
    required this.generatedAt,
  });
}
