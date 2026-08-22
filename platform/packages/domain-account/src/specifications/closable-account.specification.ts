import type { Account } from '../aggregate/account.js';

/**
 * ClosableAccountSpecification — the NAMED question of `CloseAccount`
 * (catalogue des specifications: `ClosableAccount`). The canon states the
 * machine (`Active → Closed`) and the regret rule (UX-06: the confirmation
 * is BEFORE the fact; the domain knows only the confirmed act) — it names
 * no further condition. Reading recorded: an account is closable iff it is
 * Active; the commercial consequences are the sisters' business by
 * choreography (RFC-003 P3), never a precondition here.
 */
export class ClosableAccountSpecification {
  isSatisfiedBy(account: Account): boolean {
    return account.state.kind === 'Active';
  }
}
