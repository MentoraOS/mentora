import type { Brand } from '../types/brand.js';

/**
 * Identity primitives.
 *
 * `Id<TBrand>` is an opaque, branded string — a stable identifier that cannot be
 * confused with a plain string or with another kind of id (F3.1.99 §4: opaque,
 * stable, never derived from mutable data). Generation of new ids is impure
 * (needs entropy), so it is a **port** (`IdGenerator`) whose implementation lives
 * in an adapter — the kernel only defines the contract and a pure validator.
 */

/** An opaque identifier, tagged by `TBrand` so two id kinds never mix. */
export type Id<TBrand extends string> = Brand<string, TBrand>;

/** A UUID string (any version), branded. */
export type Uuid = Brand<string, 'Uuid'>;

/**
 * Port: produces new opaque identifiers. Implemented by an adapter (e.g. a
 * UUIDv7 generator). The kernel never generates ids itself — it stays pure.
 */
export interface IdGenerator {
  generate(): string;
}

const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

/** Pure validator: is this string a canonical UUID? Narrows to `Uuid`. */
export const isUuid = (value: string): value is Uuid => UUID_PATTERN.test(value);
