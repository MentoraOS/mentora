import type { Option, Result, RetentionContext } from '@mentora/kernel';

import type { Agreement } from '../aggregate/agreement.js';
import type { AgreementRefusal } from '../decisions/agreement-refusal.js';
import type { AgreementId, ExpertId } from '../ids/identifiers.js';
import type { TimeSlot } from '../value-objects/time-slot.js';

/**
 * AgreementRepository — the registry PORT of the Agreement truth, owned by the
 * domain (F3.1: the Repository is the registry of ONE truth; the implementation
 * lives behind, replaceable). Frozen surface (F3.2-A): byId,
 * byExpertAndWindow, and retention with STRUCTURAL refusal.
 *
 * R-A, verbatim (F3.3 §10): "la règle appartient au domaine (Specification —
 * see OverlappingSlotSpecification); la clé appartient au domaine (déclarée);
 * l'application appartient au registre (structurelle, à la rétention); le
 * refus appartient à la Décision (motivée: TimeSlotUnavailable); l'infra-
 * structure exécute la clé, elle ne connaît jamais la règle."
 *
 * NOTE (mandate item 9, signaled): no Clock/Identity port here — time and
 * identity are INJECTED by the Application layer (F4.1 A-6; the kernel already
 * owns the Clock/IdGenerator port contracts); the clock never enters the unit
 * (F3.1.99 §5). The domain owns exactly ONE port: this registry.
 */
export interface AgreementRepository {
  /** Load by Identifier — nothing else; no business search (R-A). */
  byId(id: AgreementId): Promise<Option<Agreement>>;

  /** The declared R-A walk: confirmed agreements of an expert over a window. */
  byExpertAndWindow(expertId: ExpertId, window: TimeSlot): Promise<readonly Agreement[]>;

  /**
   * Atomic retention (pas 8): state + pending facts in ONE registry act; the
   * declared unique key (expert × overlapping confirmed slot) is applied
   * structurally and refused as a motivated Decision — TimeSlotUnavailable —
   * never an exception (F3.2-A, R-A). The OPTIONAL context is RFC-001
   * (Option A, RATIFIED 2026-08-18): envelope values the Outbox de faits
   * transports when they exist — never domain truth, never required.
   */
  retain(agreement: Agreement, context?: RetentionContext): Promise<Result<void, AgreementRefusal>>;
}
