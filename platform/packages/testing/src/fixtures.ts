/**
 * Fixture builder — the "object mother" pattern, typed.
 *
 * Define a fixture once with sensible defaults; each test overrides only what it
 * cares about. Overrides are shallow-merged; the result is a fresh object every
 * time (no shared mutable fixtures — determinism and isolation).
 *
 * @example
 * const aPerson = defineFixture(() => ({ name: 'Ada', age: 36 }));
 * const p = aPerson({ age: 41 }); // { name: 'Ada', age: 41 }
 */

export type FixtureFactory<T extends object> = (overrides?: Partial<T>) => T;

/** Create a fixture factory from a defaults-producing function. */
export const defineFixture = <T extends object>(defaults: () => T): FixtureFactory<T> => {
  return (overrides?: Partial<T>): T => ({ ...defaults(), ...overrides });
};

/** Build `count` fixtures, each optionally customized by its index. */
export const buildMany = <T extends object>(
  factory: FixtureFactory<T>,
  count: number,
  customize?: (index: number) => Partial<T>,
): T[] => Array.from({ length: count }, (_, i) => factory(customize?.(i)));
