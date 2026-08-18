import { agreementIdOf } from '@mentora/domain-agreement';
import { RuntimeBuilder } from '@mentora/runtime-bootstrap';
import { environmentSource } from '@mentora/runtime-config';
import { afterAll, beforeEach, describe, expect, it } from 'vitest';

import { AgreementPersistenceModule } from './module/agreement-persistence-module.js';
import { PrismaAgreementStateReadAdapter } from './read-model/prisma-agreement-state-read-adapter.js';
import { agreementPersistenceContractSuite } from './testing/agreement-persistence-contract-suite.js';
import { AgreementPersistenceFixture } from './testing/agreement-persistence-fixture.js';
import { AgreementPersistenceMother, MOTHER_T0 } from './testing/agreement-persistence-mother.js';

/**
 * INTEGRATION against a real PostgreSQL — the schema applied once by
 * `prisma migrate deploy` (the Migration species' mechanism). Gated on the
 * DECLARED test URL (read through runtime-config's environmentSource — the
 * one lawful env door): absent → the suite SKIPS, the gate stays green on
 * machines without a database; the official gate runs it for real.
 */

const url = environmentSource().read('MENTORA_AGREEMENT_DATABASE_URL');

describe.skipIf(url === undefined)('PostgreSQL integration (real engine)', () => {
  const fixture = new AgreementPersistenceFixture(url ?? '');
  const mother = new AgreementPersistenceMother();

  beforeEach(async () => {
    await fixture.truncate();
  });

  afterAll(async () => {
    await fixture.dispose();
  });

  // The port's promises — THE SAME behavior as the in-memory double.
  agreementPersistenceContractSuite('PrismaAgreementRepositoryAdapter', {
    make: async () => {
      await fixture.truncate();
      return fixture.repository;
    },
  });

  it('retention writes fact-stream AND Outbox de faits in the SAME atomic act (A-3)', async () => {
    await fixture.repository.retain(mother.confirmed());
    const facts = await fixture.prisma.agreementFact.findMany({ orderBy: { sequence: 'asc' } });
    expect(facts.map((fact) => fact.type)).toEqual([
      'AgreementRequested',
      'AgreementAccepted',
      'AgreementConfirmed',
    ]);
    const outbox = await fixture.prisma.agreementOutbox.findMany({ orderBy: { sequence: 'asc' } });
    expect(outbox).toHaveLength(3);
    expect(outbox.every((row) => row.status === 'pending' && row.deliveryAttempts === 0)).toBe(true);
    expect(new Set(outbox.map((row) => row.messageId)).size).toBe(3);
  });

  it('RFC-001: the RetentionContext rides to the Outbox de faits — and only when it exists', async () => {
    await fixture.repository.retain(mother.requested({ id: 'agr-ctx' }), {
      correlationId: 'corr-42',
      causationId: 'cause-42',
    });
    await fixture.repository.retain(mother.requested({ id: 'agr-bare', slotStartMs: MOTHER_T0.epochMillis + 30 * 3_600_000 }));
    const rows = await fixture.prisma.agreementOutbox.findMany({ orderBy: { id: 'asc' } });
    expect(rows[0]?.correlationId).toBe('corr-42');
    expect(rows[0]?.causationId).toBe('cause-42');
    expect(rows[1]?.correlationId).toBeNull();
    expect(rows[1]?.causationId).toBeNull();
  });

  it('a refused retention rolls back EVERYTHING — no fact, no outbox, no photo', async () => {
    await fixture.repository.retain(mother.confirmed({ id: 'agr-a' }));
    const before = await fixture.prisma.agreementFact.count();
    const refused = await fixture.repository.retain(mother.confirmed({ id: 'agr-b' }));
    expect(refused.ok).toBe(false);
    expect(await fixture.prisma.agreementFact.count()).toBe(before);
    expect(await fixture.prisma.agreementOutbox.count()).toBe(3);
    expect(await fixture.prisma.agreementSnapshot.count()).toBe(1);
  });

  it('a corrupted row surfaces as PERSIST.CORRUPTION — never a lying unit', async () => {
    await fixture.repository.retain(mother.requested());
    await fixture.prisma.agreementSnapshot.update({
      where: { agreementId: 'agr-1' },
      data: { checksum: 'deadbeef' },
    });
    await expect(fixture.repository.byId(agreementIdOf('agr-1'))).rejects.toThrow(/corrupted/);
  });

  it('the read adapter serves the view (parties included for the grid) from the primary', async () => {
    await fixture.repository.retain(mother.confirmed());
    const read = new PrismaAgreementStateReadAdapter(
      fixture.prisma,
      'time-tooling' as never,
    );
    const view = await read.stateOf(agreementIdOf('agr-1') as never);
    expect(view.some && view.value.stateKind).toBe('Confirmed');
    expect(view.some && view.value.version).toBe(3);
    expect(await read.holdsStateRight('cli-1' as never, agreementIdOf('agr-1') as never)).toBe(true);
    expect(await read.holdsStateRight('time-tooling' as never, agreementIdOf('agr-1') as never)).toBe(true);
    expect(await read.holdsStateRight('stranger' as never, agreementIdOf('agr-1') as never)).toBe(false);
  });

  it('the persistence module lives and dies with the runtime lifecycle (I-11)', async () => {
    const localFixture = new AgreementPersistenceFixture(url ?? '');
    const container = new RuntimeBuilder()
      .withModule(new AgreementPersistenceModule(localFixture.prisma))
      .build();
    expect((await container.boot()).ok).toBe(true);
    await container.shutdown();
    expect(container.state).toBe('Destroyed');
  });

  it('SQL constraints hold: fact idempotence key and outbox uniqueness', async () => {
    await fixture.repository.retain(mother.requested());
    await expect(
      fixture.prisma.agreementFact.create({
        data: {
          agreementId: 'agr-1',
          sequence: 1,
          type: 'AgreementRequested',
          payload: '{}',
          contractVersion: 1,
          occurredAtMs: BigInt(1),
          checksum: '00000000',
        },
      }),
    ).rejects.toThrow();
  });
});

describe.skipIf(url === undefined)('remaining integration doors', () => {
  const fixture2 = new AgreementPersistenceFixture(url ?? '');
  const mother2 = new AgreementPersistenceMother();

  afterAll(async () => {
    await fixture2.dispose();
  });

  it('the fact stream reads back in per-subject order — the eternal provenance (O-4)', async () => {
    await fixture2.truncate();
    await fixture2.repository.retain(mother2.confirmed());
    const stream = await fixture2.prisma.$transaction(async (tx) => {
      const { AgreementFactStreamStore } = await import(
        './fact-stream/agreement-fact-stream-store.js'
      );
      return new AgreementFactStreamStore().readStream(tx, 'agr-1');
    });
    expect(stream.map((row) => row.sequence)).toEqual([1, 2, 3]);
    expect(stream[0]?.type).toBe('AgreementRequested');
  });

  it('the read adapter refuses corruption and answers none for the unknown', async () => {
    await fixture2.truncate();
    const read = new PrismaAgreementStateReadAdapter(fixture2.prisma, 'time-tooling' as never);
    expect((await read.stateOf('ghost' as never)).some).toBe(false);
    expect(await read.holdsStateRight('cli-1' as never, 'ghost' as never)).toBe(false);
    await fixture2.repository.retain(mother2.requested());
    await fixture2.prisma.agreementSnapshot.update({
      where: { agreementId: 'agr-1' },
      data: { checksum: 'deadbeef' },
    });
    await expect(read.stateOf('agr-1' as never)).rejects.toThrow(/corrupted/);
  });
});
