import type { CredentialId, FactorId, PersonId } from '../identifiers.js';

/**
 * The wire facts of the Identity & Access context — the TWO ratified events
 * (dictionary F2.5 §4: « CredentialEstablished · CredentialRevoked »), in
 * the published language the relay carries (precedent: contracts-agreement
 * event contracts). References and natures, NEVER any matter (canon ch.04);
 * no strength judgment (the strength is the Policy's business, not the
 * public record's). Session publishes NOTHING — no Session fact exists in
 * this language, by constitutional state, and none may be added here.
 * The base and the closed union live in wire/event-union.ts (MENTORA0003:
 * this directory belongs to the facts alone).
 */

export interface CredentialEstablished {
  readonly contractVersion: 1;
  readonly type: 'CredentialEstablished';
  readonly credentialId: CredentialId;
  /** EventIdentity = (credentialId, sequence) — per-unit order (F4.3 §4). */
  readonly sequence: number;
  readonly occurredAtMs: number;
  /** Opaque reference — the proof↔person link lives in the Account ACL. */
  readonly personId: PersonId;
  readonly principalFactorId: FactorId;
  readonly principalFactorKind: string;
}

export interface CredentialRevoked {
  readonly contractVersion: 1;
  readonly type: 'CredentialRevoked';
  readonly credentialId: CredentialId;
  readonly sequence: number;
  readonly occurredAtMs: number;
  /** Dictionary motive — a reference, never secret material. */
  readonly motive: string;
}
