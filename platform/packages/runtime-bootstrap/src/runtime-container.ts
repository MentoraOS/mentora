import type { Result } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import { RuntimeLifecycle } from './lifecycle.js';
import type { RuntimeLifecycleState } from './lifecycle.js';
import type { BootValidator, RuntimeModule } from './runtime-module.js';

/**
 * The assembled runtime — F5.1: "Le Boot démontre et ne sert jamais ; une
 * seule preuve manquante et il meurt" (R-5); F4.4 §6: "fail closed au boot:
 * une application qui démarre à moitié ment déjà"; F4.4 §7: "Une seule
 * erreur = pas de démarrage" — ALL violations are reported, then the
 * instance dies once (no retry: a degraded instance never re-validates,
 * R-4 — a NEW instance boots instead).
 *
 * DELIBERATELY NOT a service locator: there is no resolve(), no get(), no
 * dynamic lookup — Pure DI stays at the Root (I-2: "on reçoit, on ne
 * cherche jamais"); this container only OWNS the lifecycle of what the
 * Root already wired.
 */

/** The readable description of what was assembled (a frozen property: legible tables). */
export interface RuntimeAssembly {
  readonly modules: readonly RuntimeModule[];
  readonly validators: readonly BootValidator[];
}

export class RuntimeContainer {
  private readonly lifecycle = new RuntimeLifecycle();
  private dead = false;

  constructor(readonly assembly: RuntimeAssembly) {}

  get state(): RuntimeLifecycleState {
    return this.lifecycle.state;
  }

  /**
   * BootSequence — Construction (construct, dependency order) →
   * Configuration → Validation (ALL proofs; one failure = death) →
   * Warmup (start, dependency order) → Ready → Active.
   */
  async boot(): Promise<Result<void, readonly string[]>> {
    invariant(!this.dead, 'a died instance never re-boots — a new instance is born (R-4)');
    invariant(this.lifecycle.state === 'Construction', 'boot starts at Construction, once');

    for (const module of this.assembly.modules) {
      await module.construct?.();
    }
    this.lifecycle.advance('Configuration');
    this.lifecycle.advance('Validation');

    const failures: string[] = [];
    for (const validator of this.assembly.validators) {
      const proof = await validator.validate();
      if (!proof.ok) {
        failures.push(`${validator.name}: ${proof.error}`);
      }
    }
    if (failures.length > 0) {
      // "Mourir immédiatement" (F4.4 §6) — the instance is dead, not retryable.
      this.dead = true;
      return err(failures);
    }

    this.lifecycle.advance('Warmup');
    for (const module of this.assembly.modules) {
      await module.start?.();
    }
    this.lifecycle.advance('Ready');
    this.lifecycle.advance('Active');
    return ok(undefined);
  }

  /**
   * ShutdownSequence — Draining (drain, REVERSE order) → Shutdown (dispose,
   * REVERSE order) → Destroyed. "Le drainage protège la Constitution,
   * jamais la disponibilité" (R-8).
   */
  async shutdown(): Promise<void> {
    invariant(this.lifecycle.state === 'Active', 'shutdown drains an Active instance');
    this.lifecycle.advance('Draining');
    const reversed = [...this.assembly.modules].reverse();
    for (const module of reversed) {
      await module.drain?.();
    }
    this.lifecycle.advance('Shutdown');
    for (const module of reversed) {
      await module.dispose?.();
    }
    this.lifecycle.advance('Destroyed');
    this.dead = true;
  }
}
