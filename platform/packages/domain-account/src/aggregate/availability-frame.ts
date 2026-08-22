import type { Result } from '@mentora/kernel';
import { err, instantOf, ok } from '@mentora/kernel';

import type { ChangeAvailabilityFrame } from '../commands/account-commands.js';
import type { AvailabilityFrameRefusal } from '../decisions/account-refusal.js';
import { availabilityFrameRefusal } from '../decisions/account-refusal.js';
import { AvailabilityFrameSnapshotCorruptException } from '../errors/account-exceptions.js';
import type { PersonId } from '../ids/identifiers.js';
import { personIdOf } from '../ids/identifiers.js';
import type { AvailabilityFrameSnapshot } from '../snapshots/account-snapshot.js';
import { CoherentFrameSpecification } from '../specifications/coherent-frame.specification.js';
import type { AvailabilityWindow } from '../value-objects/availability-window.js';

import type { AvailabilityFrameDomainEvent } from './account-domain-event.js';

/**
 * AvailabilityFrame — "le Cadre au Compte" (canon F3.2-B): a unit of its own,
 * ALIVE (no terminal state — catalogue §8 lists no machine for it), whose
 * only invariant is coherence of its windows. The Engagement consumes it AS
 * DATA (loi 15) and the public reads it through `AvailabilityFrameQuery`
 * (ayant droit : tous) — the domain never exits, the photograph does.
 *
 * RFC-003 P2 (ratified): singleton-par-Compte — its identity IS the
 * PersonId; it is BORN at its first `ChangeAvailabilityFrame` (the factory
 * door is implicit in the carrier: absent ⇒ birth, present ⇒ change). ONE
 * fact, `AvailabilityFrameChanged`, for birth and change alike — the
 * catalogue ratifies no other. Version +1 per act, one act per fact.
 */
export class AvailabilityFrame {
  private static readonly coherent = new CoherentFrameSpecification();

  private constructor(
    readonly id: PersonId,
    readonly windows: readonly AvailabilityWindow[],
    readonly version: number,
    readonly unretainedActs: number,
    readonly pendingFacts: readonly AvailabilityFrameDomainEvent[],
  ) {}

  /** INTERNAL: the factory's door — the first change IS the birth (RFC-003 P2). */
  static _born(command: ChangeAvailabilityFrame): Result<AvailabilityFrame, AvailabilityFrameRefusal> {
    if (!AvailabilityFrame.coherent.isSatisfiedBy(command.windows)) {
      return err(AvailabilityFrame.incoherent());
    }
    return ok(
      new AvailabilityFrame(command.personId, command.windows, 1, 1, [
        {
          type: 'AvailabilityFrameChanged',
          personId: command.personId,
          sequence: 1,
          instant: command.changedAt,
          windows: command.windows,
        },
      ]),
    );
  }

  /** 42 — the whole frame is replaced by a coherent set (a fact). */
  change(command: ChangeAvailabilityFrame): Result<AvailabilityFrame, AvailabilityFrameRefusal> {
    if (!AvailabilityFrame.coherent.isSatisfiedBy(command.windows)) {
      return err(AvailabilityFrame.incoherent());
    }
    return ok(
      new AvailabilityFrame(this.id, command.windows, this.version + 1, this.unretainedActs + 1, [
        ...this.pendingFacts,
        {
          type: 'AvailabilityFrameChanged',
          personId: this.id,
          sequence: this.version + 1,
          instant: command.changedAt,
          windows: command.windows,
        },
      ]),
    );
  }

  retained(): AvailabilityFrame {
    return new AvailabilityFrame(this.id, this.windows, this.version, 0, []);
  }

  snapshot(): AvailabilityFrameSnapshot {
    return {
      personId: this.id,
      windows: this.windows.map((window) => ({
        startMs: window.start.epochMillis,
        endMs: window.end.epochMillis,
      })),
      version: this.version,
    };
  }

  /** Reconstruction = private snapshot + delta(0). An incoherent photograph is corruption. */
  static fromSnapshot(snapshot: AvailabilityFrameSnapshot): AvailabilityFrame {
    const windows = snapshot.windows.map((window) => ({
      start: instantOf(window.startMs),
      end: instantOf(window.endMs),
    }));
    if (snapshot.version < 1 || !AvailabilityFrame.coherent.isSatisfiedBy(windows)) {
      throw new AvailabilityFrameSnapshotCorruptException(
        `availability frame ${snapshot.personId}: version ${snapshot.version} or incoherent windows`,
      );
    }
    return new AvailabilityFrame(personIdOf(snapshot.personId), windows, snapshot.version, 0, []);
  }

  private static incoherent(): AvailabilityFrameRefusal {
    return availabilityFrameRefusal(
      'WindowUnavailable',
      'The windows are not coherent: each must start before it ends and none may overlap (CoherentFrameSpecification)',
    );
  }
}
