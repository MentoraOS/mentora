import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../models/ledger_entry.dart';
import '../models/ledger_transaction.dart';
import '../models/ledger_transaction_status.dart';
import '../models/ledger_transaction_type.dart';

import 'ledger_repository.dart';

final class FirestoreLedgerRepository implements LedgerRepository {
  const FirestoreLedgerRepository({required this.firestore});

  static const String _collectionName = 'ledger_transactions';

  final FirebaseFirestore firestore;

  CollectionReference<Map<String, dynamic>> get _collection {
    return firestore.collection(_collectionName);
  }

  @override
  Future<void> saveTransaction(LedgerTransaction transaction) async {
    final transactionId = _normalizeRequired(transaction.id, 'transaction.id');

    final document = _collection.doc(transactionId);

    final serializedTransaction = _transactionToMap(transaction);

    await firestore.runTransaction((firestoreTransaction) async {
      final existingSnapshot = await firestoreTransaction.get(document);

      if (existingSnapshot.exists) {
        final existingData = existingSnapshot.data();

        if (existingData != null &&
            const DeepCollectionEquality().equals(
              existingData,
              serializedTransaction,
            )) {
          // Idempotent replay of the same transaction.
          return;
        }

        throw StateError(
          'Ledger transaction "$transactionId" '
          'already exists with different content.',
        );
      }

      firestoreTransaction.set(document, serializedTransaction);
    });
  }

  @override
  Future<LedgerTransaction?> findById(String transactionId) async {
    final normalizedId = transactionId.trim();

    if (normalizedId.isEmpty) {
      return null;
    }

    final snapshot = await _collection.doc(normalizedId).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return _transactionFromMap(data, fallbackId: snapshot.id);
  }

  @override
  Future<List<LedgerTransaction>> findByReferenceId(String referenceId) async {
    final normalizedReference = referenceId.trim();

    if (normalizedReference.isEmpty) {
      return const [];
    }

    final snapshot = await _collection
        .where('reference', isEqualTo: normalizedReference)
        .get();

    final transactions = snapshot.docs
        .map(
          (document) =>
              _transactionFromMap(document.data(), fallbackId: document.id),
        )
        .toList(growable: false);

    transactions.sort(_compareTransactions);

    return List.unmodifiable(transactions);
  }

  @override
  Future<List<LedgerTransaction>> transactionsForAccount(
    String accountId,
  ) async {
    final normalizedAccountId = accountId.trim();

    if (normalizedAccountId.isEmpty) {
      return const [];
    }

    final snapshot = await _collection
        .where('entriesAccountIds', arrayContains: normalizedAccountId)
        .get();

    final transactions = snapshot.docs
        .map(
          (document) =>
              _transactionFromMap(document.data(), fallbackId: document.id),
        )
        .toList(growable: false);

    transactions.sort(_compareTransactions);

    return List.unmodifiable(transactions);
  }

  @override
  Future<bool> exists(String transactionId) async {
    final normalizedId = transactionId.trim();

    if (normalizedId.isEmpty) {
      return false;
    }

    final snapshot = await _collection.doc(normalizedId).get();

    return snapshot.exists;
  }

  Map<String, dynamic> _transactionToMap(LedgerTransaction transaction) {
    return {
      'id': transaction.id.trim(),
      'reference': transaction.reference.trim(),
      'transactionType': transaction.transactionType.name,
      'status': transaction.status.name,

      'bookingId': transaction.bookingId,
      'consultationId': transaction.consultationId,
      'clientId': transaction.clientId,
      'expertId': transaction.expertId,

      'countryCode': transaction.countryCode.trim(),
      'currency': transaction.currency.trim().toUpperCase(),
      'provider': transaction.provider,

      'createdAt': Timestamp.fromDate(transaction.createdAt.toUtc()),

      /*
       * Denormalized index used by transactionsForAccount().
       */
      'entriesAccountIds': transaction.entries
          .map((entry) => entry.accountId.trim())
          .where((accountId) => accountId.isNotEmpty)
          .toSet()
          .toList(growable: false),

      'entries': transaction.entries
          .map(
            (entry) => {
              'accountId': entry.accountId.trim(),
              'type': entry.type.name,
              'amount': entry.amount,
            },
          )
          .toList(growable: false),

      'metadata': Map<String, dynamic>.from(transaction.metadata ?? const {}),
    };
  }

  LedgerTransaction _transactionFromMap(
    Map<String, dynamic> data, {
    required String fallbackId,
  }) {
    final rawEntries = data['entries'] as List<dynamic>? ?? const <dynamic>[];

    final rawMetadata = data['metadata'];

    return LedgerTransaction(
      id: _readRequiredString(
        data['id'],
        fallback: fallbackId,
        fieldName: 'id',
      ),
      reference: _readRequiredString(data['reference'], fieldName: 'reference'),
      transactionType: _transactionTypeFromString(
        data['transactionType'] as String?,
      ),
      status: _statusFromString(data['status'] as String?),
      bookingId: _readOptionalString(data['bookingId']),
      consultationId: _readOptionalString(data['consultationId']),
      clientId: _readOptionalString(data['clientId']),
      expertId: _readOptionalString(data['expertId']),
      countryCode: _readRequiredString(
        data['countryCode'],
        fieldName: 'countryCode',
      ),
      currency: _readRequiredString(
        data['currency'],
        fieldName: 'currency',
      ).toUpperCase(),
      provider: _readOptionalString(data['provider']),
      createdAt: _readDateTime(data['createdAt'], fieldName: 'createdAt'),
      entries: rawEntries
          .map((rawEntry) {
            final entry = Map<String, dynamic>.from(rawEntry as Map);

            return LedgerEntry(
              accountId: _readRequiredString(
                entry['accountId'],
                fieldName: 'entries.accountId',
              ),
              type: _entryTypeFromString(entry['type'] as String?),
              amount: _readAmount(entry['amount']),
            );
          })
          .toList(growable: false),
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : const {},
    );
  }

  LedgerTransactionType _transactionTypeFromString(String? value) {
    return switch (value) {
      'escrowHold' => LedgerTransactionType.escrowHold,
      'escrowRelease' => LedgerTransactionType.escrowRelease,
      'commission' => LedgerTransactionType.commission,
      'refund' => LedgerTransactionType.refund,
      'payout' => LedgerTransactionType.payout,
      'adjustment' => LedgerTransactionType.adjustment,
      _ => LedgerTransactionType.payment,
    };
  }

  LedgerTransactionStatus _statusFromString(String? value) {
    return switch (value) {
      'pending' => LedgerTransactionStatus.pending,
      'failed' => LedgerTransactionStatus.failed,
      'reversed' => LedgerTransactionStatus.reversed,
      _ => LedgerTransactionStatus.posted,
    };
  }

  LedgerEntryType _entryTypeFromString(String? value) {
    return switch (value) {
      'credit' => LedgerEntryType.credit,
      _ => LedgerEntryType.debit,
    };
  }

  DateTime _readDateTime(Object? value, {required String fieldName}) {
    if (value is Timestamp) {
      return value.toDate().toUtc();
    }

    if (value is DateTime) {
      return value.toUtc();
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);

      if (parsed != null) {
        return parsed.toUtc();
      }
    }

    throw StateError(
      'Invalid or missing Firestore field '
      '"$fieldName".',
    );
  }

  int _readAmount(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    throw StateError('Invalid ledger entry amount "$value".');
  }

  String _readRequiredString(
    Object? value, {
    required String fieldName,
    String? fallback,
  }) {
    final candidate = value is String ? value.trim() : '';

    if (candidate.isNotEmpty) {
      return candidate;
    }

    final normalizedFallback = fallback?.trim() ?? '';

    if (normalizedFallback.isNotEmpty) {
      return normalizedFallback;
    }

    throw StateError(
      'Invalid or missing Firestore field '
      '"$fieldName".',
    );
  }

  String? _readOptionalString(Object? value) {
    if (value is! String) {
      return null;
    }

    final normalized = value.trim();

    return normalized.isEmpty ? null : normalized;
  }

  int _compareTransactions(LedgerTransaction left, LedgerTransaction right) {
    final createdAtComparison = left.createdAt.compareTo(right.createdAt);

    if (createdAtComparison != 0) {
      return createdAtComparison;
    }

    return left.id.compareTo(right.id);
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
