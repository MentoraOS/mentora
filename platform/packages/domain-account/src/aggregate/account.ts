import type { Result } from '@mentora/kernel';
import { err, instantOf, ok } from '@mentora/kernel';

import type {
  ChangePreference,
  ChangeReachability,
  CloseAccount,
  RegisterDevice,
  RemoveDevice,
} from '../commands/account-commands.js';
import type { AccountRefusal } from '../decisions/account-refusal.js';
import { accountRefusal } from '../decisions/account-refusal.js';
import type { Device } from '../entities/device.js';
import { AccountSnapshotCorruptException } from '../errors/account-exceptions.js';
import type { PersonId } from '../ids/identifiers.js';
import { deviceIdOf, personIdOf } from '../ids/identifiers.js';
import type { AccountSnapshot } from '../snapshots/account-snapshot.js';
import { ClosableAccountSpecification } from '../specifications/closable-account.specification.js';
import type { AccountState } from '../value-objects/account-state.js';
import type { Preference } from '../value-objects/preference.js';
import { preferenceKindOf, preferenceValueOf } from '../value-objects/preference.js';
import type { ReachabilityChannel } from '../value-objects/reachability-channel.js';
import { reachabilityChannelOf } from '../value-objects/reachability-channel.js';
import type { VerificationState } from '../value-objects/verification-state.js';
import { verificationStateOf } from '../value-objects/verification-state.js';

import type { AccountDomainEvent } from './account-domain-event.js';

/**
 * Account — the executable incarnation of the truth "qui est la personne
 * dans Mentora" (canon F3.2-B, domaine 6; dictionary F2.5 §Account). The
 * identity and the choices of the person: `Person` is NOT an aggregate — the
 * Account IS the person's truth, and its identity IS the PersonId (RFC-003
 * P1, singleton-par-acteur).
 *
 * Constitutional posture:
 * - Frozen machine `Active → Closed` (terminal): "fermé ⇒ plus rien ne
 *   change" — every verb on a Closed account is `TransitionUnavailable`;
 *   R-B: coming back is a NEW registered person.
 * - `Reachability` and `Preferences` live INSIDE (same actor, no invariant
 *   of their own beyond self-validating VOs); `Device` is an Entity with no
 *   incoming reference and NO fact (canon).
 * - Four facts (catalogue 40-43); Device verbs are state-only transitions.
 * - VERSION LAW (differs from Credential, where every act is a fact): the
 *   version advances by exactly ONE per act, fact or not; `unretainedActs`
 *   counts the acts since reconstitution so the registry computes the
 *   expected previous version (version − unretainedActs) — the optimistic
 *   guard (F5.2 §4) holds for state-only verbs too.
 * - The clock never enters: instants arrive as data. No secret, no content:
 *   the proof is I&A's, the dialogues are Messaging's.
 */
export class Account {
  private static readonly closable = new ClosableAccountSpecification();

  private constructor(
    /** The person IS the account (RFC-003 P1). */
    readonly id: PersonId,
    /** RFC-003 P6: keeps its registration value — no ratified command changes it. */
    readonly verificationState: VerificationState,
    readonly preferences: readonly Preference[],
    readonly reachability: ReachabilityChannel | undefined,
    readonly devices: readonly Device[],
    readonly state: AccountState,
    /** Optimistic-concurrency version (F5.2 §4): +1 per act, fact or not. */
    readonly version: number,
    /** Acts since reconstitution — the registry's expected-previous delta. */
    readonly unretainedActs: number,
    /** Facts born and not yet retained — pulled by the Application layer. */
    readonly pendingFacts: readonly AccountDomainEvent[],
  ) {}

  // ------------------------------------------------------------------ birth

  /** INTERNAL to the domain: called by the factory only (the birth door, F3.1). */
  static _born(
    id: PersonId,
    verificationState: VerificationState,
    registeredAt: AccountState & { kind: 'Active' },
  ): Account {
    return new Account(
      id,
      verificationState,
      [],
      undefined,
      [],
      registeredAt,
      1,
      1,
      [
        {
          type: 'PersonRegistered',
          personId: id,
          sequence: 1,
          instant: registeredAt.registeredAt,
          verificationState,
        },
      ],
    );
  }

  // ------------------------------------------------------- frozen machine

  /** 37 — a typed preference replaces the previous value of its kind (a fact). */
  changePreference(command: ChangePreference): Result<Account, AccountRefusal> {
    const open = this.requireActive('changePreference');
    if (!open.ok) {
      return open;
    }
    const preferences = [
      ...this.preferences.filter((preference) => preference.kind !== command.preference.kind),
      command.preference,
    ];
    return ok(
      this.next({ preferences }, {
        type: 'PreferenceChanged',
        personId: this.id,
        sequence: this.version + 1,
        instant: command.changedAt,
        preferenceKind: command.preference.kind,
        preferenceValue: command.preference.value,
      }),
    );
  }

  /** 38 — the channel the Notification may use (a fact; the policy judged before the act). */
  changeReachability(command: ChangeReachability): Result<Account, AccountRefusal> {
    const open = this.requireActive('changeReachability');
    if (!open.ok) {
      return open;
    }
    return ok(
      this.next({ reachability: command.channel }, {
        type: 'ReachabilityChanged',
        personId: this.id,
        sequence: this.version + 1,
        instant: command.changedAt,
        channel: command.channel,
      }),
    );
  }

  /** 39 — NO fact (canon); a name already registered is not available again. */
  registerDevice(command: RegisterDevice): Result<Account, AccountRefusal> {
    const open = this.requireActive('registerDevice');
    if (!open.ok) {
      return open;
    }
    if (this.devices.some((device) => device.deviceId === command.deviceId)) {
      return err(
        accountRefusal('DeviceUnavailable', `device ${command.deviceId} is already registered`),
      );
    }
    return ok(
      this.next({
        devices: [...this.devices, { deviceId: command.deviceId, registeredAt: command.registeredAt }],
      }),
    );
  }

  /** 40 — NO fact (canon); an unknown name cannot be removed. */
  removeDevice(command: RemoveDevice): Result<Account, AccountRefusal> {
    const open = this.requireActive('removeDevice');
    if (!open.ok) {
      return open;
    }
    if (!this.devices.some((device) => device.deviceId === command.deviceId)) {
      return err(accountRefusal('DeviceUnavailable', `device ${command.deviceId} is not registered`));
    }
    return ok(
      this.next({
        devices: this.devices.filter((device) => device.deviceId !== command.deviceId),
      }),
    );
  }

  /** 41 — terminal; the confirmation was BEFORE (UX-06); the sisters follow by choreography (RFC-003 P3). */
  close(command: CloseAccount): Result<Account, AccountRefusal> {
    if (!Account.closable.isSatisfiedBy(this)) {
      return err(
        accountRefusal(
          'TransitionUnavailable',
          `close requires an Active account; current state is ${this.state.kind}`,
        ),
      );
    }
    return ok(
      this.next(
        { state: { kind: 'Closed', closedAt: command.closedAt, motive: command.motive } },
        {
          type: 'AccountClosed',
          personId: this.id,
          sequence: this.version + 1,
          instant: command.closedAt,
          motive: command.motive,
        },
      ),
    );
  }

  // ------------------------------------------------------------- carriers

  /** The Application layer pulls the newborn facts for atomic retention (pas 8). */
  retained(): Account {
    return new Account(
      this.id,
      this.verificationState,
      this.preferences,
      this.reachability,
      this.devices,
      this.state,
      this.version,
      0,
      [],
    );
  }

  // ------------------------------------------------------- reconstitution

  /** Photograph for the registry — private, never a served shape (F3.1.11). */
  snapshot(): AccountSnapshot {
    return {
      personId: this.id,
      verificationState: this.verificationState,
      preferences: this.preferences.map((preference) => ({
        kind: preference.kind,
        value: preference.value,
      })),
      ...(this.reachability === undefined ? {} : { reachability: this.reachability }),
      devices: this.devices.map((device) => ({
        deviceId: device.deviceId,
        registeredAtMs: device.registeredAt.epochMillis,
      })),
      state:
        this.state.kind === 'Active'
          ? { kind: 'Active', registeredAtMs: this.state.registeredAt.epochMillis }
          : { kind: 'Closed', closedAtMs: this.state.closedAt.epochMillis, motive: this.state.motive },
      version: this.version,
    };
  }

  /** Reconstruction = private snapshot + delta(0) (F5.2.99). Corruption throws — never a Refusal. */
  static fromSnapshot(snapshot: AccountSnapshot): Account {
    if (snapshot.version < 1) {
      throw new AccountSnapshotCorruptException(
        `account ${snapshot.personId}: version ${snapshot.version}`,
      );
    }
    const preferences = snapshot.preferences.map((preference) => ({
      kind: preferenceKindOf(preference.kind),
      value: preferenceValueOf(preference.value),
    }));
    if (new Set(preferences.map((preference) => preference.kind)).size !== preferences.length) {
      throw new AccountSnapshotCorruptException(
        `account ${snapshot.personId}: a preference kind appears twice`,
      );
    }
    const state: AccountState =
      snapshot.state.kind === 'Active'
        ? { kind: 'Active', registeredAt: instantOf(snapshot.state.registeredAtMs) }
        : {
            kind: 'Closed',
            closedAt: instantOf(snapshot.state.closedAtMs),
            motive: snapshot.state.motive,
          };
    return new Account(
      personIdOf(snapshot.personId),
      verificationStateOf(snapshot.verificationState),
      preferences,
      snapshot.reachability === undefined ? undefined : reachabilityChannelOf(snapshot.reachability),
      snapshot.devices.map((device) => ({
        deviceId: deviceIdOf(device.deviceId),
        registeredAt: instantOf(device.registeredAtMs),
      })),
      state,
      snapshot.version,
      0,
      [],
    );
  }

  // ------------------------------------------------------------- internals

  private requireActive(verb: string): Result<void, AccountRefusal> {
    if (this.state.kind !== 'Active') {
      return err(
        accountRefusal(
          'TransitionUnavailable',
          `${verb} requires an Active account; current state is ${this.state.kind}`,
        ),
      );
    }
    return ok(undefined);
  }

  /** ONE act: version + 1, the act counted, the fact (if any) appended. */
  private next(
    changes: Partial<{
      preferences: readonly Preference[];
      reachability: ReachabilityChannel;
      devices: readonly Device[];
      state: AccountState;
    }>,
    fact?: AccountDomainEvent,
  ): Account {
    return new Account(
      this.id,
      this.verificationState,
      changes.preferences ?? this.preferences,
      changes.reachability ?? this.reachability,
      changes.devices ?? this.devices,
      changes.state ?? this.state,
      this.version + 1,
      this.unretainedActs + 1,
      fact === undefined ? this.pendingFacts : [...this.pendingFacts, fact],
    );
  }
}
