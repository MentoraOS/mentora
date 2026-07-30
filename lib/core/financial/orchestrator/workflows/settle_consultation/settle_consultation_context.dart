class SettleConsultationContext {
  final String operationId;
  final String consultationId;
  final String paymentId;
  final String escrowId;

  final String clientId;
  final String expertId;

  final int grossAmountMinor;
  final String currency;

  final DateTime occurredAt;
  final Map<String, dynamic> metadata;

  const SettleConsultationContext({
    required this.operationId,
    required this.consultationId,
    required this.paymentId,
    required this.escrowId,
    required this.clientId,
    required this.expertId,
    required this.grossAmountMinor,
    required this.currency,
    required this.occurredAt,
    this.metadata = const {},
  });
}
