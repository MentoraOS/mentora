import 'consultation_settlement.dart';
import 'settlement_id.dart';

/// Repository abstraction for ConsultationSettlement aggregates.
///
/// Implementations must persist updates atomically and reject writes based on
/// a stale aggregate version.
abstract interface class SettlementRepository {
  /// Persists [settlement] using optimistic concurrency control.
  ///
  /// When [expectedVersion] is null, the repository expects the settlement
  /// not to exist yet.
  ///
  /// When [expectedVersion] is provided, the currently persisted aggregate
  /// must have exactly that version.
  ///
  /// The incoming aggregate must normally carry:
  ///
  /// settlement.version == expectedVersion + 1
  Future<void> save(ConsultationSettlement settlement, {int? expectedVersion});

  /// Returns the settlement identified by [id],
  /// or null when it does not exist.
  Future<ConsultationSettlement?> findById(SettlementId id);

  /// Returns true when a settlement already exists.
  Future<bool> exists(SettlementId id);

  /// Deletes the settlement identified by [id].
  Future<void> delete(SettlementId id);
}
