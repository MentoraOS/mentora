import type { ConfigSource } from '@mentora/runtime-config';

import type { ServerOverrides } from '../composition/server-composition.js';
import { serverConfigSources } from '../config/server-config.js';
import { startServerRuntime } from '../runtime/server-runtime.js';
import { wireSignals } from '../shutdown/server-shutdown.js';
import type { SignalHost } from '../shutdown/server-shutdown.js';

import { renderBootReport } from './boot-report.js';

/**
 * What the operating-system process lends the runtime: its signals, its
 * exit, and one stderr line for the boot report (the report must reach the
 * operator even when no log well exists yet). Injectable so the WHOLE
 * process behavior is provable without killing the test process — main.ts
 * stays a pure wire.
 */
export interface ProcessHost extends SignalHost {
  stderrLine(line: string): void;
}

/**
 * The process road, one direction (F5.1 §4): .env + environment →
 * configuration → the Root → boot → Active + signals wired; OR the
 * COMPLETE boot report on stderr and exit(1) — "une application qui
 * démarre à moitié ment déjà" (F4.4 §6).
 */
export const runServerProcess = async (
  host: ProcessHost,
  sources: readonly ConfigSource[] = serverConfigSources(),
  overrides: ServerOverrides = {},
): Promise<void> => {
  const started = await startServerRuntime(sources, overrides);
  if (!started.ok) {
    host.stderrLine(renderBootReport(started.error));
    host.exit(1);
    return;
  }
  wireSignals(started.value, host);
  started.value.loggers.loggerFor('server').info('mentora application ACTIVE', {
    port: started.value.http.portInUse ?? 0,
  });
};
