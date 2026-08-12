import type { Instant } from '@mentora/kernel';

import type { AgreementId } from '../ids/identifiers.js';

/**
 * Common shape of every Agreement fact. A fact carries identities, natures,
 * instants, authors, provenances — never private content (P7). Fact identity =
 * (agreementId, sequence): deterministic, born inside the unit at the instant
 * of the act (F3.1.5), consumable idempotently (loi 14).
 */
export interface AgreementFactBase {
  readonly agreementId: AgreementId;
  /** Monotonic per-aggregate sequence; (agreementId, sequence) is the fact identity. */
  readonly sequence: number;
  /** The injected instant of the act (F4.1 A-6) — never read from a clock here. */
  readonly instant: Instant;
}
