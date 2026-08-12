/**
 * Small, universal type-level utilities. No runtime code — these disappear at
 * compile time.
 */

/** The primitive types (everything that is not an object). */
export type Primitive = string | number | bigint | boolean | symbol | null | undefined;

/** A record whose keys are strings and whose values are unknown. */
export type UnknownRecord = Record<string, unknown>;

/**
 * Flattens an intersection into a single object literal so hover/IntelliSense
 * shows `{ a: 1; b: 2 }` instead of `A & B`. Purely cosmetic, but it makes
 * complex types readable.
 */
export type Prettify<T> = { [K in keyof T]: T[K] } & {};

/** A tuple with at least one element. */
export type NonEmptyArray<T> = readonly [T, ...T[]];

/**
 * Recursively marks every property (and array/map/set element) as readonly.
 * Immutable-first is the default posture of the platform (F1 §4).
 */
export type DeepReadonly<T> = T extends Primitive
  ? T
  : T extends ReadonlyArray<infer U>
    ? ReadonlyArray<DeepReadonly<U>>
    : T extends ReadonlyMap<infer K, infer V>
      ? ReadonlyMap<DeepReadonly<K>, DeepReadonly<V>>
      : T extends ReadonlySet<infer M>
        ? ReadonlySet<DeepReadonly<M>>
        : { readonly [K in keyof T]: DeepReadonly<T[K]> };
