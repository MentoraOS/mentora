import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { AgreementCancellationPolicy } from './policies/agreement-cancellation.policy.js';
import { AgreementRequestLapsePolicy } from './policies/agreement-request-lapse.policy.js';
import { ConfirmationPolicy } from './policies/confirmation.policy.js';
import { ReschedulePolicy } from './policies/reschedule.policy.js';
import { ConfirmableAgreementSpecification } from './specifications/confirmable-agreement.specification.js';
import { OverlappingSlotSpecification } from './specifications/overlapping-slot.specification.js';
import { SlotWithinFrameSpecification } from './specifications/slot-within-frame.specification.js';
import { HOUR, T0, slotAt } from './testing/agreement-mother.js';

const at = (h: number) => instantOf(T0.epochMillis + h * HOUR);

describe('the four frozen Policies (published in advance; params = product config)', () => {
  it('AgreementCancellationPolicy admits with enough notice, refuses inside the window', () => {
    const policy = new AgreementCancellationPolicy({ minimumNoticeMillis: 24 * HOUR });
    const slotStart = at(48);
    expect(policy.decide(slotStart, at(10)).ok).toBe(true);
    const refused = policy.decide(slotStart, at(47));
    expect(refused.ok).toBe(false);
    if (!refused.ok) expect(refused.error.reason).toBe('CancellationWindowClosed');
  });

  it('ReschedulePolicy refuses past the limit and inside the notice window', () => {
    const policy = new ReschedulePolicy({ minimumNoticeMillis: 24 * HOUR, maximumReschedules: 2 });
    const slotStart = at(48);
    expect(policy.decide(slotStart, at(10), 0).ok).toBe(true);
    const limit = policy.decide(slotStart, at(10), 2);
    expect(limit.ok).toBe(false);
    if (!limit.ok) expect(limit.error.reason).toBe('RescheduleLimitReached');
    const late = policy.decide(slotStart, at(47), 0);
    expect(late.ok).toBe(false);
    if (!late.ok) expect(late.error.reason).toBe('RescheduleWindowClosed');
  });

  it('AgreementRequestLapsePolicy computes the Caducité deadline (le silence a une échéance)', () => {
    const policy = new AgreementRequestLapsePolicy({ requestTimeToLiveMillis: 24 * HOUR });
    expect(policy.lapsesAt(T0).epochMillis).toBe(T0.epochMillis + 24 * HOUR);
    expect(policy.isLapsed(T0, at(23))).toBe(false);
    expect(policy.isLapsed(T0, at(24))).toBe(true);
  });

  it('ConfirmationPolicy publishes the confirmation window after Acceptation', () => {
    const policy = new ConfirmationPolicy({ confirmationWindowMillis: 12 * HOUR });
    expect(policy.isWithinWindow(T0, at(11))).toBe(true);
    expect(policy.isWithinWindow(T0, at(12))).toBe(false);
  });
});

describe('the three frozen Specifications', () => {
  it('SlotWithinFrame: the Créneau must fit one published window', () => {
    const spec = new SlotWithinFrameSpecification();
    const windows = [slotAt(0, 100), slotAt(200, 100)];
    expect(spec.isSatisfiedBy(slotAt(10, 20), windows)).toBe(true);
    expect(spec.isSatisfiedBy(slotAt(250, 20), windows)).toBe(true);
    expect(spec.isSatisfiedBy(slotAt(150, 20), windows)).toBe(false);
    expect(spec.isSatisfiedBy(slotAt(10, 20), [])).toBe(false);
  });

  it('OverlappingSlot: the rule half of the R-A key (half-open semantics)', () => {
    const spec = new OverlappingSlotSpecification();
    expect(spec.isSatisfiedBy(slotAt(0, 10), slotAt(5, 10))).toBe(true);
    expect(spec.isSatisfiedBy(slotAt(0, 10), slotAt(10, 10))).toBe(false);
  });

  it('ConfirmableAgreement: Accepted AND evidence present (F2.6 [T]+[É])', () => {
    const spec = new ConfirmableAgreementSpecification();
    expect(spec.isSatisfiedBy({ kind: 'Accepted', acceptedAt: T0 }, 'stl-1')).toBe(true);
    expect(spec.isSatisfiedBy({ kind: 'Accepted', acceptedAt: T0 }, '  ')).toBe(false);
    expect(spec.isSatisfiedBy({ kind: 'Requested', requestedAt: T0 }, 'stl-1')).toBe(false);
  });
});
