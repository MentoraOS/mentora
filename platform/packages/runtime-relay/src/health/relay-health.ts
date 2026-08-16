import type { Clock } from '@mentora/kernel';
import type { HealthCheck } from '@mentora/runtime-health';
import { healthy, unhealthy } from '@mentora/runtime-health';

import type { RelaySourcePort } from '../claim/relay-source-port.js';
import type { RelayBacklog } from '../dispatch/relay-envelope.js';

/**
 * RelayHealth — R-6 discipline: Liveness = the process exists; a BACKLOG is
 * NEVER a death signal ("un taux de refus n'est pas un signal de mort" —
 * the same law for a queue depth: depth belongs to Alerts, not to death).
 * The readiness check proves the SOURCE answers; the snapshot exposes the
 * numbers (backlog, oldest pending age, retrying, quarantined) for the
 * operations readings.
 */
export class RelayHealth {
  constructor(
    private readonly source: RelaySourcePort,
    private readonly clock: Clock,
  ) {}

  /** The operations numbers — a reading, never a verdict. */
  snapshot(): Promise<RelayBacklog> {
    return this.source.backlog(this.clock.now().epochMillis);
  }

  /** Readiness: the relay can see its source (its one executability condition). */
  readinessCheck(): HealthCheck {
    return {
      name: 'relay-source',
      kind: 'readiness',
      check: async () => {
        try {
          await this.snapshot();
          return healthy();
        } catch (error) {
          return unhealthy(error instanceof Error ? error.message : String(error));
        }
      },
    };
  }

  /** Liveness: the relay process answers — it never judges the backlog. */
  livenessCheck(): HealthCheck {
    return {
      name: 'relay-process',
      kind: 'liveness',
      check: () => Promise.resolve(healthy()),
    };
  }
}
