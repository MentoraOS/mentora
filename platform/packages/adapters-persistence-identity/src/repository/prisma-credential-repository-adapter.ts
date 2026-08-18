import { credentialRefusal } from '@mentora/domain-identity';
import type {
  Credential,
  CredentialId,
  CredentialRefusal,
  CredentialRepository,
  PersonId,
} from '@mentora/domain-identity';
import type { Option, Result, RetentionContext } from '@mentora/kernel';
import { err, none, ok, some } from '@mentora/kernel';


import { classifyIdentityEngineError } from '../concurrency/identity-optimistic-concurrency-guard.js';
import { IdentityVersionConflictError } from '../errors/identity-persistence-errors.js';
import type { PrismaClient } from '../generated/prisma/client.js';
import type { CredentialRetentionEngine } from '../retention/credential-retention-engine.js';
import { toCredentialUnit } from '../snapshot/credential-snapshot-mapper.js';

/**
 * PrismaCredentialRepositoryAdapter — the FIRST real implementation of the
 * domain's frozen registry port (`<Provider><Capability>Adapter`, F2.5 §9).
 * The port is the law; this facade only delegates to the specialized
 * mechanics below (S-1: the engine is a mechanism).
 *
 * Channel discipline after the atomic act (classification OUTSIDE the
 * aborted transaction, post-rollback):
 * - R-A key → motivated Refusal `CredentialAlreadyExists` (the SETTLED
 *   dictionary name — `<Truth>AlreadyExists` family, F3.2-B precedent);
 * - snapshot-pkey collision → version conflict, rethrown (transient Failure
 *   — S-3; the pipeline re-enters at pas 4 and the act refuses R-B there);
 * - engine failure → rethrown (a Failure, R-10);
 * - corruption on load → IdentityPersistenceCorruptionException, raw (A-7).
 */
export class PrismaCredentialRepositoryAdapter implements CredentialRepository {
  constructor(
    private readonly prisma: PrismaClient,
    private readonly engine: CredentialRetentionEngine,
  ) {}

  async byId(id: CredentialId): Promise<Option<Credential>> {
    const row = await this.prisma.credentialSnapshot.findUnique({ where: { credentialId: id } });
    return row === null ? none : some(toCredentialUnit(row));
  }

  async activeByPersonAndKind(
    personId: PersonId,
    principalFactorKind: string,
  ): Promise<Option<Credential>> {
    const row = await this.prisma.credentialSnapshot.findFirst({
      where: { personId, principalFactorKind, stateKind: 'Active' },
    });
    return row === null ? none : some(toCredentialUnit(row));
  }

  async retain(
    unit: Credential,
    context?: RetentionContext,
  ): Promise<Result<void, CredentialRefusal>> {
    try {
      await this.prisma.$transaction(
        async (tx) => {
          await this.engine.retainWithin(tx, unit, context);
        },
        { isolationLevel: 'Serializable' },
      );
      return ok(undefined);
    } catch (error) {
      if (error instanceof IdentityVersionConflictError) {
        throw error;
      }
      switch (classifyIdentityEngineError(error)) {
        case 'ra-key':
          return err(
            credentialRefusal(
              'CredentialAlreadyExists',
              'The declared R-A key refuses: an ACTIVE Credential already exists for this person and principal factor',
            ),
          );
        case 'version-conflict':
          throw new IdentityVersionConflictError(unit.id, unit.version - unit.pendingFacts.length);
        case 'engine':
          throw error;
      }
    }
  }
}
