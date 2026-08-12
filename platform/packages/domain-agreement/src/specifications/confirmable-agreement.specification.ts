import type { AgreementState } from '../value-objects/agreement-state.js';

/**
 * Frozen Specification (F3.2-A, F3.3 §7: ConfirmableAgreement).
 * "L'Acceptation précède toute Confirmation" [T] and "Nulle Confirmation sans
 * conditions accomplies, encaissement compris" [É] (F2.6): confirmable ⇔ the
 * state is Accepted AND the translated settlement evidence is present.
 */
export class ConfirmableAgreementSpecification {
  isSatisfiedBy(state: AgreementState, settlementReference: string): boolean {
    return state.kind === 'Accepted' && settlementReference.trim().length > 0;
  }
}
