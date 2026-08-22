import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { AccountCommandContract } from '../commands/account-command-contracts.js';
import { ACCOUNT_COMMAND_TYPES } from '../commands/account-command-contracts.js';

/**
 * Structural validation of the wire — the published language validates its
 * OWN single definition, per type, listing EVERY violation (precedent:
 * contracts-identity). Malformed = the caller's defect (Exception channel at
 * pas 1), never a Refusal.
 */

export interface AccountContractViolation {
  readonly code: string;
  readonly field: string;
  readonly message: string;
}

const violation = (code: string, field: string, message: string): AccountContractViolation => ({
  code,
  field,
  message,
});

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null;

const blankString = (value: unknown): boolean =>
  typeof value !== 'string' || value.trim().length === 0;

const requireStrings = (
  payload: Record<string, unknown>,
  fields: readonly string[],
  violations: AccountContractViolation[],
): void => {
  for (const field of fields) {
    if (blankString(payload[field])) {
      violations.push(violation('CONTRACT.MALFORMED', field, 'must be a non-blank string'));
    }
  }
};

export const validateAccountCommand = (
  payload: unknown,
): Result<AccountCommandContract, readonly AccountContractViolation[]> => {
  if (!isRecord(payload)) {
    return err([violation('CONTRACT.MALFORMED', '$', 'payload must be an object')]);
  }
  const type = payload['type'];
  if (typeof type !== 'string' || !(ACCOUNT_COMMAND_TYPES as readonly string[]).includes(type)) {
    return err([
      violation(
        'CONTRACT.UNKNOWN_CONTRACT',
        'type',
        `type must be one of: ${ACCOUNT_COMMAND_TYPES.join(', ')}`,
      ),
    ]);
  }
  const violations: AccountContractViolation[] = [];
  if (payload['contractVersion'] !== 1) {
    violations.push(violation('CONTRACT.UNKNOWN_GENERATION', 'contractVersion', 'must be 1'));
  }
  requireStrings(payload, ['commandId', 'personId'], violations);

  switch (type) {
    case 'RegisterPerson':
      requireStrings(payload, ['verificationState'], violations);
      break;
    case 'ChangePreference': {
      const preference = payload['preference'];
      if (!isRecord(preference)) {
        violations.push(violation('CONTRACT.MALFORMED', 'preference', 'must be an object'));
      } else {
        for (const field of ['kind', 'value']) {
          if (blankString(preference[field])) {
            violations.push(
              violation('CONTRACT.MALFORMED', `preference.${field}`, 'must be a non-blank string'),
            );
          }
        }
      }
      break;
    }
    case 'ChangeReachability':
      requireStrings(payload, ['channel'], violations);
      break;
    case 'RegisterDevice':
    case 'RemoveDevice':
      requireStrings(payload, ['deviceId'], violations);
      break;
    case 'CloseAccount':
      requireStrings(payload, ['motive'], violations);
      break;
    case 'ChangeAvailabilityFrame': {
      const windows = payload['windows'];
      if (!Array.isArray(windows)) {
        violations.push(violation('CONTRACT.MALFORMED', 'windows', 'must be an array'));
      } else {
        windows.forEach((window, index) => {
          if (
            !isRecord(window) ||
            typeof window['startMs'] !== 'number' ||
            typeof window['endMs'] !== 'number'
          ) {
            violations.push(
              violation(
                'CONTRACT.MALFORMED',
                `windows[${String(index)}]`,
                'must carry numeric startMs and endMs',
              ),
            );
          }
        });
      }
      break;
    }
    case 'StartSubscription':
      requireStrings(payload, ['subscriptionId', 'offerReference'], violations);
      break;
    case 'EndSubscription':
      requireStrings(payload, ['subscriptionId', 'motive'], violations);
      break;
    case 'OpenSupportRequest':
      requireStrings(payload, ['supportRequestId', 'motive'], violations);
      break;
    case 'HandleSupportRequest':
      requireStrings(payload, ['supportRequestId'], violations);
      break;
    default:
      break;
  }
  if (violations.length > 0) {
    return err(violations);
  }
  return ok(payload as unknown as AccountCommandContract);
};
