import '../models/ledger_journal_entry.dart';

/// One chronological accounting line in a general ledger.
///
/// This read-side model preserves the identity of the originating journal
/// and exposes the running normal balance calculated for the account.
final class LedgerGeneralLedgerEntry {
  LedgerGeneralLedgerEntry({
    required String journalId,
    required String operationId,
    required String workflowKey,
    required String entryId,
    required String accountId,
    required String currency,
    required this.direction,
    required this.amountMinor,
    required this.runningBalanceMinor,
    required DateTime occurredAt,
    required DateTime createdAt,
    required String description,
  }) : journalId = _normalizeRequired(journalId, 'journalId'),
       operationId = _normalizeRequired(operationId, 'operationId'),
       workflowKey = _normalizeRequired(workflowKey, 'workflowKey'),
       entryId = _normalizeRequired(entryId, 'entryId'),
       accountId = _normalizeRequired(accountId, 'accountId'),
       currency = _normalizeCurrency(currency),
       occurredAt = occurredAt.toUtc(),
       createdAt = createdAt.toUtc(),
       description = _normalizeRequired(description, 'description') {
    if (amountMinor <= 0) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'General-ledger entry amount must be greater than zero.',
      );
    }
  }

  /// Journal containing the original accounting entry.
  final String journalId;

  /// Idempotency or business-operation identifier.
  final String operationId;

  /// Workflow that produced the journal.
  final String workflowKey;

  /// Original journal-entry identifier.
  final String entryId;

  /// Account represented by this general-ledger line.
  final String accountId;

  /// Currency of the line.
  final String currency;

  /// Debit or credit accounting direction.
  final LedgerJournalEntryDirection direction;

  /// Absolute entry amount in minor units.
  final int amountMinor;

  /// Account normal balance immediately after this line.
  ///
  /// Its interpretation follows the account type:
  /// - asset and expense: debit minus credit;
  /// - liability, equity and revenue: credit minus debit.
  final int runningBalanceMinor;

  /// Business occurrence date inherited from the journal.
  final DateTime occurredAt;

  /// Journal creation date used as a deterministic secondary ordering key.
  final DateTime createdAt;

  /// Human-readable accounting description.
  final String description;

  int get debitMinor {
    return switch (direction) {
      LedgerJournalEntryDirection.debit => amountMinor,
      LedgerJournalEntryDirection.credit => 0,
    };
  }

  int get creditMinor {
    return switch (direction) {
      LedgerJournalEntryDirection.debit => 0,
      LedgerJournalEntryDirection.credit => amountMinor,
    };
  }

  bool get isDebit => direction == LedgerJournalEntryDirection.debit;

  bool get isCredit => direction == LedgerJournalEntryDirection.credit;

  LedgerGeneralLedgerEntry copyWith({
    String? journalId,
    String? operationId,
    String? workflowKey,
    String? entryId,
    String? accountId,
    String? currency,
    LedgerJournalEntryDirection? direction,
    int? amountMinor,
    int? runningBalanceMinor,
    DateTime? occurredAt,
    DateTime? createdAt,
    String? description,
  }) {
    return LedgerGeneralLedgerEntry(
      journalId: journalId ?? this.journalId,
      operationId: operationId ?? this.operationId,
      workflowKey: workflowKey ?? this.workflowKey,
      entryId: entryId ?? this.entryId,
      accountId: accountId ?? this.accountId,
      currency: currency ?? this.currency,
      direction: direction ?? this.direction,
      amountMinor: amountMinor ?? this.amountMinor,
      runningBalanceMinor: runningBalanceMinor ?? this.runningBalanceMinor,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'journalId': journalId,
      'operationId': operationId,
      'workflowKey': workflowKey,
      'entryId': entryId,
      'accountId': accountId,
      'currency': currency,
      'direction': direction.name,
      'amountMinor': amountMinor,
      'debitMinor': debitMinor,
      'creditMinor': creditMinor,
      'runningBalanceMinor': runningBalanceMinor,
      'occurredAt': occurredAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerGeneralLedgerEntry &&
            other.journalId == journalId &&
            other.operationId == operationId &&
            other.workflowKey == workflowKey &&
            other.entryId == entryId &&
            other.accountId == accountId &&
            other.currency == currency &&
            other.direction == direction &&
            other.amountMinor == amountMinor &&
            other.runningBalanceMinor == runningBalanceMinor &&
            other.occurredAt == occurredAt &&
            other.createdAt == createdAt &&
            other.description == description;
  }

  @override
  int get hashCode => Object.hash(
    journalId,
    operationId,
    workflowKey,
    entryId,
    accountId,
    currency,
    direction,
    amountMinor,
    runningBalanceMinor,
    occurredAt,
    createdAt,
    description,
  );

  @override
  String toString() {
    return 'LedgerGeneralLedgerEntry('
        'journalId: $journalId, '
        'entryId: $entryId, '
        'accountId: $accountId, '
        'currency: $currency, '
        'direction: ${direction.name}, '
        'amountMinor: $amountMinor, '
        'runningBalanceMinor: $runningBalanceMinor, '
        'occurredAt: $occurredAt'
        ')';
  }

  static String _normalizeRequired(String value, String fieldName) {
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

  static String _normalizeCurrency(String currency) {
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
