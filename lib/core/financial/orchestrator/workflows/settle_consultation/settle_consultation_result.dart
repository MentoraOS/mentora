import '../../../fees/models/fee_quote.dart';

class SettleConsultationResult {
  final bool success;
  final String operationId;
  final String consultationId;
  final FeeQuote feeQuote;
  final DateTime settledAt;

  const SettleConsultationResult({
    required this.success,
    required this.operationId,
    required this.consultationId,
    required this.feeQuote,
    required this.settledAt,
  });
}
