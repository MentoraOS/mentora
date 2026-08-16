import type { Agreement } from '@mentora/domain-agreement';
import { Prisma } from '@prisma/client';

/**
 * AgreementOptimisticConcurrencyGuard — NOT a lock: a comparison (F5.2 §4;
 * F5.1 §19: no invariant ever rests on a lease). It computes the expected
 * previous version and CLASSIFIES engine collisions into their lawful
 * channels: R-A key violation → structural Refusal; identity collision →
 * structural Refusal (R-B); everything else → engine Failure (R-10).
 */

export const RA_CONSTRAINT_NAME = 'agreement_confirmed_slot_ra_key';

/** The stored version this retention expects (version − newborn facts). */
export const previousVersionOf = (unit: Agreement): number =>
  unit.version - unit.pendingFacts.length;

export type EngineCollision = 'ra-key' | 'duplicate-identity' | 'engine';

export const classifyEngineError = (error: unknown): EngineCollision => {
  const text =
    error instanceof Error ? `${error.message} ${JSON.stringify((error as { meta?: unknown }).meta ?? '')}` : String(error);
  if (text.includes(RA_CONSTRAINT_NAME) || text.includes('23P01')) {
    return 'ra-key';
  }
  if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
    return 'duplicate-identity';
  }
  if (text.includes('AgreementSnapshot_pkey')) {
    return 'duplicate-identity';
  }
  return 'engine';
};
