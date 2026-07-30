import 'models/settlement_posting_instruction.dart';

class FinancialPostingContext {
  final String operationId;
  final String consultationId;
  final String escrowId;

  final String clientId;
  final String expertId;

  final DateTime occurredAt;
  final Map<String, dynamic> metadata;

  final SettlementPostingInstruction instruction;

  const FinancialPostingContext({
    required this.operationId,
    required this.consultationId,
    required this.escrowId,
    required this.clientId,
    required this.expertId,
    required this.occurredAt,
    this.metadata = const {},
    required this.instruction,
  });
}
