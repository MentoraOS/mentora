import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import { Agreement } from '../aggregate/agreement.js';
import type { RequestAgreement } from '../commands/agreement-commands.js';
import type { AgreementRefusal } from '../decisions/agreement-refusal.js';
import { agreementRefusal } from '../decisions/agreement-refusal.js';
import { SlotWithinFrameSpecification } from '../specifications/slot-within-frame.specification.js';
import { agreementConditionsOf } from '../value-objects/agreement-conditions.js';
import { timeSlotOf } from '../value-objects/time-slot.js';

/**
 * AgreementFactory — the birth door (F3.1: mandatory when birth establishes
 * invariants; "la Factory refuse les naissances"). Constitutional constraints:
 * - it NEVER calls a port — the outside world arrives IN PARAMETERS (the
 *   published AvailabilityFrame windows ride on the command, loi 15);
 * - it applies Specifications (F3.1 matrix: Factory → applique Spec);
 * - it arms the FIRST fact (AgreementRequested); the unit carries it; the
 *   Application layer publishes after retention — the Factory never publishes.
 */
export class AgreementFactory {
  private readonly slotWithinFrame = new SlotWithinFrameSpecification();

  request(command: RequestAgreement): Result<Agreement, AgreementRefusal> {
    // The VO door first: a slot that refuses to exist invalid (F3.1).
    const slot = timeSlotOf(command.slot.start, command.slot.end);
    if (!slot.ok) {
      return slot;
    }
    // "Une Demande vise un Créneau du Cadre publié" (F2.6 [S]) — frame as data.
    if (!this.slotWithinFrame.isSatisfiedBy(slot.value, command.availabilityWindows)) {
      return err(
        agreementRefusal(
          'OutsideAvailabilityFrame',
          'The requested Créneau is outside the published AvailabilityFrame',
        ),
      );
    }
    return ok(
      Agreement._born(
        command.agreementId,
        command.clientId,
        command.expertId,
        agreementConditionsOf(command.offerId),
        slot.value,
        command.instant,
      ),
    );
  }
}
