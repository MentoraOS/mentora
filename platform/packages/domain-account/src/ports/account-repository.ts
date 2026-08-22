import type { Option, Result, RetentionContext } from '@mentora/kernel';

import type { Account } from '../aggregate/account.js';
import type { AvailabilityFrame } from '../aggregate/availability-frame.js';
import type { AccountRefusal, AvailabilityFrameRefusal } from '../decisions/account-refusal.js';
import type { PersonId } from '../ids/identifiers.js';

/**
 * The registry ports of Lot A01 — OWNED BY THE DOMAIN (F4.4 §3), shaped
 * EXACTLY like the reference (CredentialRepository): Option for presence,
 * Result<void> for the atomic retention verdict, the OPTIONAL
 * RetentionContext of RFC-001 from birth.
 *
 * retain() is ONE atomic act (A-3): version control → facts → photo →
 * outbox. VERSION LAW of these units: +1 per act, fact or not; the expected
 * previous version is `version − unretainedActs` (the reference and every
 * real registry compute it that way; a stale expectation is a transient
 * Failure thrown, S-3 — never a Refusal). R-B (an inhabited identity at
 * birth) is refused structurally by the registry.
 */
export interface AccountRepository {
  byId(id: PersonId): Promise<Option<Account>>;
  retain(account: Account, context?: RetentionContext): Promise<Result<void, AccountRefusal>>;
}

/** The frame's identity is the person's (RFC-003 P2): byId takes the PersonId. */
export interface AvailabilityFrameRepository {
  byId(id: PersonId): Promise<Option<AvailabilityFrame>>;
  retain(
    frame: AvailabilityFrame,
    context?: RetentionContext,
  ): Promise<Result<void, AvailabilityFrameRefusal>>;
}
