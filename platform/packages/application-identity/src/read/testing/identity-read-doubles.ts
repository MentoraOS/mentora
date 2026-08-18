import type { CredentialId, SessionId } from '@mentora/domain-identity';
import type { Option } from '@mentora/kernel';
import { none, some } from '@mentora/kernel';

import type {
  CredentialStateReadPort,
  CredentialStateView,
  SessionStateReadPort,
  SessionStateView,
} from '../ports/identity-state-read.port.js';

/**
 * The in-memory REFERENCES of the Identity read capabilities (I-10) — pure
 * classes, no test-runner import (the barrels lesson). The composition spec
 * and the future gate's tests seed them; the PostgreSQL adapter must
 * exhibit the same promises (proven in its integration gate).
 */

export class InMemorySessionStateRead implements SessionStateReadPort {
  private readonly views = new Map<string, SessionStateView>();

  seed(view: SessionStateView): void {
    this.views.set(view.sessionId, view);
  }

  stateOf(sessionId: SessionId): Promise<Option<SessionStateView>> {
    const view = this.views.get(sessionId);
    return Promise.resolve(view === undefined ? none : some(view));
  }
}

export class InMemoryCredentialStateRead implements CredentialStateReadPort {
  private readonly views = new Map<string, CredentialStateView>();

  seed(view: CredentialStateView): void {
    this.views.set(view.credentialId, view);
  }

  stateOf(credentialId: CredentialId): Promise<Option<CredentialStateView>> {
    const view = this.views.get(credentialId);
    return Promise.resolve(view === undefined ? none : some(view));
  }
}
