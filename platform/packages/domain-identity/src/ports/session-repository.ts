import type { Option, Result } from '@mentora/kernel';

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
 */
export interface SessionRepository {
  byId(id: SessionId): Promise<Option<Session>>;
  activeByCredential(credentialId: CredentialId): Promise<readonly Session[]>;
  retain(session: Session): Promise<Result<void, SessionRefusal>>;
}
