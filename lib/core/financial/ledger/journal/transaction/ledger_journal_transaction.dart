import 'ledger_journal_transaction_context.dart';
import 'ledger_journal_transaction_result.dart';

abstract interface class LedgerJournalTransaction {
  Future<LedgerJournalTransactionResult> execute({
    required LedgerJournalTransactionContext context,

    required Future<void> Function() action,
  });
}
