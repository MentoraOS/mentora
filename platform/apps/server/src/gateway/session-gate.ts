import type {
  CredentialStateReadPort,
  SessionStateReadPort,
} from '@mentora/application-identity';
import type { ActorRef } from '@mentora/contracts';
import type { SessionId } from '@mentora/domain-identity';

/**
 * SessionGate — M-10/M-9 verbatim: "le gateway est borné à la session : il
 * vérifie l'identité de transport ; le droit métier ne se juge qu'au
 * dispatch et chez le propriétaire." This gate answers ONE question — does
 * the presented session close the chain of proof (1) Credential → Session →
 * ActorRef (F5.4) — and injects the ActorRef. It never judges a business
 * right (a right judged here would be "un droit dupliqué qui divergera").
 *
 * The WHOLE chain is verified, not the session row alone: a session whose
 * credential is no longer Active is a broken chain — 401 immediately, even
 * BEFORE the future cascade Réaction retires the session rows (this is the
 * révocation-immédiate promise the Sprint 5 lot #118/#119 will measure).
 *
 * The ActorRef is the PERSON's opaque reference (T-8: no session-identity,
 * no implicit identity; T-14: nothing substitutes the ActorRef) — resolved
 * through the read capabilities, on the primary (S-5).
 */

export type GateVerdict =
  | { readonly kind: 'admitted'; readonly actor: ActorRef }
  | { readonly kind: 'unauthenticated'; readonly detail: string };

export class SessionGate {
  constructor(
    private readonly sessions: SessionStateReadPort,
    private readonly credentials: CredentialStateReadPort,
  ) {}

  async verify(presented: string | undefined): Promise<GateVerdict> {
    if (presented === undefined || presented.trim() === '') {
      return { kind: 'unauthenticated', detail: 'no session presented' };
    }
    const session = await this.sessions.stateOf(presented as SessionId);
    if (!session.some) {
      return { kind: 'unauthenticated', detail: 'unknown session' };
    }
    if (session.value.stateKind !== 'Active') {
      return { kind: 'unauthenticated', detail: 'session is not active' };
    }
    const credential = await this.credentials.stateOf(session.value.credentialId);
    if (!credential.some || credential.value.stateKind !== 'Active') {
      // The chain of proof is broken at its root — the revocation bites
      // HERE, immediately, whatever the session row still says.
      return { kind: 'unauthenticated', detail: 'the proof behind this session is revoked' };
    }
    return { kind: 'admitted', actor: credential.value.personId as unknown as ActorRef };
  }
}
