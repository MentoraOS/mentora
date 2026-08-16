import type { Clock } from '@mentora/kernel';

import { MonotonicClock } from './monotonic-clock.js';
import { SystemClock } from './system-clock.js';

/**
 * ClockFactory — what the Root asks for its executables (F4.4 §2: the Root
 * builds the machinery). DELIBERATE ABSENCE of a "FakeClockRuntime": the
 * ratified test double is FakeClock in @mentora/testing-clock (Lot 0C) —
 * duplicating it here would create a second definition of one truth.
 */
export interface ClockFactory {
  system(): Clock;
  monotonic(): MonotonicClock;
}

export const clockFactory: ClockFactory = {
  system: () => new SystemClock(),
  monotonic: () => new MonotonicClock(),
};
