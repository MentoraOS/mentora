import type { Instant, Result } from '@mentora/kernel';
import { err, isBefore, ok } from '@mentora/kernel';

import type { AgreementRefusal } from '../decisions/agreement-refusal.js';
import { agreementRefusal } from '../decisions/agreement-refusal.js';

/**
 * TimeSlot — the ratified VO (F2.5 §3: Créneau → TimeSlot; "Slot" nu banned).
 * Immutable; refuses to exist invalid (F3.1: "un VO invalide n'existe pas" —
 * the VO's own refusal door, rendered as a Decision value, fail closed).
 */
export interface TimeSlot {
  readonly start: Instant;
  readonly end: Instant;
}

/** Smart constructor: start must be strictly before end. */
export const timeSlotOf = (start: Instant, end: Instant): Result<TimeSlot, AgreementRefusal> =>
  isBefore(start, end)
    ? ok({ start, end })
    : err(agreementRefusal('SlotBoundsInvalid', 'TimeSlot start must be strictly before end'));

/** Half-open overlap: [a.start, a.end) ∩ [b.start, b.end) ≠ ∅. */
export const timeSlotsOverlap = (a: TimeSlot, b: TimeSlot): boolean =>
  isBefore(a.start, b.end) && isBefore(b.start, a.end);

/** Is `slot` entirely inside `window` (inclusive bounds)? */
export const timeSlotWithin = (slot: TimeSlot, window: TimeSlot): boolean =>
  !isBefore(slot.start, window.start) && !isBefore(window.end, slot.end);
