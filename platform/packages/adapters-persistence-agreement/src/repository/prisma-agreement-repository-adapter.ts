import { agreementRefusal } from '@mentora/domain-agreement';
import type { Agreement, AgreementRefusal, AgreementRepository } from '@mentora/domain-agreement';
import type { AgreementId, ExpertId, TimeSlot } from '@mentora/domain-agreement';
import type { Option, Result, RetentionContext } from '@mentora/kernel';
import { err, none, ok, some } from '@mentora/kernel';
import type { PrismaClient } from '@prisma/client';

import { classifyEngineError } from '../concurrency/agreement-optimistic-concurrency-guard.js';
import { AgreementVersionConflictError } from '../errors/agreement-persistence-errors.js';
import type { AgreementRetentionEngine } from '../retention/agreement-retention-engine.js';
import { toUnit } from '../snapshot/agreement-snapshot-mapper.js';

/**
 * PrismaAgreementRepositoryAdapter — the FIRST real implementation of the
 * domain's frozen registry port (`<Provider><Capability>Adapter`, F2.5 §9 —
 * the mandate's "AgreementRepositoryPrismaAdapter" spelling is reconciled to
 * the frozen pattern, as the Blueprint already did). The port is the law;
 * this facade only delegates to the specialized mechanics below (S-1: the
 * engine is a mechanism).
 *
 * Channel discipline after the atomic act (classification OUTSIDE the
 * aborted transaction, post-rollback):
 * - R-A exclusion → motivated Refusal `TimeSlotUnavailable` (a VALUE, R-A);
 * - identity collision → motivated Refusal `TransitionUnavailable` (R-B);
 * - version conflict → rethrown (transient Failure — S-3; the pipeline's
 *   retention stage yields the retryable channel and re-enters at pas 4);
 * - engine failure → rethrown (a Failure, R-10);
 * - corruption on load → AgreementPersistenceCorruptionException, raw (A-7).
 */
export class PrismaAgreementRepositoryAdapter implements AgreementRepository {
  constructor(
    private readonly prisma: PrismaClient,
    private readonly engine: AgreementRetentionEngine,
  ) {}

  async byId(id: AgreementId): Promise<Option<Agreement>> {
    const row = await this.prisma.agreementSnapshot.findUnique({ where: { agreementId: id } });
    return row === null ? none : some(toUnit(row));
  }

  async byExpertAndWindow(expertId: ExpertId, window: TimeSlot): Promise<readonly Agreement[]> {
    const rows = await this.prisma.agreementSnapshot.findMany({
      where: {
        expertId,
        stateKind: 'Confirmed',
        slotStartMs: { lt: BigInt(window.end.epochMillis) },
        slotEndMs: { gt: BigInt(window.start.epochMillis) },
      },
      orderBy: { slotStartMs: 'asc' },
    });
    return rows.map(toUnit);
  }

  async retain(unit: Agreement, context?: RetentionContext): Promise<Result<void, AgreementRefusal>> {
    try {
      await this.prisma.$transaction(
        async (tx) => {
          await this.engine.retainWithin(tx, unit, context);
        },
        { isolationLevel: 'Serializable' },
      );
      return ok(undefined);
    } catch (error) {
      if (error instanceof AgreementVersionConflictError) {
        throw error;
      }
      switch (classifyEngineError(error)) {
        case 'ra-key':
          return err(
            agreementRefusal(
              'TimeSlotUnavailable',
              'The declared R-A key refuses: this expert already holds a confirmed agreement on an overlapping slot',
            ),
          );
        case 'duplicate-identity':
          return err(
            agreementRefusal(
              'TransitionUnavailable',
              'An Agreement already lives under this Identifier — a new unit requires a new identity (R-B)',
            ),
          );
        case 'engine':
          throw error;
      }
    }
  }
}
