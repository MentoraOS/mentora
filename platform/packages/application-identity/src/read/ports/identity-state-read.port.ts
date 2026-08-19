import type { CredentialId, PersonId, SessionId } from '@mentora/domain-identity';
import type { Option } from '@mentora/kernel';

/**
 * The READ ports of Identity & Access — owned by their consumer, the
 * application (I-4); implemented by adapters below (I-12). READ ONLY by
 * construction: no save, no retain, no publish exists on these surfaces.
 *
 * CONSTITUTIONAL STATE (Story #56/#57, STOP #59 answered): the ratified
 * lecture catalogue (F3.3 §5 — 11 lectures) contains NO Identity & Access
 * Query. No SessionStateQuery, no CredentialStateQuery exists in the
 * Corpus, so NONE is declared here and the Identity query table stays
 * CLOSED AND EMPTY (see the composition). These are CAPABILITY ports
 * (`<Capability>Port`, F2.5 §9), not Queries: their consumer is the M-10
 * gate (FEATURE-005, Sprint 3) — "le gateway vérifie la session, les
 * droits restent au dispatch" — which must resolve a session's state to
 * inject the ActorRef, an infrastructure act, never a public read with a
 * rights grid (R-C). Should a public I&A read ever be needed, it is a
 * Titre VII instruction first — never an addition here.
 */

/** The Read Model row of a session's state — a VIEW, never the unit. */
export interface SessionStateView {
  readonly sessionId: SessionId;
  readonly credentialId: CredentialId;
  readonly stateKind: 'Active' | 'Ended' | 'Revoked';
  readonly version: number;
}

/** The Read Model row of a credential's state — a VIEW, never the unit. */
export interface CredentialStateView {
  readonly credentialId: CredentialId;
  readonly personId: PersonId;
  readonly stateKind: 'Active' | 'Revoked';
  readonly version: number;
  /**
   * The factor REFERENCES AND NATURES (Story #96/#111): the vestibule's
   * verification mechanisms resolve material BY factorId at the vault —
   * no matter exists here by construction (the unit holds none).
   */
  readonly factors: readonly {
    readonly factorId: string;
    readonly kind: string;
    readonly strength: string;
    readonly principal: boolean;
  }[];
}

/** The gate's lecture of ONE session's state, by Identifier, nothing else. */
export interface SessionStateReadPort {
  stateOf(sessionId: SessionId): Promise<Option<SessionStateView>>;
}

/** The gate's lecture of ONE credential's state, by Identifier, nothing else. */
export interface CredentialStateReadPort {
  stateOf(credentialId: CredentialId): Promise<Option<CredentialStateView>>;
}
