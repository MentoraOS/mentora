import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { Agreement } from './aggregate/agreement.js';
import type { AgreementRefusal } from './decisions/agreement-refusal.js';
import { AgreementCancellationPolicy } from './policies/agreement-cancellation.policy.js';
import { ReschedulePolicy } from './policies/reschedule.policy.js';
import {
  HOUR,
  T0,
  acceptCommand,
  acceptedAgreement,
  cancelCommand,
  confirmCommand,
  confirmedAgreement,
  elapseCommand,
  lapseCommand,
  rejectCommand,
  requestedAgreement,
  rescheduleCommand,
  slotAt,
} from './testing/agreement-mother.js';

/**
 * The formalized invariants of the Agreement (each cites its R2 law):
 *
 * INV-1  A TimeSlot exists only with start < end (VO door — F3.1).
 *        → tested in value-objects.spec.ts.
 * INV-2  The state machine is frozen; only the F3.3 §8 transitions exist.
 * INV-3  L'Acceptation précède toute Confirmation (F2.6 [T]).
 * INV-4  Nulle Confirmation sans conditions accomplies, encaissement compris
 *        (F2.6 [É]) — ConfirmationConditionsMissing.
 * INV-5  Terminal states are irreversible (R-B): every act on a terminal
 *        agreement is refused; coming back is a NEW Demande.
 * INV-6  Every successful mutation gives birth to EXACTLY ONE fact and
 *        increments the version by one (F3.1.99 §3).
 * INV-7  The clock never enters the unit: deadlines are judged on provided
 *        instants only (F3.1.99 §5) — structural: no method reads time.
 * INV-8  The inter-unit uniqueness (expert × overlapping confirmed slots) is
 *        the declared R-A key: rule in OverlappingSlotSpecification, applied
 *        structurally by the registry at retention (TimeSlotUnavailable).
 *        → the rule half is tested in specifications.spec.ts; the key half is
 *          opposable to the registry adapter (contract suite, later lot).
 */

const at = (h: number) => instantOf(T0.epochMillis + h * HOUR);
const cancellation = new AgreementCancellationPolicy({ minimumNoticeMillis: 0 });
const reschedule = new ReschedulePolicy({ minimumNoticeMillis: 0, maximumReschedules: 3 });

type Act = (a: Agreement) => { ok: true; value: Agreement } | { ok: false; error: AgreementRefusal };

const ALL_ACTS: ReadonlyArray<readonly [string, Act]> = [
  ['accept', (a) => a.accept(acceptCommand(at(50)))],
  ['reject', (a) => a.reject(rejectCommand(at(50)))],
  ['confirm', (a) => a.confirm(confirmCommand(at(50)))],
  ['reschedule', (a) => a.reschedule(rescheduleCommand(at(50), slotAt(T0.epochMillis + 96 * HOUR)), reschedule)],
  ['cancel', (a) => a.cancel(cancelCommand(at(50)), cancellation)],
  ['lapseRequest', (a) => a.lapseRequest(lapseCommand(at(50)))],
  ['elapse', (a) => a.elapse(elapseCommand(at(50)))],
];

const terminalAgreements = (): ReadonlyArray<readonly [string, Agreement]> => {
  const rejected = requestedAgreement().reject(rejectCommand(at(1)));
  const lapsed = requestedAgreement().lapseRequest(lapseCommand(at(24)));
  const cancelled = confirmedAgreement().cancel(cancelCommand(at(3)), cancellation);
  const elapsed = confirmedAgreement().elapse(elapseCommand(at(49)));
  if (!rejected.ok || !lapsed.ok || !cancelled.ok || !elapsed.ok) {
    throw new Error('terminal fixtures must build');
  }
  return [
    ['Rejected', rejected.value],
    ['Lapsed', lapsed.value],
    ['Cancelled', cancelled.value],
    ['Elapsed', elapsed.value],
  ];
};

describe('INV-2 — the machine is frozen: forbidden transitions are refused', () => {
  it('confirm from Requested is refused (never Confirmed without Acceptation — INV-3)', () => {
    const result = requestedAgreement().confirm(confirmCommand(at(1)));
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error.reason).toBe('TransitionUnavailable');
  });

  it('reject from Accepted is refused (Confirmed→Rejected and beyond are dead)', () => {
    const result = acceptedAgreement().reject(rejectCommand(at(2)));
    expect(result.ok).toBe(false);
  });

  it('cancel from Requested is refused (Cancelled exits Confirmed only)', () => {
    const result = requestedAgreement().cancel(cancelCommand(at(1)), cancellation);
    expect(result.ok).toBe(false);
  });

  it('lapse from Confirmed is refused (la Caducité frappe la Demande, F2.5.2)', () => {
    const result = confirmedAgreement().lapseRequest(lapseCommand(at(3)));
    expect(result.ok).toBe(false);
  });
});

describe('INV-4 — no Confirmation without settlement evidence (F2.6 [É])', () => {
  it('blank settlement reference → ConfirmationConditionsMissing', () => {
    const result = acceptedAgreement().confirm(confirmCommand(at(2), '   '));
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error.reason).toBe('ConfirmationConditionsMissing');
  });
});

describe('INV-5 — terminal states are irreversible (R-B): every act is refused', () => {
  for (const [terminalKind, agreement] of terminalAgreements()) {
    for (const [actName, act] of ALL_ACTS) {
      it(`${actName} on ${terminalKind} is refused as TransitionUnavailable`, () => {
        const result = act(agreement);
        expect(result.ok).toBe(false);
        if (!result.ok) expect(result.error.reason).toBe('TransitionUnavailable');
      });
    }
  }
});

describe('INV-6 — one successful mutation = exactly one newborn fact, version +1', () => {
  it('holds across the whole happy path', () => {
    let agreement = requestedAgreement();
    expect(agreement.pendingFacts.length).toBe(1);
    const steps: ReadonlyArray<Act> = [
      (a) => a.accept(acceptCommand(at(1))),
      (a) => a.confirm(confirmCommand(at(2))),
      (a) => a.reschedule(rescheduleCommand(at(3), slotAt(T0.epochMillis + 96 * HOUR)), reschedule),
      (a) => a.elapse(elapseCommand(at(97))),
    ];
    for (const step of steps) {
      const before = agreement;
      const result = step(agreement);
      expect(result.ok).toBe(true);
      if (!result.ok) return;
      agreement = result.value;
      expect(agreement.pendingFacts.length).toBe(before.pendingFacts.length + 1);
      expect(agreement.version).toBe(before.version + 1);
    }
  });

  it('a refused act mutates nothing: same instance semantics, no fact born', () => {
    const agreement = requestedAgreement();
    const refused = agreement.confirm(confirmCommand(at(1)));
    expect(refused.ok).toBe(false);
    expect(agreement.pendingFacts.length).toBe(1);
    expect(agreement.state.kind).toBe('Requested');
  });
});
