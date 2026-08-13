import type { Instant, Result } from '@mentora/kernel';
import { err, instantOf, ok } from '@mentora/kernel';

import type {
  AcceptAgreement,
  CancelAgreement,
  ConfirmAgreement,
  ElapseAgreement,
  LapseAgreementRequest,
  RejectAgreement,
  RescheduleAgreement,
} from '../commands/agreement-commands.js';
import type { AgreementRefusal } from '../decisions/agreement-refusal.js';
import { agreementRefusal } from '../decisions/agreement-refusal.js';
import { AgreementSnapshotCorruptException } from '../errors/agreement-exceptions.js';
import type { AgreementId, ClientId, ExpertId } from '../ids/identifiers.js';
import { agreementIdOf, clientIdOf, expertIdOf, offerIdOf } from '../ids/identifiers.js';
import type { AgreementCancellationPolicy } from '../policies/agreement-cancellation.policy.js';
import type { ReschedulePolicy } from '../policies/reschedule.policy.js';
import type {
  AgreementSnapshot,
  AgreementSnapshotParty,
  AgreementSnapshotSlot,
} from '../snapshots/agreement-snapshot.js';
import { ConfirmableAgreementSpecification } from '../specifications/confirmable-agreement.specification.js';
import type { AgreementConditions } from '../value-objects/agreement-conditions.js';
import { agreementConditionsOf } from '../value-objects/agreement-conditions.js';
import type { AgreementParty } from '../value-objects/agreement-party.js';
import type { AgreementState } from '../value-objects/agreement-state.js';
import { isTerminalState } from '../value-objects/agreement-state.js';
import type { CancellationRecord } from '../value-objects/cancellation-record.js';
import type { RescheduleRecord } from '../value-objects/reschedule-record.js';
import type { TimeSlot } from '../value-objects/time-slot.js';
import { timeSlotOf } from '../value-objects/time-slot.js';

import type { AgreementDomainEvent } from './agreement-domain-event.js';

/**
 * Agreement — the executable incarnation of the NO-holder for the truth
 * "l'accord d'un moment entre un Client et un Expert" (F2.5 §2, F3.2-A
 * Domaine 3 — Engagement).
 *
 * Constitutional posture (F3.1, amended F3.1.99):
 * - ONE unit of the truth; the smallest frontier that keeps its invariant true.
 * - Born at the Demande ("la demande est sa jeunesse; la scission est
 *   interdite") — birth happens in the AgreementFactory.
 * - Every mutation carries a dictionary verb (a Command), yields a motivated
 *   Decision, and gives birth to its fact — NO public setter, no silent
 *   mutation (F3.1.99 §3). Implemented immutably: a successful decision
 *   returns a NEW Agreement carrying the newborn fact in `pendingFacts`.
 * - The clock never enters the unit: every deadline is judged on an instant
 *   RECEIVED as data (F3.1.99 §5).
 * - Facts are born inside, retained atomically with state by the registry
 *   (pas 8), and published AFTER retention by the Application layer (F4.1
 *   A-3/A-4) — the unit only CARRIES them.
 * - Terminal states are irreversible (R-B): coming back is a NEW Demande.
 * - The inter-unit invariant (no two Confirmed agreements for the same expert
 *   on overlapping slots) is the DECLARED R-A KEY: the rule lives here (see
 *   OverlappingSlotSpecification), the key is applied structurally by the
 *   registry at retention, refusing with TimeSlotUnavailable (F3.2-A, R-A).
 */
export class Agreement {
  private constructor(
    readonly id: AgreementId,
    readonly clientId: ClientId,
    readonly expertId: ExpertId,
    readonly conditions: AgreementConditions,
    readonly slot: TimeSlot,
    readonly state: AgreementState,
    readonly reschedules: readonly RescheduleRecord[],
    /** Optimistic-concurrency version (F5.2 §4); increments with every fact. */
    readonly version: number,
    /** Facts born and not yet retained — pulled by the Application layer. */
    readonly pendingFacts: readonly AgreementDomainEvent[],
  ) {}

  // ------------------------------------------------------------------ birth

  /**
   * INTERNAL to the domain: called by AgreementFactory only (the Factory is
   * the birth door, F3.1). Arms the first fact; the unit carries it.
   */
  static _born(
    id: AgreementId,
    clientId: ClientId,
    expertId: ExpertId,
    conditions: AgreementConditions,
    slot: TimeSlot,
    requestedAt: Instant,
  ): Agreement {
    return new Agreement(
      id,
      clientId,
      expertId,
      conditions,
      slot,
      { kind: 'Requested', requestedAt },
      [],
      1,
      [
        {
          type: 'AgreementRequested',
          agreementId: id,
          sequence: 1,
          instant: requestedAt,
          clientId,
          expertId,
          offerId: conditions.offerId,
          slot,
        },
      ],
    );
  }

  // ------------------------------------------------------- frozen machine

  /** Expert accepts the Demande: Requested → Accepted. */
  accept(command: AcceptAgreement): Result<Agreement, AgreementRefusal> {
    if (this.state.kind !== 'Requested') {
      return this.transitionUnavailable('accept', 'Requested');
    }
    return ok(
      this.evolve({ kind: 'Accepted', acceptedAt: command.instant }, this.slot, this.reschedules, {
        type: 'AgreementAccepted',
        agreementId: this.id,
        sequence: this.version + 1,
        instant: command.instant,
        expertId: command.expertId,
      }),
    );
  }

  /** Expert rejects the Demande: Requested → Rejected (terminal). */
  reject(command: RejectAgreement): Result<Agreement, AgreementRefusal> {
    if (this.state.kind !== 'Requested') {
      return this.transitionUnavailable('reject', 'Requested');
    }
    return ok(
      this.evolve({ kind: 'Rejected', rejectedAt: command.instant }, this.slot, this.reschedules, {
        type: 'AgreementRejected',
        agreementId: this.id,
        sequence: this.version + 1,
        instant: command.instant,
        expertId: command.expertId,
      }),
    );
  }

  /**
   * Commissioner confirms: Accepted → Confirmed. "L'Acceptation précède toute
   * Confirmation" [T]; "Nulle Confirmation sans conditions accomplies,
   * encaissement compris" [É] (F2.6) — the ConfirmableAgreementSpecification
   * is applied by the unit itself (F3.1 matrix: the Aggregate applies Specs).
   */
  confirm(command: ConfirmAgreement): Result<Agreement, AgreementRefusal> {
    const confirmable = new ConfirmableAgreementSpecification();
    if (!confirmable.isSatisfiedBy(this.state, command.settlementReference)) {
      if (this.state.kind !== 'Accepted') {
        return this.transitionUnavailable('confirm', 'Accepted');
      }
      return err(
        agreementRefusal(
          'ConfirmationConditionsMissing',
          'No Confirmation without accomplished conditions, settlement included (F2.6)',
        ),
      );
    }
    return ok(
      this.evolve(
        {
          kind: 'Confirmed',
          confirmedAt: command.instant,
          settlementReference: command.settlementReference,
        },
        this.slot,
        this.reschedules,
        {
          type: 'AgreementConfirmed',
          agreementId: this.id,
          sequence: this.version + 1,
          instant: command.instant,
          settlementReference: command.settlementReference,
        },
      ),
    );
  }

  /**
   * A party reschedules: Confirmed ⇄ Confirmed, under the published
   * ReschedulePolicy (the Aggregate applies the Policy — F3.1 matrix).
   */
  reschedule(
    command: RescheduleAgreement,
    policy: ReschedulePolicy,
  ): Result<Agreement, AgreementRefusal> {
    if (this.state.kind !== 'Confirmed') {
      return this.transitionUnavailable('reschedule', 'Confirmed');
    }
    const admitted = policy.decide(this.slot.start, command.instant, this.reschedules.length);
    if (!admitted.ok) {
      return admitted;
    }
    const record: RescheduleRecord = {
      previousSlot: this.slot,
      newSlot: command.newSlot,
      requestedBy: command.requestedBy,
      instant: command.instant,
    };
    return ok(
      this.evolve(this.state, command.newSlot, [...this.reschedules, record], {
        type: 'AgreementRescheduled',
        agreementId: this.id,
        sequence: this.version + 1,
        instant: command.instant,
        record,
      }),
    );
  }

  /**
   * A party cancels: Confirmed → Cancelled (terminal). "Toute Annulation porte
   * son Auteur et subit les règles publiées" (F2.6) — the record carries
   * CancelledBy; the published AgreementCancellationPolicy decides.
   */
  cancel(
    command: CancelAgreement,
    policy: AgreementCancellationPolicy,
  ): Result<Agreement, AgreementRefusal> {
    if (this.state.kind !== 'Confirmed') {
      return this.transitionUnavailable('cancel', 'Confirmed');
    }
    const admitted = policy.decide(this.slot.start, command.instant);
    if (!admitted.ok) {
      return admitted;
    }
    const record: CancellationRecord = {
      cancelledBy: command.cancelledBy,
      instant: command.instant,
      motive: command.motive,
    };
    return ok(
      this.evolve({ kind: 'Cancelled', record }, this.slot, this.reschedules, {
        type: 'AgreementCancelled',
        agreementId: this.id,
        sequence: this.version + 1,
        instant: command.instant,
        record,
      }),
    );
  }

  /**
   * Time tooling: the Demande lapses (Caducité) — Requested|Accepted → Lapsed
   * (terminal). The instant is PROVIDED; the unit judges it, never reads it.
   */
  lapseRequest(command: LapseAgreementRequest): Result<Agreement, AgreementRefusal> {
    if (this.state.kind !== 'Requested' && this.state.kind !== 'Accepted') {
      return this.transitionUnavailable('lapseRequest', 'Requested|Accepted');
    }
    return ok(
      this.evolve({ kind: 'Lapsed', lapsedAt: command.instant }, this.slot, this.reschedules, {
        type: 'AgreementRequestLapsed',
        agreementId: this.id,
        sequence: this.version + 1,
        instant: command.instant,
      }),
    );
  }

  /** Time tooling: the Échéance — Confirmed → Elapsed (terminal). */
  elapse(command: ElapseAgreement): Result<Agreement, AgreementRefusal> {
    if (this.state.kind !== 'Confirmed') {
      return this.transitionUnavailable('elapse', 'Confirmed');
    }
    return ok(
      this.evolve({ kind: 'Elapsed', elapsedAt: command.instant }, this.slot, this.reschedules, {
        type: 'AgreementElapsed',
        agreementId: this.id,
        sequence: this.version + 1,
        instant: command.instant,
      }),
    );
  }

  // ------------------------------------------------------------ reconstitution

  /** After atomic retention (pas 8), the registry gets a fact-free instance. */
  retained(): Agreement {
    return new Agreement(
      this.id,
      this.clientId,
      this.expertId,
      this.conditions,
      this.slot,
      this.state,
      this.reschedules,
      this.version,
      [],
    );
  }

  /** PRIVATE TO THE REGISTRY (F3.1.11): the reconstitution photograph. */
  toSnapshot(): AgreementSnapshot {
    return {
      agreementId: this.id,
      clientId: this.clientId,
      expertId: this.expertId,
      offerId: this.conditions.offerId,
      slot: { startMs: this.slot.start.epochMillis, endMs: this.slot.end.epochMillis },
      state: snapshotStateOf(this.state),
      reschedules: this.reschedules.map((r) => ({
        previousSlot: { startMs: r.previousSlot.start.epochMillis, endMs: r.previousSlot.end.epochMillis },
        newSlot: { startMs: r.newSlot.start.epochMillis, endMs: r.newSlot.end.epochMillis },
        requestedBy: partySnapshotOf(r.requestedBy),
        instantMs: r.instant.epochMillis,
      })),
      version: this.version,
    };
  }

  /** PRIVATE TO THE REGISTRY: reconstitution — never re-constates the past. */
  static fromSnapshot(snapshot: AgreementSnapshot): Agreement {
    return new Agreement(
      agreementIdOf(snapshot.agreementId),
      clientIdOf(snapshot.clientId),
      expertIdOf(snapshot.expertId),
      agreementConditionsOf(offerIdOf(snapshot.offerId)),
      slotFromSnapshot(snapshot.slot),
      stateFromSnapshot(snapshot),
      snapshot.reschedules.map((r) => ({
        previousSlot: slotFromSnapshot(r.previousSlot),
        newSlot: slotFromSnapshot(r.newSlot),
        requestedBy: partyFromSnapshot(r.requestedBy),
        instant: instantOf(r.instantMs),
      })),
      snapshot.version,
      [],
    );
  }

  // ------------------------------------------------------------------ internals

  get isTerminal(): boolean {
    return isTerminalState(this.state);
  }

  private evolve(
    state: AgreementState,
    slot: TimeSlot,
    reschedules: readonly RescheduleRecord[],
    fact: AgreementDomainEvent,
  ): Agreement {
    return new Agreement(
      this.id,
      this.clientId,
      this.expertId,
      this.conditions,
      slot,
      state,
      reschedules,
      this.version + 1,
      [...this.pendingFacts, fact],
    );
  }

  private transitionUnavailable(
    act: string,
    expected: string,
  ): Result<Agreement, AgreementRefusal> {
    return err(
      agreementRefusal(
        'TransitionUnavailable',
        `Cannot ${act} an Agreement in state ${this.state.kind} (requires ${expected}); ` +
          'terminal states are irreversible — coming back is a NEW Demande (R-B)',
      ),
    );
  }
}

// ----------------------------------------------------------- snapshot mapping

const snapshotStateOf = (state: AgreementState): AgreementSnapshot['state'] => {
  switch (state.kind) {
    case 'Requested':
      return { kind: 'Requested', atMs: state.requestedAt.epochMillis };
    case 'Accepted':
      return { kind: 'Accepted', atMs: state.acceptedAt.epochMillis };
    case 'Confirmed':
      return {
        kind: 'Confirmed',
        atMs: state.confirmedAt.epochMillis,
        settlementReference: state.settlementReference,
      };
    case 'Rejected':
      return { kind: 'Rejected', atMs: state.rejectedAt.epochMillis };
    case 'Lapsed':
      return { kind: 'Lapsed', atMs: state.lapsedAt.epochMillis };
    case 'Cancelled':
      return {
        kind: 'Cancelled',
        atMs: state.record.instant.epochMillis,
        cancelledBy: partySnapshotOf(state.record.cancelledBy),
        motive: state.record.motive,
      };
    case 'Elapsed':
      return { kind: 'Elapsed', atMs: state.elapsedAt.epochMillis };
  }
};

const partySnapshotOf = (party: AgreementParty): AgreementSnapshotParty =>
  party.role === 'Client'
    ? { role: 'Client', id: party.clientId }
    : { role: 'Expert', id: party.expertId };

const partyFromSnapshot = (party: AgreementSnapshotParty): AgreementParty =>
  party.role === 'Client'
    ? { role: 'Client', clientId: clientIdOf(party.id) }
    : { role: 'Expert', expertId: expertIdOf(party.id) };

const slotFromSnapshot = (slot: AgreementSnapshotSlot): TimeSlot => {
  const restored = timeSlotOf(instantOf(slot.startMs), instantOf(slot.endMs));
  if (!restored.ok) {
    throw new AgreementSnapshotCorruptException('Snapshot slot bounds are invalid');
  }
  return restored.value;
};

const stateFromSnapshot = (snapshot: AgreementSnapshot): AgreementState => {
  const s = snapshot.state;
  switch (s.kind) {
    case 'Requested':
      return { kind: 'Requested', requestedAt: instantOf(s.atMs) };
    case 'Accepted':
      return { kind: 'Accepted', acceptedAt: instantOf(s.atMs) };
    case 'Confirmed':
      return {
        kind: 'Confirmed',
        confirmedAt: instantOf(s.atMs),
        settlementReference: s.settlementReference,
      };
    case 'Rejected':
      return { kind: 'Rejected', rejectedAt: instantOf(s.atMs) };
    case 'Lapsed':
      return { kind: 'Lapsed', lapsedAt: instantOf(s.atMs) };
    case 'Cancelled':
      return {
        kind: 'Cancelled',
        record: {
          cancelledBy: partyFromSnapshot(s.cancelledBy),
          instant: instantOf(s.atMs),
          motive: s.motive,
        },
      };
    case 'Elapsed':
      return { kind: 'Elapsed', elapsedAt: instantOf(s.atMs) };
    default: {
      throw new AgreementSnapshotCorruptException(
        `Unknown snapshot state kind: ${JSON.stringify(s)}`,
      );
    }
  }
};
