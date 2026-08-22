import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AccountContractViolation } from '../validation/account-command-validation.js';
import type { AccountEventContract } from '../wire/event-union.js';
import { ACCOUNT_EVENT_TYPES } from '../wire/event-union.js';

/**
 * The official serializers of the Account event language (precedent:
 * contracts-identity). DETERMINISTIC: keys sorted recursively — the same
 * contract always yields byte-identical JSON (stable checksums in the fact
 * stream). The owner serializes its OWN language (V-1); the persistence
 * adapter calls these, never redefines them.
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

export const serializeAccountEvent = (event: AccountEventContract): string =>
  JSON.stringify(sortedValue(event));

const violation = (code: string, field: string, message: string): AccountContractViolation => ({
  code,
  field,
  message,
});

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null;

const blankString = (value: unknown): boolean =>
  typeof value !== 'string' || value.trim().length === 0;

/** The subject key of each fact: the person for Account/frame facts, the subscription for its own. */
const SUBJECT_FIELD: Readonly<Record<(typeof ACCOUNT_EVENT_TYPES)[number], string>> = {
  PersonRegistered: 'personId',
  PreferenceChanged: 'personId',
  ReachabilityChanged: 'personId',
  AccountClosed: 'personId',
  AvailabilityFrameChanged: 'personId',
  SubscriptionStarted: 'subscriptionId',
  SubscriptionEnded: 'subscriptionId',
};

const REQUIRED_STRINGS: Readonly<Record<(typeof ACCOUNT_EVENT_TYPES)[number], readonly string[]>> = {
  PersonRegistered: ['verificationState'],
  PreferenceChanged: ['preferenceKind', 'preferenceValue'],
  ReachabilityChanged: ['channel'],
  AccountClosed: ['motive'],
  AvailabilityFrameChanged: [],
  SubscriptionStarted: ['personId', 'offerReference'],
  SubscriptionEnded: ['motive'],
};

/** Structural validation of a wire fact — the language validates its OWN definition. */
export const validateAccountEvent = (
  payload: unknown,
): Result<AccountEventContract, readonly AccountContractViolation[]> => {
  if (!isRecord(payload)) {
    return err([violation('CONTRACT.NOT_AN_OBJECT', '$', 'An event contract is an object')]);
  }
  const type = payload['type'];
  if (typeof type !== 'string' || !(ACCOUNT_EVENT_TYPES as readonly string[]).includes(type)) {
    return err([
      violation(
        'CONTRACT.UNKNOWN_CONTRACT',
        'type',
        `An Account event is one of: ${ACCOUNT_EVENT_TYPES.join(', ')}`,
      ),
    ]);
  }
  const known = type as (typeof ACCOUNT_EVENT_TYPES)[number];
  const violations: AccountContractViolation[] = [];
  if (payload['contractVersion'] !== 1) {
    violations.push(violation('CONTRACT.UNKNOWN_VERSION', 'contractVersion', 'Generation 1 only'));
  }
  if (blankString(payload[SUBJECT_FIELD[known]])) {
    violations.push(
      violation('CONTRACT.FIELD_MISSING', SUBJECT_FIELD[known], 'The unit identity is due'),
    );
  }
  if (typeof payload['sequence'] !== 'number' || payload['sequence'] < 1) {
    violations.push(violation('CONTRACT.FIELD_INVALID', 'sequence', 'A positive per-unit order'));
  }
  if (typeof payload['occurredAtMs'] !== 'number') {
    violations.push(
      violation('CONTRACT.FIELD_INVALID', 'occurredAtMs', 'The instant in epoch millis'),
    );
  }
  for (const field of REQUIRED_STRINGS[known]) {
    if (blankString(payload[field])) {
      violations.push(violation('CONTRACT.FIELD_MISSING', field, `${field} is due`));
    }
  }
  if (known === 'AvailabilityFrameChanged' && !Array.isArray(payload['windows'])) {
    violations.push(violation('CONTRACT.FIELD_INVALID', 'windows', 'The windows are due'));
  }
  if (violations.length > 0) {
    return err(violations);
  }
  return ok(payload as unknown as AccountEventContract);
};

export const deserializeAccountEvent = (
  json: string,
): Result<AccountEventContract, readonly AccountContractViolation[]> => {
  let parsed: unknown;
  try {
    parsed = JSON.parse(json);
  } catch {
    return err([violation('CONTRACT.MALFORMED_JSON', '$', 'Payload is not valid JSON')]);
  }
  return validateAccountEvent(parsed);
};
