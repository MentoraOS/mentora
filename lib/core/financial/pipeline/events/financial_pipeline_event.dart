abstract base class FinancialPipelineEvent {
  const FinancialPipelineEvent({
    required this.pipelineId,
    required this.occurredAt,
  });

  /// Pipeline identifier.
  final String pipelineId;

  /// UTC timestamp.
  final DateTime occurredAt;
}
