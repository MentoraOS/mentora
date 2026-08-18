import type { SequenceDefinition } from '@mentora/application-kernel';
import type { ActorRef } from '@mentora/contracts';
import type { IdentityCommandContract } from '@mentora/contracts-identity';
import type { Credential, CredentialRefusal, CredentialRepository } from '@mentora/domain-identity';
import type { Instant, Option, Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';

import { receiveIdentityCommand } from '../validators/reception.js';

/**
 * The Identity & Access instantiation of the Golden Pipeline's plug (1C-2,
 * precedent: agreement-sequence-definition). ONE skeleton for the ratified
 * use cases — the pipeline stays generic; the definition is what the context
 * injects: Reception delegates to the published language (pas 1); Loading is
 * the registry by Identifier (R-A); the seam injects the instant (A-6); the
 * Act is the unit's (or Factory's) Decision; Retention is the port's atomic
 * act, where the declared R-A key refuses structurally.
 */

export type IdentitySequenceDefinition<
  TWire extends IdentityCommandContract,
  TCommand,
> = SequenceDefinition<TWire, TCommand, Credential, CredentialRefusal>;

/** What one use case brings: its dictionary name, its seam, its act. */
export interface IdentityUseCase<TWire extends IdentityCommandContract, TCommand> {
  readonly commandType: TWire['type'];
  /** The wire→domain seam (pas 5): published command + injected instant → domain command. */
  map(wire: TWire, instant: Instant, actor: ActorRef): Result<TCommand, CredentialRefusal>;
  /** The act (pas 6): the unit (or its Factory) renders the Decision. */
  act(unit: Option<Credential>, command: TCommand): Result<Credential, CredentialRefusal>;
}

export const identitySequenceDefinition = <TWire extends IdentityCommandContract, TCommand>(
  useCase: IdentityUseCase<TWire, TCommand>,
  repository: CredentialRepository,
): IdentitySequenceDefinition<TWire, TCommand> => ({
  commandTypeOf: (wire) => wire.type,

  /** The act identity rides the wire (F4.1 §3) — replay is deduplicated by it. */
  actIdentityOf: (wire) => wire.commandId,

  receive: (payload) => {
    const received = receiveIdentityCommand(payload);
    if (!received.ok) {
      return received;
    }
    // NOTE(#21): the A-1 cross-carrier guard (precedent: agreement) is
    // statically dead while the published union has ONE member — a foreign
    // type already dies at validation as UNKNOWN_CONTRACT. Reintroduce the
    // guard the moment RevokeCredential joins the union (Story #21).
    return ok(received.value as TWire);
  },

  load: (wire) => repository.byId(wire.credentialId),

  validate: (wire, instant, actor) => Promise.resolve(useCase.map(wire, instant, actor)),

  act: (unit, command) => useCase.act(unit, command),

  retain: (unit) => repository.retain(unit),
});
