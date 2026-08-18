import { CredentialFactStreamStore } from '../fact-stream/credential-fact-stream-store.js';
import { PrismaClient } from '../generated/prisma/client.js';
import { CredentialOutboxStore } from '../outbox/credential-outbox-store.js';
import { PrismaCredentialRepositoryAdapter } from '../repository/prisma-credential-repository-adapter.js';
import { PrismaSessionRepositoryAdapter } from '../repository/prisma-session-repository-adapter.js';
import { CredentialRetentionEngine } from '../retention/credential-retention-engine.js';
import { SessionRetentionEngine } from '../retention/session-retention-engine.js';

import { UuidFactory } from './uuid-source.js';

/**
 * IdentityPersistenceFixture — the integration harness: one PrismaClient
 * bound to the DECLARED test database URL, truncation between tests (the
 * schema is applied once by `prisma migrate deploy` — the Migration
 * species' mechanism, never the boot). Real data never enter here (S-9:
 * spec data only).
 */
export class IdentityPersistenceFixture {
  readonly prisma: PrismaClient;
  readonly credentials: PrismaCredentialRepositoryAdapter;
  readonly sessions: PrismaSessionRepositoryAdapter;

  constructor(databaseUrl: string) {
    this.prisma = new PrismaClient({ datasources: { db: { url: databaseUrl } } });
    this.credentials = new PrismaCredentialRepositoryAdapter(
      this.prisma,
      new CredentialRetentionEngine(
        new CredentialFactStreamStore(),
        new CredentialOutboxStore(new UuidFactory()),
      ),
    );
    this.sessions = new PrismaSessionRepositoryAdapter(this.prisma, new SessionRetentionEngine());
  }

  async truncate(): Promise<void> {
    await this.prisma.$executeRawUnsafe(
      'TRUNCATE "CredentialSnapshot", "CredentialFact", "CredentialOutbox", "CredentialInbox", "SessionSnapshot"',
    );
  }

  async dispose(): Promise<void> {
    await this.prisma.$disconnect();
  }
}
