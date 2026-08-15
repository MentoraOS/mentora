import type { SequenceJournalPort, SequenceStepRecord } from '../journal/sequence-journal.port.js';

/**
 * A SequenceJournalPort that records everything in memory — the test double
 * for asserting the frozen order, the error journal and the abandon journal.
 */
export class RecordingJournal implements SequenceJournalPort {
  readonly entries: SequenceStepRecord[] = [];

  record(entry: SequenceStepRecord): void {
    this.entries.push(entry);
  }

  steps(): readonly string[] {
    return this.entries.map((entry) => entry.step);
  }

  outcomes(): ReadonlyArray<readonly [string, string]> {
    return this.entries.map((entry) => [entry.step, entry.outcome] as const);
  }
}
