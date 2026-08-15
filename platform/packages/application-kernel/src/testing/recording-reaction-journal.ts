import type { ReactionJournalPort, ReactionStepRecord } from '../reaction/reaction-journal.port.js';
import type { ReactionStep } from '../reaction/reaction-steps.js';

/** In-memory ReactionJournalPort for specs — records every step, in order. */
export class RecordingReactionJournal implements ReactionJournalPort {
  readonly entries: ReactionStepRecord[] = [];

  record(entry: ReactionStepRecord): void {
    this.entries.push(entry);
  }

  steps(): readonly ReactionStep[] {
    return this.entries.map((entry) => entry.step);
  }

  outcomes(): ReadonlyArray<readonly [ReactionStep, string]> {
    return this.entries.map((entry) => [entry.step, entry.outcome] as const);
  }
}
