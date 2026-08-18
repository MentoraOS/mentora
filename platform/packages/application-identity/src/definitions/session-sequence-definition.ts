import type { SequenceDefinition } from '@mentora/application-kernel';
import type { ActorRef } from '@mentora/contracts';
import type { SessionCommandContract, IdentityContractViolation } from '@mentora/contracts-identity';
import { validateSessionCommand } from '@mentora/contracts-identity';
import type { Session, SessionRefusal, SessionRepository } from '@mentora/domain-identity';
import { sessionRefusal } from '@mentora/domain-identity';
import type { Instant, Option, Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

/**
 * The Session instantiation of the Golden Pipeline's plug — same skeleton
 * as the Credential's, typed on the Session unit. The registry retains
 * STATE ONLY (the unit has no facts, structurally).
 */

export type SessionSequenceDefinition<
  TWire extends SessionCommandContract,
  TCommand,
> = SequenceDefinition<TWire, TCommand, Session, SessionRefusal>;

export interface SessionUseCase<TWire extends SessionCommandContract, TCommand> {
  readonly commandType: TWire['type'];
  map(wire: TWire, instant: Instant, actor: ActorRef): Result<TCommand, SessionRefusal>;
  act(unit: Option<Session>, command: TCommand): Result<Session, SessionRefusal>;
}

/** No Session lives under this Identifier — a motivated Decision (precedent). */
export const sessionAbsentRefusal = (): SessionRefusal =>
  sessionRefusal(
    'TransitionUnavailable',
    'No Session lives under this Identifier — the frozen machine offers no transition',
  );

export const receiveSessionCommand = (
  payload: unknown,
): Result<SessionCommandContract, readonly IdentityContractViolation[]> =>
  validateSessionCommand(payload);

export const sessionSequenceDefinition = <TWire extends SessionCommandContract, TCommand>(
  useCase: SessionUseCase<TWire, TCommand>,
  repository: SessionRepository,
): SessionSequenceDefinition<TWire, TCommand> => ({
  commandTypeOf: (wire) => wire.type,
  actIdentityOf: (wire) => wire.commandId,

  receive: (payload) => {
    const received = receiveSessionCommand(payload);
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

  load: (wire) => repository.byId(wire.sessionId),
  validate: (wire, instant, actor) => Promise.resolve(useCase.map(wire, instant, actor)),
  act: (unit, command) => useCase.act(unit, command),
  retain: (unit) => repository.retain(unit),
});
