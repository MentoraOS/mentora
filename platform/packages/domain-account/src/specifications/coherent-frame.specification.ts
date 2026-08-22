import type { AvailabilityWindow } from '../value-objects/availability-window.js';

/**
 * CoherentFrameSpecification — the NAMED invariant of the AvailabilityFrame
 * (canon F3.2-B: "invariant : fenêtres cohérentes"; catalogue
 * `CoherentFrame`). Reading recorded (the canon names the invariant, not
 * its arithmetic): a set of windows is coherent iff every window is
 * well-formed (start strictly before end) and no two windows overlap. An
 * empty frame is coherent (nothing published). Touching windows
 * (end == next start) do not overlap.
 */
export class CoherentFrameSpecification {
  isSatisfiedBy(windows: readonly AvailabilityWindow[]): boolean {
    if (windows.some((window) => window.start.epochMillis >= window.end.epochMillis)) {
      return false;
    }
    const sorted = [...windows].sort((a, b) => a.start.epochMillis - b.start.epochMillis);
    for (let index = 1; index < sorted.length; index += 1) {
      const previous = sorted[index - 1] as AvailabilityWindow;
      const current = sorted[index] as AvailabilityWindow;
      if (current.start.epochMillis < previous.end.epochMillis) {
        return false;
      }
    }
    return true;
  }
}
