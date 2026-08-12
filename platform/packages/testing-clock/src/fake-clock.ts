import type { Clock, Instant } from '@mentora/kernel';
import { instantOf, invariant } from '@mentora/kernel';

/**
 * A `Clock` whose "now" only moves when the test says so.
 *
 * @example
 * const clock = FakeClock.at(instantOf(0));
 * clock.advanceMillis(5_000);
 * expect(clock.now().epochMillis).toBe(5_000);
 */
export class FakeClock implements Clock {
  #current: Instant;

  private constructor(initial: Instant) {
    this.#current = initial;
  }

  /** A clock frozen at the given instant. */
  static at(initial: Instant): FakeClock {
    return new FakeClock(initial);
  }

  /** A clock frozen at the Unix epoch (t = 0). */
  static atEpoch(): FakeClock {
    return new FakeClock(instantOf(0));
  }

  now(): Instant {
    return this.#current;
  }

  /** Move time forward by `millis` (must be >= 0 — time never rewinds). */
  advanceMillis(millis: number): void {
    invariant(millis >= 0, 'FakeClock only advances; time never rewinds');
    this.#current = instantOf(this.#current.epochMillis + millis);
  }

  /** Jump directly to `instant` (must not be in the past of the clock). */
  setTo(instant: Instant): void {
    invariant(
      instant.epochMillis >= this.#current.epochMillis,
      'FakeClock only advances; time never rewinds',
    );
    this.#current = instant;
  }
}
