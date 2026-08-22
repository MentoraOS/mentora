import type { Result } from '@mentora/kernel';
import { ok } from '@mentora/kernel';

import type {
  SettlementAclPort,
  SettlementAclViolation,
  SettlementOrderRequest,
} from './settlement-acl.port.js';

/**
 * DevelopmentNoSettlementAdapter — PROVISIONAL, by CTO order (Sprint 7):
 * "explicitement identifié comme provisoire ; échoue immédiatement hors
 * environnement de développement ; ne masque jamais l'absence du domaine
 * Settlement".
 *
 * - Its name is a declaration, read by the composition and reported at
 *   boot: `development-no-settlement (PROVISIONAL)`.
 * - Constructing it outside `development` THROWS: a non-dev Root cannot be
 *   assembled with it (fail closed, F4.4 §7 — pas de démarrage).
 * - It commissions nothing: every order is RECORDED in its ledger (readable
 *   by tests and operators) and acknowledged — the absence is visible, never
 *   simulated: no report is ever produced, so no Subscription is ever ended
 *   by a Settlement that does not exist.
 */
export const DEVELOPMENT_NO_SETTLEMENT = 'development-no-settlement (PROVISIONAL)';

export class DevelopmentNoSettlementAdapter implements SettlementAclPort {
  readonly adapterName = DEVELOPMENT_NO_SETTLEMENT;
  private readonly ledger: SettlementOrderRequest[] = [];

  constructor(environment: string) {
    if (environment !== 'development') {
      throw new Error(
        `DevelopmentNoSettlementAdapter is PROVISIONAL and refuses to exist in '${environment}' — the Settlement domain is absent; provide its real adapter`,
      );
    }
  }

  commission(order: SettlementOrderRequest): Promise<Result<void, SettlementAclViolation>> {
    this.ledger.push(order);
    return Promise.resolve(ok(undefined));
  }

  /** The orders that NO Settlement ever executed — the visible trace of the absence. */
  get commissioned(): readonly SettlementOrderRequest[] {
    return this.ledger;
  }
}
