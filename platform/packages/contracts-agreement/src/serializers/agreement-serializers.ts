import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AgreementCommandContract } from '../commands/agreement-command-contracts.js';
import type { AgreementContractViolation } from '../errors/agreement-error-contract.js';
import {
  validateAgreementCommand,
  validateAgreementEvent,
} from '../validators/agreement-validators.js';
import type { AgreementEventContract } from '../wire/event-union.js';

/**
 * The official serializers of the Agreement language.
 * - DETERMINISTIC: object keys are sorted recursively, so the same contract
 *   always yields byte-identical JSON (stable hashes, stable diffs).
 * - VERSIONED & BACKWARD COMPATIBLE: deserialization validates structure AND
 *   generation compatibility (V-2/V-4 — tolerant reader; unknown fields pass
 *   through validation untouched).
 * - Pure functions; no framework.
 */

const sortedValue = (value: unknown): unknown => {
  if (Array.isArray(value)) {
    return value.map(sortedValue);
  }
  if (typeof value === 'object' && value !== null) {
    const record = value as Record<string, unknown>;
    const out: Record<string, unknown> = {};
    for (const key of Object.keys(record).sort()) {
      out[key] = sortedValue(record[key]);
    }
    return out;
  }
  return value;
};

/** Deterministic JSON — the single wire encoding of the Agreement language. */
export const serializeAgreementEvent = (event: AgreementEventContract): string =>
  JSON.stringify(sortedValue(event));

export const serializeAgreementCommand = (command: AgreementCommandContract): string =>
  JSON.stringify(sortedValue(command));

type Deserialized<T> = Result<T, readonly AgreementContractViolation[]>;

const parse = (json: string): Deserialized<unknown> => {
  try {
    return ok(JSON.parse(json) as unknown);
  } catch {
    return err([
      { code: 'CONTRACT.MALFORMED_JSON', field: '$', message: 'Payload is not valid JSON' },
    ]);
  }
};

export const deserializeAgreementEvent = (json: string): Deserialized<AgreementEventContract> => {
  const parsed = parse(json);
  return parsed.ok ? validateAgreementEvent(parsed.value) : parsed;
};

export const deserializeAgreementCommand = (
  json: string,
): Deserialized<AgreementCommandContract> => {
  const parsed = parse(json);
  return parsed.ok ? validateAgreementCommand(parsed.value) : parsed;
};
