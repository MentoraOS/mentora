import type { Option, Result } from '@mentora/kernel';
import { err, none, ok, some } from '@mentora/kernel';
import type { Config } from '@mentora/shared';

import type {
  ConfigSchema,
  ConfigValues,
  ConfigViolation,
} from './config-schema.js';
import type { ConfigSource } from './config-sources.js';

/**
 * loadConfig — reads each declared key from the sources IN ORDER (first
 * defined wins), parses, validates type and bounds, and FAILS CLOSED with
 * the COMPLETE list of violations: "une seule erreur = pas de démarrage"
 * (F4.4 §7) — the boot reports everything, then dies once.
 */
export const loadConfig = <TSchema extends ConfigSchema>(
  schema: TSchema,
  sources: readonly ConfigSource[],
): Result<ConfigValues<TSchema>, readonly ConfigViolation[]> => {
  const violations: ConfigViolation[] = [];
  const values: Record<string, string | number | boolean> = {};

  for (const [key, spec] of Object.entries(schema)) {
    const raw = readFirst(sources, key);
    if (raw === undefined) {
      if (spec.default !== undefined) {
        values[key] = spec.default;
        continue;
      }
      violations.push({
        key,
        code: 'CONFIG.MISSING',
        message: `'${key}' is required and no source provides it`,
      });
      continue;
    }
    switch (spec.kind) {
      case 'string': {
        if (spec.nonBlank === true && raw.trim() === '') {
          violations.push({ key, code: 'CONFIG.BLANK', message: `'${key}' must not be blank` });
          break;
        }
        values[key] = raw;
        break;
      }
      case 'number': {
        const parsed = Number(raw);
        if (raw.trim() === '' || Number.isNaN(parsed)) {
          violations.push({ key, code: 'CONFIG.TYPE', message: `'${key}' must be a number` });
          break;
        }
        if ((spec.min !== undefined && parsed < spec.min) || (spec.max !== undefined && parsed > spec.max)) {
          violations.push({
            key,
            code: 'CONFIG.BOUNDS',
            message: `'${key}' must lie within its declared bounds`,
          });
          break;
        }
        values[key] = parsed;
        break;
      }
      case 'boolean': {
        if (raw !== 'true' && raw !== 'false') {
          violations.push({
            key,
            code: 'CONFIG.TYPE',
            message: `'${key}' must be 'true' or 'false'`,
          });
          break;
        }
        values[key] = raw === 'true';
        break;
      }
      case 'choice': {
        if (!spec.values.includes(raw)) {
          violations.push({
            key,
            code: 'CONFIG.CHOICE',
            message: `'${key}' must be one of the declared values`,
          });
          break;
        }
        values[key] = raw;
        break;
      }
    }
  }

  if (violations.length > 0) {
    return err(violations);
  }
  return ok(values as ConfigValues<TSchema>);
};

const readFirst = (sources: readonly ConfigSource[], key: string): string | undefined => {
  for (const source of sources) {
    const value = source.read(key);
    if (value !== undefined) {
      return value;
    }
  }
  return undefined;
};

/** Serves loaded values through the shared Config contract (owned by shared, 0B). */
export const asSharedConfig = (values: Readonly<Record<string, unknown>>): Config => ({
  get: (key): Option<string> => {
    const value = values[key];
    return value === undefined ? none : some(String(value));
  },
});
