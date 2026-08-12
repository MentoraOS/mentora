import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { AgreementIdentifierBlankException } from './errors/agreement-exceptions.js';
import { agreementIdOf, clientIdOf } from './ids/identifiers.js';
import { HOUR, T0, slotAt } from './testing/agreement-mother.js';
import { isTerminalState } from './value-objects/agreement-state.js';
import { timeSlotOf, timeSlotWithin, timeSlotsOverlap } from './value-objects/time-slot.js';

describe('identifiers (F3.1.99 §4 — opaque, stable, never blank)', () => {
  it('accepts a non-blank identifier', () => {
    expect(agreementIdOf('agr-1')).toBe('agr-1');
  });

  it('a blank identifier is a malformed call — Exception, not a refusal', () => {
    expect(() => agreementIdOf('')).toThrow(AgreementIdentifierBlankException);
    expect(() => clientIdOf('   ')).toThrow(AgreementIdentifierBlankException);
  });
});

describe('TimeSlot (ratified VO — refuses to exist invalid, F3.1)', () => {
  it('exists when start < end', () => {
    const slot = timeSlotOf(instantOf(10), instantOf(20));
    expect(slot.ok).toBe(true);
  });

  it('refuses to exist when start >= end (VO refusal door, as a value)', () => {
    const empty = timeSlotOf(instantOf(20), instantOf(20));
    const inverted = timeSlotOf(instantOf(30), instantOf(20));
    expect(empty.ok).toBe(false);
    expect(inverted.ok).toBe(false);
    if (!inverted.ok) {
      expect(inverted.error.reason).toBe('SlotBoundsInvalid');
    }
  });

  it('overlap is half-open: touching slots do not overlap', () => {
    const a = slotAt(0, 10);
    const b = slotAt(10, 10);
    const c = slotAt(5, 10);
    expect(timeSlotsOverlap(a, b)).toBe(false);
    expect(timeSlotsOverlap(a, c)).toBe(true);
    expect(timeSlotsOverlap(c, a)).toBe(true);
  });

  it('within is inclusive on both bounds', () => {
    const window = slotAt(0, 100);
    expect(timeSlotWithin(slotAt(0, 100), window)).toBe(true);
    expect(timeSlotWithin(slotAt(10, 20), window)).toBe(true);
    expect(timeSlotWithin(slotAt(90, 20), window)).toBe(false);
  });
});

describe('AgreementState (frozen machine, F3.3 §8)', () => {
  it('exactly the four terminals are terminal (R-B)', () => {
    expect(isTerminalState({ kind: 'Requested', requestedAt: T0 })).toBe(false);
    expect(isTerminalState({ kind: 'Accepted', acceptedAt: T0 })).toBe(false);
    expect(
      isTerminalState({ kind: 'Confirmed', confirmedAt: T0, settlementReference: 'stl-1' }),
    ).toBe(false);
    expect(isTerminalState({ kind: 'Rejected', rejectedAt: T0 })).toBe(true);
    expect(isTerminalState({ kind: 'Lapsed', lapsedAt: T0 })).toBe(true);
    expect(isTerminalState({ kind: 'Elapsed', elapsedAt: instantOf(T0.epochMillis + HOUR) })).toBe(
      true,
    );
    expect(
      isTerminalState({
        kind: 'Cancelled',
        record: {
          cancelledBy: { role: 'Client', clientId: clientIdOf('cli-1') },
          instant: T0,
          motive: 'x',
        },
      }),
    ).toBe(true);
  });
});
