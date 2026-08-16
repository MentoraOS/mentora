import { invariant } from '@mentora/kernel';

/**
 * The NINE-state machine of F5.1 §4, verbatim: "La machine à neuf états,
 * fermée et sans retour : Construction → Configuration → Validation →
 * Warmup → Ready → Active → Draining → Shutdown → Destroyed. AUCUN RETOUR —
 * une instance dégradée ne re-valide pas : elle meurt et une neuve naît
 * (R-B appliquée aux machines)." (R-4.)
 */

export const RUNTIME_LIFECYCLE_STATES = Object.freeze([
  'Construction',
  'Configuration',
  'Validation',
  'Warmup',
  'Ready',
  'Active',
  'Draining',
  'Shutdown',
  'Destroyed',
] as const);

export type RuntimeLifecycleState = (typeof RUNTIME_LIFECYCLE_STATES)[number];

export const lifecycleStateIndex = (state: RuntimeLifecycleState): number =>
  RUNTIME_LIFECYCLE_STATES.indexOf(state);

export class RuntimeLifecycle {
  private current: RuntimeLifecycleState = 'Construction';

  get state(): RuntimeLifecycleState {
    return this.current;
  }

  /** Forward by exactly ONE state — no return, no skip (the machine is closed). */
  advance(to: RuntimeLifecycleState): void {
    const from = lifecycleStateIndex(this.current);
    const target = lifecycleStateIndex(to);
    invariant(
      target === from + 1,
      `no path ${this.current} → ${to}: the machine is closed and returnless (F5.1 §4, R-4)`,
    );
    this.current = to;
  }
}
