import type {
  SequenceInput,
  SequenceJournalPort,
  SequenceOutcome,
} from '@mentora/application-kernel';
import { SequenceBuilder, type SequenceExecutor } from '@mentora/application-kernel';
import type { AgreementCommandContract } from '@mentora/contracts-agreement';
import type { Agreement, AgreementRefusal } from '@mentora/domain-agreement';
import type { Clock } from '@mentora/kernel';

import type { AgreementSequenceDefinition } from '../definitions/agreement-sequence-definition.js';

/**
 * The machinery every Agreement Application Service receives from the
 * composition root (I-2: "au-dessus, on reçoit, on ne cherche jamais"):
 * the injected Clock (A-6), the Journal port (A-10), and the TECHNICAL retry
 * budget (F4.4 I-5 — "comment vite et comment gros", never a permit; bounded
 * by M-8: "les retries sont bornés").
 */
export interface AgreementSequenceMachinery {
  readonly clock: Clock;
  readonly journal: SequenceJournalPort;
  readonly maxAttempts?: number;
}

/**
 * The ONE shape of the eight Agreement Application Services — the guardian of
 * execution of ONE use case (F4.1 §1, A-1: "un cas d'usage = une Command = un
 * Application Service = une unité = une transaction").
 *
 * The service is deliberately BORING (F4.1 §7: "conforme s'il est ennuyeux —
 * dix pas, aucun talent"): it instantiates its SequenceDefinition, hands it
 * to the ratified SequenceBuilder (it never composes stages), and DELEGATES
 * every call to the one SequenceExecutor. It owns the Séquence and nothing
 * else: no business rule, no invariant, no state between two calls, no
 * publication (the relay's, A-4), no direct journaling (the pipeline's,
 * A-10), and it never calls another Application Service (F3.1.10).
 */
export abstract class AgreementSequenceApplicationService<
  TWire extends AgreementCommandContract,
  TCommand,
> {
  private readonly executor: SequenceExecutor<TWire, TCommand, Agreement, AgreementRefusal>;

  protected constructor(
    definition: AgreementSequenceDefinition<TWire, TCommand>,
    machinery: AgreementSequenceMachinery,
  ) {
    const builder = new SequenceBuilder<TWire, TCommand, Agreement, AgreementRefusal>()
      .withDefinition(definition)
      .withClock(machinery.clock)
      .withJournal(machinery.journal);
    this.executor = (
      machinery.maxAttempts === undefined ? builder : builder.withMaxAttempts(machinery.maxAttempts)
    ).build();
  }

  /** The whole service: ONE delegation to the Golden Pipeline. */
  execute(input: SequenceInput): Promise<SequenceOutcome<Agreement, AgreementRefusal>> {
    return this.executor.execute(input);
  }
}
