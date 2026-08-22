import type { SequenceDefinition, SequenceRefusalLike } from '@mentora/application-kernel';
import type { ActorRef } from '@mentora/contracts';
import type { AccountCommandContract, AccountContractViolation } from '@mentora/contracts-account';
import { validateAccountCommand } from '@mentora/contracts-account';
import type { Instant, Option, Result, RetentionContext } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

/**
 * THE ONE Account plug of the Golden Pipeline — generic over the four units
 * (pattern extracted from Identity, where one definition per unit was
 * written twice by hand: the skeleton never varied, only the types did).
 * The unit's registry enters as two seams (`load`, `retain`) and the use
 * case as two (`map` at pas 5, `act` at pas 6). Everything else is the
 * frozen skeleton: reception by the PUBLISHED language (A-1 guard: a
 * foreign type is a violation, never a Refusal), load by Identifier only,
 * the instant injected into the seam, the RetentionContext of RFC-001
 * handed through (pas 8).
 */

export interface AccountUseCase<TWire extends AccountCommandContract, TCommand, TUnit, TRefusal> {
  readonly commandType: TWire['type'];
  /** The wire→domain seam (pas 5): published command + injected instant → domain command. */
  map(wire: TWire, instant: Instant, actor: ActorRef): Result<TCommand, TRefusal>;
  /** The act (pas 6): the unit (or its Factory) renders the Decision. */
  act(unit: Option<TUnit>, command: TCommand): Result<TUnit, TRefusal>;
}

export interface AccountRegistrySeams<TWire, TUnit, TRefusal> {
  load(wire: TWire): Promise<Option<TUnit>>;
  retain(unit: TUnit, context?: RetentionContext): Promise<Result<void, TRefusal>>;
}

export const receiveAccountCommand = (
  payload: unknown,
): Result<AccountCommandContract, readonly AccountContractViolation[]> =>
  validateAccountCommand(payload);

export const accountSequenceDefinition = <
  TWire extends AccountCommandContract,
  TCommand,
  TUnit,
  TRefusal extends SequenceRefusalLike,
>(
  useCase: AccountUseCase<TWire, TCommand, TUnit, TRefusal>,
  registry: AccountRegistrySeams<TWire, TUnit, TRefusal>,
): SequenceDefinition<TWire, TCommand, TUnit, TRefusal> => ({
  commandTypeOf: (wire) => wire.type,
  actIdentityOf: (wire) => wire.commandId,

  receive: (payload) => {
    const received = receiveAccountCommand(payload);
    if (!received.ok) {
      return received;
    }
    if (received.value.type !== useCase.commandType) {
      return err([
        {
          code: 'CONTRACT.UNKNOWN_CONTRACT',
          field: 'type',
          message: `This service carries '${useCase.commandType}', not '${received.value.type}' (A-1)`,
        },
      ]);
    }
    return ok(received.value as TWire);
  },

  load: (wire) => registry.load(wire),
  validate: (wire, instant, actor) => Promise.resolve(useCase.map(wire, instant, actor)),
  act: (unit, command) => useCase.act(unit, command),
  // RFC-001: the stage-built envelope context rides through to the registry.
  retain: (unit, context) => registry.retain(unit, context),
});

/** A command aimed at an Identifier under which no unit lives — the ratified generic refusal. */
export const absentRefusal = <TRefusal>(
  make: (reason: 'TransitionUnavailable', message: string) => TRefusal,
  truth: string,
): TRefusal =>
  make(
    'TransitionUnavailable',
    `No ${truth} lives under this Identifier — the frozen machine offers no transition`,
  );

/** A birth aimed at an inhabited Identifier — R-B. */
export const inhabitedRefusal = <TRefusal>(
  make: (reason: 'TransitionUnavailable', message: string) => TRefusal,
  truth: string,
): TRefusal =>
  make(
    'TransitionUnavailable',
    `A ${truth} already lives under this Identifier — a new unit requires a new identity (R-B)`,
  );
