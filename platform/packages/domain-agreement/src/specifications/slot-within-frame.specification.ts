import type { TimeSlot } from '../value-objects/time-slot.js';
import { timeSlotWithin } from '../value-objects/time-slot.js';

/**
 * Frozen Specification (F3.2-A, F3.3 §7: SlotWithinFrame). "Une Demande vise un
 * Créneau du Cadre publié" (F2.6 [S]). The Cadre is PROVIDED as data (loi 15);
 * the question is named, composable, reusable (F3.1).
 */
export class SlotWithinFrameSpecification {
  isSatisfiedBy(slot: TimeSlot, publishedWindows: readonly TimeSlot[]): boolean {
    return publishedWindows.some((window) => timeSlotWithin(slot, window));
  }
}
