import type { Instant } from '@mentora/kernel';

import type { CancellationRecord } from './cancellation-record.js';

/**
 * The frozen state machine of the Agreement (F3.3 §8, sole owner of the
 * transitions): Requested → Accepted → Confirmed (⇄ Rescheduled) →
 * Cancelled | Elapsed ; Requested → Rejected | Lapsed ; Accepted → Lapsed.
 * Four terminals, irreversible (R-B: coming back is a NEW Demande).
 *
 * Modeled as a closed discriminated union so the type renders impossible
 * states inexpressible (F3.1.99 §5). "État → State" — Status is banned
 * (F2.5 §8, VD-0071).
 */
export type AgreementState =
  | { readonly kind: 'Requested'; readonly requestedAt: Instant }
  | { readonly kind: 'Accepted'; readonly acceptedAt: Instant }
  | { readonly kind: 'Confirmed'; readonly confirmedAt: Instant; readonly settlementReference: string }
  | { readonly kind: 'Rejected'; readonly rejectedAt: Instant }
  | { readonly kind: 'Lapsed'; readonly lapsedAt: Instant }
  | { readonly kind: 'Cancelled'; readonly record: CancellationRecord }
  | { readonly kind: 'Elapsed'; readonly elapsedAt: Instant };

export type AgreementStateKind = AgreementState['kind'];

const TERMINAL_KINDS: ReadonlySet<AgreementStateKind> = new Set([
  'Rejected',
  'Lapsed',
  'Cancelled',
  'Elapsed',
]);

/** Terminal states are irreversible (R-B). */
export const isTerminalState = (state: AgreementState): boolean => TERMINAL_KINDS.has(state.kind);
