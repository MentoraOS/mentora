import 'ledger_journal_transaction.dart';
import 'ledger_journal_transaction_context.dart';
import 'ledger_journal_transaction_exception.dart';
import 'ledger_journal_transaction_result.dart';

final class MemoryLedgerJournalTransaction implements LedgerJournalTransaction {
  const MemoryLedgerJournalTransaction();

  @override
  Future<LedgerJournalTransactionResult> execute({
    required LedgerJournalTransactionContext context,

    required Future<void> Function() action,
  }) async {
    try {
      await action();

      return const LedgerJournalTransactionResult(success: true);
    } catch (error) {
      throw LedgerJournalTransactionException(
        'Ledger transaction failed: $error',
      );
    }
  }
}
