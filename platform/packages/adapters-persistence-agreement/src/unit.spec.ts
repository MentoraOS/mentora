import type { CommandId } from '@mentora/contracts';
import { validateAgreementEvent } from '@mentora/contracts-agreement';
import { agreementIdOf, clientIdOf, expertIdOf, timeSlotOf } from '@mentora/domain-agreement';
import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import {
  classifyEngineError,
  previousVersionOf,
} from './concurrency/agreement-optimistic-concurrency-guard.js';
import { toFactRow, toWireFact } from './fact-stream/agreement-fact-mapper.js';
import {
  agreementSnapshotChecksum,
  deserializeAgreementSnapshot,
  serializeAgreementSnapshot,
} from './serialization/agreement-snapshot-serializer.js';
import { toSnapshotRow, toUnit } from './snapshot/agreement-snapshot-mapper.js';
import { AgreementPersistenceMother, MOTHER_T0 } from './testing/agreement-persistence-mother.js';

const HOUR = 3_600_000;
const mother = new AgreementPersistenceMother();

const unwrap = <T, E>(result: { ok: boolean; value?: T; error?: E }): T => {
  if (!result.ok || result.value === undefined) {
    throw new Error(JSON.stringify(result.error));
  }
  return result.value;
};

describe('the private photograph (serializer + mapper)', () => {
  it('round-trips a unit byte-identically through its own doors (S-2)', () => {
    const unit = mother.confirmed().retained();
    const row = toSnapshotRow(unit);
    expect(row.stateKind).toBe('Confirmed');
    expect(row.version).toBe(3);
    const back = toUnit(row);
    expect(back.toSnapshot()).toEqual(unit.toSnapshot());
    // Determinism: same unit, same bytes, always.
    expect(toSnapshotRow(unit).payload).toBe(row.payload);
    expect(toSnapshotRow(unit).checksum).toBe(row.checksum);
  });

  it('a corrupted checksum is an EXCEPTION, never a lying unit (PERSIST.CORRUPTION)', () => {
    const row = toSnapshotRow(mother.requested().retained());
    expect(() => toUnit({ ...row, checksum: 'deadbeef' })).toThrow(/corrupted/);
  });

  it('a malformed or foreign-format payload is an EXCEPTION', () => {
    const row = toSnapshotRow(mother.requested().retained());
    const malformed = { ...row, payload: '{broken', checksum: agreementSnapshotChecksum('{broken') };
    expect(() => toUnit(malformed)).toThrow(/corrupted/);
    const foreign = JSON.stringify({ version: 99, payload: {} });
    expect(() =>
      toUnit({ ...row, payload: foreign, checksum: agreementSnapshotChecksum(foreign) }),
    ).toThrow(/unknown photograph format/);
  });

  it('the serializer wraps in VersionedPayload v1 and reads it back', () => {
    const snapshot = mother.requested().toSnapshot();
    const serialized = serializeAgreementSnapshot(snapshot);
    const parsed = deserializeAgreementSnapshot(serialized.payload);
    expect(parsed.ok && parsed.value).toEqual(snapshot);
  });
});

describe('the fact-mapper — every wire fact conforms to the PUBLISHED language (V-1)', () => {
  it('maps all EIGHT frozen facts to validator-clean wire contracts', () => {
    const confirmed = mother.confirmed();
    const rescheduled = unwrap(
      confirmed.retained().reschedule(
        {
          type: 'RescheduleAgreement',
          commandId: 'cmd-res' as CommandId,
          instant: instantOf(MOTHER_T0.epochMillis + 3 * HOUR),
          agreementId: agreementIdOf('agr-1'),
          requestedBy: { role: 'Expert', expertId: expertIdOf('exp-1') },
          newSlot: unwrap(
            timeSlotOf(
              instantOf(MOTHER_T0.epochMillis + 30 * HOUR),
              instantOf(MOTHER_T0.epochMillis + 31 * HOUR),
            ),
          ),
        },
        mother.reschedulePolicy,
      ),
    );
    const cancelled = unwrap(
      rescheduled.retained().cancel(
        {
          type: 'CancelAgreement',
          commandId: 'cmd-can' as CommandId,
          instant: instantOf(MOTHER_T0.epochMillis + 4 * HOUR),
          agreementId: agreementIdOf('agr-1'),
          cancelledBy: { role: 'Client', clientId: clientIdOf('cli-1') },
          motive: 'schedule conflict',
        },
        mother.cancellationPolicy,
      ),
    );
    const rejected = unwrap(
      mother.requested({ id: 'agr-r' }).retained().reject({
        type: 'RejectAgreement',
        commandId: 'cmd-rej' as CommandId,
        instant: instantOf(MOTHER_T0.epochMillis + HOUR),
        agreementId: agreementIdOf('agr-r'),
        expertId: expertIdOf('exp-1'),
      }),
    );
    const lapsed = unwrap(
      mother.requested({ id: 'agr-l' }).retained().lapseRequest({
        type: 'LapseAgreementRequest',
        commandId: 'cmd-lap' as CommandId,
        instant: instantOf(MOTHER_T0.epochMillis + HOUR),
        agreementId: agreementIdOf('agr-l'),
      }),
    );
    const elapsed = unwrap(
      mother.confirmed({ id: 'agr-e', slotStartMs: MOTHER_T0.epochMillis + 60 * HOUR }).retained().elapse({
        type: 'ElapseAgreement',
        commandId: 'cmd-ela' as CommandId,
        instant: instantOf(MOTHER_T0.epochMillis + 62 * HOUR),
        agreementId: agreementIdOf('agr-e'),
      }),
    );

    const facts = [
      ...confirmed.pendingFacts, // Requested, Accepted, Confirmed
      ...rescheduled.pendingFacts, // Rescheduled
      ...cancelled.pendingFacts, // Cancelled
      ...rejected.pendingFacts, // Rejected
      ...lapsed.pendingFacts, // RequestLapsed
      ...elapsed.pendingFacts, // Elapsed
    ];
    expect(new Set(facts.map((fact) => fact.type)).size).toBe(8);
    for (const fact of facts) {
      const wire = toWireFact(fact);
      const validated = validateAgreementEvent(wire);
      expect(validated.ok, `${fact.type} must satisfy its published validator`).toBe(true);
      const row = toFactRow(fact);
      expect(row.sequence).toBe(fact.sequence);
      expect(row.checksum).toHaveLength(8);
    }
  });
});

describe('the concurrency guard — a comparison, never a lock', () => {
  it('computes the expected previous version (version − newborn facts)', () => {
    expect(previousVersionOf(mother.requested())).toBe(0);
    expect(previousVersionOf(mother.confirmed())).toBe(0); // 3 facts, version 3, unretained chain
    expect(previousVersionOf(mother.confirmed().retained())).toBe(3);
  });

  it('classifies engine collisions into their lawful channels', () => {
    expect(classifyEngineError(new Error('violates exclusion constraint "agreement_confirmed_slot_ra_key"'))).toBe('ra-key');
    expect(classifyEngineError(new Error('ERROR: conflicting key value (23P01)'))).toBe('ra-key');
    expect(classifyEngineError(new Error('duplicate key "AgreementSnapshot_pkey"'))).toBe(
      'duplicate-identity',
    );
    expect(classifyEngineError(new Error('connection refused'))).toBe('engine');
    expect(classifyEngineError('raw-string')).toBe('engine');
  });
});

describe('remaining doors', () => {
  it('a payload that parses but is not a VersionedPayload is corruption', () => {
    const parsed = deserializeAgreementSnapshot('"just-a-string"');
    expect(!parsed.ok && parsed.error).toContain('versioned payload');
  });

  it('a photograph that refuses to canonicalize is a defect, thrown', () => {
    expect(() =>
      serializeAgreementSnapshot({ bad: BigInt(1) } as never),
    ).toThrow(/refused to canonicalize/);
  });

  it('an engine failure in retain is RETHROWN — the Failure channel (R-10)', async () => {
    const { PrismaAgreementRepositoryAdapter } = await import(
      './repository/prisma-agreement-repository-adapter.js'
    );
    const broken = {
      $transaction: () => Promise.reject(new Error('connection refused')),
    } as never;
    const repository = new PrismaAgreementRepositoryAdapter(broken, undefined as never);
    await expect(repository.retain(mother.requested())).rejects.toThrow(/connection refused/);
  });
});
