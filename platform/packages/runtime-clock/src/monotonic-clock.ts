/**
 * MonotonicClock — elapsed-time measurement for TECHNICAL durations only
 * (timers, drain windows). It never yields an Instant of truth: domain time
 * arrives as data on commands (F3.1.99: the clock never enters the unit);
 * emission timestamps belong to the emitting layer (F5.3 §2). Monotonic by
 * construction — never jumps backwards with wall-clock adjustments.
 */
export class MonotonicClock {
  private readonly origin: number;

  constructor() {
    this.origin = globalThis.performance.now();
  }

  /** Milliseconds elapsed since this clock was constructed. Never decreases. */
  elapsedMillis(): number {
    return globalThis.performance.now() - this.origin;
  }
}
