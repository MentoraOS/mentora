import '../../../ledger/journal/models/'
    'ledger_journal_source.dart';

import '../../financial_pipeline_context.dart';

final class LedgerJournalPostingRecoveryContext
    extends FinancialPipelineContext {
  LedgerJournalPostingRecoveryContext({
    required String transactionId,
    required String journalId,
    required String workflowKey,
    required this.source,
    DateTime? occurredAt,
    DateTime? createdAt,
    Map<String, dynamic> metadata = const {},
  }) : transactionId = _normalizeRequired(transactionId, 'transactionId'),
       journalId = _normalizeRequired(journalId, 'journalId'),
       workflowKey = _normalizeRequired(workflowKey, 'workflowKey'),
       occurredAt = occurredAt?.toUtc(),
       createdAt = createdAt?.toUtc(),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata)) {
    final normalizedOccurredAt = this.occurredAt;
    final normalizedCreatedAt = this.createdAt;

    if (normalizedOccurredAt != null &&
        normalizedCreatedAt != null &&
        normalizedCreatedAt.isBefore(normalizedOccurredAt)) {
      throw ArgumentError(
        'Recovery journal createdAt cannot be before occurredAt.',
      );
    }
  }

  final String transactionId;

  /// Deterministic identifier to use when a missing journal must be rebuilt.
  final String journalId;

  /// Financial workflow responsible for the original operation.
  final String workflowKey;

  /// Business source that produced the original financial operation.
  final LedgerJournalSource source;

  /// Optional business occurrence time.
  ///
  /// When absent, [LedgerJournalFactory] falls back to the transaction date.
  final DateTime? occurredAt;

  /// Optional journal creation time.
  ///
  /// When absent, [LedgerJournalFactory] falls back to the transaction date.
  final DateTime? createdAt;

  /// Immutable recovery and audit metadata.
  final Map<String, dynamic> metadata;

  /// Alias reflecting the journal domain terminology.
  ///
  /// LedgerJournal.operationId is derived from the ledger transaction ID.
  String get operationId => transactionId;

  bool get hasExplicitOccurredAt => occurredAt != null;

  bool get hasExplicitCreatedAt => createdAt != null;

  LedgerJournalPostingRecoveryContext copyWith({
    String? transactionId,
    String? journalId,
    String? workflowKey,
    LedgerJournalSource? source,
    DateTime? occurredAt,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return LedgerJournalPostingRecoveryContext(
      transactionId: transactionId ?? this.transactionId,
      journalId: journalId ?? this.journalId,
      workflowKey: workflowKey ?? this.workflowKey,
      source: source ?? this.source,
      occurredAt: occurredAt ?? this.occurredAt,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  static String _normalizeRequired(String value, String fieldName) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        '$fieldName must not be empty.',
      );
    }

    return normalized;
  }

  @override
  String toString() {
    return 'LedgerJournalPostingRecoveryContext('
        'transactionId: $transactionId, '
        'journalId: $journalId, '
        'workflowKey: $workflowKey, '
        'source: $source, '
        'occurredAt: $occurredAt, '
        'createdAt: $createdAt'
        ')';
  }
}
