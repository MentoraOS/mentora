import '../models/ledger_journal.dart';
import '../models/ledger_journal_entry.dart';
import '../models/ledger_journal_status.dart';
import '../repository/ledger_journal_repository.dart';

import 'ledger_trial_balance.dart';
import 'ledger_trial_balance_entry.dart';

/// Builds an accounting trial balance from ledger journals.
///
/// The engine is read-only:
/// - it never modifies journals;
/// - it never writes to the repository;
/// - it aggregates only journals included by the reporting rules.
///
/// Entries are grouped by account ID and currency. The same account used
/// with two currencies therefore produces two distinct trial-balance lines.
final class LedgerTrialBalanceEngine {
  const LedgerTrialBalanceEngine({required this.repository});

  final LedgerJournalRepository repository;

  /// Builds a trial balance from all active accounting journals.
  ///
  /// Included statuses:
  /// - posted;
  /// - reversed.
  ///
  /// A journal marked as [LedgerJournalStatus.reversed] remains part of the
  /// accounting history because its economic effect is neutralized by a
  /// separate posted compensating journal.
  ///
  /// Excluded statuses:
  /// - pending;
  /// - cancelled.
  Future<LedgerTrialBalance> build() async {
    final journals = await repository.findAll();

    return buildFromJournals(journals);
  }

  /// Builds a trial balance from an explicit journal collection.
  ///
  /// This method keeps the aggregation logic deterministic and easy to test
  /// without requiring repository access.
  LedgerTrialBalance buildFromJournals(Iterable<LedgerJournal> journals) {
    final aggregates =
        <_LedgerTrialBalanceAggregationKey, _MutableAccountAggregate>{};

    for (final journal in journals) {
      if (!_shouldInclude(journal)) {
        continue;
      }

      for (final entry in journal.entries) {
        final key = _LedgerTrialBalanceAggregationKey(
          accountId: entry.accountId,
          currency: entry.currency,
        );

        final aggregate = aggregates.putIfAbsent(
          key,
          () => _MutableAccountAggregate(
            accountId: entry.accountId,
            currency: entry.currency,
          ),
        );

        aggregate.add(entry);
      }
    }

    final entries =
        aggregates.values
            .map((aggregate) => aggregate.toEntry())
            .toList(growable: true)
          ..sort(_compareEntries);

    return LedgerTrialBalance(entries: entries);
  }

  /// Builds a trial balance restricted to one currency.
  Future<LedgerTrialBalance> buildForCurrency(String currency) async {
    final normalizedCurrency = _normalizeCurrency(currency);

    final journals = await repository.findAll();

    final aggregates =
        <_LedgerTrialBalanceAggregationKey, _MutableAccountAggregate>{};

    for (final journal in journals) {
      if (!_shouldInclude(journal)) {
        continue;
      }

      for (final entry in journal.entries) {
        if (entry.currency != normalizedCurrency) {
          continue;
        }

        final key = _LedgerTrialBalanceAggregationKey(
          accountId: entry.accountId,
          currency: entry.currency,
        );

        final aggregate = aggregates.putIfAbsent(
          key,
          () => _MutableAccountAggregate(
            accountId: entry.accountId,
            currency: entry.currency,
          ),
        );

        aggregate.add(entry);
      }
    }

    final entries =
        aggregates.values
            .map((aggregate) => aggregate.toEntry())
            .toList(growable: true)
          ..sort(_compareEntries);

    return LedgerTrialBalance(entries: entries);
  }

  /// Builds a trial balance for an occurrence interval.
  ///
  /// [from] is inclusive and [to] is exclusive.
  Future<LedgerTrialBalance> buildForPeriod({
    required DateTime from,
    required DateTime to,
  }) async {
    final normalizedFrom = from.toUtc();
    final normalizedTo = to.toUtc();

    if (!normalizedFrom.isBefore(normalizedTo)) {
      throw ArgumentError('Trial-balance period start must be before its end.');
    }

    final journals = await repository.findOccurredBetween(
      from: normalizedFrom,
      to: normalizedTo,
    );

    return buildFromJournals(journals);
  }

  /// Builds a trial balance for a specific workflow.
  Future<LedgerTrialBalance> buildForWorkflow(String workflowKey) async {
    final normalizedWorkflowKey = _normalizeRequired(
      workflowKey,
      'workflowKey',
    );

    final journals = await repository.findByWorkflowKey(normalizedWorkflowKey);

    return buildFromJournals(journals);
  }

  bool _shouldInclude(LedgerJournal journal) {
    return switch (journal.status) {
      LedgerJournalStatus.posted => true,
      LedgerJournalStatus.reversed => true,
      LedgerJournalStatus.pending => false,
      LedgerJournalStatus.cancelled => false,
    };
  }

  int _compareEntries(
    LedgerTrialBalanceEntry first,
    LedgerTrialBalanceEntry second,
  ) {
    final currencyComparison = first.currency.compareTo(second.currency);

    if (currencyComparison != 0) {
      return currencyComparison;
    }

    return first.accountId.compareTo(second.accountId);
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

final class _LedgerTrialBalanceAggregationKey {
  const _LedgerTrialBalanceAggregationKey({
    required this.accountId,
    required this.currency,
  });

  final String accountId;
  final String currency;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _LedgerTrialBalanceAggregationKey &&
            other.accountId == accountId &&
            other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(accountId, currency);
}

final class _MutableAccountAggregate {
  _MutableAccountAggregate({required this.accountId, required this.currency});

  final String accountId;
  final String currency;

  int totalDebitMinor = 0;
  int totalCreditMinor = 0;
  int entryCount = 0;

  void add(LedgerJournalEntry entry) {
    if (entry.accountId != accountId) {
      throw StateError(
        'Cannot aggregate entry "${entry.entryId}" into account '
        '"$accountId".',
      );
    }

    if (entry.currency != currency) {
      throw StateError(
        'Cannot aggregate entry "${entry.entryId}" with currency '
        '"${entry.currency}" into "$currency".',
      );
    }

    switch (entry.direction) {
      case LedgerJournalEntryDirection.debit:
        totalDebitMinor += entry.amountMinor;

      case LedgerJournalEntryDirection.credit:
        totalCreditMinor += entry.amountMinor;
    }

    entryCount++;
  }

  LedgerTrialBalanceEntry toEntry() {
    return LedgerTrialBalanceEntry(
      accountId: accountId,
      currency: currency,
      totalDebitMinor: totalDebitMinor,
      totalCreditMinor: totalCreditMinor,
      entryCount: entryCount,
    );
  }
}
