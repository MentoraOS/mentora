import 'package:collection/collection.dart';

import '../models/ledger_entry.dart';
import '../models/ledger_transaction.dart';

import 'ledger_repository.dart';

// In-memory repository for the official Mentora Ledger.
//
// Guarantees:
// - idempotent persistence by transaction id;
// - uniqueness of a transaction reference;
// - direct recovery lookup;
// - account transaction and entry queries;
// - deterministic read ordering.

final class MemoryLedgerRepository implements LedgerRepository {
  final Map<String, LedgerTransaction> _transactionsById = {};

  final Map<String, String> _transactionIdsByReferenceId = {};

  @override
  Future<void> saveTransaction(LedgerTransaction transaction) async {
    final transactionId = _normalizeRequired(transaction.id, 'transaction.id');

    final referenceId = _normalizeRequired(
      transaction.referenceId,
      'transaction.referenceId',
    );

    final existingById = _transactionsById[transactionId];

    if (existingById != null) {
      if (_hasSameContent(existingById, transaction)) {
        // Idempotent replay.
        return;
      }

      throw StateError(
        'Ledger transaction "$transactionId" already exists '
        'with different content.',
      );
    }

    final existingTransactionId = _transactionIdsByReferenceId[referenceId];

    if (existingTransactionId != null) {
      final existingByReference = _transactionsById[existingTransactionId];

      if (existingByReference != null &&
          _hasSameContent(existingByReference, transaction)) {
        return;
      }

      throw StateError(
        'Ledger reference "$referenceId" is already '
        'associated with transaction '
        '"$existingTransactionId".',
      );
    }

    _transactionsById[transactionId] = transaction;

    _transactionIdsByReferenceId[referenceId] = transactionId;
  }

  @override
  Future<LedgerTransaction?> findTransactionById(String transactionId) async {
    final normalizedId = transactionId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    return _transactionsById[normalizedId];
  }

  @override
  Future<LedgerTransaction?> findTransactionByReferenceId(
    String referenceId,
  ) async {
    final normalizedReferenceId = referenceId.trim();

    if (normalizedReferenceId.isEmpty) {
      return null;
    }

    final transactionId = _transactionIdsByReferenceId[normalizedReferenceId];

    if (transactionId == null) {
      return null;
    }

    return _transactionsById[transactionId];
  }

  @override
  Future<List<LedgerTransaction>> findTransactionsByAccountId(
    String accountId,
  ) async {
    final normalizedAccountId = accountId.trim();

    if (normalizedAccountId.isEmpty) {
      return const [];
    }

    final transactions = _transactionsById.values
        .where(
          (transaction) => transaction.entries.any(
            (entry) => entry.accountId.trim() == normalizedAccountId,
          ),
        )
        .toList();

    transactions.sort(_compareTransactions);

    return List.unmodifiable(transactions);
  }

  @override
  Future<List<LedgerEntry>> findEntriesByAccountId(String accountId) async {
    final normalizedAccountId = accountId.trim();

    if (normalizedAccountId.isEmpty) {
      return const [];
    }

    final entries = _transactionsById.values
        .expand((transaction) => transaction.entries)
        .where((entry) => entry.accountId.trim() == normalizedAccountId)
        .toList();

    entries.sort(_compareEntries);

    return List.unmodifiable(entries);
  }

  @override
  Future<bool> existsByTransactionId(String transactionId) async {
    final normalizedId = transactionId.trim();

    if (normalizedId.isEmpty) {
      return false;
    }

    return _transactionsById.containsKey(normalizedId);
  }

  @override
  Future<bool> existsByReferenceId(String referenceId) async {
    final normalizedReferenceId = referenceId.trim();

    if (normalizedReferenceId.isEmpty) {
      return false;
    }

    return _transactionIdsByReferenceId.containsKey(normalizedReferenceId);
  }

  int get length => _transactionsById.length;

  bool get isEmpty => _transactionsById.isEmpty;

  bool get isNotEmpty => _transactionsById.isNotEmpty;

  List<LedgerTransaction> get allTransactions {
    final transactions = _transactionsById.values.toList();

    transactions.sort(_compareTransactions);

    return List.unmodifiable(transactions);
  }

  void clear() {
    _transactionsById.clear();
    _transactionIdsByReferenceId.clear();
  }

  int _compareTransactions(LedgerTransaction left, LedgerTransaction right) {
    final dateComparison = left.createdAt.compareTo(right.createdAt);

    if (dateComparison != 0) {
      return dateComparison;
    }

    return left.id.compareTo(right.id);
  }

  int _compareEntries(LedgerEntry left, LedgerEntry right) {
    final dateComparison = left.createdAt.compareTo(right.createdAt);

    if (dateComparison != 0) {
      return dateComparison;
    }

    return left.id.compareTo(right.id);
  }

  bool _hasSameContent(LedgerTransaction left, LedgerTransaction right) {
    const equality = DeepCollectionEquality();

    if (left.id != right.id ||
        left.referenceId != right.referenceId ||
        left.description != right.description ||
        left.currency != right.currency ||
        left.status != right.status ||
        left.createdAt != right.createdAt ||
        left.entries.length != right.entries.length ||
        !equality.equals(left.metadata, right.metadata)) {
      return false;
    }

    for (var index = 0; index < left.entries.length; index++) {
      final leftEntry = left.entries[index];
      final rightEntry = right.entries[index];

      if (leftEntry.id != rightEntry.id ||
          leftEntry.transactionId != rightEntry.transactionId ||
          leftEntry.accountId != rightEntry.accountId ||
          leftEntry.amountMinor != rightEntry.amountMinor ||
          leftEntry.currency != rightEntry.currency ||
          leftEntry.side != rightEntry.side ||
          leftEntry.createdAt != rightEntry.createdAt) {
        return false;
      }
    }

    return true;
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
