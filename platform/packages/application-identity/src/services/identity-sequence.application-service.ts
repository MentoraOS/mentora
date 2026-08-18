import type {
  SequenceInput,
  SequenceJournalPort,
  SequenceOutcome,
} from '@mentora/application-kernel';
import { SequenceBuilder, type SequenceExecutor } from '@mentora/application-kernel';
import type { IdentityCommandContract } from '@mentora/contracts-identity';
import type { Credential, CredentialRefusal } from '@mentora/domain-identity';
import type { Clock } from '@mentora/kernel';

import type { IdentitySequenceDefinition } from '../definitions/identity-sequence-definition.js';

/**
 * The machinery every Identity Application Service receives from the
 * composition root (I-2): the injected Clock (A-6), the Journal port (A-10),
 * and the TECHNICAL retry budget (bounded, M-8).
 */
export interface IdentitySequenceMachinery {
  readonly clock: Clock;
  readonly journal: SequenceJournalPort;
  readonly maxAttempts?: number;
}

/**
 * The ONE shape of the Identity Application Services (precedent:
 * AgreementSequenceApplicationService — F4.1 §7: conforming because boring).
 * It instantiates its definition, hands it to the ratified SequenceBuilder,
 * and delegates every call to the one SequenceExecutor. No business rule,
 * no state, no publication, no direct journaling, never another service.
 */
export abstract class IdentitySequenceApplicationService<
  TWire extends IdentityCommandContract,
  TCommand,
> {
  private readonly executor: SequenceExecutor<TWire, TCommand, Credential, CredentialRefusal>;

  protected constructor(
    definition: IdentitySequenceDefinition<TWire, TCommand>,
    machinery: IdentitySequenceMachinery,
  ) {
    const builder = new SequenceBuilder<TWire, TCommand, Credential, CredentialRefusal>()
      .withDefinition(definition)
      .withClock(machinery.clock)
      .withJournal(machinery.journal);
    this.executor = (
      machinery.maxAttempts === undefined ? builder : builder.withMaxAttempts(machinery.maxAttempts)
    ).build();
  }

  execute(input: SequenceInput): Promise<SequenceOutcome<Credential, CredentialRefusal>> {
    return this.executor.execute(input);
  }
}
