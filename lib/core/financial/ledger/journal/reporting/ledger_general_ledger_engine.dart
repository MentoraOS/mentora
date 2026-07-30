import '../../balance/ledger_normal_balance_calculator.dart';
import '../../chart/chart_of_accounts.dart';
import '../../models/ledger_account.dart';
import '../../models/ledger_account_type.dart';

import '../models/ledger_journal.dart';
import '../models/ledger_journal_entry.dart';
import '../models/ledger_journal_status.dart';
import '../repository/ledger_journal_repository.dart';

import 'ledger_general_ledger.dart';
import 'ledger_general_ledger_entry.dart';

/// Reconstructs the chronological general ledger of one account.
///
/// The engine is read-only and deterministic.
///
/// It:
/// - loads the requested account;
/// - reads accounting-active journals;
/// - extracts the entries belonging to the account;
/// - orders them chronologically;
/// - calculates the normal running balance;
/// - produces a complete [LedgerGeneralLedger].
final class LedgerGeneralLedgerEngine {
  const LedgerGeneralLedgerEngine({
    required this.repository,
    required this.chartOfAccounts,
    this.normalBalanceCalculator = const LedgerNormalBalanceCalculator(),
  });

  final LedgerJournalRepository repository;
  final ChartOfAccounts chartOfAccounts;
  final LedgerNormalBalanceCalculator normalBalanceCalculator;

  /// Generates the full-history general ledger for one account.
  ///
  /// [openingBalanceMinor] is generally zero for a complete historical
  /// reconstruction. It may contain a previous period's closing balance
  /// when this engine is later used for period-specific statements.
  Future<LedgerGeneralLedger> generate({
    required String accountId,
    int openingBalanceMinor = 0,
  }) async {
    final account = _loadAccount(accountId);

    final journals = await repository.findAll();

    return buildFromJournals(
      accountId: account.id,
      accountCurrency: account.currency,
      accountType: account.type,
      journals: journals,
      openingBalanceMinor: openingBalanceMinor,
    );
  }

  /// Builds a general ledger from an explicit journal collection.
  ///
  /// This method contains the deterministic projection algorithm and is
  /// useful for isolated testing and future reporting adapters.
  LedgerGeneralLedger buildFromJournals({
    required String accountId,
    required String accountCurrency,
    required LedgerAccountType accountType,
    required Iterable<LedgerJournal> journals,
    int openingBalanceMinor = 0,
  }) {
    final normalizedAccountId = _normalizeRequired(accountId, 'accountId');

    final normalizedCurrency = _normalizeCurrency(accountCurrency);

    final sourceLines = _collectSourceLines(
      accountId: normalizedAccountId,
      accountCurrency: normalizedCurrency,
      journals: journals,
    );

    _sortSourceLines(sourceLines);

    final projection = _buildEntries(
      accountId: normalizedAccountId,
      accountCurrency: normalizedCurrency,
      accountType: accountType,
      sourceLines: sourceLines,
      openingBalanceMinor: openingBalanceMinor,
    );

    return _buildLedger(
      accountId: normalizedAccountId,
      currency: normalizedCurrency,
      openingBalanceMinor: openingBalanceMinor,
      totalDebitMinor: projection.totalDebitMinor,
      totalCreditMinor: projection.totalCreditMinor,
      closingBalanceMinor: projection.closingBalanceMinor,
      entries: projection.entries,
    );
  }

  LedgerAccount _loadAccount(String accountId) {
    final normalizedAccountId = _normalizeRequired(accountId, 'accountId');

    final account = chartOfAccounts.getRequiredAccount(normalizedAccountId);

    if (!account.active) {
      throw StateError(
        'Cannot generate a general ledger for inactive account '
        '"${account.id}".',
      );
    }

    return account;
  }

  List<_GeneralLedgerSourceLine> _collectSourceLines({
    required String accountId,
    required String accountCurrency,
    required Iterable<LedgerJournal> journals,
  }) {
    final sourceLines = <_GeneralLedgerSourceLine>[];

    for (final journal in journals) {
      if (!_shouldIncludeJournal(journal.status)) {
        continue;
      }

      for (final entry in journal.entries) {
        if (entry.accountId != accountId) {
          continue;
        }

        final normalizedEntryCurrency = _normalizeCurrency(entry.currency);

        if (normalizedEntryCurrency != accountCurrency) {
          throw StateError(
            'Ledger entry "${entry.entryId}" uses currency '
            '"$normalizedEntryCurrency", but account '
            '"$accountId" uses "$accountCurrency".',
          );
        }

        sourceLines.add(
          _GeneralLedgerSourceLine(journal: journal, entry: entry),
        );
      }
    }

    return sourceLines;
  }

  void _sortSourceLines(List<_GeneralLedgerSourceLine> sourceLines) {
    sourceLines.sort((first, second) {
      final occurredComparison = first.journal.occurredAt.compareTo(
        second.journal.occurredAt,
      );

      if (occurredComparison != 0) {
        return occurredComparison;
      }

      final createdComparison = first.journal.createdAt.compareTo(
        second.journal.createdAt,
      );

      if (createdComparison != 0) {
        return createdComparison;
      }

      final journalComparison = first.journal.journalId.compareTo(
        second.journal.journalId,
      );

      if (journalComparison != 0) {
        return journalComparison;
      }

      return first.entry.entryId.compareTo(second.entry.entryId);
    });
  }

  _GeneralLedgerProjection _buildEntries({
    required String accountId,
    required String accountCurrency,
    required LedgerAccountType accountType,
    required List<_GeneralLedgerSourceLine> sourceLines,
    required int openingBalanceMinor,
  }) {
    var cumulativeDebitMinor = 0;
    var cumulativeCreditMinor = 0;

    final reportEntries = <LedgerGeneralLedgerEntry>[];

    for (final sourceLine in sourceLines) {
      final entry = sourceLine.entry;

      switch (entry.direction) {
        case LedgerJournalEntryDirection.debit:
          cumulativeDebitMinor += entry.amountMinor;

        case LedgerJournalEntryDirection.credit:
          cumulativeCreditMinor += entry.amountMinor;
      }

      final movementBalanceMinor = normalBalanceCalculator.calculate(
        accountType: accountType,
        debitMinor: cumulativeDebitMinor,
        creditMinor: cumulativeCreditMinor,
      );

      final runningBalanceMinor = openingBalanceMinor + movementBalanceMinor;

      reportEntries.add(
        LedgerGeneralLedgerEntry(
          journalId: sourceLine.journal.journalId,
          operationId: sourceLine.journal.operationId,
          workflowKey: sourceLine.journal.workflowKey,
          entryId: entry.entryId,
          accountId: accountId,
          currency: accountCurrency,
          direction: entry.direction,
          amountMinor: entry.amountMinor,
          runningBalanceMinor: runningBalanceMinor,
          occurredAt: sourceLine.journal.occurredAt,
          createdAt: sourceLine.journal.createdAt,
          description: entry.description,
        ),
      );
    }

    final closingMovementMinor = normalBalanceCalculator.calculate(
      accountType: accountType,
      debitMinor: cumulativeDebitMinor,
      creditMinor: cumulativeCreditMinor,
    );

    return _GeneralLedgerProjection(
      entries: List<LedgerGeneralLedgerEntry>.unmodifiable(reportEntries),
      totalDebitMinor: cumulativeDebitMinor,
      totalCreditMinor: cumulativeCreditMinor,
      closingBalanceMinor: openingBalanceMinor + closingMovementMinor,
    );
  }

  LedgerGeneralLedger _buildLedger({
    required String accountId,
    required String currency,
    required int openingBalanceMinor,
    required int closingBalanceMinor,
    required int totalDebitMinor,
    required int totalCreditMinor,
    required List<LedgerGeneralLedgerEntry> entries,
  }) {
    return LedgerGeneralLedger(
      accountId: accountId,
      currency: currency,
      entries: entries,
      openingBalanceMinor: openingBalanceMinor,
      closingBalanceMinor: closingBalanceMinor,
      totalDebitMinor: totalDebitMinor,
      totalCreditMinor: totalCreditMinor,
    );
  }

  bool _shouldIncludeJournal(LedgerJournalStatus status) {
    return switch (status) {
      LedgerJournalStatus.posted => true,

      // A reversed journal remains part of the immutable accounting
      // history. Its economic effect is cancelled by a separate posted
      // compensating journal.
      LedgerJournalStatus.reversed => true,

      LedgerJournalStatus.pending => false,
      LedgerJournalStatus.cancelled => false,
    };
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

final class _GeneralLedgerSourceLine {
  const _GeneralLedgerSourceLine({required this.journal, required this.entry});

  final LedgerJournal journal;
  final LedgerJournalEntry entry;
}

final class _GeneralLedgerProjection {
  const _GeneralLedgerProjection({
    required this.entries,
    required this.totalDebitMinor,
    required this.totalCreditMinor,
    required this.closingBalanceMinor,
  });

  final List<LedgerGeneralLedgerEntry> entries;
  final int totalDebitMinor;
  final int totalCreditMinor;
  final int closingBalanceMinor;
}
