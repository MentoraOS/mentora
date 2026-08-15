import type { Clock } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import { SequenceExecutor } from '../executor/sequence-executor.js';
import type { SequenceDefinition } from '../interfaces/sequence-definition.js';
import type { SequenceJournalPort } from '../journal/sequence-journal.port.js';
import type { SequenceRefusalLike } from '../result/sequence-outcome.js';

/**
 * SequenceBuilder — composes the official Sequence. A handler NEVER builds
 * the stages itself (the composition belongs to the Root, which uses this
 * builder — I-2/I-3): the builder receives the injected definition and ports,
 * validates completeness (fail closed), and yields the executor of the ten
 * frozen steps.
 */
export class SequenceBuilder<TWire, TCommand, TUnit, TRefusal extends SequenceRefusalLike> {
  private definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal> | undefined;
  private clock: Clock | undefined;
  private journal: SequenceJournalPort | undefined;
  private maxAttempts = 1;

  withDefinition(definition: SequenceDefinition<TWire, TCommand, TUnit, TRefusal>): this {
    this.definition = definition;
    return this;
  }

  withClock(clock: Clock): this {
    this.clock = clock;
    return this;
  }

  withJournal(journal: SequenceJournalPort): this {
    this.journal = journal;
    return this;
  }

  /** Technical configuration (I-5): retry budget for retryable Failures. */
  withMaxAttempts(maxAttempts: number): this {
    invariant(maxAttempts >= 1, 'maxAttempts must be >= 1');
    this.maxAttempts = maxAttempts;
    return this;
  }

  build(): SequenceExecutor<TWire, TCommand, TUnit, TRefusal> {
    invariant(this.definition !== undefined, 'SequenceBuilder requires a definition');
    invariant(this.clock !== undefined, 'SequenceBuilder requires a Clock (A-6)');
    invariant(this.journal !== undefined, 'SequenceBuilder requires a Journal (A-10)');
    return new SequenceExecutor({
      definition: this.definition,
      clock: this.clock,
      journal: this.journal,
      maxAttempts: this.maxAttempts,
    });
  }
}
