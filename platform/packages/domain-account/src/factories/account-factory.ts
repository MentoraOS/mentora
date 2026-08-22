import type { Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';

import { Account } from '../aggregate/account.js';
import { AvailabilityFrame } from '../aggregate/availability-frame.js';
import type { ChangeAvailabilityFrame, RegisterPerson } from '../commands/account-commands.js';
import type { AccountRefusal, AvailabilityFrameRefusal } from '../decisions/account-refusal.js';

/**
 * The birth doors of Lot A01 (F3.1: birth happens in the Factory, the unit's
 * constructor stays private).
 *
 * `registerPerson` (36) — the Account's birth: the entry's act; the Account
 * ACL then commands the proof to I&A with this very PersonId (A05). Birth
 * never queries the world; R-B (an inhabited identity) is the carrier's and
 * registry's business.
 *
 * `changeAvailabilityFrameBirth` (42, RFC-003 P2) — the frame has no birth
 * command: its FIRST change births it. The carrier routes: absent ⇒ this
 * door, present ⇒ `frame.change`.
 */
export const registerPerson = (command: RegisterPerson): Result<Account, AccountRefusal> =>
  ok(
    Account._born(command.personId, command.verificationState, {
      kind: 'Active',
      registeredAt: command.registeredAt,
    }),
  );

export const changeAvailabilityFrameBirth = (
  command: ChangeAvailabilityFrame,
): Result<AvailabilityFrame, AvailabilityFrameRefusal> => AvailabilityFrame._born(command);
