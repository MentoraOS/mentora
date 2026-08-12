import type { IdGenerator } from '@mentora/kernel';

/** Always returns the same id. For tests that need one known value. */
export class ConstantIdGenerator implements IdGenerator {
  readonly #value: string;

  constructor(value: string) {
    this.#value = value;
  }

  generate(): string {
    return this.#value;
  }
}
