import 'package:flutter_test/flutter_test.dart';

import 'package:mentora/core/financial/ledger/journal/models/'
    'ledger_journal_status.dart';
import 'package:mentora/core/financial/ledger/journal/reporting/'
    'ledger_journal_summary.dart';

void main() {
  group('LedgerJournalSummary', () {
    test('creates a valid summary', () {
      const summary = LedgerJournalSummary(
        totalJournals: 10,
        pendingJournals: 2,
        postedJournals: 5,
        cancelledJournals: 1,
        reversedJournals: 2,
      );

      expect(summary.totalJournals, 10);
      expect(summary.pendingJournals, 2);
      expect(summary.postedJournals, 5);
      expect(summary.cancelledJournals, 1);
      expect(summary.reversedJournals, 2);
    });

    test('exposes an empty summary', () {
      const summary = LedgerJournalSummary.empty;

      expect(summary.totalJournals, 0);
      expect(summary.isEmpty, isTrue);
      expect(summary.isNotEmpty, isFalse);
    });

    test('returns counts by status', () {
      const summary = LedgerJournalSummary(
        totalJournals: 10,
        pendingJournals: 2,
        postedJournals: 5,
        cancelledJournals: 1,
        reversedJournals: 2,
      );

      expect(summary.countForStatus(LedgerJournalStatus.pending), 2);

      expect(summary.countForStatus(LedgerJournalStatus.posted), 5);

      expect(summary.countForStatus(LedgerJournalStatus.cancelled), 1);

      expect(summary.countForStatus(LedgerJournalStatus.reversed), 2);
    });

    test('calculates status percentages', () {
      const summary = LedgerJournalSummary(
        totalJournals: 10,
        pendingJournals: 2,
        postedJournals: 5,
        cancelledJournals: 1,
        reversedJournals: 2,
      );

      expect(summary.percentageForStatus(LedgerJournalStatus.pending), 0.2);

      expect(summary.percentageForStatus(LedgerJournalStatus.posted), 0.5);
    });

    test('returns zero percentage for an empty summary', () {
      expect(
        LedgerJournalSummary.empty.percentageForStatus(
          LedgerJournalStatus.posted,
        ),
        0,
      );
    });

    test('supports value equality', () {
      const first = LedgerJournalSummary(
        totalJournals: 4,
        pendingJournals: 1,
        postedJournals: 1,
        cancelledJournals: 1,
        reversedJournals: 1,
      );

      const second = LedgerJournalSummary(
        totalJournals: 4,
        pendingJournals: 1,
        postedJournals: 1,
        cancelledJournals: 1,
        reversedJournals: 1,
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('converts the summary to a map', () {
      const summary = LedgerJournalSummary(
        totalJournals: 4,
        pendingJournals: 1,
        postedJournals: 1,
        cancelledJournals: 1,
        reversedJournals: 1,
      );

      expect(summary.toMap(), {
        'totalJournals': 4,
        'pendingJournals': 1,
        'postedJournals': 1,
        'cancelledJournals': 1,
        'reversedJournals': 1,
      });
    });

    test('supports immutable copies', () {
      const original = LedgerJournalSummary(
        totalJournals: 4,
        pendingJournals: 1,
        postedJournals: 1,
        cancelledJournals: 1,
        reversedJournals: 1,
      );

      final updated = original.copyWith(totalJournals: 5, postedJournals: 2);

      expect(original.totalJournals, 4);
      expect(original.postedJournals, 1);

      expect(updated.totalJournals, 5);
      expect(updated.postedJournals, 2);
    });
  });
}
