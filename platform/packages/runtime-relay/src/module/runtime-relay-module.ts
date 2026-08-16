import type { RuntimeModule } from '@mentora/runtime-bootstrap';

import type { RelayDispatch } from '../dispatch/relay-dispatch.js';

/**
 * RuntimeRelayModule — the I-11 lifecycle owner of the relay's cadence:
 * construire (nothing to allocate) → démarrer (the pacing begins) →
 * drainer (close the intake, finish the in-flight pass — R-8: "le drainage
 * protège la Constitution, jamais la disponibilité"; the rows left pending
 * are FORGIVEN — the next boot's relay resumes them, F4.4 §6) → libérer.
 *
 * The pacer is INJECTED (a free mechanism; specs drive ticks by hand;
 * production hands setInterval). No overlap: a tick never starts while the
 * previous pass runs.
 */

export type RelayPacer = (tick: () => Promise<void>, intervalMillis: number) => () => void;

export const intervalPacer: RelayPacer = (tick, intervalMillis) => {
  const handle = setInterval(() => {
    void tick();
  }, intervalMillis);
  return () => {
    clearInterval(handle);
  };
};

export class RuntimeRelayModule implements RuntimeModule {
  readonly name = 'runtime-relay';
  private stop: (() => void) | undefined;
  private inFlight: Promise<unknown> = Promise.resolve();
  private running = false;

  constructor(
    private readonly dispatch: RelayDispatch,
    private readonly intervalMillis: number,
    private readonly pacer: RelayPacer = intervalPacer,
  ) {}

  start(): void {
    this.stop = this.pacer(async () => {
      if (this.running) {
        return;
      }
      this.running = true;
      this.inFlight = this.dispatch.runOnce().finally(() => {
        this.running = false;
      });
      await this.inFlight.catch(() => undefined);
    }, this.intervalMillis);
  }

  async drain(): Promise<void> {
    this.stop?.();
    this.stop = undefined;
    await this.inFlight.catch(() => undefined);
  }

  dispose(): void {
    this.stop?.();
    this.stop = undefined;
  }
}
