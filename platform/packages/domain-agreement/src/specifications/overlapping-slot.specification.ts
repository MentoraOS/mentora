import type { TimeSlot } from '../value-objects/time-slot.js';
import { timeSlotsOverlap } from '../value-objects/time-slot.js';

/**
 * Frozen Specification (F3.2-A, F3.3 §7: OverlappingSlot — "sert la clé R-A").
 * THE RULE BELONGS TO THE DOMAIN; THE KEY BELONGS TO THE REGISTRY (R-A): two
 * CONFIRMED Agreements never target the same expert on overlapping slots. The
 * registry applies the declared key structurally at retention and refuses with
 * the motivated Decision TimeSlotUnavailable — it never knows this rule.
 */
export class OverlappingSlotSpecification {
  isSatisfiedBy(a: TimeSlot, b: TimeSlot): boolean {
    return timeSlotsOverlap(a, b);
  }
}
