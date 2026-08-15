import type { ReadJournalPort, ReadStepRecord } from '../read/read-journal.port.js';
import type { ReadStep } from '../read/read-steps.js';

/** In-memory ReadJournalPort for specs — records every step, in order. */
export class RecordingReadJournal implements ReadJournalPort {
  readonly entries: ReadStepRecord[] = [];

  record(entry: ReadStepRecord): void {
    this.entries.push(entry);
  }

  steps(): readonly ReadStep[] {
    return this.entries.map((entry) => entry.step);
  }

  outcomes(): ReadonlyArray<readonly [ReadStep, string]> {
    return this.entries.map((entry) => [entry.step, entry.outcome] as const);
  }
}
