import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { SerializationViolation } from './canonical-json.js';

/**
 * VersionedPayload — the runtime envelope of a versioned text (generations
 * are the OWNER's law, V-1/V-2: evolution is additive, the reader tolerant;
 * this wrapper only CARRIES the declared version, it never judges it).
 */
export interface VersionedPayload {
  readonly version: number;
  readonly payload: unknown;
}

export const versionedPayload = (version: number, payload: unknown): VersionedPayload => ({
  version,
  payload,
});

export const readVersionedPayload = (
  value: unknown,
): Result<VersionedPayload, SerializationViolation> => {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) {
    return err({ code: 'SERIAL.MALFORMED', message: 'a versioned payload is an object' });
  }
  const record = value as Record<string, unknown>;
  const version = record['version'];
  if (typeof version !== 'number' || !Number.isInteger(version) || version < 1) {
    return err({
      code: 'SERIAL.MALFORMED',
      message: 'a versioned payload declares a positive integer version',
    });
  }
  if (!('payload' in record)) {
    return err({ code: 'SERIAL.MALFORMED', message: 'a versioned payload carries its payload' });
  }
  return ok({ version, payload: record['payload'] });
};
