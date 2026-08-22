import type { Result } from '@mentora/kernel';
import { err, instantOf, ok } from '@mentora/kernel';

import type { HandleSupportRequest, OpenSupportRequest } from '../commands/subscription-commands.js';
import type { SupportRequestRefusal } from '../decisions/account-refusal.js';
import { supportRequestRefusal } from '../decisions/account-refusal.js';
import { SupportRequestSnapshotCorruptException } from '../errors/account-exceptions.js';
import type { PersonId, SupportRequestId } from '../ids/identifiers.js';
import { personIdOf, supportRequestIdOf } from '../ids/identifiers.js';
import type { SupportRequestSnapshot } from '../snapshots/account-snapshot.js';
import type { SupportRequestState } from '../value-objects/subscription-state.js';

/**
 * SupportRequest — "promu Aggregate par le test du NON clandestin (le
 * Requester l'ouvre, la plateforme la traite et la clôt)" (canon F3.2-B).
 * States `Opened → Handled` (terminal). **Aucun fait publié** ("droit, pas
 * devoir ; les dialogues d'aide sont des Conversations") — STRUCTURALLY,
 * exactly like the Session of the reference domain: this class has NO
 * `pendingFacts` field, so nothing it holds can ever reach an Outbox; the
 * key-surface test locks it. The motive is a REFERENCE — no content of the
 * help dialogue ever lives here (that is Messaging's).
 *
 * Version law of the context: +1 per act, `unretainedActs` for the
 * registry (state-only retention, Lot A04: a photograph and nothing else).
 */
export class SupportRequest {
  private constructor(
    readonly id: SupportRequestId,
    /** The SupportRequester — a qualified actor reference. */
    readonly requesterId: PersonId,
    readonly motive: string,
    readonly state: SupportRequestState,
    readonly version: number,
    readonly unretainedActs: number,
  ) {}

  /** INTERNAL: the birth door (F3.1) — `OpenSupportRequest` (45). */
  static _born(command: OpenSupportRequest): SupportRequest {
    return new SupportRequest(
      command.supportRequestId,
      command.requesterId,
      command.motive,
      { kind: 'Opened', openedAt: command.openedAt },
      1,
      1,
    );
  }

  /** 46 — the platform handles and closes; terminal. */
  handle(command: HandleSupportRequest): Result<SupportRequest, SupportRequestRefusal> {
    if (this.state.kind !== 'Opened') {
      return err(
        supportRequestRefusal(
          'TransitionUnavailable',
          `handle requires an Opened request; current state is ${this.state.kind}`,
        ),
      );
    }
    return ok(
      new SupportRequest(
        this.id,
        this.requesterId,
        this.motive,
        { kind: 'Handled', handledAt: command.handledAt },
        this.version + 1,
        this.unretainedActs + 1,
      ),
    );
  }

  retained(): SupportRequest {
    return new SupportRequest(this.id, this.requesterId, this.motive, this.state, this.version, 0);
  }

  snapshot(): SupportRequestSnapshot {
    return {
      supportRequestId: this.id,
      requesterId: this.requesterId,
      motive: this.motive,
      state:
        this.state.kind === 'Opened'
          ? { kind: 'Opened', openedAtMs: this.state.openedAt.epochMillis }
          : { kind: 'Handled', handledAtMs: this.state.handledAt.epochMillis },
      version: this.version,
    };
  }

  static fromSnapshot(snapshot: SupportRequestSnapshot): SupportRequest {
    if (snapshot.version < 1 || snapshot.motive.trim() === '') {
      throw new SupportRequestSnapshotCorruptException(
        `support request ${snapshot.supportRequestId}: version ${snapshot.version} or blank motive`,
      );
    }
    const state: SupportRequestState =
      snapshot.state.kind === 'Opened'
        ? { kind: 'Opened', openedAt: instantOf(snapshot.state.openedAtMs) }
        : { kind: 'Handled', handledAt: instantOf(snapshot.state.handledAtMs) };
    return new SupportRequest(
      supportRequestIdOf(snapshot.supportRequestId),
      personIdOf(snapshot.requesterId),
      snapshot.motive,
      state,
      snapshot.version,
      0,
    );
  }
}
