import type { SessionRepository } from '@mentora/domain-identity';
import { credentialIdOf, personIdOf, sessionIdOf } from '@mentora/domain-identity';
import { credentialRepositoryContractSuite } from '@mentora/domain-identity/contract-suite';
import { sessionRepositoryContractSuite } from '@mentora/domain-identity/session-contract-suite';
import { RuntimeBuilder } from '@mentora/runtime-bootstrap';
import { environmentSource } from '@mentora/runtime-config';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import { IdentityPersistenceModule } from './module/identity-persistence-module.js';
import { PrismaProofMaterialVault } from './proof/prisma-proof-material-vault.js';
import { ScryptPasswordHasher } from './proof/scrypt-password-hasher.js';
import { IdentityPersistenceFixture } from './testing/identity-persistence-fixture.js';
import { IdentityPersistenceMother } from './testing/identity-persistence-mother.js';

/**
 * INTEGRATION against a real PostgreSQL — the schema applied once by
 * `prisma migrate deploy` (the Migration species' mechanism). Gated on the
 * DECLARED test URL (read through runtime-config's environmentSource — the
 * one lawful env door): absent → the suite SKIPS, the gate stays green on
 * machines without a database; the official gate runs it for real.
 *
 * THE ACCEPTANCE CRITERION of Stories #64/#68/#75: the two domain contract
 * suites — written ONCE (I-10) — replayed here against the real engine.
 */

const url = environmentSource().read('MENTORA_IDENTITY_DATABASE_URL');

describe.skipIf(url === undefined)('PostgreSQL integration (real engine)', () => {
  const fixture = new IdentityPersistenceFixture(url ?? '');
  const mother = new IdentityPersistenceMother();

  beforeEach(async () => {
    await fixture.truncate();
  });

  afterAll(async () => {
    await fixture.dispose();
  });

  // The ports' promises — THE SAME behavior as the in-memory references.
  credentialRepositoryContractSuite('PrismaCredentialRepositoryAdapter', {
    make: async () => {
      await fixture.truncate();
      return { repository: fixture.credentials };
    },
  });

  sessionRepositoryContractSuite('PrismaSessionRepositoryAdapter', {
    make: async () => {
      await fixture.truncate();
      return { repository: fixture.sessions };
    },
  });

  it('retention writes fact-stream AND Outbox de faits in the SAME atomic act (A-3)', async () => {
    await fixture.credentials.retain(mother.revoked());
    const facts = await fixture.prisma.credentialFact.findMany({ orderBy: { sequence: 'asc' } });
    expect(facts.map((fact) => fact.type)).toEqual(['CredentialEstablished', 'CredentialRevoked']);
    const outbox = await fixture.prisma.credentialOutbox.findMany({ orderBy: { sequence: 'asc' } });
    expect(outbox).toHaveLength(2);
    expect(outbox.every((row) => row.status === 'pending' && row.deliveryAttempts === 0)).toBe(true);
    expect(new Set(outbox.map((row) => row.messageId)).size).toBe(2);
  });

  it('RFC-001: the RetentionContext rides to the outbox — and only when it exists', async () => {
    await fixture.credentials.retain(mother.established('cred-ctx', 'person-ctx'), {
      correlationId: 'corr-42',
      causationId: 'cause-42',
    });
    await fixture.credentials.retain(mother.established('cred-bare', 'person-bare'));
    const rows = await fixture.prisma.credentialOutbox.findMany({ orderBy: { id: 'asc' } });
    expect(rows[0]?.correlationId).toBe('corr-42');
    expect(rows[0]?.causationId).toBe('cause-42');
    expect(rows[1]?.correlationId).toBeNull();
    expect(rows[1]?.causationId).toBeNull();
  });

  it('a refused retention (R-A key) rolls back EVERYTHING — no fact, no outbox, no photo', async () => {
    await fixture.credentials.retain(mother.established('cred-a', 'person-1'));
    const factsBefore = await fixture.prisma.credentialFact.count();
    const refused = await fixture.credentials.retain(mother.established('cred-b', 'person-1'));
    expect(refused.ok).toBe(false);
    if (!refused.ok) {
      expect(refused.error.reason).toBe('CredentialAlreadyExists');
    }
    expect(await fixture.prisma.credentialFact.count()).toBe(factsBefore);
    expect(await fixture.prisma.credentialOutbox.count()).toBe(1);
    expect(await fixture.prisma.credentialSnapshot.count()).toBe(1);
  });

  it('the R-A key is a DECLARED index of the engine — present under its settled name', async () => {
    const indexes = await fixture.prisma.$queryRawUnsafe<Array<{ indexname: string }>>(
      "SELECT indexname FROM pg_indexes WHERE tablename = 'CredentialSnapshot'",
    );
    expect(indexes.map((row) => row.indexname)).toContain('credential_active_principal_ra_key');
  });

  it('a corrupted row surfaces as PERSIST.CORRUPTION — never a lying unit', async () => {
    await fixture.credentials.retain(mother.established('cred-1'));
    await fixture.prisma.credentialSnapshot.update({
      where: { credentialId: 'cred-1' },
      data: { checksum: 'deadbeef' },
    });
    await expect(fixture.credentials.byId(credentialIdOf('cred-1'))).rejects.toThrow(/corrupted/);
  });

  it('NO SECRET MATERIAL ever reaches the engine: the stored photograph carries natures, never matter', async () => {
    await fixture.credentials.retain(mother.established('cred-1'));
    const row = await fixture.prisma.credentialSnapshot.findUnique({
      where: { credentialId: 'cred-1' },
    });
    // The whole stored text: identifiers, kinds, strengths, instants — the
    // snapshot SHAPE has no field for matter, so no matter can be here.
    expect(row?.payload).not.toMatch(/secret|password-value|hash|material/);
    expect(row?.payload).toContain('"kind":"password"');
  });

  it('the Session registry is STATE ONLY — the very tables for its facts DO NOT EXIST', async () => {
    const tables = await fixture.prisma.$queryRawUnsafe<Array<{ table_name: string }>>(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE 'Session%'",
    );
    // Structural no-publication (canon ch.04): one photograph, nothing else.
    expect(tables.map((row) => row.table_name)).toEqual(['SessionSnapshot']);
  });

  it('a session retention touches NOTHING outside its photograph', async () => {
    await fixture.credentials.retain(mother.established('cred-1'));
    const outboxBefore = await fixture.prisma.credentialOutbox.count();
    // Through the PORT type: the optional RetentionContext (RFC-001) is
    // accepted by the contract — and has nothing to ride to here.
    const port: SessionRepository = fixture.sessions;
    await port.retain(mother.opened('sess-1', 'cred-1'), { correlationId: 'corr-x' });
    expect(await fixture.prisma.credentialOutbox.count()).toBe(outboxBefore);
    expect(await fixture.prisma.sessionSnapshot.count()).toBe(1);
  });

  it('the cascade probe reads from the materialized index: actives only, per credential', async () => {
    await fixture.sessions.retain(mother.opened('sess-1', 'cred-1'));
    await fixture.sessions.retain(mother.opened('sess-2', 'cred-1'));
    const ended = mother.ended('sess-1', 'cred-1');
    await fixture.sessions.retain(ended);
    const actives = await fixture.sessions.activeByCredential(credentialIdOf('cred-1'));
    expect(actives.map((session) => session.id)).toEqual([sessionIdOf('sess-2')]);
  });

  it('the R-A probe reads the ACTIVE credential through the real engine', async () => {
    await fixture.credentials.retain(mother.established('cred-1', 'person-1', 'password'));
    const probe = await fixture.credentials.activeByPersonAndKind(personIdOf('person-1'), 'password');
    expect(probe.some && probe.value.id).toBe(credentialIdOf('cred-1'));
    const miss = await fixture.credentials.activeByPersonAndKind(personIdOf('person-1'), 'federated');
    expect(miss.some).toBe(false);
  });

  it('SQL constraints hold: fact idempotence key refuses a duplicate EventIdentity', async () => {
    await fixture.credentials.retain(mother.established('cred-1'));
    await expect(
      fixture.prisma.credentialFact.create({
        data: {
          credentialId: 'cred-1',
          sequence: 1,
          type: 'CredentialEstablished',
          payload: '{}',
          contractVersion: 1,
          occurredAtMs: BigInt(1),
          checksum: '00000000',
        },
      }),
    ).rejects.toThrow();
  });

  it('the gate read adapters serve VERIFIED views from the primary — and refuse corruption', async () => {
    const { PrismaSessionStateReadAdapter, PrismaCredentialStateReadAdapter } = await import(
      './read-model/prisma-identity-state-read-adapter.js'
    );
    await fixture.credentials.retain(mother.established('cred-1', 'person-1'));
    await fixture.sessions.retain(mother.opened('sess-1', 'cred-1'));
    const sessionRead = new PrismaSessionStateReadAdapter(fixture.prisma);
    const credentialRead = new PrismaCredentialStateReadAdapter(fixture.prisma);

    const session = await sessionRead.stateOf(sessionIdOf('sess-1'));
    expect(session.some && session.value.stateKind).toBe('Active');
    expect(session.some && session.value.credentialId).toBe(credentialIdOf('cred-1'));
    const credential = await credentialRead.stateOf(credentialIdOf('cred-1'));
    expect(credential.some && credential.value.personId).toBe(personIdOf('person-1'));
    expect((await sessionRead.stateOf(sessionIdOf('sess-ghost'))).some).toBe(false);

    await fixture.prisma.sessionSnapshot.update({
      where: { sessionId: 'sess-1' },
      data: { checksum: 'deadbeef' },
    });
    await expect(sessionRead.stateOf(sessionIdOf('sess-1'))).rejects.toThrow(/corrupted/);
  });

  it('the persistence module lives and dies with the runtime lifecycle (I-11)', async () => {
    const localFixture = new IdentityPersistenceFixture(url ?? '');
    const container = new RuntimeBuilder()
      .withModule(new IdentityPersistenceModule(localFixture.prisma))
      .build();
    expect((await container.boot()).ok).toBe(true);
    await container.shutdown();
    expect(container.state).toBe('Destroyed');
  });
});

describe.skipIf(url === undefined)('the dev vault (Story #96) — one place, one-way, disownable', () => {
  const fixture = new IdentityPersistenceFixture(url ?? '');
  const vault = new PrismaProofMaterialVault(fixture.prisma, new ScryptPasswordHasher());
  afterAll(async () => {
    await fixture.dispose();
  });

  it('stores sealed, verifies by demonstration, re-seals on re-store, disowns on recovery', async () => {
    await vault.store('factor-v1', 'password', 'first material');
    expect(await vault.verify('factor-v1', 'first material')).toBe(true);
    expect(await vault.verify('factor-v1', 'wrong material')).toBe(false);
    expect(await vault.verify('factor-ghost', 'first material')).toBe(false);
    await vault.store('factor-v1', 'password', 'second material');
    expect(await vault.verify('factor-v1', 'first material')).toBe(false);
    expect(await vault.verify('factor-v1', 'second material')).toBe(true);
    await vault.disown(['factor-v1']);
    expect(await vault.verify('factor-v1', 'second material')).toBe(false);
  });
});
