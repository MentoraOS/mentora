import type { SequenceDefinition } from '@mentora/application-kernel';
import type { ActorRef } from '@mentora/contracts';
import type { IdentityCommandContract } from '@mentora/contracts-identity';
import type { Credential, CredentialRefusal, CredentialRepository } from '@mentora/domain-identity';
import { credentialRefusal } from '@mentora/domain-identity';
import type { Instant, Option, Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

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

/**
 * A command aimed at an Identifier under which no Credential lives: the
 * frozen machine has no transition from nothingness — the ratified refusal
 * family motivates the Decision (precedent: agreementAbsentRefusal). Not an
 * Exception (the call is well-formed), not a Failure (nothing technical).
 */
export const credentialAbsentRefusal = (): CredentialRefusal =>
  credentialRefusal(
    'TransitionUnavailable',
    'No Credential lives under this Identifier — the frozen machine offers no transition',
  );

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
    if (received.value.type !== useCase.commandType) {
      // Reintroduced with Story #21 (the union now has two members): a
      // well-formed command of ANOTHER use case reached this service — the
      // dispatch table (one carrier per Command, A-8) was violated by the
      // caller, a malformed call for THIS contract, the Exception channel.
      return err([
        {
          code: 'CONTRACT.UNKNOWN_CONTRACT',
          field: 'type',
          message: `This service carries '${useCase.commandType}', not '${received.value.type}' (A-1: one Command, one Application Service)`,
        },
      ]);
    }
    return ok(received.value as TWire);
  },

  load: (wire) => repository.byId(wire.credentialId),

  validate: (wire, instant, actor) => Promise.resolve(useCase.map(wire, instant, actor)),

  act: (unit, command) => useCase.act(unit, command),

  retain: (unit) => repository.retain(unit),
});
