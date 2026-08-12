import { instantOf, invariant } from '@mentora/kernel';

import type { FakeClock } from './fake-clock.js';

/** A callback scheduled to run at a virtual instant. */
export interface ScheduledTask {
  readonly id: number;
  readonly runAtEpochMillis: number;
  readonly run: () => void;
}

/**
 * A virtual timer: schedule callbacks at delays, then advance virtual time and
 * watch them fire in order — synchronously, with zero real waiting. Pairs with a
 * `FakeClock` so "now" and "due" agree.
 *
 * @example
 * const clock = FakeClock.atEpoch();
 * const scheduler = new VirtualScheduler(clock);
 * scheduler.schedule(1_000, () => events.push('a'));
 * scheduler.advanceMillis(1_000); // fires 'a'
 */
export class VirtualScheduler {
  readonly #clock: FakeClock;
  #tasks: ScheduledTask[] = [];
  #nextId = 1;

  constructor(clock: FakeClock) {
    this.#clock = clock;
  }

  /** Schedule `run` to fire `delayMillis` from the current virtual now. */
  schedule(delayMillis: number, run: () => void): number {
    invariant(delayMillis >= 0, 'delay must be >= 0');
    const id = this.#nextId;
    this.#nextId += 1;
    this.#tasks.push({
      id,
      runAtEpochMillis: this.#clock.now().epochMillis + delayMillis,
      run,
    });
    return id;
  }

  /** Cancel a scheduled task by id. Returns true if it existed. */
  cancel(id: number): boolean {
    const before = this.#tasks.length;
    this.#tasks = this.#tasks.filter((t) => t.id !== id);
    return this.#tasks.length !== before;
  }

  /** Number of tasks still pending. */
  pendingCount(): number {
    return this.#tasks.length;
  }

  /**
   * Advance virtual time by `millis`, firing every task that becomes due, in
   * due-time order (FIFO among equal times). The clock is stepped to each
   * task's due time before it runs, so a task reading `clock.now()` sees the
   * moment it fires. Tasks scheduled *by* a running task also fire if due
   * within the window.
   */
  advanceMillis(millis: number): void {
    invariant(millis >= 0, 'advance must be >= 0');
    const target = this.#clock.now().epochMillis + millis;
    for (;;) {
      const due = this.#tasks
        .filter((t) => t.runAtEpochMillis <= target)
        .sort((a, b) => a.runAtEpochMillis - b.runAtEpochMillis || a.id - b.id);
      const next = due[0];
      if (next === undefined) {
        break;
      }
      this.#tasks = this.#tasks.filter((t) => t.id !== next.id);
      this.#clock.setTo(instantOf(next.runAtEpochMillis));
      next.run();
    }
    this.#clock.advanceMillis(target - this.#clock.now().epochMillis);
  }

  /** Run every pending task in order, advancing time as far as needed. */
  runAll(): void {
    while (this.#tasks.length > 0) {
      const horizon = Math.max(...this.#tasks.map((t) => t.runAtEpochMillis));
      this.advanceMillis(horizon - this.#clock.now().epochMillis);
    }
  }
}
