import type { Option, Result, RetentionContext } from '@mentora/kernel';

import type { Session } from '../aggregate/session.js';
import type { SessionRefusal } from '../decisions/session-refusal.js';
import type { CredentialId, SessionId } from '../ids/identifiers.js';

/**
 * SessionRepository — the registry port owned by the domain, shaped like
 * the frozen precedent. retain() persists STATE ONLY: the Session has no
 * facts, so the registry writes NOTHING to any Outbox de faits — that
 * absence is part of the port's contract and of its suite.
 * activeByCredential is the cascade probe: the future Réaction consuming
 * `CredentialRevoked` uses it to bring the credential's sessions down.
 *
 * The OPTIONAL `context` is RFC-001 (Option A, RATIFIED): the port family
 * shares ONE signature. A session registry has no outbox to carry it to —
 * accepting it changes nothing here, by design.
 */
export interface SessionRepository {
  byId(id: SessionId): Promise<Option<Session>>;
  activeByCredential(credentialId: CredentialId): Promise<readonly Session[]>;
  retain(session: Session, context?: RetentionContext): Promise<Result<void, SessionRefusal>>;
}
