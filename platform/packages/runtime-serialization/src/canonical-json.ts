import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

/**
 * Canonical, DETERMINISTIC JSON — recursive key sort, same value → same
 * text, always ("Canonicalisation lorsque pertinente", F1). RUNTIME
 * machinery only: the published-language serializers of the contracts
 * packages remain the owners of their contracts (V-1: "le propriétaire du
 * fait possède son contrat"); the dialects die at the adapter (S-2).
 */

export interface SerializationViolation {
  readonly code: 'SERIAL.UNSUPPORTED' | 'SERIAL.CYCLE' | 'SERIAL.MALFORMED';
  readonly message: string;
}

export const canonicalJson = (value: unknown): Result<string, SerializationViolation> => {
  try {
    return ok(stringify(value, new Set()));
  } catch (error) {
    if (error instanceof CycleMark) {
      return err({ code: 'SERIAL.CYCLE', message: 'the value cycles — nothing canonical exists' });
    }
    return err({
      code: 'SERIAL.UNSUPPORTED',
      message: error instanceof Error ? error.message : String(error),
    });
  }
};

class CycleMark extends Error {}

const stringify = (value: unknown, seen: Set<object>): string => {
  if (value === null) {
    return 'null';
  }
  switch (typeof value) {
    case 'string':
      return JSON.stringify(value);
    case 'number': {
      if (!Number.isFinite(value)) {
        throw new Error('non-finite numbers have no canonical text');
      }
      return JSON.stringify(value);
    }
    case 'boolean':
      return value ? 'true' : 'false';
    case 'object': {
      const target = value;
      if (seen.has(target)) {
        throw new CycleMark();
      }
      seen.add(target);
      const text = Array.isArray(target)
        ? `[${target.map((item) => stringify(item, seen)).join(',')}]`
        : `{${Object.keys(target as Record<string, unknown>)
            .sort()
            .filter((key) => (target as Record<string, unknown>)[key] !== undefined)
            .map(
              (key) =>
                `${JSON.stringify(key)}:${stringify((target as Record<string, unknown>)[key], seen)}`,
            )
            .join(',')}}`;
      seen.delete(target);
      return text;
    }
    case 'bigint':
    case 'symbol':
    case 'undefined':
    case 'function':
      break;
  }
  throw new Error(`values of type '${typeof value}' have no canonical text`);
};
