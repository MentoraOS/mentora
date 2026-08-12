import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { AgreementFactory } from './factories/agreement-factory.js';
import { AgreementCancellationPolicy } from './policies/agreement-cancellation.policy.js';
import { ReschedulePolicy } from './policies/reschedule.policy.js';
import {
  DEFAULT_SLOT,
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
  requestCommand,
  requestedAgreement,
  rescheduleCommand,
  slotAt,
} from './testing/agreement-mother.js';

const at = (hoursAfterT0: number) => instantOf(T0.epochMillis + hoursAfterT0 * HOUR);
const permissiveCancellation = new AgreementCancellationPolicy({ minimumNoticeMillis: 0 });
const permissiveReschedule = new ReschedulePolicy({ minimumNoticeMillis: 0, maximumReschedules: 3 });

describe('the frozen lifecycle (F3.3 §8 — sole owner of the transitions)', () => {
  it('birth: the Demande is the Agreement’s youth — Requested with its first fact', () => {
    const agreement = requestedAgreement();
    expect(agreement.state.kind).toBe('Requested');
    expect(agreement.version).toBe(1);
    expect(agreement.pendingFacts).toHaveLength(1);
    const fact = agreement.pendingFacts[0];
    expect(fact?.type).toBe('AgreementRequested');
    expect(fact?.sequence).toBe(1);
  });

  it('Requested → Accepted (AgreementAccepted)', () => {
    const result = requestedAgreement().accept(acceptCommand(at(1)));
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.state.kind).toBe('Accepted');
      expect(result.value.version).toBe(2);
      expect(result.value.pendingFacts.at(-1)?.type).toBe('AgreementAccepted');
    }
  });

  it('Requested → Rejected (terminal)', () => {
    const result = requestedAgreement().reject(rejectCommand(at(1)));
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.state.kind).toBe('Rejected');
      expect(result.value.isTerminal).toBe(true);
      expect(result.value.pendingFacts.at(-1)?.type).toBe('AgreementRejected');
    }
  });

  it('Accepted → Confirmed with settlement evidence (AgreementConfirmed)', () => {
    const result = acceptedAgreement().confirm(confirmCommand(at(2)));
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.state.kind).toBe('Confirmed');
      expect(result.value.pendingFacts.at(-1)?.type).toBe('AgreementConfirmed');
    }
  });

  it('Confirmed ⇄ Confirmed on reschedule; the record carries both slots and its author', () => {
    const newSlot = slotAt(T0.epochMillis + 72 * HOUR);
    const result = confirmedAgreement().reschedule(
      rescheduleCommand(at(3), newSlot),
      permissiveReschedule,
    );
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.state.kind).toBe('Confirmed');
      expect(result.value.slot).toEqual(newSlot);
      expect(result.value.reschedules).toHaveLength(1);
      expect(result.value.reschedules[0]?.previousSlot).toEqual(DEFAULT_SLOT);
      expect(result.value.pendingFacts.at(-1)?.type).toBe('AgreementRescheduled');
    }
  });

  it('Confirmed → Cancelled (terminal); the Annulation carries its Auteur (F2.6)', () => {
    const result = confirmedAgreement().cancel(cancelCommand(at(3)), permissiveCancellation);
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.state.kind).toBe('Cancelled');
      const fact = result.value.pendingFacts.at(-1);
      expect(fact?.type).toBe('AgreementCancelled');
      if (fact?.type === 'AgreementCancelled') {
        expect(fact.record.cancelledBy.role).toBe('Client');
        expect(fact.record.motive).toBe('change of plans');
      }
    }
  });

  it('Requested → Lapsed and Accepted → Lapsed on a PROVIDED instant (Caducité)', () => {
    const fromRequested = requestedAgreement().lapseRequest(lapseCommand(at(24)));
    const fromAccepted = acceptedAgreement().lapseRequest(lapseCommand(at(24)));
    expect(fromRequested.ok && fromRequested.value.state.kind === 'Lapsed').toBe(true);
    expect(fromAccepted.ok && fromAccepted.value.state.kind === 'Lapsed').toBe(true);
  });

  it('Confirmed → Elapsed on a PROVIDED instant (Échéance)', () => {
    const result = confirmedAgreement().elapse(elapseCommand(at(49)));
    expect(result.ok).toBe(true);
    if (result.ok) {
      expect(result.value.state.kind).toBe('Elapsed');
      expect(result.value.pendingFacts.at(-1)?.type).toBe('AgreementElapsed');
    }
  });

  it('the full happy path emits the frozen facts in order with monotonic sequences', () => {
    const requested = requestedAgreement();
    const accepted = requested.accept(acceptCommand(at(1)));
    if (!accepted.ok) throw new Error('accept refused');
    const confirmed = accepted.value.confirm(confirmCommand(at(2)));
    if (!confirmed.ok) throw new Error('confirm refused');
    const elapsed = confirmed.value.elapse(elapseCommand(at(49)));
    if (!elapsed.ok) throw new Error('elapse refused');
    expect(elapsed.value.pendingFacts.map((f) => f.type)).toEqual([
      'AgreementRequested',
      'AgreementAccepted',
      'AgreementConfirmed',
      'AgreementElapsed',
    ]);
    expect(elapsed.value.pendingFacts.map((f) => f.sequence)).toEqual([1, 2, 3, 4]);
    expect(elapsed.value.version).toBe(4);
  });

  it('retained() hands the registry a fact-free instance (facts published after retention)', () => {
    const agreement = requestedAgreement().retained();
    expect(agreement.pendingFacts).toHaveLength(0);
    expect(agreement.version).toBe(1);
  });

  it('factory refuses a Créneau outside the published Cadre (F2.6 [S])', () => {
    const outside = requestCommand({ slot: slotAt(T0.epochMillis + 20 * 24 * HOUR) });
    const result = new AgreementFactory().request(outside);
    expect(result.ok).toBe(false);
    if (!result.ok) {
      expect(result.error.reason).toBe('OutsideAvailabilityFrame');
    }
  });
});
