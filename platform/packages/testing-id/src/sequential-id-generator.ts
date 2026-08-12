import type { IdGenerator } from '@mentora/kernel';

/**
 * Ids `prefix-1`, `prefix-2`, … in call order. The simplest deterministic
 * generator; ideal when a test asserts on exact ids.
 */
export class SequentialIdGenerator implements IdGenerator {
  #next = 1;
  readonly #prefix: string;

  constructor(prefix = 'id') {
    this.#prefix = prefix;
  }

  generate(): string {
    const id = `${this.#prefix}-${String(this.#next)}`;
    this.#next += 1;
    return id;
  }

  /** Reset the sequence back to 1. */
  reset(): void {
    this.#next = 1;
  }
}
