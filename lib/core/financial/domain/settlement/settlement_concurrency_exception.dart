import 'settlement_id.dart';

/// Raised when a settlement is persisted from a stale aggregate version.
///
/// This protects the financial domain against concurrent workers attempting
/// to update the same settlement from the same previously loaded version.
final class SettlementConcurrencyException implements Exception {
  const SettlementConcurrencyException({
    required this.settlementId,
    required this.expectedVersion,
    required this.actualVersion,
    required this.incomingVersion,
  });

  final SettlementId settlementId;

  /// Version the caller expected to still be persisted.
  final int expectedVersion;

  /// Version currently stored by the repository.
  final int actualVersion;

  /// Version carried by the aggregate being saved.
  final int incomingVersion;

  @override
  String toString() {
    return 'SettlementConcurrencyException('
        'settlementId: $settlementId, '
        'expectedVersion: $expectedVersion, '
        'actualVersion: $actualVersion, '
        'incomingVersion: $incomingVersion'
        ')';
  }
}
