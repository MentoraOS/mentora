import type { Clock } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import type { ReactionDefinition } from './reaction-definition.js';
import { ReactionExecutor } from './reaction-executor.js';
import type { ReactionJournalPort } from './reaction-journal.port.js';

/**
 * ReactionBuilder — composition composes, journeys never build the steps
 * (I-2/I-3: concrete machinery is assembled at the Root and received above).
 * Fail-closed: no definition, no clock, no journal → refuses to build
 * (a Séquence assembled by half already lies — the boot law, F4.4 §6).
 */
export class ReactionBuilder<TFact, TPosition, TCommand> {
  private definition: ReactionDefinition<TFact, TPosition, TCommand> | undefined;
  private clock: Clock | undefined;
  private journal: ReactionJournalPort | undefined;
  private maxAttempts: number | undefined;

  withDefinition(definition: ReactionDefinition<TFact, TPosition, TCommand>): this {
    this.definition = definition;
    return this;
  }

  withClock(clock: Clock): this {
    this.clock = clock;
    return this;
  }

  withJournal(journal: ReactionJournalPort): this {
    this.journal = journal;
    return this;
  }

  /** Technical retry budget (I-5; bounded — M-8). */
  withMaxAttempts(maxAttempts: number): this {
    invariant(maxAttempts >= 1, 'maxAttempts >= 1');
    this.maxAttempts = maxAttempts;
    return this;
  }

  build(): ReactionExecutor<TFact, TPosition, TCommand> {
    invariant(this.definition !== undefined, 'a reaction requires its definition (fail closed)');
    invariant(this.clock !== undefined, 'a reaction requires the injected clock (A-6)');
    invariant(this.journal !== undefined, 'a reaction requires its journal (A-10)');
    return new ReactionExecutor({
      definition: this.definition,
      clock: this.clock,
      journal: this.journal,
      ...(this.maxAttempts !== undefined ? { maxAttempts: this.maxAttempts } : {}),
    });
  }
}
