import '../../ledger/models/ledger_transaction.dart';
import '../../ledger/posting/models/posting_request.dart';

import '../workflows/financial_posting/models/'
    'settlement_posting_instruction.dart';
import '../workflows/financial_posting/'
    'settlement_posting_port.dart';
import '../workflows/financial_posting/'
    'settlement_posting_receipt.dart';

import 'factories/'
    'settlement_component_posting_request_factory.dart';

typedef LedgerPostFunction =
    Future<LedgerTransaction> Function(PostingRequest request);

class SettlementPostingAdapter implements SettlementPostingPort {
  const SettlementPostingAdapter({
    required this.post,
    this.requestFactory = const SettlementComponentPostingRequestFactory(),
  });

  final LedgerPostFunction post;

  final SettlementComponentPostingRequestFactory requestFactory;

  @override
  Future<SettlementPostingReceipt> postSettlement({
    required SettlementPostingInstruction instruction,
  }) async {
    if (instruction.lines.isEmpty) {
      throw StateError('Settlement posting instruction contains no lines.');
    }

    if (instruction.totalMinorUnits <= 0) {
      throw StateError(
        'Settlement posting instruction total '
        'must be greater than zero.',
      );
    }

    final ledgerIds = <String>[];

    for (final line in instruction.lines) {
      final request = requestFactory.create(
        instruction: instruction,
        line: line,
      );

      final transaction = await post(request);

      ledgerIds.add(transaction.id);
    }

    return SettlementPostingReceipt(
      operationId: instruction.operationId,
      ledgerTransactionIds: List<String>.unmodifiable(ledgerIds),
    );
  }
}
