import '../models/ledger_journal_entry.dart';
import '../models/ledger_journal_status.dart';
import '../repository/ledger_journal_repository.dart';

import 'ledger_account_activity.dart';
import 'ledger_general_ledger.dart';
import 'ledger_general_ledger_engine.dart';
import 'ledger_journal_summary.dart';
import 'ledger_trial_balance.dart';
import 'ledger_trial_balance_engine.dart';

/// Unified read-side entry point for ledger journal reporting.
///
/// Responsibilities:
/// - build journal status summaries;
/// - aggregate account activity;
/// - delegate trial-balance generation;
/// - delegate general-ledger generation.
///
/// This engine is read-only and never modifies accounting journals.
final class LedgerJournalReportingEngine {
  const LedgerJournalReportingEngine({
    required this.repository,
    required this.trialBalanceEngine,
    required this.generalLedgerEngine,
  });

  final LedgerJournalRepository repository;
  final LedgerTrialBalanceEngine trialBalanceEngine;
  final LedgerGeneralLedgerEngine generalLedgerEngine;

  /// Produces a journal summary.
  ///
  /// When [currency] is provided, only journals containing at least one
  /// entry in that currency are included.
  ///
  /// Unlike accounting projections, this summary includes every journal
  /// status because its purpose is operational reporting.
  Future<LedgerJournalSummary> summary({String? currency}) async {
    final journals = await repository.findAll();

    final normalizedCurrency = currency == null
        ? null
        : _normalizeCurrency(currency);

    final selectedJournals = journals.where((journal) {
      if (normalizedCurrency == null) {
        return true;
      }

      return journal.entries.any(
        (entry) => _normalizeCurrency(entry.currency) == normalizedCurrency,
      );
    });

    var pendingJournals = 0;
    var postedJournals = 0;
    var cancelledJournals = 0;
    var reversedJournals = 0;

    for (final journal in selectedJournals) {
      switch (journal.status) {
        case LedgerJournalStatus.pending:
          pendingJournals++;

        case LedgerJournalStatus.posted:
          postedJournals++;

        case LedgerJournalStatus.cancelled:
          cancelledJournals++;

        case LedgerJournalStatus.reversed:
          reversedJournals++;
      }
    }

    final totalJournals =
        pendingJournals + postedJournals + cancelledJournals + reversedJournals;

    if (totalJournals == 0) {
      return LedgerJournalSummary.empty;
    }

    return LedgerJournalSummary(
      totalJournals: totalJournals,
      pendingJournals: pendingJournals,
      postedJournals: postedJournals,
      cancelledJournals: cancelledJournals,
      reversedJournals: reversedJournals,
    );
  }

  /// Produces aggregated activity for one account.
  ///
  /// Only accounting-active journals are included:
  /// - posted;
  /// - reversed.
  ///
  /// Pending and cancelled journals do not affect accounting activity.
  ///
  /// [from] is inclusive and [to] is exclusive.
  Future<LedgerAccountActivity> accountActivity({
    required String accountId,
    DateTime? from,
    DateTime? to,
  }) async {
    final normalizedAccountId = _normalizeRequired(accountId, 'accountId');

    final normalizedFrom = from?.toUtc();
    final normalizedTo = to?.toUtc();

    _validatePeriod(from: normalizedFrom, to: normalizedTo);

    final journals = await repository.findAll();

    String? detectedCurrency;
    var entryCount = 0;
    var totalDebitMinor = 0;
    var totalCreditMinor = 0;

    for (final journal in journals) {
      if (!_isAccountingActive(journal.status)) {
        continue;
      }

      if (!_isWithinPeriod(
        occurredAt: journal.occurredAt,
        from: normalizedFrom,
        to: normalizedTo,
      )) {
        continue;
      }

      for (final entry in journal.entries) {
        if (entry.accountId != normalizedAccountId) {
          continue;
        }

        final entryCurrency = _normalizeCurrency(entry.currency);

        if (detectedCurrency == null) {
          detectedCurrency = entryCurrency;
        } else if (detectedCurrency != entryCurrency) {
          throw StateError(
            'Account "$normalizedAccountId" contains entries in multiple '
            'currencies: "$detectedCurrency" and "$entryCurrency".',
          );
        }

        entryCount++;

        switch (entry.direction) {
          case LedgerJournalEntryDirection.debit:
            totalDebitMinor += entry.amountMinor;

          case LedgerJournalEntryDirection.credit:
            totalCreditMinor += entry.amountMinor;
        }
      }
    }

    if (detectedCurrency == null) {
      throw StateError(
        'No accounting activity found for account '
        '"$normalizedAccountId".',
      );
    }

    return LedgerAccountActivity(
      accountId: normalizedAccountId,
      currency: detectedCurrency,
      entryCount: entryCount,
      totalDebitMinor: totalDebitMinor,
      totalCreditMinor: totalCreditMinor,
    );
  }

  /// Produces the complete trial balance.
  Future<LedgerTrialBalance> trialBalance({String? currency}) {
    if (currency == null) {
      return trialBalanceEngine.build();
    }

    return trialBalanceEngine.buildForCurrency(currency);
  }

  /// Produces the chronological general ledger of one account.
  Future<LedgerGeneralLedger> generalLedger({
    required String accountId,
    int openingBalanceMinor = 0,
  }) {
    return generalLedgerEngine.generate(
      accountId: accountId,
      openingBalanceMinor: openingBalanceMinor,
    );
  }

  bool _isAccountingActive(LedgerJournalStatus status) {
    return switch (status) {
      LedgerJournalStatus.posted => true,
      LedgerJournalStatus.reversed => true,
      LedgerJournalStatus.pending => false,
      LedgerJournalStatus.cancelled => false,
    };
  }

  bool _isWithinPeriod({
    required DateTime occurredAt,
    required DateTime? from,
    required DateTime? to,
  }) {
    final normalizedOccurredAt = occurredAt.toUtc();

    if (from != null && normalizedOccurredAt.isBefore(from)) {
      return false;
    }

    if (to != null && !normalizedOccurredAt.isBefore(to)) {
      return false;
    }

    return true;
  }

  void _validatePeriod({required DateTime? from, required DateTime? to}) {
    if (from == null || to == null) {
      return;
    }

    if (!from.isBefore(to)) {
      throw ArgumentError('Reporting period start must be before its end.');
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
