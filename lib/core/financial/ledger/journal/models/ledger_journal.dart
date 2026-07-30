import 'ledger_journal_entry.dart';
import 'ledger_journal_source.dart';
import 'ledger_journal_status.dart';

// Immutable accounting journal representing one complete financial
// operation.
//
// The journal is generic and does not depend on any business domain.
final class LedgerJournal {
  LedgerJournal({
    required String journalId,
    required String operationId,
    required String workflowKey,
    required this.source,
    required this.status,
    required DateTime occurredAt,
    required DateTime createdAt,
    required List<LedgerJournalEntry> entries,
    Map<String, dynamic> metadata = const {},
    this.version = 1,
  }) : journalId = _normalizeRequired(value: journalId, fieldName: 'journalId'),
       operationId = _normalizeRequired(
         value: operationId,
         fieldName: 'operationId',
       ),
       workflowKey = _normalizeRequired(
         value: workflowKey,
         fieldName: 'workflowKey',
       ),
       occurredAt = occurredAt.toUtc(),
       createdAt = createdAt.toUtc(),
       entries = _validateEntries(entries),
       metadata = Map.unmodifiable(Map<String, dynamic>.from(metadata)) {
    if (version <= 0) {
      throw ArgumentError.value(
        version,
        'version',
        'Ledger journal version must be greater than zero.',
      );
    }

    if (this.createdAt.isBefore(this.occurredAt)) {
      throw ArgumentError(
        'Ledger journal createdAt cannot be before occurredAt.',
      );
    }
  }

  // Unique identifier of this journal.
  final String journalId;

  // Idempotency and business-operation identifier.
  final String operationId;

  // Workflow or process that created this journal.
  final String workflowKey;

  // Business source responsible for the operation.
  final LedgerJournalSource source;

  // Current journal lifecycle status.
  final LedgerJournalStatus status;

  // Time at which the business event occurred.
  final DateTime occurredAt;

  // Time at which the journal was created.
  final DateTime createdAt;

  // Immutable ordered accounting entries.
  final List<LedgerJournalEntry> entries;

  // Immutable contextual metadata.
  final Map<String, dynamic> metadata;

  // Optimistic version of the journal.
  final int version;

  int get debitAmountMinor {
    return entries
        .where((entry) => entry.isDebit)
        .fold(0, (total, entry) => total + entry.amountMinor);
  }

  int get creditAmountMinor {
    return entries
        .where((entry) => entry.isCredit)
        .fold(0, (total, entry) => total + entry.amountMinor);
  }

  bool get isBalanced => debitAmountMinor == creditAmountMinor;

  String get currency => entries.first.currency;

  bool get containsMultipleCurrencies {
    return entries.map((entry) => entry.currency).toSet().length > 1;
  }

  LedgerJournal copyWith({
    LedgerJournalStatus? status,
    Map<String, dynamic>? metadata,
    int? version,
  }) {
    return LedgerJournal(
      journalId: journalId,
      operationId: operationId,
      workflowKey: workflowKey,
      source: source,
      status: status ?? this.status,
      occurredAt: occurredAt,
      createdAt: createdAt,
      entries: entries,
      metadata: metadata ?? this.metadata,
      version: version ?? this.version,
    );
  }

  static List<LedgerJournalEntry> _validateEntries(
    List<LedgerJournalEntry> entries,
  ) {
    if (entries.length < 2) {
      throw ArgumentError.value(
        entries,
        'entries',
        'A ledger journal must contain at least two entries.',
      );
    }

    final immutableEntries = List<LedgerJournalEntry>.unmodifiable(entries);

    final entryIds = <String>{};

    for (final entry in immutableEntries) {
      if (!entryIds.add(entry.entryId)) {
        throw ArgumentError(
          'A ledger journal cannot contain duplicate entry ID '
          '"${entry.entryId}".',
        );
      }
    }

    return immutableEntries;
  }

  static String _normalizeRequired({
    required String value,
    required String fieldName,
  }) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        value,
        fieldName,
        'Ledger journal $fieldName cannot be empty.',
      );
    }

    return normalized;
  }

  @override
  String toString() {
    return 'LedgerJournal('
        'journalId: $journalId, '
        'operationId: $operationId, '
        'status: $status, '
        'entries: ${entries.length}, '
        'version: $version'
        ')';
  }
}
