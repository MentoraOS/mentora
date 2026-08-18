import type { Option, Result } from '@mentora/kernel';
import { none, ok, some } from '@mentora/kernel';

import type { Session } from '../aggregate/session.js';
import type { SessionRefusal } from '../decisions/session-refusal.js';
import type { CredentialId, SessionId } from '../ids/identifiers.js';

/**
 * InMemorySessionRepository — the REFERENCE implementation of the
 * SessionRepository port (I-10). STATE ONLY: nothing resembling an outbox
 * exists here, and the contract suite asserts that absence. Pure class —
 * no test-runner import (the barrels lesson).
 */
export class InMemorySessionRepository {
  private readonly store = new Map<string, { session: Session; version: number }>();

  byId(id: SessionId): Promise<Option<Session>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found.session));
  }

  activeByCredential(credentialId: CredentialId): Promise<readonly Session[]> {
    const active: Session[] = [];
    for (const { session } of this.store.values()) {
      if (session.credentialId === credentialId && session.state.kind === 'Active') {
        active.push(session);
      }
    }
    return Promise.resolve(active);
  }

  retain(session: Session): Promise<Result<void, SessionRefusal>> {
    const existing = this.store.get(session.id);
    const expectedPrevious = session.version - 1;
    if (existing !== undefined && existing.version !== expectedPrevious) {
      // Version conflict: the transient FAILURE channel (S-3) — thrown,
      // retryable by the pipeline, never a Refusal.
      return Promise.reject(
        new Error(
          `version conflict on ${session.id}: retained ${existing.version}, expected ${expectedPrevious}`,
        ),
      );
    }
    this.store.set(session.id, { session, version: session.version });
    return Promise.resolve(ok(undefined));
  }
}
