import type { Credential, Session } from '@mentora/domain-identity';
import {
  ProofRequirementPolicy,
  commandIdOf,
  credentialIdOf,
  establishCredential,
  factorIdOf,
  factorKindOf,
  openSession,
  personIdOf,
  proofStrengthOf,
  sessionIdOf,
} from '@mentora/domain-identity';
import { instantOf } from '@mentora/kernel';

/**
 * IdentityPersistenceMother — units built through REAL domain acts (the
 * house pattern since 1A: the Mother replays acts, never fabricates state).
 * Deterministic instants; the ratified policy with a permissive allowlist.
 */

export const MOTHER_T0 = instantOf(1_700_000_000_000);

const unwrap = <T>(result: { ok: boolean; value?: T; error?: unknown }): T => {
  if (!result.ok || result.value === undefined) {
    throw new Error(`the Mother replays valid acts only: ${JSON.stringify(result.error)}`);
  }
  return result.value;
};

export class IdentityPersistenceMother {
  readonly policy = new ProofRequirementPolicy({ acceptedStrengths: ['standard'] });

  established(id = 'cred-1', person = 'person-1', kind = 'password'): Credential {
    return unwrap(
      establishCredential({
        commandId: commandIdOf(`cmd-est-${id}`),
        credentialId: credentialIdOf(id),
        personId: personIdOf(person),
        principalFactor: {
          factorId: factorIdOf(`factor-${id}`),
          kind: factorKindOf(kind),
          strength: proofStrengthOf('standard'),
        },
        establishedAt: MOTHER_T0,
      }),
    );
  }

  /** Established then revoked in the SAME pre-retention life: two facts, one act of retention. */
  revoked(id = 'cred-1', person = 'person-1', kind = 'password'): Credential {
    const unit = this.established(id, person, kind);
    return unwrap(
      unit.revoke({
        commandId: commandIdOf(`cmd-rev-${id}`),
        credentialId: unit.id,
        motive: 'rotation',
        revokedAt: instantOf(MOTHER_T0.epochMillis + 1_000),
      }),
    );
  }

  opened(id = 'sess-1', credential = 'cred-1'): Session {
    return unwrap(
      openSession(
        {
          commandId: commandIdOf(`cmd-open-${id}`),
          sessionId: sessionIdOf(id),
          credentialId: credentialIdOf(credential),
          presentedStrength: proofStrengthOf('standard'),
          openedAt: MOTHER_T0,
        },
        this.policy,
      ),
    );
  }

  ended(id = 'sess-1', credential = 'cred-1'): Session {
    const unit = this.opened(id, credential);
    return unwrap(
      unit.end({
        commandId: commandIdOf(`cmd-end-${id}`),
        sessionId: unit.id,
        endedAt: instantOf(MOTHER_T0.epochMillis + 1_000),
      }),
    );
  }
}
