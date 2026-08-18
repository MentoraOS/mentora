import type {
  IdentityCommandContract,
  IdentityContractViolation,
} from '@mentora/contracts-identity';
import { validateIdentityCommand } from '@mentora/contracts-identity';
import type { Result } from '@mentora/kernel';

/**
 * Pas 1 — Reception (F4.1 §2): the payload becomes a typed dictionary
 * Command; malformed → Exception, end. The application ADDS NOTHING to the
 * published language's validation — single definition, no duplication.
 */
export const receiveIdentityCommand = (
  payload: unknown,
): Result<IdentityCommandContract, readonly IdentityContractViolation[]> =>
  validateIdentityCommand(payload);
