import '../../models/ledger_transaction.dart';
import '../../posting/engine/posting_engine.dart';

import '../engine/ledger_journal_engine.dart';
import '../models/ledger_journal.dart';
import '../models/ledger_journal_status.dart';

import 'ledger_journal_factory.dart';
import 'ledger_journal_posting_request.dart';
import 'ledger_journal_posting_result.dart';

/// Coordinates transaction posting and journal posting.
///
/// Execution flow:
///
/// PostingRequest
///   -> PostingEngine.post()
///   -> LedgerTransaction
///   -> LedgerJournalFactory.create()
///   -> LedgerJournalEngine.create()
///   -> LedgerJournalEngine.post()
///
/// The bridge is also idempotent on journal operationId:
/// if a journal already exists for the posted transaction, the existing
/// journal is returned instead of creating a duplicate.
final class LedgerJournalPostingBridge {
  const LedgerJournalPostingBridge({
    required this.postingEngine,
    required this.journalFactory,
    required this.journalEngine,
  });

  final PostingEngine postingEngine;
  final LedgerJournalFactory journalFactory;
  final LedgerJournalEngine journalEngine;

  Future<LedgerJournalPostingResult> post({
    required LedgerJournalPostingRequest request,
  }) async {
    _validateRequest(request);

    final postedTransaction = await postingEngine.post(request.postingRequest);

    final existingJournal = await journalEngine.findByOperationId(
      postedTransaction.id,
    );

    if (existingJournal != null) {
      final resolvedExisting = await _ensurePosted(existingJournal);

      _validateCoherence(
        transaction: postedTransaction,
        journal: resolvedExisting,
      );

      return LedgerJournalPostingResult(
        transaction: postedTransaction,
        journal: resolvedExisting,
        wasAlreadyJournalized: true,
      );
    }

    final pendingJournal = journalFactory.create(
      transaction: postedTransaction,
      journalId: request.journalId,
      workflowKey: request.workflowKey,
      source: request.source,
      occurredAt: request.occurredAt,
      createdAt: request.createdAt,
      metadata: request.metadata,
    );

    final createdJournal = await journalEngine.create(pendingJournal);

    final postedJournal = await journalEngine.post(createdJournal.journalId);

    _validateCoherence(transaction: postedTransaction, journal: postedJournal);

    return LedgerJournalPostingResult(
      transaction: postedTransaction,
      journal: postedJournal,
      wasAlreadyJournalized: false,
    );
  }

  Future<LedgerJournal> _ensurePosted(LedgerJournal journal) async {
    return switch (journal.status) {
      LedgerJournalStatus.posted => journal,
      LedgerJournalStatus.pending => journalEngine.post(journal.journalId),
      LedgerJournalStatus.cancelled => throw StateError(
        'Journal "${journal.journalId}" already exists for operation '
        '"${journal.operationId}" but is cancelled.',
      ),
      LedgerJournalStatus.reversed => throw StateError(
        'Journal "${journal.journalId}" already exists for operation '
        '"${journal.operationId}" but is reversed.',
      ),
    };
  }

  void _validateRequest(LedgerJournalPostingRequest request) {
    _normalizeRequired(request.journalId, 'journalId');

    _normalizeRequired(request.workflowKey, 'workflowKey');

    if (request.createdAt != null &&
        request.occurredAt != null &&
        request.createdAt!.toUtc().isBefore(request.occurredAt!.toUtc())) {
      throw ArgumentError('Journal createdAt cannot be before occurredAt.');
    }
  }

  void _validateCoherence({
    required LedgerTransaction transaction,
    required LedgerJournal journal,
  }) {
    if (journal.operationId != transaction.id) {
      throw StateError(
        'Journal operationId "${journal.operationId}" does not match '
        'transaction id "${transaction.id}".',
      );
    }

    if (journal.status != LedgerJournalStatus.posted) {
      throw StateError(
        'Journal "${journal.journalId}" must be posted after bridge '
        'execution, but its status is "${journal.status.name}".',
      );
    }

    if (journal.entries.length != transaction.entries.length) {
      throw StateError(
        'Journal "${journal.journalId}" contains '
        '${journal.entries.length} entries while transaction '
        '"${transaction.id}" contains ${transaction.entries.length}.',
      );
    }

    if (journal.debitAmountMinor != transaction.totalDebits) {
      throw StateError(
        'Journal debit total ${journal.debitAmountMinor} does not match '
        'transaction debit total ${transaction.totalDebits}.',
      );
    }

    if (journal.creditAmountMinor != transaction.totalCredits) {
      throw StateError(
        'Journal credit total ${journal.creditAmountMinor} does not match '
        'transaction credit total ${transaction.totalCredits}.',
      );
    }

    if (!journal.isBalanced) {
      throw StateError('Journal "${journal.journalId}" is not balanced.');
    }

    final transactionCurrency = transaction.currency.trim().toUpperCase();

    final journalCurrencies = journal.entries
        .map((entry) => entry.currency.trim().toUpperCase())
        .toSet();

    if (journalCurrencies.length != 1 ||
        journalCurrencies.single != transactionCurrency) {
      throw StateError(
        'Journal currencies $journalCurrencies do not match transaction '
        'currency "$transactionCurrency".',
      );
    }

    final transactionEntriesById = {
      for (final entry in transaction.entries) entry.id: entry,
    };

    for (final journalEntry in journal.entries) {
      final transactionEntry = transactionEntriesById[journalEntry.entryId];

      if (transactionEntry == null) {
        throw StateError(
          'Journal entry "${journalEntry.entryId}" has no matching '
          'transaction entry.',
        );
      }

      if (journalEntry.accountId != transactionEntry.accountId) {
        throw StateError(
          'Account mismatch for entry "${journalEntry.entryId}".',
        );
      }

      if (journalEntry.amountMinor != transactionEntry.amountMinor) {
        throw StateError(
          'Amount mismatch for entry "${journalEntry.entryId}".',
        );
      }

      if (journalEntry.currency.trim().toUpperCase() !=
          transactionEntry.currency.trim().toUpperCase()) {
        throw StateError(
          'Currency mismatch for entry "${journalEntry.entryId}".',
        );
      }
    }
  }

  String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName cannot be empty.',
      );
    }

    return normalized;
  }
}
