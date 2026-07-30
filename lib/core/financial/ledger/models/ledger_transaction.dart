import 'ledger_entry.dart';
import 'ledger_entry_side.dart';
import 'ledger_transaction_status.dart';

class LedgerTransaction {
  final String id;
  final String referenceId;
  final String description;
  final String currency;
  final List<LedgerEntry> entries;
  final LedgerTransactionStatus status;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  LedgerTransaction({
    required this.id,
    required this.referenceId,
    required this.description,
    required this.currency,
    required List<LedgerEntry> entries,
    required this.status,
    required this.createdAt,
    this.metadata = const {},
  }) : entries = List.unmodifiable(entries) {
    _validate();
  }

  int get totalDebits => entries
      .where((entry) => entry.side == LedgerEntrySide.debit)
      .fold(0, (total, entry) => total + entry.amountMinor);

  int get totalCredits => entries
      .where((entry) => entry.side == LedgerEntrySide.credit)
      .fold(0, (total, entry) => total + entry.amountMinor);

  bool get isBalanced => totalDebits == totalCredits;

  void _validate() {
    if (entries.length < 2) {
      throw ArgumentError('A ledger transaction requires at least two entries');
    }

    if (entries.any((entry) => entry.transactionId != id)) {
      throw ArgumentError('Every ledger entry must belong to transaction $id');
    }

    if (entries.any((entry) => entry.currency != currency)) {
      throw ArgumentError('Every ledger entry must use currency $currency');
    }

    if (!isBalanced) {
      throw ArgumentError(
        'Unbalanced ledger transaction: '
        'debits=$totalDebits, credits=$totalCredits',
      );
    }
  }
}
