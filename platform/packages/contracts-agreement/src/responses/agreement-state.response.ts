import type { AgreementId } from '../ids/identifiers.js';
import type { AgreementSlotContract } from '../wire/fragments.js';

/**
 * The response of AgreementStateQuery — exactly what the frozen catalogue
 * grants ("l'état") and nothing more: no conditions to third parties, no
 * private content (P7). Not a business DTO: a published read shape.
 * Pagination: none — a single-truth read (Page<T> from @mentora/contracts is
 * reused the day a ratified collection read exists; none does today).
 */
export interface AgreementStateResponse {
  readonly contractVersion: 1;
  readonly type: 'AgreementStateResponse';
  readonly agreementId: AgreementId;
  readonly stateKind:
    | 'Requested'
    | 'Accepted'
    | 'Confirmed'
    | 'Rejected'
    | 'Lapsed'
    | 'Cancelled'
    | 'Elapsed';
  readonly slot: AgreementSlotContract;
  /** Optimistic-concurrency version of the unit (F5.2 §4). */
  readonly version: number;
}
