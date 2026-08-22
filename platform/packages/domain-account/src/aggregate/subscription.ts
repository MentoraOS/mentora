import type { Result } from '@mentora/kernel';
import { err, instantOf, ok } from '@mentora/kernel';

import type { EndSubscription, StartSubscription } from '../commands/subscription-commands.js';
import type { SubscriptionRefusal } from '../decisions/account-refusal.js';
import { subscriptionRefusal } from '../decisions/account-refusal.js';
import { SubscriptionSnapshotCorruptException } from '../errors/account-exceptions.js';
import type { PersonId, SubscriptionId } from '../ids/identifiers.js';
import { personIdOf, subscriptionIdOf } from '../ids/identifiers.js';
import type { SubscriptionSnapshot } from '../snapshots/account-snapshot.js';
import { SubscriptionChangeSpecification } from '../specifications/subscription-change.specification.js';
import type { SubscriptionState } from '../value-objects/subscription-state.js';

import type { SubscriptionDomainEvent } from './subscription-domain-event.js';

/**
 * Subscription — the commercial contract of the holder (canon F3.2-B: "une
 * unité propre : cycle Active → Ended, Commissioner du Règlement via l'ACL
 * du Compte ; invariant : une souscription active à la fois (clé R-A)";
 * règle du contrat commercial: a unit because it has a lifecycle and
 * refusals of its own).
 *
 * Constitutional posture:
 * - Frozen machine `Active → Ended` (terminal); R-B: re-subscribing is a
 *   NEW unit. RFC-003 P4: Active AT start — the Settlement's failure
 *   reaches it as a reaction that ends it (Lot A03), never a `Pending`.
 * - THE R-A KEY, DECLARED by ActiveSubscriptionUniquenessSpecification,
 *   APPLIED by the registry at retention, refused as
 *   `SubscriptionAlreadyExists`.
 * - The terms are frozen BY REFERENCE (`offerReference`): no price, no
 *   amount ever lives here — the Settlement translates through the ACL.
 * - Two facts (catalogue 45-46); version law of the context: +1 per act,
 *   `unretainedActs` for the registry's expected-previous delta.
 */
export class Subscription {
  private static readonly changeable = new SubscriptionChangeSpecification();

  private constructor(
    readonly id: SubscriptionId,
    /** The holder — the Account's identity; the Commissioner of the Settlement. */
    readonly personId: PersonId,
    readonly offerReference: string,
    readonly state: SubscriptionState,
    readonly version: number,
    readonly unretainedActs: number,
    readonly pendingFacts: readonly SubscriptionDomainEvent[],
  ) {}

  /** INTERNAL: the SubscriptionFactory's door (F3.1). */
  static _born(command: StartSubscription): Subscription {
    return new Subscription(
      command.subscriptionId,
      command.personId,
      command.offerReference,
      { kind: 'Active', startedAt: command.startedAt },
      1,
      1,
      [
        {
          type: 'SubscriptionStarted',
          subscriptionId: command.subscriptionId,
          sequence: 1,
          instant: command.startedAt,
          personId: command.personId,
          offerReference: command.offerReference,
        },
      ],
    );
  }

  /** 44 — terminal; by the holder, by the AccountClosed choreography (P3) or by the Settlement's failure (P4). */
  end(command: EndSubscription): Result<Subscription, SubscriptionRefusal> {
    if (!Subscription.changeable.isSatisfiedBy(this)) {
      return err(
        subscriptionRefusal(
          'TransitionUnavailable',
          `end requires an Active subscription; current state is ${this.state.kind}`,
        ),
      );
    }
    return ok(
      new Subscription(
        this.id,
        this.personId,
        this.offerReference,
        { kind: 'Ended', endedAt: command.endedAt, motive: command.motive },
        this.version + 1,
        this.unretainedActs + 1,
        [
          ...this.pendingFacts,
          {
            type: 'SubscriptionEnded',
            subscriptionId: this.id,
            sequence: this.version + 1,
            instant: command.endedAt,
            motive: command.motive,
          },
        ],
      ),
    );
  }

  retained(): Subscription {
    return new Subscription(this.id, this.personId, this.offerReference, this.state, this.version, 0, []);
  }

  snapshot(): SubscriptionSnapshot {
    return {
      subscriptionId: this.id,
      personId: this.personId,
      offerReference: this.offerReference,
      state:
        this.state.kind === 'Active'
          ? { kind: 'Active', startedAtMs: this.state.startedAt.epochMillis }
          : { kind: 'Ended', endedAtMs: this.state.endedAt.epochMillis, motive: this.state.motive },
      version: this.version,
    };
  }

  static fromSnapshot(snapshot: SubscriptionSnapshot): Subscription {
    if (snapshot.version < 1 || snapshot.offerReference.trim() === '') {
      throw new SubscriptionSnapshotCorruptException(
        `subscription ${snapshot.subscriptionId}: version ${snapshot.version} or blank offer`,
      );
    }
    const state: SubscriptionState =
      snapshot.state.kind === 'Active'
        ? { kind: 'Active', startedAt: instantOf(snapshot.state.startedAtMs) }
        : { kind: 'Ended', endedAt: instantOf(snapshot.state.endedAtMs), motive: snapshot.state.motive };
    return new Subscription(
      subscriptionIdOf(snapshot.subscriptionId),
      personIdOf(snapshot.personId),
      snapshot.offerReference,
      state,
      snapshot.version,
      0,
      [],
    );
  }
}
