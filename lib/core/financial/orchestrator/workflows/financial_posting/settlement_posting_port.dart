import 'models/settlement_posting_instruction.dart';
import 'settlement_posting_receipt.dart';

abstract interface class SettlementPostingPort {
  Future<SettlementPostingReceipt> postSettlement({
    required SettlementPostingInstruction instruction,
  });
}
