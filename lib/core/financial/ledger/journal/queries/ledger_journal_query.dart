import '../models/ledger_journal_status.dart';

// Sorting strategy applied to ledger journal query results.
enum LedgerJournalSortOrder {
  occurredAtAscending,
  occurredAtDescending,
  createdAtAscending,
  createdAtDescending,
}

// Immutable criteria used to search ledger journals.
//
// Every criterion is optional. When several criteria are supplied,
// they are combined using AND semantics.
final class LedgerJournalQuery {
  LedgerJournalQuery({
    String? journalId,
    String? operationId,
    String? workflowKey,
    String? sourceType,
    String? sourceId,
    this.status,
    String? currency,
    String? accountId,
    DateTime? occurredFrom,
    DateTime? occurredTo,
    this.minimumAmountMinor,
    this.maximumAmountMinor,
    String? reversalOfJournalId,
    this.reversalsOnly = false,
    this.sortOrder = LedgerJournalSortOrder.occurredAtDescending,
    this.offset = 0,
    this.limit = 50,
  }) : journalId = _normalizeOptional(journalId),
       operationId = _normalizeOptional(operationId),
       workflowKey = _normalizeOptional(workflowKey, lowercase: true),
       sourceType = _normalizeOptional(sourceType, lowercase: true),
       sourceId = _normalizeOptional(sourceId, lowercase: true),
       currency = _normalizeOptional(currency, uppercase: true),
       accountId = _normalizeOptional(accountId),
       occurredFrom = occurredFrom?.toUtc(),
       occurredTo = occurredTo?.toUtc(),
       reversalOfJournalId = _normalizeOptional(reversalOfJournalId) {
    if (offset < 0) {
      throw ArgumentError.value(
        offset,
        'offset',
        'Query offset cannot be negative.',
      );
    }

    if (limit <= 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Query limit must be greater than zero.',
      );
    }

    if (limit > 500) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Query limit cannot exceed 500.',
      );
    }

    if (minimumAmountMinor != null && minimumAmountMinor! < 0) {
      throw ArgumentError.value(
        minimumAmountMinor,
        'minimumAmountMinor',
        'Minimum amount cannot be negative.',
      );
    }

    if (maximumAmountMinor != null && maximumAmountMinor! < 0) {
      throw ArgumentError.value(
        maximumAmountMinor,
        'maximumAmountMinor',
        'Maximum amount cannot be negative.',
      );
    }

    if (minimumAmountMinor != null &&
        maximumAmountMinor != null &&
        minimumAmountMinor! > maximumAmountMinor!) {
      throw ArgumentError(
        'Minimum amount cannot be greater than '
        'maximum amount.',
      );
    }

    if (this.occurredFrom != null &&
        this.occurredTo != null &&
        !this.occurredFrom!.isBefore(this.occurredTo!)) {
      throw ArgumentError('Query occurredFrom must be before occurredTo.');
    }
  }

  final String? journalId;
  final String? operationId;
  final String? workflowKey;

  final String? sourceType;
  final String? sourceId;

  final LedgerJournalStatus? status;

  final String? currency;
  final String? accountId;

  // Inclusive lower occurrence bound.
  final DateTime? occurredFrom;

  // Exclusive upper occurrence bound.
  final DateTime? occurredTo;

  final int? minimumAmountMinor;
  final int? maximumAmountMinor;

  // Finds a reversal associated with one original journal.
  final String? reversalOfJournalId;

  // Restricts results to compensating reversal journals.
  final bool reversalsOnly;

  final LedgerJournalSortOrder sortOrder;

  final int offset;
  final int limit;

  bool get hasFilters =>
      journalId != null ||
      operationId != null ||
      workflowKey != null ||
      sourceType != null ||
      sourceId != null ||
      status != null ||
      currency != null ||
      accountId != null ||
      occurredFrom != null ||
      occurredTo != null ||
      minimumAmountMinor != null ||
      maximumAmountMinor != null ||
      reversalOfJournalId != null ||
      reversalsOnly;

  LedgerJournalQuery copyWith({
    String? journalId,
    String? operationId,
    String? workflowKey,
    String? sourceType,
    String? sourceId,
    LedgerJournalStatus? status,
    String? currency,
    String? accountId,
    DateTime? occurredFrom,
    DateTime? occurredTo,
    int? minimumAmountMinor,
    int? maximumAmountMinor,
    String? reversalOfJournalId,
    bool? reversalsOnly,
    LedgerJournalSortOrder? sortOrder,
    int? offset,
    int? limit,
  }) {
    return LedgerJournalQuery(
      journalId: journalId ?? this.journalId,
      operationId: operationId ?? this.operationId,
      workflowKey: workflowKey ?? this.workflowKey,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      accountId: accountId ?? this.accountId,
      occurredFrom: occurredFrom ?? this.occurredFrom,
      occurredTo: occurredTo ?? this.occurredTo,
      minimumAmountMinor: minimumAmountMinor ?? this.minimumAmountMinor,
      maximumAmountMinor: maximumAmountMinor ?? this.maximumAmountMinor,
      reversalOfJournalId: reversalOfJournalId ?? this.reversalOfJournalId,
      reversalsOnly: reversalsOnly ?? this.reversalsOnly,
      sortOrder: sortOrder ?? this.sortOrder,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }

  static String? _normalizeOptional(
    String? value, {
    bool lowercase = false,
    bool uppercase = false,
  }) {
    if (value == null) {
      return null;
    }

    var normalized = value.trim();

    if (normalized.isEmpty) {
      return null;
    }

    if (lowercase) {
      normalized = normalized.toLowerCase();
    }

    if (uppercase) {
      normalized = normalized.toUpperCase();
    }

    return normalized;
  }
}
