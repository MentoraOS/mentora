import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { Account } from './aggregate/account.js';
import { registerPerson } from './factories/account-factory.js';
import { commandIdOf, deviceIdOf, personIdOf } from './ids/identifiers.js';
import { ReachabilityPolicy } from './policies/reachability.policy.js';
import { ClosableAccountSpecification } from './specifications/closable-account.specification.js';
import { preferenceKindOf, preferenceValueOf } from './value-objects/preference.js';
import { reachabilityChannelOf } from './value-objects/reachability-channel.js';
import { verificationStateOf } from './value-objects/verification-state.js';

const T0 = instantOf(1_000);
const T1 = instantOf(2_000);
const PERSON = personIdOf('person-1');

const born = (): Account => {
  const result = registerPerson({
    commandId: commandIdOf('cmd-reg'),
    personId: PERSON,
    verificationState: verificationStateOf('Unverified'),
    registeredAt: T0,
  });
  if (!result.ok) throw new Error('unreachable');
  return result.value;
};

const unwrap = <T, E>(result: { ok: true; value: T } | { ok: false; error: E }): T => {
  if (!result.ok) throw new Error('unreachable');
  return result.value;
};

describe('Account — the person IS the account; Active → Closed; facts for choices, none for devices', () => {
  it('is born Active at RegisterPerson with the ONE fact PersonRegistered, version 1, one unretained act', () => {
    const account = born();
    expect(account.id).toBe('person-1');
    expect(account.state.kind).toBe('Active');
    expect(account.verificationState).toBe('unverified');
    expect(account.version).toBe(1);
    expect(account.unretainedActs).toBe(1);
    expect(account.pendingFacts.map((fact) => fact.type)).toEqual(['PersonRegistered']);
    expect(account.preferences).toHaveLength(0);
    expect(account.reachability).toBeUndefined();
  });

  it('a typed preference replaces the previous value of its kind — one fact, version +1', () => {
    const first = unwrap(
      born().changePreference({
        commandId: commandIdOf('c1'),
        personId: PERSON,
        preference: { kind: preferenceKindOf('Language'), value: preferenceValueOf('fr') },
        changedAt: T1,
      }),
    );
    const second = unwrap(
      first.changePreference({
        commandId: commandIdOf('c2'),
        personId: PERSON,
        preference: { kind: preferenceKindOf('language'), value: preferenceValueOf('en') },
        changedAt: T1,
      }),
    );
    expect(second.preferences).toEqual([{ kind: 'language', value: 'en' }]);
    expect(second.version).toBe(3);
    expect(second.pendingFacts.map((fact) => fact.type)).toEqual([
      'PersonRegistered',
      'PreferenceChanged',
      'PreferenceChanged',
    ]);
    const fact = second.pendingFacts[2];
    expect(fact?.type === 'PreferenceChanged' && fact.preferenceValue).toBe('en');
  });

  it('reachability is a channel — a fact; the policy judged BEFORE the act', () => {
    const policy = new ReachabilityPolicy({ admittedChannels: ['email', 'SMS'] });
    expect(policy.judge(reachabilityChannelOf('sms')).ok).toBe(true);
    const refused = policy.judge(reachabilityChannelOf('carrier-pigeon'));
    expect(!refused.ok && refused.error.reason).toBe('ChannelUnavailable');
    const changed = unwrap(
      born().changeReachability({
        commandId: commandIdOf('c'),
        personId: PERSON,
        channel: reachabilityChannelOf('Email'),
        changedAt: T1,
      }),
    );
    expect(changed.reachability).toBe('email');
    expect(changed.pendingFacts[1]?.type).toBe('ReachabilityChanged');
  });

  it('devices: register and remove advance the version WITHOUT a fact; duplicates and unknowns refuse', () => {
    const account = born();
    const device = { commandId: commandIdOf('d'), personId: PERSON, deviceId: deviceIdOf('dev-1') };
    const registered = unwrap(account.registerDevice({ ...device, registeredAt: T1 }));
    expect(registered.devices).toHaveLength(1);
    expect(registered.version).toBe(2);
    expect(registered.unretainedActs).toBe(2);
    expect(registered.pendingFacts).toHaveLength(1); // PersonRegistered only
    const duplicate = registered.registerDevice({ ...device, registeredAt: T1 });
    expect(!duplicate.ok && duplicate.error.reason).toBe('DeviceUnavailable');
    const removed = unwrap(registered.removeDevice({ ...device, removedAt: T1 }));
    expect(removed.devices).toHaveLength(0);
    expect(removed.version).toBe(3);
    const unknown = removed.removeDevice({ ...device, removedAt: T1 });
    expect(!unknown.ok && unknown.error.reason).toBe('DeviceUnavailable');
  });

  it('close is terminal: AccountClosed, then EVERY verb is TransitionUnavailable (fermé ⇒ plus rien ne change)', () => {
    const closed = unwrap(
      born().close({ commandId: commandIdOf('x'), personId: PERSON, motive: 'leaving', closedAt: T1 }),
    );
    expect(closed.state.kind).toBe('Closed');
    expect(closed.pendingFacts[1]?.type).toBe('AccountClosed');
    expect(new ClosableAccountSpecification().isSatisfiedBy(closed)).toBe(false);
    const verbs = [
      closed.close({ commandId: commandIdOf('x'), personId: PERSON, motive: 'again', closedAt: T1 }),
      closed.changePreference({
        commandId: commandIdOf('x'),
        personId: PERSON,
        preference: { kind: preferenceKindOf('timezone'), value: preferenceValueOf('Africa/Bamako') },
        changedAt: T1,
      }),
      closed.changeReachability({ commandId: commandIdOf('x'), personId: PERSON, channel: reachabilityChannelOf('email'), changedAt: T1 }),
      closed.registerDevice({ commandId: commandIdOf('x'), personId: PERSON, deviceId: deviceIdOf('d'), registeredAt: T1 }),
      closed.removeDevice({ commandId: commandIdOf('x'), personId: PERSON, deviceId: deviceIdOf('d'), removedAt: T1 }),
    ];
    for (const verb of verbs) {
      expect(!verb.ok && verb.error.reason).toBe('TransitionUnavailable');
    }
  });

  it('retained() empties the facts and the act counter, keeps the version', () => {
    const retained = unwrap(
      born().registerDevice({ commandId: commandIdOf('d'), personId: PERSON, deviceId: deviceIdOf('dev-1'), registeredAt: T1 }),
    ).retained();
    expect(retained.pendingFacts).toHaveLength(0);
    expect(retained.unretainedActs).toBe(0);
    expect(retained.version).toBe(2);
  });

  it('snapshot round-trips every field; corruption throws (version, duplicate preference kinds)', () => {
    const rich = unwrap(
      unwrap(
        unwrap(
          born().changePreference({
            commandId: commandIdOf('a'),
            personId: PERSON,
            preference: { kind: preferenceKindOf('notification'), value: preferenceValueOf('digest') },
            changedAt: T1,
          }),
        ).changeReachability({ commandId: commandIdOf('b'), personId: PERSON, channel: reachabilityChannelOf('email'), changedAt: T1 }),
      ).registerDevice({ commandId: commandIdOf('c'), personId: PERSON, deviceId: deviceIdOf('dev-1'), registeredAt: T1 }),
    );
    const back = Account.fromSnapshot(rich.snapshot());
    expect(back.snapshot()).toEqual(rich.snapshot());
    expect(back.reachability).toBe('email');
    expect(back.devices[0]?.registeredAt.epochMillis).toBe(2_000);
    const closedBack = Account.fromSnapshot(
      unwrap(rich.close({ commandId: commandIdOf('z'), personId: PERSON, motive: 'm', closedAt: T1 })).snapshot(),
    );
    expect(closedBack.state.kind === 'Closed' && closedBack.state.motive).toBe('m');
    expect(() => Account.fromSnapshot({ ...rich.snapshot(), version: 0 })).toThrow(/version 0/);
    expect(() =>
      Account.fromSnapshot({
        ...rich.snapshot(),
        preferences: [
          { kind: 'language', value: 'fr' },
          { kind: 'language', value: 'en' },
        ],
      }),
    ).toThrow(/twice/);
  });

  it('the unit carries NO secret, NO content — its key surface is the declared one', () => {
    expect(Object.keys(born()).sort()).toEqual([
      'devices',
      'id',
      'pendingFacts',
      'preferences',
      'reachability',
      'state',
      'unretainedActs',
      'verificationState',
      'version',
    ]);
  });

  it('guards: blank ids/values and an unknown preference kind are the caller defect', () => {
    expect(() => personIdOf(' ')).toThrow(/PersonId/);
    expect(() => preferenceKindOf('theme')).toThrow(/PreferenceKind/);
    expect(() => preferenceValueOf(' ')).toThrow(/PreferenceValue/);
    expect(() => reachabilityChannelOf('')).toThrow(/ReachabilityChannel/);
    expect(() => verificationStateOf('')).toThrow(/VerificationState/);
    expect(() => deviceIdOf('')).toThrow(/DeviceId/);
  });
});
