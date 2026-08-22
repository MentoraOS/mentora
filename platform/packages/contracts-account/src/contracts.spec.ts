import { describe, expect, it } from 'vitest';

import { ACCOUNT_COMMAND_TYPES } from './commands/account-command-contracts.js';
import {
  deserializeAccountEvent,
  serializeAccountEvent,
  validateAccountEvent,
} from './serialization/account-event-serialization.js';
import { validateAccountCommand } from './validation/account-command-validation.js';
import { ACCOUNT_EVENT_TYPES } from './wire/event-union.js';

const base = { contractVersion: 1, commandId: 'cmd-1', personId: 'person-1' };

const wellFormed: readonly Record<string, unknown>[] = [
  { ...base, type: 'RegisterPerson', verificationState: 'unverified' },
  { ...base, type: 'ChangePreference', preference: { kind: 'language', value: 'fr' } },
  { ...base, type: 'ChangeReachability', channel: 'email' },
  { ...base, type: 'RegisterDevice', deviceId: 'dev-1' },
  { ...base, type: 'RemoveDevice', deviceId: 'dev-1' },
  { ...base, type: 'CloseAccount', motive: 'leaving' },
  { ...base, type: 'ChangeAvailabilityFrame', windows: [{ startMs: 1, endMs: 2 }] },
  { ...base, type: 'StartSubscription', subscriptionId: 'sub-1', offerReference: 'offer-1' },
  { ...base, type: 'EndSubscription', subscriptionId: 'sub-1', motive: 'done' },
  { ...base, type: 'OpenSupportRequest', supportRequestId: 'sr-1', motive: 'help' },
  { ...base, type: 'HandleSupportRequest', supportRequestId: 'sr-1' },
];

describe('the Account language — the eleven ratified commands (catalogue 36-46)', () => {
  it('declares exactly the catalogue, in catalogue order', () => {
    expect([...ACCOUNT_COMMAND_TYPES]).toHaveLength(11);
    expect(ACCOUNT_COMMAND_TYPES[0]).toBe('RegisterPerson');
    expect(ACCOUNT_COMMAND_TYPES[10]).toBe('HandleSupportRequest');
  });

  it('accepts every well-formed wire', () => {
    for (const wire of wellFormed) {
      const validated = validateAccountCommand(wire);
      expect(validated.ok, String(wire['type'])).toBe(true);
    }
  });

  it('refuses an unknown type, a foreign generation, a non-object — the caller defect', () => {
    expect(validateAccountCommand('x').ok).toBe(false);
    expect(validateAccountCommand({ ...base, type: 'DeleteAccount' }).ok).toBe(false);
    const generation = validateAccountCommand({ ...base, contractVersion: 2, type: 'RegisterPerson', verificationState: 'v' });
    expect(!generation.ok && generation.error[0]?.code).toBe('CONTRACT.UNKNOWN_GENERATION');
  });

  it('lists EVERY violation per type', () => {
    const preference = validateAccountCommand({ ...base, type: 'ChangePreference', preference: { kind: ' ', value: '' } });
    expect(!preference.ok && preference.error.map((v) => v.field)).toEqual(['preference.kind', 'preference.value']);
    const windows = validateAccountCommand({ ...base, type: 'ChangeAvailabilityFrame', windows: [{ startMs: 'a' }, 3] });
    expect(!windows.ok && windows.error.map((v) => v.field)).toEqual(['windows[0]', 'windows[1]']);
    const notArray = validateAccountCommand({ ...base, type: 'ChangeAvailabilityFrame', windows: 'x' });
    expect(!notArray.ok && notArray.error[0]?.field).toBe('windows');
    const notObject = validateAccountCommand({ ...base, type: 'ChangePreference', preference: 'fr' });
    expect(!notObject.ok && notObject.error[0]?.field).toBe('preference');
    const blanks = validateAccountCommand({ contractVersion: 1, commandId: '', personId: ' ', type: 'CloseAccount', motive: '' });
    expect(!blanks.ok && blanks.error).toHaveLength(3);
  });
});

describe('the Account language — the seven ratified facts (catalogue 40-46)', () => {
  const facts: readonly Record<string, unknown>[] = [
    { contractVersion: 1, type: 'PersonRegistered', personId: 'p', sequence: 1, occurredAtMs: 1, verificationState: 'v' },
    { contractVersion: 1, type: 'PreferenceChanged', personId: 'p', sequence: 2, occurredAtMs: 2, preferenceKind: 'language', preferenceValue: 'fr' },
    { contractVersion: 1, type: 'ReachabilityChanged', personId: 'p', sequence: 3, occurredAtMs: 3, channel: 'email' },
    { contractVersion: 1, type: 'AccountClosed', personId: 'p', sequence: 4, occurredAtMs: 4, motive: 'm' },
    { contractVersion: 1, type: 'AvailabilityFrameChanged', personId: 'p', sequence: 1, occurredAtMs: 1, windows: [] },
    { contractVersion: 1, type: 'SubscriptionStarted', subscriptionId: 's', sequence: 1, occurredAtMs: 1, personId: 'p', offerReference: 'o' },
    { contractVersion: 1, type: 'SubscriptionEnded', subscriptionId: 's', sequence: 2, occurredAtMs: 2, motive: 'm' },
  ];

  it('declares exactly seven; each validates and round-trips deterministically', () => {
    expect([...ACCOUNT_EVENT_TYPES]).toHaveLength(7);
    for (const fact of facts) {
      const validated = validateAccountEvent(fact);
      expect(validated.ok, String(fact['type'])).toBe(true);
      if (!validated.ok) continue;
      const json = serializeAccountEvent(validated.value);
      expect(serializeAccountEvent(validated.value)).toBe(json);
      const back = deserializeAccountEvent(json);
      expect(back.ok && back.value).toEqual(fact);
    }
  });

  it('sorts keys — byte-identical JSON whatever the construction order', () => {
    const a = validateAccountEvent({ type: 'AccountClosed', motive: 'm', occurredAtMs: 4, sequence: 4, personId: 'p', contractVersion: 1 });
    const b = validateAccountEvent(facts[3]);
    expect(a.ok && b.ok && serializeAccountEvent(a.value)).toBe(b.ok && serializeAccountEvent(b.value));
  });

  it('refuses the unknown, the foreign generation, the missing subject, the bad order, the bad windows', () => {
    expect(validateAccountEvent(null).ok).toBe(false);
    expect(validateAccountEvent({ type: 'DeviceRegistered' }).ok).toBe(false);
    const bad = validateAccountEvent({ contractVersion: 2, type: 'SubscriptionStarted', subscriptionId: '', sequence: 0, occurredAtMs: 'x', personId: '', offerReference: '' });
    expect(!bad.ok && bad.error.map((v) => v.field)).toEqual(['contractVersion', 'subscriptionId', 'sequence', 'occurredAtMs', 'personId', 'offerReference']);
    const frame = validateAccountEvent({ contractVersion: 1, type: 'AvailabilityFrameChanged', personId: 'p', sequence: 1, occurredAtMs: 1, windows: 'x' });
    expect(!frame.ok && frame.error[0]?.field).toBe('windows');
    expect(deserializeAccountEvent('{not json').ok).toBe(false);
  });
});
