import '../../../fees/models/fee_quote.dart';
import '../../../splits/models/settlement_split.dart';
import '../financial_posting/financial_posting_result.dart';

class FinalizeConsultationSettlementResult {
  final bool success;

  final String operationId;
  final String consultationId;

  final FeeQuote feeQuote;
  final SettlementSplit split;
  final FinancialPostingResult postingResult;

  final DateTime finalizedAt;

  const FinalizeConsultationSettlementResult({
    required this.success,
    required this.operationId,
    required this.consultationId,
    required this.feeQuote,
    required this.split,
    required this.postingResult,
    required this.finalizedAt,
  });

  List<String> get ledgerTransactionIds {
    return postingResult.ledgerTransactionIds;
  }

  String get primaryLedgerTransactionId {
    return postingResult.primaryLedgerTransactionId;
  }

  bool get isFinanciallyBalanced {
    return feeQuote.isBalanced &&
        split.isBalanced &&
        feeQuote.grossAmountMinor == split.grossAmountMinor &&
        feeQuote.currency == split.currency;
  }
}
