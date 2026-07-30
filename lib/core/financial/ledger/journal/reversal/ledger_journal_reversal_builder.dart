import '../models/ledger_journal.dart';
import '../models/ledger_journal_entry.dart';
import '../models/ledger_journal_source.dart';
import '../models/ledger_journal_status.dart';

import 'ledger_journal_reversal_request.dart';
import 'ledger_journal_reversal_result.dart';

// Builds a compensating journal by reversing every accounting entry.
//
// This builder is deterministic and has no side effects:
// it does not persist journals and does not change their statuses.
final class LedgerJournalReversalBuilder {
  const LedgerJournalReversalBuilder();

  LedgerJournalReversalResult build({
    required LedgerJournal original,
    required LedgerJournalReversalRequest request,
  }) {
    _validateOriginal(original: original, request: request);

    final reversalEntries = original.entries
        .asMap()
        .entries
        .map(
          (indexedEntry) => _reverseEntry(
            originalJournal: original,
            originalEntry: indexedEntry.value,
            index: indexedEntry.key,
            reversalJournalId: request.reversalJournalId,
          ),
        )
        .toList(growable: false);

    final reversalJournal = LedgerJournal(
      journalId: request.reversalJournalId,
      operationId: request.reversalOperationId,
      workflowKey: '${original.workflowKey}.reversal',
      source: LedgerJournalSource(
        type: 'ledger_reversal',
        id: original.journalId,
      ),
      status: LedgerJournalStatus.pending,
      occurredAt: request.occurredAt,
      createdAt: request.createdAt,
      entries: reversalEntries,
      metadata: {
        ...original.metadata,
        ...request.metadata,
        'reversalOfJournalId': original.journalId,
        'reversalOfOperationId': original.operationId,
        'reversalReason': request.reason,
        'originalWorkflowKey': original.workflowKey,
      },
    );

    if (!reversalJournal.isBalanced) {
      throw StateError('The generated reversal journal is not balanced.');
    }

    if (reversalJournal.containsMultipleCurrencies) {
      throw StateError(
        'The generated reversal journal contains '
        'multiple currencies.',
      );
    }

    return LedgerJournalReversalResult(
      originalJournal: original,
      reversalJournal: reversalJournal,
    );
  }

  LedgerJournalEntry _reverseEntry({
    required LedgerJournal originalJournal,
    required LedgerJournalEntry originalEntry,
    required int index,
    required String reversalJournalId,
  }) {
    final reversedDirection =
        originalEntry.direction == LedgerJournalEntryDirection.debit
        ? LedgerJournalEntryDirection.credit
        : LedgerJournalEntryDirection.debit;

    return LedgerJournalEntry(
      entryId: '${reversalJournalId}entry${index + 1}',
      accountId: originalEntry.accountId,
      direction: reversedDirection,
      amountMinor: originalEntry.amountMinor,
      currency: originalEntry.currency,
      description:
          'Reversal of ${originalEntry.entryId}: '
          '${originalEntry.description}',
      metadata: {
        ...originalEntry.metadata,
        'reversalOfEntryId': originalEntry.entryId,
        'reversalOfJournalId': originalJournal.journalId,
      },
    );
  }

  void _validateOriginal({
    required LedgerJournal original,
    required LedgerJournalReversalRequest request,
  }) {
    if (original.journalId != request.originalJournalId) {
      throw ArgumentError(
        'The reversal request originalJournalId does '
        'not match the supplied journal.',
      );
    }

    if (original.status != LedgerJournalStatus.posted) {
      throw StateError('Only a posted ledger journal can be reversed.');
    }

    if (!original.isBalanced) {
      throw StateError('An unbalanced ledger journal cannot be reversed.');
    }

    if (original.containsMultipleCurrencies) {
      throw StateError('A multi-currency ledger journal cannot be reversed.');
    }

    if (request.reversalOperationId == original.operationId) {
      throw ArgumentError(
        'The reversal operation ID must differ from the '
        'original operation ID.',
      );
    }
  }
}
