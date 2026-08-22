import type { Instant } from '@mentora/kernel';

/**
 * AvailabilityWindow — one window of the published frame (dictionary:
 * AvailabilityWindow). A value: two instants. Coherence of a SET of windows
 * is the CoherentFrameSpecification's judgment, not the window's.
 */
export interface AvailabilityWindow {
  readonly start: Instant;
  readonly end: Instant;
}
