import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { Agreement } from './aggregate/agreement.js';
import { AgreementSnapshotCorruptException } from './errors/agreement-exceptions.js';
import { AgreementCancellationPolicy } from './policies/agreement-cancellation.policy.js';
import {
  HOUR,
  T0,
  cancelCommand,
  confirmedAgreement,
  rejectCommand,
  requestedAgreement,
} from './testing/agreement-mother.js';

/**
 * The Snapshot is the registry's PRIVATE reconstitution photograph (F3.1.11) —
 * never a contract, never served. Roundtrip must be lossless for every state,
 * and reconstitution never re-constates the past (no facts reborn).
 */

const at = (h: number) => instantOf(T0.epochMillis + h * HOUR);
const cancellation = new AgreementCancellationPolicy({ minimumNoticeMillis: 0 });

const roundtrip = (agreement: Agreement): Agreement =>
  Agreement.fromSnapshot(agreement.retained().toSnapshot());

describe('AgreementSnapshot (private reconstitution — F3.1.11, F5.2.99)', () => {
  it('roundtrips a Requested agreement losslessly', () => {
    const original = requestedAgreement().retained();
    const restored = roundtrip(original);
    expect(restored.id).toBe(original.id);
    expect(restored.state).toEqual(original.state);
    expect(restored.slot).toEqual(original.slot);
    expect(restored.version).toBe(original.version);
  });

  it('roundtrips Confirmed (keeps the settlement reference)', () => {
    const restored = roundtrip(confirmedAgreement());
    expect(restored.state.kind).toBe('Confirmed');
    if (restored.state.kind === 'Confirmed') {
      expect(restored.state.settlementReference).toBe('stl-0001');
    }
  });

  it('roundtrips Cancelled (keeps the Auteur and motive — F2.6)', () => {
    const cancelled = confirmedAgreement().cancel(cancelCommand(at(3)), cancellation);
    if (!cancelled.ok) throw new Error('fixture');
    const restored = roundtrip(cancelled.value);
    expect(restored.state.kind).toBe('Cancelled');
    if (restored.state.kind === 'Cancelled') {
      expect(restored.state.record.cancelledBy.role).toBe('Client');
      expect(restored.state.record.motive).toBe('change of plans');
    }
  });

  it('roundtrips a terminal Rejected agreement', () => {
    const rejected = requestedAgreement().reject(rejectCommand(at(1)));
    if (!rejected.ok) throw new Error('fixture');
    expect(roundtrip(rejected.value).state.kind).toBe('Rejected');
  });

  it('reconstitution never re-constates the past: no pending facts after fromSnapshot', () => {
    expect(roundtrip(confirmedAgreement()).pendingFacts).toHaveLength(0);
  });

  it('a corrupt snapshot is a malformed call — Exception, fail closed', () => {
    const snapshot = requestedAgreement().retained().toSnapshot();
    const corrupt = {
      ...snapshot,
      state: { kind: 'Nonsense', atMs: 0 },
    } as unknown as ReturnType<Agreement['toSnapshot']>;
    expect(() => Agreement.fromSnapshot(corrupt)).toThrow(AgreementSnapshotCorruptException);
    const badSlot = {
      ...snapshot,
      slot: { startMs: 10, endMs: 10 },
    } as unknown as ReturnType<Agreement['toSnapshot']>;
    expect(() => Agreement.fromSnapshot(badSlot)).toThrow(AgreementSnapshotCorruptException);
  });
});
