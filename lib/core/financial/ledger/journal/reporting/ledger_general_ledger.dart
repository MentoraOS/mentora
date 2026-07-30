import 'package:collection/collection.dart';

import 'ledger_general_ledger_entry.dart';

/// Chronological general ledger for one account and one currency.
///
/// This read-side model contains the account movements, opening balance,
/// closing balance and aggregated debit/credit totals.
final class LedgerGeneralLedger {
  LedgerGeneralLedger({
    required String accountId,
    required String currency,
    required List<LedgerGeneralLedgerEntry> entries,
    required this.openingBalanceMinor,
    required this.closingBalanceMinor,
    required this.totalDebitMinor,
    required this.totalCreditMinor,
  }) : accountId = _normalizeRequired(accountId, 'accountId'),
       currency = _normalizeCurrency(currency),
       entries = List<LedgerGeneralLedgerEntry>.unmodifiable(entries) {
    if (totalDebitMinor < 0) {
      throw ArgumentError.value(
        totalDebitMinor,
        'totalDebitMinor',
        'Total debit cannot be negative.',
      );
    }

    if (totalCreditMinor < 0) {
      throw ArgumentError.value(
        totalCreditMinor,
        'totalCreditMinor',
        'Total credit cannot be negative.',
      );
    }

    _validateEntries();
  }

  /// Ledger account identifier.
  final String accountId;

  /// Currency represented by this general ledger.
  final String currency;

  /// Immutable chronological ledger lines.
  final List<LedgerGeneralLedgerEntry> entries;

  /// Balance brought forward before the first reported line.
  final int openingBalanceMinor;

  /// Balance after the last reported line.
  final int closingBalanceMinor;

  /// Sum of all debit movements.
  final int totalDebitMinor;

  /// Sum of all credit movements.
  final int totalCreditMinor;

  /// Number of reported lines.
  int get entryCount => entries.length;

  bool get isEmpty => entries.isEmpty;

  bool get isNotEmpty => entries.isNotEmpty;

  /// Net change between opening and closing balance.
  int get movementMinor => closingBalanceMinor - openingBalanceMinor;

  /// Indicates whether the projected closing balance matches the last line.
  ///
  /// The account-type-specific normal-balance calculation is performed by
  /// LedgerGeneralLedgerEngine. This model only verifies projection
  /// consistency.
  bool get isConsistent {
    if (entries.isEmpty) {
      return closingBalanceMinor == openingBalanceMinor;
    }

    return entries.last.runningBalanceMinor == closingBalanceMinor;
  }

  LedgerGeneralLedger copyWith({
    String? accountId,
    String? currency,
    List<LedgerGeneralLedgerEntry>? entries,
    int? openingBalanceMinor,
    int? closingBalanceMinor,
    int? totalDebitMinor,
    int? totalCreditMinor,
  }) {
    return LedgerGeneralLedger(
      accountId: accountId ?? this.accountId,
      currency: currency ?? this.currency,
      entries: entries ?? this.entries,
      openingBalanceMinor: openingBalanceMinor ?? this.openingBalanceMinor,
      closingBalanceMinor: closingBalanceMinor ?? this.closingBalanceMinor,
      totalDebitMinor: totalDebitMinor ?? this.totalDebitMinor,
      totalCreditMinor: totalCreditMinor ?? this.totalCreditMinor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'currency': currency,
      'openingBalanceMinor': openingBalanceMinor,
      'closingBalanceMinor': closingBalanceMinor,
      'movementMinor': movementMinor,
      'totalDebitMinor': totalDebitMinor,
      'totalCreditMinor': totalCreditMinor,
      'entryCount': entryCount,
      'isConsistent': isConsistent,
      'entries': entries.map((entry) => entry.toMap()).toList(growable: false),
    };
  }

  void _validateEntries() {
    for (final entry in entries) {
      if (entry.accountId != accountId) {
        throw ArgumentError(
          'General-ledger entry "${entry.entryId}" belongs to '
          'account "${entry.accountId}" instead of "$accountId".',
        );
      }

      if (entry.currency != currency) {
        throw ArgumentError(
          'General-ledger entry "${entry.entryId}" uses currency '
          '"${entry.currency}" instead of "$currency".',
        );
      }
    }
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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerGeneralLedger &&
            other.accountId == accountId &&
            other.currency == currency &&
            other.openingBalanceMinor == openingBalanceMinor &&
            other.closingBalanceMinor == closingBalanceMinor &&
            other.totalDebitMinor == totalDebitMinor &&
            other.totalCreditMinor == totalCreditMinor &&
            const ListEquality<LedgerGeneralLedgerEntry>().equals(
              other.entries,
              entries,
            );
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    currency,
    openingBalanceMinor,
    closingBalanceMinor,
    totalDebitMinor,
    totalCreditMinor,
    const ListEquality<LedgerGeneralLedgerEntry>().hash(entries),
  );

  @override
  String toString() {
    return 'LedgerGeneralLedger('
        'accountId: $accountId, '
        'currency: $currency, '
        'entryCount: $entryCount, '
        'openingBalanceMinor: $openingBalanceMinor, '
        'closingBalanceMinor: $closingBalanceMinor, '
        'movementMinor: $movementMinor, '
        'totalDebitMinor: $totalDebitMinor, '
        'totalCreditMinor: $totalCreditMinor, '
        'isConsistent: $isConsistent'
        ')';
  }
}
