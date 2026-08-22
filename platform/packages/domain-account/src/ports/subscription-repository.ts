import type { Option, Result, RetentionContext } from '@mentora/kernel';

import type { Subscription } from '../aggregate/subscription.js';
import type { SupportRequest } from '../aggregate/support-request.js';
import type { SubscriptionRefusal, SupportRequestRefusal } from '../decisions/account-refusal.js';
import type { PersonId, SubscriptionId, SupportRequestId } from '../ids/identifiers.js';

/**
 * The registry ports of Lot A02 — OWNED BY THE DOMAIN (F4.4 §3), the
 * reference shape (Option / Result<void> / optional RetentionContext).
 *
 * SubscriptionRepository applies the DECLARED R-A key at retention (one
 * ACTIVE subscription per holder) and refuses it as the motivated Decision
 * `SubscriptionAlreadyExists`; `activeByHolder` is the key's PROBE surface
 * (the declared walk), never a search.
 *
 * SupportRequestRepository retains STATE ONLY: the unit has no facts, so
 * no Outbox de faits is ever touched — the contract suite asserts it and
 * the Lot A04 schema proves it by ABSENCE of tables (precedent: Session).
 * Version law: +1 per act, expected previous = version − unretainedActs.
 */
export interface SubscriptionRepository {
  byId(id: SubscriptionId): Promise<Option<Subscription>>;
  /** The R-A probe: the ACTIVE subscription of a holder, if any. */
  activeByHolder(personId: PersonId): Promise<Option<Subscription>>;
  retain(
    subscription: Subscription,
    context?: RetentionContext,
  ): Promise<Result<void, SubscriptionRefusal>>;
}

export interface SupportRequestRepository {
  byId(id: SupportRequestId): Promise<Option<SupportRequest>>;
  retain(
    request: SupportRequest,
    context?: RetentionContext,
  ): Promise<Result<void, SupportRequestRefusal>>;
}
