import type { ServerGraph } from '../composition/server-composition.js';

/**
 * The SHUTDOWN road — the exact REVERSE of the boot (I-11: "mort dans
 * l'ordre inverse"): the container drains modules in reverse registration
 * order (http stops accepting → relay drains its in-flight pass → the
 * engine client closes last via dispose), then Destroyed. "Le drainage
 * protège la Constitution, jamais la disponibilité" (R-8); pending Outbox
 * rows are FORGIVEN — the next boot's relay resumes them (F4.4 §6).
 *
 * Signals: SIGINT and SIGTERM both take this road — never a brutal exit.
 * The signal wiring is injectable so specs drive it without killing the
 * test process.
 */

export interface SignalHost {
  on(signal: 'SIGINT' | 'SIGTERM', handler: () => void): void;
  exit(code: number): void;
}

export const shutdownServer = async (graph: ServerGraph): Promise<void> => {
  await graph.container.shutdown();
};

export const wireSignals = (
  graph: ServerGraph,
  host: SignalHost,
  onDown?: () => void,
): void => {
  let closing = false;
  const road = (signal: string): void => {
    if (closing) {
      return;
    }
    closing = true;
    graph.loggers.loggerFor('server').info('drainage begins', { signal });
    void shutdownServer(graph)
      .then(() => {
        onDown?.();
        host.exit(0);
      })
      .catch(() => {
        host.exit(1);
      });
  };
  host.on('SIGINT', () => {
    road('SIGINT');
  });
  host.on('SIGTERM', () => {
    road('SIGTERM');
  });
};
