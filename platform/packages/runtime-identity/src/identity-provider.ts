import type { IdGenerator } from '@mentora/kernel';

import { RandomIdFactory } from './random-id-factory.js';
import { UuidFactory } from './uuid-factory.js';

/**
 * IdentityProvider — the bundle a Root injects where identifier generation
 * is needed (F4.4 §2: the Root builds the machinery; I-2: above it, one
 * receives). DELIBERATE ABSENCE of a "SequentialIdFactory": deterministic
 * generators are test doubles and live in @mentora/testing-id (Lot 0C) —
 * a production sequential id would collide across instances by construction.
 */
export interface IdentityProvider {
  readonly uuids: IdGenerator;
  readonly randoms: IdGenerator;
}

export const createIdentityProvider = (): IdentityProvider => ({
  uuids: new UuidFactory(),
  randoms: new RandomIdFactory(),
});
