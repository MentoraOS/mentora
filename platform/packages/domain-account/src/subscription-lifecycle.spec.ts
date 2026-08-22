import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { Subscription } from './aggregate/subscription.js';
import { SupportRequest } from './aggregate/support-request.js';
import { openSupportRequest, startSubscription } from './factories/subscription-factory.js';
import { commandIdOf, personIdOf, subscriptionIdOf, supportRequestIdOf } from './ids/identifiers.js';
import { SubscriptionPolicy } from './policies/subscription.policy.js';
import { ActiveSubscriptionUniquenessSpecification } from './specifications/active-subscription-uniqueness.specification.js';
import { SubscriptionChangeSpecification } from './specifications/subscription-change.specification.js';
import { startedSubscription } from './testing/subscription-repository-contract-suite.js';
import { openedRequest } from './testing/support-request-repository-contract-suite.js';

const T1 = instantOf(2_000);
const policy = new SubscriptionPolicy({ admittedOffers: ['offer-basic', ' offer-plus '] });

describe('Subscription — Active at start (P4), one active per holder (R-A), Ended is terminal (R-B)', () => {
  it('is born ACTIVE by the SubscriptionFactory after the policy judged the offer — one fact, version 1', () => {
    const born = startSubscription(
      {
        commandId: commandIdOf('c'),
        subscriptionId: subscriptionIdOf('sub-1'),
        personId: personIdOf('person-1'),
        offerReference: 'offer-plus',
        startedAt: instantOf(1_000),
      },
      policy,
    );
    expect(born.ok).toBe(true);
    if (!born.ok) return;
    expect(born.value.state.kind).toBe('Active');
    expect(born.value.version).toBe(1);
    expect(born.value.unretainedActs).toBe(1);
    expect(born.value.pendingFacts.map((fact) => fact.type)).toEqual(['SubscriptionStarted']);
    const fact = born.value.pendingFacts[0];
    expect(fact?.type === 'SubscriptionStarted' && fact.offerReference).toBe('offer-plus');
  });

  it('the SubscriptionPolicy refuses an offer outside the product allowlist — OfferUnavailable, BEFORE any birth', () => {
    const refused = startSubscription(
      {
        commandId: commandIdOf('c'),
        subscriptionId: subscriptionIdOf('sub-1'),
        personId: personIdOf('person-1'),
        offerReference: 'offer-gold',
        startedAt: instantOf(1_000),
      },
      policy,
    );
    expect(!refused.ok && refused.error.reason).toBe('OfferUnavailable');
  });

  it('end is terminal: SubscriptionEnded, then end again is TransitionUnavailable', () => {
    const ended = startedSubscription('sub-1', 'person-1').end({
      commandId: commandIdOf('e'),
      subscriptionId: subscriptionIdOf('sub-1'),
      motive: 'cancelled',
      endedAt: T1,
    });
    expect(ended.ok).toBe(true);
    if (!ended.ok) return;
    expect(ended.value.state.kind).toBe('Ended');
    expect(ended.value.version).toBe(2);
    expect(ended.value.pendingFacts.map((fact) => fact.type)).toEqual(['SubscriptionStarted', 'SubscriptionEnded']);
    expect(new SubscriptionChangeSpecification().isSatisfiedBy(ended.value)).toBe(false);
    const again = ended.value.end({ commandId: commandIdOf('e2'), subscriptionId: subscriptionIdOf('sub-1'), motive: 'x', endedAt: T1 });
    expect(!again.ok && again.error.reason).toBe('TransitionUnavailable');
  });

  it('the R-A rule is DECLARED here: two ACTIVE subscriptions of one holder conflict; ended or other-holder do not', () => {
    const rule = new ActiveSubscriptionUniquenessSpecification();
    const a = startedSubscription('sub-a', 'person-1');
    const b = startedSubscription('sub-b', 'person-1');
    const c = startedSubscription('sub-c', 'person-2');
    expect(rule.conflicts(a, b)).toBe(true);
    expect(rule.conflicts(a, a)).toBe(false);
    expect(rule.conflicts(a, c)).toBe(false);
    const ended = b.end({ commandId: commandIdOf('e'), subscriptionId: b.id, motive: 'm', endedAt: T1 });
    expect(ended.ok && rule.conflicts(a, ended.value)).toBe(false);
  });

  it('retained() empties; snapshot round-trips; corruption throws', () => {
    const started = startedSubscription('sub-1', 'person-1');
    expect(started.retained().pendingFacts).toHaveLength(0);
    expect(started.retained().unretainedActs).toBe(0);
    const back = Subscription.fromSnapshot(started.snapshot());
    expect(back.snapshot()).toEqual(started.snapshot());
    const ended = started.end({ commandId: commandIdOf('e'), subscriptionId: started.id, motive: 'm', endedAt: T1 });
    if (!ended.ok) throw new Error('unreachable');
    const endedBack = Subscription.fromSnapshot(ended.value.snapshot());
    expect(endedBack.state.kind === 'Ended' && endedBack.state.motive).toBe('m');
    expect(() => Subscription.fromSnapshot({ ...started.snapshot(), version: 0 })).toThrow(/version 0/);
    expect(() => Subscription.fromSnapshot({ ...started.snapshot(), offerReference: ' ' })).toThrow(/blank offer/);
  });

  it('key surface: the terms by reference, never a price', () => {
    expect(Object.keys(startedSubscription('sub-1', 'person-1')).sort()).toEqual([
      'id',
      'offerReference',
      'pendingFacts',
      'personId',
      'state',
      'unretainedActs',
      'version',
    ]);
  });
});

describe('SupportRequest — Opened → Handled, NO fact structurally (precedent: Session)', () => {
  it('is born Opened without any fact; the unit has NO pendingFacts field at all', () => {
    const opened = openSupportRequest({
      commandId: commandIdOf('c'),
      supportRequestId: supportRequestIdOf('sr-1'),
      requesterId: personIdOf('person-1'),
      motive: 'billing',
      openedAt: instantOf(1_000),
    });
    expect(opened.ok).toBe(true);
    if (!opened.ok) return;
    expect(Object.keys(opened.value).sort()).toEqual(['id', 'motive', 'requesterId', 'state', 'unretainedActs', 'version']);
    expect(opened.value.state.kind).toBe('Opened');
    expect(opened.value.version).toBe(1);
  });

  it('handle is terminal: version +1, then TransitionUnavailable', () => {
    const handled = openedRequest('sr-1').handle({ commandId: commandIdOf('h'), supportRequestId: supportRequestIdOf('sr-1'), handledAt: T1 });
    expect(handled.ok).toBe(true);
    if (!handled.ok) return;
    expect(handled.value.state.kind).toBe('Handled');
    expect(handled.value.version).toBe(2);
    const again = handled.value.handle({ commandId: commandIdOf('h2'), supportRequestId: supportRequestIdOf('sr-1'), handledAt: T1 });
    expect(!again.ok && again.error.reason).toBe('TransitionUnavailable');
  });

  it('retained() resets the act counter; snapshot round-trips both states; corruption throws', () => {
    const opened = openedRequest('sr-1');
    expect(opened.retained().unretainedActs).toBe(0);
    expect(SupportRequest.fromSnapshot(opened.snapshot()).snapshot()).toEqual(opened.snapshot());
    const handled = opened.handle({ commandId: commandIdOf('h'), supportRequestId: opened.id, handledAt: T1 });
    if (!handled.ok) throw new Error('unreachable');
    const back = SupportRequest.fromSnapshot(handled.value.snapshot());
    expect(back.state.kind === 'Handled' && back.state.handledAt.epochMillis).toBe(2_000);
    expect(() => SupportRequest.fromSnapshot({ ...opened.snapshot(), version: 0 })).toThrow(/version 0/);
    expect(() => SupportRequest.fromSnapshot({ ...opened.snapshot(), motive: '' })).toThrow(/blank motive/);
  });

  it('guards: blank ids are the caller defect', () => {
    expect(() => subscriptionIdOf('')).toThrow(/SubscriptionId/);
    expect(() => supportRequestIdOf(' ')).toThrow(/SupportRequestId/);
  });
});
