// Command describing the reversal of a posted ledger journal.
//
// Identifiers and timestamps are supplied by the caller to keep the
// reversal builder deterministic and independent from infrastructure.
final class LedgerJournalReversalRequest {
  LedgerJournalReversalRequest({
    required String originalJournalId,
    required String reversalJournalId,
    required String reversalOperationId,
    required String reason,
    required DateTime occurredAt,
    required DateTime createdAt,
    Map<String, dynamic> metadata = const {},
  }) : originalJournalId = _normalizeRequired(
         originalJournalId,
         'originalJournalId',
       ),
       reversalJournalId = _normalizeRequired(
         reversalJournalId,
         'reversalJournalId',
       ),
       reversalOperationId = _normalizeRequired(
         reversalOperationId,
         'reversalOperationId',
       ),
       reason = _normalizeRequired(reason, 'reason'),
       occurredAt = occurredAt.toUtc(),
       createdAt = createdAt.toUtc(),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata)) {
    if (this.createdAt.isBefore(this.occurredAt)) {
      throw ArgumentError('Reversal createdAt cannot be before occurredAt.');
    }

    if (this.originalJournalId == this.reversalJournalId) {
      throw ArgumentError(
        'The reversal journal ID must differ from the '
        'original journal ID.',
      );
    }
  }

  final String originalJournalId;
  final String reversalJournalId;
  final String reversalOperationId;
  final String reason;
  final DateTime occurredAt;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

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
}
