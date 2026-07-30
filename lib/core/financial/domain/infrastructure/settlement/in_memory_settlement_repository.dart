import '../../settlement/consultation_settlement.dart';
import '../../settlement/settlement_concurrency_exception.dart';
import '../../settlement/settlement_id.dart';
import '../../settlement/settlement_repository.dart';

/// In-memory SettlementRepository implementation.
///
/// Primarily intended for tests and local development.
///
/// Persistence rules:
/// - a new settlement requires expectedVersion == null;
/// - updating a settlement requires the persisted version to equal
///   expectedVersion;
/// - the incoming aggregate version must equal expectedVersion + 1;
/// - saving exactly the same aggregate is idempotent.
final class InMemorySettlementRepository implements SettlementRepository {
  final Map<SettlementId, ConsultationSettlement> _storage =
      <SettlementId, ConsultationSettlement>{};

  @override
  Future<void> save(
    ConsultationSettlement settlement, {
    int? expectedVersion,
  }) async {
    if (expectedVersion != null && expectedVersion < 0) {
      throw ArgumentError.value(
        expectedVersion,
        'expectedVersion',
        'expectedVersion cannot be negative.',
      );
    }

    final existingSettlement = _storage[settlement.id];

    if (existingSettlement == null) {
      if (expectedVersion != null) {
        throw SettlementConcurrencyException(
          settlementId: settlement.id,
          expectedVersion: expectedVersion,
          actualVersion: -1,
          incomingVersion: settlement.version,
        );
      }

      _storage[settlement.id] = settlement;
      return;
    }

    // Exact replay is safe and idempotent.
    if (existingSettlement == settlement) {
      return;
    }

    if (expectedVersion == null) {
      throw SettlementConcurrencyException(
        settlementId: settlement.id,
        expectedVersion: -1,
        actualVersion: existingSettlement.version,
        incomingVersion: settlement.version,
      );
    }

    if (existingSettlement.version != expectedVersion) {
      throw SettlementConcurrencyException(
        settlementId: settlement.id,
        expectedVersion: expectedVersion,
        actualVersion: existingSettlement.version,
        incomingVersion: settlement.version,
      );
    }

    final requiredIncomingVersion = expectedVersion + 1;

    if (settlement.version != requiredIncomingVersion) {
      throw StateError(
        'Settlement "${settlement.id}" has an invalid '
        'incoming version: '
        'expected=$requiredIncomingVersion, '
        'actual=${settlement.version}.',
      );
    }

    _storage[settlement.id] = settlement;
  }

  @override
  Future<ConsultationSettlement?> findById(SettlementId id) async {
    return _storage[id];
  }

  @override
  Future<bool> exists(SettlementId id) async {
    return _storage.containsKey(id);
  }

  @override
  Future<void> delete(SettlementId id) async {
    _storage.remove(id);
  }

  /// Returns the number of persisted settlements.
  int get length => _storage.length;

  /// Removes every settlement from the repository.
  void clear() {
    _storage.clear();
  }
}
