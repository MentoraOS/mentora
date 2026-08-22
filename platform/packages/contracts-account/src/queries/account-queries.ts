import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import type { PersonId } from '../identifiers.js';
import type { AccountContractViolation } from '../validation/account-command-validation.js';

/**
 * The TWO ratified Account lectures (catalogue 03 des lectures: n°4
 * `AvailabilityFrameQuery` — ayant droit : tous, le cadre publié ; n°10
 * `ReachabilityQuery` — la Notification (sanctionnée) + le Titulaire).
 * Precedent: contracts-agreement/queries. The rights grid is applied by
 * the reader's Séquence de Lecture (R-C), never here. Read-only. No other
 * Account read exists: the assembled profile is a projection of the
 * Discovery, not a Query of the Account.
 */

export interface AvailabilityFrameQuery {
  readonly contractVersion: 1;
  readonly type: 'AvailabilityFrameQuery';
  readonly personId: PersonId;
}

export interface ReachabilityQuery {
  readonly contractVersion: 1;
  readonly type: 'ReachabilityQuery';
  readonly personId: PersonId;
}

export type AccountQueryContract = AvailabilityFrameQuery | ReachabilityQuery;

export const ACCOUNT_QUERY_TYPES = ['AvailabilityFrameQuery', 'ReachabilityQuery'] as const;

/** "Le cadre publié" — the windows ⊘ everything else of the Account. */
export interface AvailabilityFrameResponse {
  readonly contractVersion: 1;
  readonly type: 'AvailabilityFrameResponse';
  readonly personId: PersonId;
  readonly windows: readonly { readonly startMs: number; readonly endMs: number }[];
  readonly version: number;
}

/** "La joignabilité" — the channel ⊘ preferences, devices; absent until first set. */
export interface ReachabilityResponse {
  readonly contractVersion: 1;
  readonly type: 'ReachabilityResponse';
  readonly personId: PersonId;
  readonly channel?: string;
}

const violation = (code: string, field: string, message: string): AccountContractViolation => ({
  code,
  field,
  message,
});

export const validateAccountQuery = (
  payload: unknown,
): Result<AccountQueryContract, readonly AccountContractViolation[]> => {
  if (typeof payload !== 'object' || payload === null) {
    return err([violation('CONTRACT.MALFORMED', '$', 'payload must be an object')]);
  }
  const record = payload as Record<string, unknown>;
  const type = record['type'];
  if (typeof type !== 'string' || !(ACCOUNT_QUERY_TYPES as readonly string[]).includes(type)) {
    return err([
      violation(
        'CONTRACT.UNKNOWN_CONTRACT',
        'type',
        `type must be one of: ${ACCOUNT_QUERY_TYPES.join(', ')}`,
      ),
    ]);
  }
  const violations: AccountContractViolation[] = [];
  if (record['contractVersion'] !== 1) {
    violations.push(violation('CONTRACT.UNKNOWN_GENERATION', 'contractVersion', 'must be 1'));
  }
  if (typeof record['personId'] !== 'string' || record['personId'].trim() === '') {
    violations.push(violation('CONTRACT.MALFORMED', 'personId', 'must be a non-blank string'));
  }
  return violations.length > 0 ? err(violations) : ok(payload as AccountQueryContract);
};
