import type { Credential, Session } from '@mentora/domain-identity';

/**
 * IdentityOptimisticConcurrencyGuard — NOT a lock: a comparison (F5.2 §4;
 * F5.1 §19: no invariant ever rests on a lease). It computes the expected
 * previous version and CLASSIFIES engine collisions into their lawful
 * channels.
 *
 * Classification decision (recorded): a duplicate write against a SNAPSHOT
 * primary key is a VERSION CONFLICT (two writes, one generation — thrown,
 * retryable; the pipeline re-loads and the act then refuses lawfully R-B).
 * The R-A partial unique index is the DECLARED KEY: its violation is the
 * motivated Refusal `CredentialAlreadyExists` (the settled dictionary name).
 * Everything else is an engine Failure (R-10).
 */

export const RA_CONSTRAINT_NAME = 'credential_active_principal_ra_key';

/** The stored version this retention expects (version − newborn facts). */
export const previousCredentialVersionOf = (unit: Credential): number =>
  unit.version - unit.pendingFacts.length;

/** A session act always advances by exactly one — state only, no facts. */
export const previousSessionVersionOf = (unit: Session): number => unit.version - 1;

export type IdentityEngineCollision = 'ra-key' | 'version-conflict' | 'engine';

const isUniqueViolation = (error: unknown, text: string): boolean =>
  text.includes('23505') ||
  text.includes('P2002') ||
  (error instanceof Error && (error as { code?: string }).code === 'P2002');

export const classifyIdentityEngineError = (error: unknown): IdentityEngineCollision => {
  const text =
    error instanceof Error
      ? `${error.message} ${JSON.stringify((error as { meta?: unknown }).meta ?? '')} ${String((error as { code?: string }).code ?? '')}`
      : String(error);
  // Prisma voices a unique violation by FIELDS, the raw engine by index
  // name — both spellings of the same declared key are recognized.
  if (
    text.includes(RA_CONSTRAINT_NAME) ||
    (isUniqueViolation(error, text) &&
      text.includes('personId') &&
      text.includes('principalFactorKind'))
  ) {
    return 'ra-key';
  }
  if (
    isUniqueViolation(error, text) &&
    (text.includes('CredentialSnapshot_pkey') ||
      text.includes('SessionSnapshot_pkey') ||
      text.includes('credentialId') ||
      text.includes('sessionId'))
  ) {
    return 'version-conflict';
  }
  return 'engine';
};
