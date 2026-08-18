import type {
  SequenceInput,
  SequenceJournalPort,
  SequenceOutcome,
} from '@mentora/application-kernel';
import { SequenceBuilder, type SequenceExecutor } from '@mentora/application-kernel';
import type {
  EndSession as EndSessionContract,
  OpenSession as OpenSessionContract,
  RevokeSession as RevokeSessionContract,
  SessionCommandContract,
} from '@mentora/contracts-identity';
import type {
  EndSession,
  OpenSession,
  ProofRequirementPolicy,
  RevokeSession,
  Session,
  SessionRefusal,
  SessionRepository,
} from '@mentora/domain-identity';
import {
  commandIdOf,
  credentialIdOf,
  openSession,
  proofStrengthOf,
  sessionIdOf,
  sessionRefusal,
} from '@mentora/domain-identity';
import type { Clock, Instant, Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';
import { err } from '@mentora/kernel';

import type { SessionSequenceDefinition, SessionUseCase } from '../definitions/session-sequence-definition.js';
import { sessionAbsentRefusal, sessionSequenceDefinition } from '../definitions/session-sequence-definition.js';

/** The machinery the composition root injects (I-2) — same shape as the Credential side. */
export interface SessionSequenceMachinery {
  readonly clock: Clock;
  readonly journal: SequenceJournalPort;
  readonly maxAttempts?: number;
}

abstract class SessionSequenceApplicationService<TWire extends SessionCommandContract, TCommand> {
  private readonly executor: SequenceExecutor<TWire, TCommand, Session, SessionRefusal>;

  protected constructor(
    definition: SessionSequenceDefinition<TWire, TCommand>,
    machinery: SessionSequenceMachinery,
  ) {
    const builder = new SequenceBuilder<TWire, TCommand, Session, SessionRefusal>()
      .withDefinition(definition)
      .withClock(machinery.clock)
      .withJournal(machinery.journal);
    this.executor = (
      machinery.maxAttempts === undefined ? builder : builder.withMaxAttempts(machinery.maxAttempts)
    ).build();
  }

  execute(input: SequenceInput): Promise<SequenceOutcome<Session, SessionRefusal>> {
    return this.executor.execute(input);
  }
}

// ---------------------------------------------------------------- seams (pas 5)

const toOpenSession = (wire: OpenSessionContract, instant: Instant): Result<OpenSession, SessionRefusal> =>
  ok({
    commandId: commandIdOf(wire.commandId),
    sessionId: sessionIdOf(wire.sessionId),
    credentialId: credentialIdOf(wire.credentialId),
    presentedStrength: proofStrengthOf(wire.presentedStrength),
    openedAt: instant,
  });

const toEndSession = (wire: EndSessionContract, instant: Instant): Result<EndSession, SessionRefusal> =>
  ok({ commandId: commandIdOf(wire.commandId), sessionId: sessionIdOf(wire.sessionId), endedAt: instant });

const toRevokeSession = (
  wire: RevokeSessionContract,
  instant: Instant,
): Result<RevokeSession, SessionRefusal> =>
  ok({
    commandId: commandIdOf(wire.commandId),
    sessionId: sessionIdOf(wire.sessionId),
    motive: wire.motive,
    revokedAt: instant,
  });

// ---------------------------------------------------------------- carriers (A-1)

/** Carries `OpenSession` — the birth on proof; the RATIFIED ProofRequirementPolicy judges. */
export class OpenSessionApplicationService extends SessionSequenceApplicationService<
  OpenSessionContract,
  OpenSession
> {
  constructor(
    deps: { readonly repository: SessionRepository; readonly proofRequirement: ProofRequirementPolicy },
    machinery: SessionSequenceMachinery,
  ) {
    const useCase: SessionUseCase<OpenSessionContract, OpenSession> = {
      commandType: 'OpenSession',
      map: (wire, instant) => toOpenSession(wire, instant),
      act: (unit, command) =>
        unit.some
          ? err(
              sessionRefusal(
                'TransitionUnavailable',
                'A Session already lives under this Identifier — a new unit requires a new identity (R-B)',
              ),
            )
          : openSession(command, deps.proofRequirement),
    };
    super(sessionSequenceDefinition(useCase, deps.repository), machinery);
  }
}

/** Carries `EndSession` — the person's own terminal. */
export class EndSessionApplicationService extends SessionSequenceApplicationService<
  EndSessionContract,
  EndSession
> {
  constructor(deps: { readonly repository: SessionRepository }, machinery: SessionSequenceMachinery) {
    const useCase: SessionUseCase<EndSessionContract, EndSession> = {
      commandType: 'EndSession',
      map: (wire, instant) => toEndSession(wire, instant),
      act: (unit, command) => (unit.some ? unit.value.end(command) : err(sessionAbsentRefusal())),
    };
    super(sessionSequenceDefinition(useCase, deps.repository), machinery);
  }
}

/** Carries `RevokeSession` — the suffered terminal. */
export class RevokeSessionApplicationService extends SessionSequenceApplicationService<
  RevokeSessionContract,
  RevokeSession
> {
  constructor(deps: { readonly repository: SessionRepository }, machinery: SessionSequenceMachinery) {
    const useCase: SessionUseCase<RevokeSessionContract, RevokeSession> = {
      commandType: 'RevokeSession',
      map: (wire, instant) => toRevokeSession(wire, instant),
      act: (unit, command) => (unit.some ? unit.value.revoke(command) : err(sessionAbsentRefusal())),
    };
    super(sessionSequenceDefinition(useCase, deps.repository), machinery);
  }
}
