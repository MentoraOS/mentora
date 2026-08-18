import type { Instant, Result } from '@mentora/kernel';
import { err, instantOf, ok } from '@mentora/kernel';

import type { EndSession, RevokeSession } from '../commands/session-commands.js';
import type { SessionRefusal } from '../decisions/session-refusal.js';
import { sessionRefusal } from '../decisions/session-refusal.js';
import { SessionSnapshotCorruptException } from '../errors/identity-exceptions.js';
import type { CredentialId, SessionId } from '../ids/identifiers.js';
import { credentialIdOf, sessionIdOf } from '../ids/identifiers.js';
import type { SessionSnapshot } from '../snapshots/session-snapshot.js';
import type { SessionState } from '../value-objects/session-state.js';

/**
 * Session — opened on a proof, never a business fact (canon ch.04):
 * provenance `CredentialId`; frozen machine `Active → Ended | Revoked`
 * (two DISTINCT terminals: Ended = the person's own act, Revoked =
 * suffered); several sessions per credential; "déconnecter cet appareil"
 * without revoking the proof.
 *
 * THE STRUCTURAL LAW OF THIS UNIT: **no published fact, ever** —
 * "« connecté » n'est jamais un fait métier ; ce qui n'est pas publié ne
 * peut pas fuir". This class has NO pendingFacts field AT ALL: the absence
 * is not a discipline, it is the shape. The registry retains STATE only;
 * nothing enters any Outbox de faits.
 *
 * The credential-revocation CASCADE (RevokeCredential ⇒ its sessions die)
 * is transported by the application layer (a Réaction consuming
 * `CredentialRevoked`, wired at the integration lot) — the unit offers the
 * verb, the circulation carries the cause. Story #118 measures the bounded
 * latency.
 */
export class Session {
  private constructor(
    readonly id: SessionId,
    /** Provenance — the proof this session was opened on. */
    readonly credentialId: CredentialId,
    readonly state: SessionState,
    /** Optimistic-concurrency version (F5.2 §4); increments with every transition. */
    readonly version: number,
  ) {}

  // ------------------------------------------------------------------ birth

  /** INTERNAL to the domain: called by openSession (the factory door) only. */
  static _born(id: SessionId, credentialId: CredentialId, openedAt: Instant): Session {
    return new Session(id, credentialId, { kind: 'Active', openedAt }, 1);
  }

  // ------------------------------------------------------- frozen machine

  /** The person's own act — Active → Ended (terminal, R-B). */
  end(command: EndSession): Result<Session, SessionRefusal> {
    if (this.state.kind !== 'Active') {
      return err(this.transitionUnavailable('end'));
    }
    return ok(
      new Session(this.id, this.credentialId, { kind: 'Ended', endedAt: command.endedAt }, this.version + 1),
    );
  }

  /** The suffered terminal — Active → Revoked (guardian's act or credential cascade). */
  revoke(command: RevokeSession): Result<Session, SessionRefusal> {
    if (this.state.kind !== 'Active') {
      return err(this.transitionUnavailable('revoke'));
    }
    return ok(
      new Session(
        this.id,
        this.credentialId,
        { kind: 'Revoked', revokedAt: command.revokedAt, motive: command.motive },
        this.version + 1,
      ),
    );
  }

  private transitionUnavailable(verb: string): SessionRefusal {
    return sessionRefusal(
      'TransitionUnavailable',
      `${verb} requires an Active session; current state is ${this.state.kind}`,
    );
  }

  // ------------------------------------------------------- reconstitution

  /** Photograph for the registry — private, never served (F3.1.11). */
  snapshot(): SessionSnapshot {
    return {
      sessionId: this.id,
      credentialId: this.credentialId,
      state:
        this.state.kind === 'Active'
          ? { kind: 'Active', openedAtMs: this.state.openedAt.epochMillis }
          : this.state.kind === 'Ended'
            ? { kind: 'Ended', endedAtMs: this.state.endedAt.epochMillis }
            : {
                kind: 'Revoked',
                revokedAtMs: this.state.revokedAt.epochMillis,
                motive: this.state.motive,
              },
      version: this.version,
    };
  }

  /** Reconstruction = private snapshot + delta(0). Corruption throws — never a Refusal. */
  static fromSnapshot(snapshot: SessionSnapshot): Session {
    if (snapshot.version < 1) {
      throw new SessionSnapshotCorruptException(
        `session ${snapshot.sessionId}: version ${snapshot.version}`,
      );
    }
    const state: SessionState =
      snapshot.state.kind === 'Active'
        ? { kind: 'Active', openedAt: instantOf(snapshot.state.openedAtMs) }
        : snapshot.state.kind === 'Ended'
          ? { kind: 'Ended', endedAt: instantOf(snapshot.state.endedAtMs) }
          : {
              kind: 'Revoked',
              revokedAt: instantOf(snapshot.state.revokedAtMs),
              motive: snapshot.state.motive,
            };
    return new Session(
      sessionIdOf(snapshot.sessionId),
      credentialIdOf(snapshot.credentialId),
      state,
      snapshot.version,
    );
  }
}
