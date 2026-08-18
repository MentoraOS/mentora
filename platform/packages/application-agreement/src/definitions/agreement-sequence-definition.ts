import type { SequenceDefinition } from '@mentora/application-kernel';
import type { ActorRef } from '@mentora/contracts';
import type { AgreementCommandContract } from '@mentora/contracts-agreement';
import type { Agreement, AgreementRefusal, AgreementRepository } from '@mentora/domain-agreement';
import { agreementRefusal } from '@mentora/domain-agreement';
import type { Instant, Option, Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import { receiveAgreementCommand } from '../validators/reception.js';

/**
 * The Agreement instantiation of the Golden Pipeline's plug (1C-2,
 * `SequenceDefinition`). ONE skeleton for the eight use cases — the pipeline
 * stays generic (it never knows Agreement); the definition is what the
 * context injects:
 * - Reception delegates to the published language (pas 1 — the application
 *   adds nothing to the wire's single definition);
 * - Loading is the registry, by Identifier, nothing else (R-A);
 * - SourceValidities is the wire→domain seam (1C-1 factory): the injected
 *   instant (A-6) enters here; cross-domain preconditions already ride the
 *   wire AS DATA (loi 15);
 * - Act is the unit's Decision (or the Factory's, for births) — the service
 *   transports it, never judges it (F4.1 §1: "il ne décide pas");
 * - Retention is the port's atomic act; the declared R-A key refuses
 *   STRUCTURALLY (TimeSlotUnavailable), a motivated Decision.
 */

export type AgreementSequenceDefinition<
  TWire extends AgreementCommandContract,
  TCommand,
> = SequenceDefinition<TWire, TCommand, Agreement, AgreementRefusal>;

/** What one use case brings: its dictionary name, its seam, its act. */
export interface AgreementUseCase<TWire extends AgreementCommandContract, TCommand> {
  readonly commandType: TWire['type'];
  /** The wire→domain seam (pas 5): published command + injected instant → domain command. */
  map(wire: TWire, instant: Instant, actor: ActorRef): Result<TCommand, AgreementRefusal>;
  /** The act (pas 6): the unit (or its Factory) renders the Decision. */
  act(unit: Option<Agreement>, command: TCommand): Result<Agreement, AgreementRefusal>;
}

/**
 * A command aimed at an Identifier under which no Agreement lives: the frozen
 * machine has no transition from nothingness — the ratified refusal family
 * (`-Unavailable`, F3.2-A) motivates the Decision. Not an Exception (the call
 * is well-formed), not a Failure (nothing technical failed).
 */
export const agreementAbsentRefusal = (): AgreementRefusal =>
  agreementRefusal(
    'TransitionUnavailable',
    'No Agreement lives under this Identifier — the frozen machine offers no transition',
  );

export const agreementSequenceDefinition = <TWire extends AgreementCommandContract, TCommand>(
  useCase: AgreementUseCase<TWire, TCommand>,
  repository: AgreementRepository,
): AgreementSequenceDefinition<TWire, TCommand> => ({
  commandTypeOf: (wire) => wire.type,

  /** The act identity rides the wire (F4.1 §3) — replay is deduplicated by it. */
  actIdentityOf: (wire) => wire.commandId,

  receive: (payload) => {
    const received = receiveAgreementCommand(payload);
    if (!received.ok) {
      return received;
    }
    if (received.value.type !== useCase.commandType) {
      // A well-formed command of ANOTHER use case reached this service: the
      // dispatch table (one carrier per Command, A-8) was violated by the
      // caller — a malformed call for THIS contract, the Exception channel.
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

  load: (wire) => repository.byId(wire.agreementId),

  validate: (wire, instant, actor) => Promise.resolve(useCase.map(wire, instant, actor)),

  act: (unit, command) => useCase.act(unit, command),

  // RFC-001: the stage-built envelope context rides through to the registry.
  retain: (unit, context) => repository.retain(unit, context),
});
