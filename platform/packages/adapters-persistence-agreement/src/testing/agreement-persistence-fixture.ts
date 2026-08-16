import { PrismaClient } from '@prisma/client';


import { AgreementFactStreamStore } from '../fact-stream/agreement-fact-stream-store.js';
import { AgreementOutboxStore } from '../outbox/agreement-outbox-store.js';
import { PrismaAgreementRepositoryAdapter } from '../repository/prisma-agreement-repository-adapter.js';
import { AgreementRetentionEngine } from '../retention/agreement-retention-engine.js';

import { UuidFactory } from './uuid-source.js';

/**
 * AgreementPersistenceFixture — the integration harness: one PrismaClient
 * bound to the DECLARED test database URL, truncation between tests (the
 * schema is applied once by `prisma migrate deploy` — the Migration species'
 * mechanism, never the boot). Real data never enter here (S-9: spec data
 * only).
 */
export class AgreementPersistenceFixture {
  readonly prisma: PrismaClient;
  readonly repository: PrismaAgreementRepositoryAdapter;

  constructor(databaseUrl: string) {
    this.prisma = new PrismaClient({ datasources: { db: { url: databaseUrl } } });
    this.repository = new PrismaAgreementRepositoryAdapter(
      this.prisma,
      new AgreementRetentionEngine(
        new AgreementFactStreamStore(),
        new AgreementOutboxStore(new UuidFactory()),
      ),
    );
  }

  async truncate(): Promise<void> {
    await this.prisma.$executeRawUnsafe(
      'TRUNCATE "AgreementSnapshot", "AgreementFact", "AgreementOutbox", "AgreementInbox"',
    );
  }

  async dispose(): Promise<void> {
    await this.prisma.$disconnect();
  }
}
