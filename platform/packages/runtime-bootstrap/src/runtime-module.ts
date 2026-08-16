import { invariant } from '@mentora/kernel';
import type { Result } from '@mentora/kernel';

/**
 * RuntimeModule — a lifecycle-registered resource owner. I-11, verbatim:
 * "toute ressource a un propriétaire-composant … le Runtime orchestre des
 * crochets (construire → démarrer → drainer → libérer), naissance dans
 * l'ordre des dépendances, mort dans l'ordre INVERSE ; l'enregistrement au
 * cycle de vie est une CONDITION D'ASSEMBLAGE — un composant non enregistré
 * ne peut pas exister — rien d'orphelin, par construction."
 */
export interface RuntimeModule {
  readonly name: string;
  /** construire — allocate, never serve. */
  construct?(): Promise<void> | void;
  /** démarrer — begin serving (Warmup: rebuild tooling projections, never invent — R-7). */
  start?(): Promise<void> | void;
  /** drainer — close the entrance, finish in-flight work (R-8). */
  drain?(): Promise<void> | void;
  /** libérer — release resources; crash remains are waste, never inheritance (F5.1 §19). */
  dispose?(): Promise<void> | void;
}

/** The closed, declared module list — registration IS the assembly condition. */
export class RuntimeRegistry {
  private readonly registered: RuntimeModule[] = [];

  register(module: RuntimeModule): void {
    invariant(
      !this.registered.some((existing) => existing.name === module.name),
      `two modules named '${module.name}' — the lifecycle list is closed and declared (I-11)`,
    );
    this.registered.push(module);
  }

  modules(): readonly RuntimeModule[] {
    return [...this.registered];
  }
}

/** A boot proof: demonstrates one executability condition (F4.4 §7). */
export interface BootValidator {
  readonly name: string;
  validate(): Promise<Result<void, string>> | Result<void, string>;
}
