import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { EstablishCredential, IdentityCommandContract } from '../commands/identity-command-contracts.js';
import { IDENTITY_COMMAND_TYPES } from '../commands/identity-command-contracts.js';

/**
 * Structural validation of the wire — the published language validates its
 * OWN single definition (precedent: contracts-agreement schemas). A violation
 * list feeds the Exception channel at reception (pas 1): malformed = the
 * caller's defect, never a Refusal.
 */

export interface IdentityContractViolation {
  readonly code: string;
  readonly field: string;
  readonly message: string;
}

const violation = (code: string, field: string, message: string): IdentityContractViolation => ({
  code,
  field,
  message,
});

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null;

const blankString = (value: unknown): boolean =>
  typeof value !== 'string' || value.trim().length === 0;

export const validateIdentityCommand = (
  payload: unknown,
): Result<IdentityCommandContract, readonly IdentityContractViolation[]> => {
  const violations: IdentityContractViolation[] = [];
  if (!isRecord(payload)) {
    return err([violation('CONTRACT.MALFORMED', '$', 'payload must be an object')]);
  }
  const type = payload['type'];
  if (typeof type !== 'string' || !IDENTITY_COMMAND_TYPES.includes(type as never)) {
    return err([
      violation(
        'CONTRACT.UNKNOWN_CONTRACT',
        'type',
        `type must be one of: ${IDENTITY_COMMAND_TYPES.join(', ')}`,
      ),
    ]);
  }
  if (payload['contractVersion'] !== 1) {
    violations.push(violation('CONTRACT.UNKNOWN_GENERATION', 'contractVersion', 'must be 1'));
  }
  for (const field of ['commandId', 'credentialId', 'personId']) {
    if (blankString(payload[field])) {
      violations.push(violation('CONTRACT.MALFORMED', field, 'must be a non-blank string'));
    }
  }
  const factor = payload['principalFactor'];
  if (!isRecord(factor)) {
    violations.push(violation('CONTRACT.MALFORMED', 'principalFactor', 'must be an object'));
  } else {
    for (const field of ['factorId', 'kind', 'strength']) {
      if (blankString(factor[field])) {
        violations.push(
          violation('CONTRACT.MALFORMED', `principalFactor.${field}`, 'must be a non-blank string'),
        );
      }
    }
  }
  if (violations.length > 0) {
    return err(violations);
  }
  return ok(payload as unknown as EstablishCredential);
};
