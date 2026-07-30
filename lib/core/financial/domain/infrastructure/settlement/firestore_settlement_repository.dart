import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import '../../settlement/consultation_settlement.dart';
import '../../settlement/settlement_id.dart';
import '../../settlement/settlement_repository.dart';
import 'settlement_firestore_mapper.dart';

import '../../settlement/settlement_concurrency_exception.dart';

/// Firestore implementation of the SettlementRepository contract.
///
/// Persistence rules:
/// - a new aggregate may be saved at any valid non-negative version;
/// - replaying exactly the same aggregate is idempotent;
/// - an update must increment the stored version by exactly one;
/// - conflicting writes are rejected.
final class FirestoreSettlementRepository implements SettlementRepository {
  const FirestoreSettlementRepository({
    required this.firestore,
    this.mapper = const SettlementFirestoreMapper(),
  });

  static const String _collectionName = 'consultation_settlements';

  final FirebaseFirestore firestore;
  final SettlementFirestoreMapper mapper;

  CollectionReference<Map<String, dynamic>> get _collection {
    return firestore.collection(_collectionName);
  }

  @override
  Future<void> save(
    ConsultationSettlement settlement, {
    int? expectedVersion,
  }) async {
    final settlementIdValue = _normalizeRequired(
      settlement.id.toPrimitive(),
      'settlement.id',
    );

    if (expectedVersion != null && expectedVersion < 0) {
      throw ArgumentError.value(
        expectedVersion,
        'expectedVersion',
        'expectedVersion cannot be negative.',
      );
    }

    final document = _collection.doc(settlementIdValue);

    final serializedSettlement = mapper.toMap(settlement);

    await firestore.runTransaction((firestoreTransaction) async {
      final existingSnapshot = await firestoreTransaction.get(document);

      final now = Timestamp.fromDate(DateTime.now().toUtc());

      if (!existingSnapshot.exists) {
        if (expectedVersion != null) {
          throw SettlementConcurrencyException(
            settlementId: settlement.id,
            expectedVersion: expectedVersion,
            actualVersion: -1,
            incomingVersion: settlement.version,
          );
        }

        firestoreTransaction.set(document, <String, dynamic>{
          ...serializedSettlement,
          'createdAt': now,
          'updatedAt': now,
        });

        return;
      }

      final existingData = existingSnapshot.data();

      if (existingData == null) {
        throw StateError(
          'Settlement "$settlementIdValue" exists but '
          'contains no Firestore data.',
        );
      }

      final existingDomainData = _extractDomainData(existingData);

      if (const DeepCollectionEquality().equals(
        existingDomainData,
        serializedSettlement,
      )) {
        // Idempotent replay of exactly the same aggregate.
        return;
      }

      final storedVersion = _readNonNegativeInt(
        existingData['version'],
        fieldName: 'version',
      );

      if (expectedVersion == null) {
        throw SettlementConcurrencyException(
          settlementId: settlement.id,
          expectedVersion: -1,
          actualVersion: storedVersion,
          incomingVersion: settlement.version,
        );
      }

      if (storedVersion != expectedVersion) {
        throw SettlementConcurrencyException(
          settlementId: settlement.id,
          expectedVersion: expectedVersion,
          actualVersion: storedVersion,
          incomingVersion: settlement.version,
        );
      }

      final requiredIncomingVersion = expectedVersion + 1;

      if (settlement.version != requiredIncomingVersion) {
        throw StateError(
          'Settlement "$settlementIdValue" has an invalid '
          'incoming version: '
          'expected=$requiredIncomingVersion, '
          'actual=${settlement.version}.',
        );
      }

      firestoreTransaction.set(document, <String, dynamic>{
        ...serializedSettlement,
        'createdAt': existingData['createdAt'] ?? now,
        'updatedAt': now,
      });
    });
  }

  @override
  Future<ConsultationSettlement?> findById(SettlementId id) async {
    final settlementId = id.toPrimitive().trim();

    if (settlementId.isEmpty) {
      return null;
    }

    final snapshot = await _collection.doc(settlementId).get();

    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data();

    if (data == null) {
      return null;
    }

    return mapper.fromMap(data, fallbackId: snapshot.id);
  }

  @override
  Future<bool> exists(SettlementId id) async {
    final settlementId = id.toPrimitive().trim();

    if (settlementId.isEmpty) {
      return false;
    }

    final snapshot = await _collection.doc(settlementId).get();

    return snapshot.exists;
  }

  @override
  Future<void> delete(SettlementId id) async {
    final settlementId = id.toPrimitive().trim();

    if (settlementId.isEmpty) {
      return;
    }

    await _collection.doc(settlementId).delete();
  }

  /// Extracts only deterministic aggregate fields.
  ///
  /// Firestore timestamps are intentionally excluded because they are
  /// infrastructure metadata and must not affect idempotency checks.
  Map<String, dynamic> _extractDomainData(Map<String, dynamic> data) {
    return <String, dynamic>{
      'schemaVersion': data['schemaVersion'],
      'id': data['id'],
      'status': data['status'],
      'version': data['version'],
      'lines': data['lines'],
    };
  }

  int _readNonNegativeInt(Object? value, {required String fieldName}) {
    final int? parsed = switch (value) {
      int number => number,
      num number => number.toInt(),
      _ => null,
    };

    if (parsed == null || parsed < 0) {
      throw StateError(
        'Invalid Firestore settlement field '
        '"$fieldName": "$value". '
        'A non-negative integer is required.',
      );
    }

    return parsed;
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
