import '../../models/ledger_entry.dart';
import '../../models/ledger_entry_side.dart';
import '../../models/ledger_transaction.dart';

import '../models/ledger_journal.dart';
import '../models/ledger_journal_entry.dart';
import '../models/ledger_journal_source.dart';
import '../models/ledger_journal_status.dart';

// Converts a transaction-oriented ledger posting into an immutable journal.
//
// This factory is pure and deterministic:
// - it performs no persistence;
// - it does not post the journal;
// - it does not generate dates implicitly;
// - it preserves the original transaction accounting data.
//
// The produced journal starts as [LedgerJournalStatus.pending].
// A [LedgerJournalEngine] is responsible for creating and posting it.
final class LedgerJournalFactory {
  const LedgerJournalFactory();

  LedgerJournal create({
    required LedgerTransaction transaction,
    required String journalId,
    required String workflowKey,
    required LedgerJournalSource source,
    DateTime? occurredAt,
    DateTime? createdAt,
    Map<String, dynamic> metadata = const {},
  }) {
    final normalizedJournalId = _normalizeRequired(journalId, 'journalId');

    final normalizedWorkflowKey = _normalizeRequired(
      workflowKey,
      'workflowKey',
    );

    _validateTransaction(transaction);

    final normalizedOccurredAt = (occurredAt ?? transaction.createdAt).toUtc();

    final normalizedCreatedAt = (createdAt ?? transaction.createdAt).toUtc();

    if (normalizedCreatedAt.isBefore(normalizedOccurredAt)) {
      throw ArgumentError('Journal createdAt cannot be before occurredAt.');
    }

    final journalEntries = transaction.entries
        .map(
          (entry) =>
              _createJournalEntry(transaction: transaction, entry: entry),
        )
        .toList(growable: false);

    final journal = LedgerJournal(
      journalId: normalizedJournalId,

      // The transaction ID is already the posting idempotency key.
      operationId: transaction.id,

      workflowKey: normalizedWorkflowKey,
      source: source,
      status: LedgerJournalStatus.pending,
      occurredAt: normalizedOccurredAt,
      createdAt: normalizedCreatedAt,
      entries: journalEntries,
      metadata: {
        ...transaction.metadata,
        ...metadata,
        'ledgerTransactionId': transaction.id,
        'ledgerReferenceId': transaction.referenceId,
        'ledgerTransactionStatus': transaction.status.name,
        'ledgerTransactionDescription': transaction.description,
        'journalCreatedBy': 'ledger_journal_factory',
      },
    );

    _validateJournalProjection(transaction: transaction, journal: journal);

    return journal;
  }

  LedgerJournalEntry _createJournalEntry({
    required LedgerTransaction transaction,
    required LedgerEntry entry,
  }) {
    return LedgerJournalEntry(
      // Preserve the original ledger entry identity.
      entryId: entry.id,
      accountId: entry.accountId,
      direction: _mapDirection(entry.side),
      amountMinor: entry.amountMinor,
      currency: entry.currency,
      description: transaction.description,
      metadata: {
        'ledgerEntryId': entry.id,
        'ledgerTransactionId': entry.transactionId,
        'ledgerEntryCreatedAt': entry.createdAt.toUtc().toIso8601String(),
        'ledgerReferenceId': transaction.referenceId,
      },
    );
  }

  LedgerJournalEntryDirection _mapDirection(LedgerEntrySide side) {
    return switch (side) {
      LedgerEntrySide.debit => LedgerJournalEntryDirection.debit,
      LedgerEntrySide.credit => LedgerJournalEntryDirection.credit,
    };
  }

  void _validateTransaction(LedgerTransaction transaction) {
    _normalizeRequired(transaction.id, 'transaction.id');

    _normalizeRequired(transaction.referenceId, 'transaction.referenceId');

    _normalizeRequired(transaction.description, 'transaction.description');

    final normalizedCurrency = _normalizeCurrency(transaction.currency);

    if (transaction.entries.length < 2) {
      throw ArgumentError(
        'A ledger journal requires at least two '
        'transaction entries.',
      );
    }

    if (!transaction.isBalanced) {
      throw StateError(
        'Ledger transaction "${transaction.id}" '
        'cannot be journalized because it is unbalanced.',
      );
    }

    for (final entry in transaction.entries) {
      if (entry.transactionId != transaction.id) {
        throw StateError(
          'Ledger entry "${entry.id}" belongs to '
          'transaction "${entry.transactionId}" instead '
          'of "${transaction.id}".',
        );
      }

      if (_normalizeCurrency(entry.currency) != normalizedCurrency) {
        throw StateError(
          'Ledger entry "${entry.id}" uses currency '
          '"${entry.currency}" instead of '
          '"$normalizedCurrency".',
        );
      }
    }

    final entryIds = <String>{};

    for (final entry in transaction.entries) {
      final normalizedEntryId = _normalizeRequired(entry.id, 'entry.id');

      if (!entryIds.add(normalizedEntryId)) {
        throw StateError(
          'Duplicate ledger entry ID '
          '"$normalizedEntryId" in transaction '
          '"${transaction.id}".',
        );
      }
    }
  }

  void _validateJournalProjection({
    required LedgerTransaction transaction,
    required LedgerJournal journal,
  }) {
    if (!journal.isBalanced) {
      throw StateError(
        'Journal "${journal.journalId}" generated from '
        'transaction "${transaction.id}" is unbalanced.',
      );
    }

    if (journal.containsMultipleCurrencies) {
      throw StateError(
        'Journal "${journal.journalId}" generated from '
        'transaction "${transaction.id}" contains '
        'multiple currencies.',
      );
    }

    if (journal.entries.length != transaction.entries.length) {
      throw StateError(
        'Journal projection lost ledger entries. '
        'Expected ${transaction.entries.length}, '
        'received ${journal.entries.length}.',
      );
    }

    if (journal.debitAmountMinor != transaction.totalDebits) {
      throw StateError(
        'Journal debit total '
        '${journal.debitAmountMinor} does not match '
        'transaction debit total '
        '${transaction.totalDebits}.',
      );
    }

    if (journal.creditAmountMinor != transaction.totalCredits) {
      throw StateError(
        'Journal credit total '
        '${journal.creditAmountMinor} does not match '
        'transaction credit total '
        '${transaction.totalCredits}.',
      );
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

  String _normalizeCurrency(String currency) {
    final normalized = currency.trim().toUpperCase();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        currency,
        'currency',
        'Currency cannot be empty.',
      );
    }

    return normalized;
  }
}
