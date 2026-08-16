import { invariant } from '@mentora/kernel';

/**
 * Health — F5.1 R-6, verbatim: "Readiness = aptitude aux trois Séquences ;
 * Liveness = existence du processus ; NI L'UNE NI L'AUTRE NE JUGENT LE
 * MÉTIER" (a refusal rate is never a death signal). F4.4 §6: "Readiness :
 * l'application ne répond qu'après validation complète ET relais/Échéancier
 * ré-hydratés." Verdicts are FAIL CLOSED: one unhealthy entry, one
 * unhealthy report. A check that throws is a Failure described in the
 * verdict (R-10: "toute défaillance de Runtime est une Failure") — never a
 * silent pass.
 */

export type HealthStatus =
  | { readonly kind: 'healthy' }
  | { readonly kind: 'unhealthy'; readonly reason: string };

export const healthy = (): HealthStatus => ({ kind: 'healthy' });
export const unhealthy = (reason: string): HealthStatus => ({ kind: 'unhealthy', reason });

/** The three probes of the lifecycle — startup, readiness, liveness. */
export type ProbeKind = 'startup' | 'readiness' | 'liveness';

export interface HealthCheck {
  readonly name: string;
  readonly kind: ProbeKind;
  check(): Promise<HealthStatus>;
}

/** A named composite: healthy iff EVERY member is (fail closed). */
export class CompositeHealthCheck implements HealthCheck {
  constructor(
    readonly name: string,
    readonly kind: ProbeKind,
    private readonly members: readonly HealthCheck[],
  ) {}

  async check(): Promise<HealthStatus> {
    const reasons: string[] = [];
    for (const member of this.members) {
      const status = await runSafely(member);
      if (status.kind === 'unhealthy') {
        reasons.push(`${member.name}: ${status.reason}`);
      }
    }
    return reasons.length === 0 ? healthy() : unhealthy(reasons.join(' · '));
  }
}

export interface HealthReportEntry {
  readonly name: string;
  readonly status: HealthStatus;
}

export interface HealthReport {
  readonly kind: ProbeKind;
  readonly overall: HealthStatus;
  readonly entries: readonly HealthReportEntry[];
}

/** The closed, declared list of an executable's checks (dup name = assembly error). */
export class HealthRegistry {
  private readonly registered: HealthCheck[] = [];

  register(check: HealthCheck): void {
    invariant(
      !this.registered.some((existing) => existing.name === check.name),
      `two health checks named '${check.name}' — the list is closed and declared`,
    );
    this.registered.push(check);
  }

  checks(kind?: ProbeKind): readonly HealthCheck[] {
    return kind === undefined
      ? [...this.registered]
      : this.registered.filter((check) => check.kind === kind);
  }

  async report(kind: ProbeKind): Promise<HealthReport> {
    const entries: HealthReportEntry[] = [];
    for (const check of this.checks(kind)) {
      entries.push({ name: check.name, status: await runSafely(check) });
    }
    const failed = entries.filter((entry) => entry.status.kind === 'unhealthy');
    return {
      kind,
      overall:
        failed.length === 0 ? healthy() : unhealthy(failed.map((entry) => entry.name).join(' · ')),
      entries,
    };
  }
}

const runSafely = async (check: HealthCheck): Promise<HealthStatus> => {
  try {
    return await check.check();
  } catch (error) {
    return unhealthy(error instanceof Error ? error.message : String(error));
  }
};
