import '../models/ledger_journal_status.dart';

/// Global statistical summary of ledger journals.
///
/// This model is immutable and contains only aggregated read-side data.
/// It does not perform persistence or modify journals.
final class LedgerJournalSummary {
  const LedgerJournalSummary({
    required this.totalJournals,
    required this.pendingJournals,
    required this.postedJournals,
    required this.cancelledJournals,
    required this.reversedJournals,
  }) : assert(totalJournals >= 0),
       assert(pendingJournals >= 0),
       assert(postedJournals >= 0),
       assert(cancelledJournals >= 0),
       assert(reversedJournals >= 0),
       assert(
         totalJournals ==
             pendingJournals +
                 postedJournals +
                 cancelledJournals +
                 reversedJournals,
         'The status counters must equal totalJournals.',
       );

  /// Total number of journals included in the report.
  final int totalJournals;

  /// Journals not yet posted or cancelled.
  final int pendingJournals;

  /// Journals successfully posted.
  final int postedJournals;

  /// Journals cancelled before posting.
  final int cancelledJournals;

  /// Posted journals later reversed by a compensating journal.
  final int reversedJournals;

  /// Empty summary used when no journal matches the report criteria.
  static const empty = LedgerJournalSummary(
    totalJournals: 0,
    pendingJournals: 0,
    postedJournals: 0,
    cancelledJournals: 0,
    reversedJournals: 0,
  );

  bool get isEmpty => totalJournals == 0;

  bool get isNotEmpty => !isEmpty;

  int countForStatus(LedgerJournalStatus status) {
    return switch (status) {
      LedgerJournalStatus.pending => pendingJournals,
      LedgerJournalStatus.posted => postedJournals,
      LedgerJournalStatus.cancelled => cancelledJournals,
      LedgerJournalStatus.reversed => reversedJournals,
    };
  }

  double percentageForStatus(LedgerJournalStatus status) {
    if (totalJournals == 0) {
      return 0;
    }

    return countForStatus(status) / totalJournals;
  }

  LedgerJournalSummary copyWith({
    int? totalJournals,
    int? pendingJournals,
    int? postedJournals,
    int? cancelledJournals,
    int? reversedJournals,
  }) {
    return LedgerJournalSummary(
      totalJournals: totalJournals ?? this.totalJournals,
      pendingJournals: pendingJournals ?? this.pendingJournals,
      postedJournals: postedJournals ?? this.postedJournals,
      cancelledJournals: cancelledJournals ?? this.cancelledJournals,
      reversedJournals: reversedJournals ?? this.reversedJournals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalJournals': totalJournals,
      'pendingJournals': pendingJournals,
      'postedJournals': postedJournals,
      'cancelledJournals': cancelledJournals,
      'reversedJournals': reversedJournals,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is LedgerJournalSummary &&
            other.totalJournals == totalJournals &&
            other.pendingJournals == pendingJournals &&
            other.postedJournals == postedJournals &&
            other.cancelledJournals == cancelledJournals &&
            other.reversedJournals == reversedJournals;
  }

  @override
  int get hashCode => Object.hash(
    totalJournals,
    pendingJournals,
    postedJournals,
    cancelledJournals,
    reversedJournals,
  );

  @override
  String toString() {
    return 'LedgerJournalSummary('
        'totalJournals: $totalJournals, '
        'pendingJournals: $pendingJournals, '
        'postedJournals: $postedJournals, '
        'cancelledJournals: $cancelledJournals, '
        'reversedJournals: $reversedJournals'
        ')';
  }
}
