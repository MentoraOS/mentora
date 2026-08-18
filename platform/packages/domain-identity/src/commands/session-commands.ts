import type { Instant } from '@mentora/kernel';

import type { CommandId, CredentialId, SessionId } from '../ids/identifiers.js';
import type { ProofStrength } from '../value-objects/proof-strength.js';

/**
 * Commands of the Session unit — the three ratified dictionary verbs
 * (catalog 72-74). Instants arrive as data (the clock never enters). The
 * presented proof rides as its STRENGTH only — nature and weight, never
 * material (the mechanism adapter verified the material outside).
 */

export interface OpenSession {
  readonly commandId: CommandId;
  readonly sessionId: SessionId;
  /** Provenance (canon ch.04): a session is always opened ON a proof. */
  readonly credentialId: CredentialId;
  /** The strength of the proof the mechanism just verified — data, never material. */
  readonly presentedStrength: ProofStrength;
  readonly openedAt: Instant;
}

export interface EndSession {
  readonly commandId: CommandId;
  readonly sessionId: SessionId;
  readonly endedAt: Instant;
}

export interface RevokeSession {
  readonly commandId: CommandId;
  readonly sessionId: SessionId;
  readonly motive: string;
  readonly revokedAt: Instant;
}
