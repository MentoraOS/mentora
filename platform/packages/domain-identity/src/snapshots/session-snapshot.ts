/**
 * SessionSnapshot — the internal reconstitution photograph (F3.1.11),
 * registry-private. STATE ONLY: a session has no facts to photograph —
 * nothing it holds may ever leak through an Outbox.
 */

export type SessionSnapshotState =
  | { readonly kind: 'Active'; readonly openedAtMs: number }
  | { readonly kind: 'Ended'; readonly endedAtMs: number }
  | { readonly kind: 'Revoked'; readonly revokedAtMs: number; readonly motive: string };

export interface SessionSnapshot {
  readonly sessionId: string;
  readonly credentialId: string;
  readonly state: SessionSnapshotState;
  readonly version: number;
}
