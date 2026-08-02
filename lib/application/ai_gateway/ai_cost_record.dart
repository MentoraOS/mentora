/// One AI cost record — INTERNAL to the orchestrator. CONTRACT ONLY.
///
/// Immutable, with ONLY optional fields: an unknown value stays null,
/// forever — no computation, no automatic estimation, no invented
/// number, no deduced price. Engines that report their own figures will
/// fill these fields through their own waves; nothing else may.
final class AICostRecord {
  final String? requestId;
  final String? provider;
  final String? model;
  final int? estimatedInputTokens;
  final int? estimatedOutputTokens;
  final int? estimatedTotalTokens;
  final num? estimatedCost;
  final String? currency;
  final DateTime? createdAt;

  const AICostRecord({
    this.requestId,
    this.provider,
    this.model,
    this.estimatedInputTokens,
    this.estimatedOutputTokens,
    this.estimatedTotalTokens,
    this.estimatedCost,
    this.currency,
    this.createdAt,
  });
}
