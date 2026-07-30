import '../models/ledger_journal.dart';

// Immutable paginated result returned by the query engine.
final class LedgerJournalQueryResult {
  LedgerJournalQueryResult({
    required List<LedgerJournal> journals,
    required this.totalCount,
    required this.offset,
    required this.limit,
  }) : journals = List<LedgerJournal>.unmodifiable(journals);

  final List<LedgerJournal> journals;

  // Total number of matching journals before pagination.
  final int totalCount;

  final int offset;
  final int limit;

  int get returnedCount => journals.length;

  bool get isEmpty => journals.isEmpty;

  bool get isNotEmpty => journals.isNotEmpty;

  bool get hasMore => offset + journals.length < totalCount;

  int? get nextOffset {
    if (!hasMore) {
      return null;
    }

    return offset + journals.length;
  }

  LedgerJournal? get singleOrNull {
    if (journals.length != 1) {
      return null;
    }

    return journals.first;
  }
}
