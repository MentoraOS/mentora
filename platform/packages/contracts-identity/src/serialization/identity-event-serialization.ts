import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type {
  CredentialEstablished,
  CredentialRevoked,
} from '../events/identity-event-contracts.js';
import type { IdentityContractViolation } from '../validation/identity-command-validation.js';
import type { IdentityEventContract } from '../wire/event-union.js';
import { IDENTITY_EVENT_TYPES } from '../wire/event-union.js';

/**
 * The official serializers of the Identity event language (precedent:
 * contracts-agreement serializers). DETERMINISTIC: keys sorted recursively —
 * the same contract always yields byte-identical JSON (stable checksums in
 * the fact stream). Pure functions; no framework. The owner serializes its
 * OWN language (V-1) — the persistence adapter calls these, never redefines.
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

export const serializeIdentityEvent = (event: IdentityEventContract): string =>
  JSON.stringify(sortedValue(event));

const violation = (code: string, field: string, message: string): IdentityContractViolation => ({
  code,
  field,
  message,
});

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null;

const blankString = (value: unknown): boolean =>
  typeof value !== 'string' || value.trim().length === 0;

/** Structural validation of a wire fact — the language validates its OWN definition. */
export const validateIdentityEvent = (
  payload: unknown,
): Result<IdentityEventContract, readonly IdentityContractViolation[]> => {
  if (!isRecord(payload)) {
    return err([violation('CONTRACT.NOT_AN_OBJECT', '$', 'An event contract is an object')]);
  }
  const violations: IdentityContractViolation[] = [];
  const type = payload['type'];
  if (
    typeof type !== 'string' ||
    !(IDENTITY_EVENT_TYPES as readonly string[]).includes(type)
  ) {
    return err([
      violation(
        'CONTRACT.UNKNOWN_CONTRACT',
        'type',
        `An Identity event is one of: ${IDENTITY_EVENT_TYPES.join(', ')}`,
      ),
    ]);
  }
  if (payload['contractVersion'] !== 1) {
    violations.push(violation('CONTRACT.UNKNOWN_VERSION', 'contractVersion', 'Generation 1 only'));
  }
  if (blankString(payload['credentialId'])) {
    violations.push(violation('CONTRACT.FIELD_MISSING', 'credentialId', 'The unit identity is due'));
  }
  if (typeof payload['sequence'] !== 'number' || payload['sequence'] < 1) {
    violations.push(violation('CONTRACT.FIELD_INVALID', 'sequence', 'A positive per-unit order'));
  }
  if (typeof payload['occurredAtMs'] !== 'number') {
    violations.push(violation('CONTRACT.FIELD_INVALID', 'occurredAtMs', 'The instant in epoch millis'));
  }
  if (type === 'CredentialEstablished') {
    if (blankString(payload['personId'])) {
      violations.push(violation('CONTRACT.FIELD_MISSING', 'personId', 'The opaque person reference is due'));
    }
    if (blankString(payload['principalFactorId'])) {
      violations.push(violation('CONTRACT.FIELD_MISSING', 'principalFactorId', 'The principal factor identity is due'));
    }
    if (blankString(payload['principalFactorKind'])) {
      violations.push(violation('CONTRACT.FIELD_MISSING', 'principalFactorKind', 'The factor nature is due'));
    }
  }
  if (type === 'CredentialRevoked' && blankString(payload['motive'])) {
    violations.push(violation('CONTRACT.FIELD_MISSING', 'motive', 'A revocation is always motivated'));
  }
  if (violations.length > 0) {
    return err(violations);
  }
  return ok(payload as unknown as CredentialEstablished | CredentialRevoked);
};

export const deserializeIdentityEvent = (
  json: string,
): Result<IdentityEventContract, readonly IdentityContractViolation[]> => {
  let parsed: unknown;
  try {
    parsed = JSON.parse(json);
  } catch {
    return err([
      violation('CONTRACT.MALFORMED_JSON', '$', 'Payload is not valid JSON'),
    ]);
  }
  return validateIdentityEvent(parsed);
};
