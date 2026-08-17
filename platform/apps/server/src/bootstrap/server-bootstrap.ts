import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import type { ConfigSource, ConfigViolation } from '@mentora/runtime-config';

import { composeServer } from '../composition/server-composition.js';
import type { ServerGraph, ServerOverrides } from '../composition/server-composition.js';
import { loadServerConfig } from '../config/server-config.js';

/**
 * The BOOT road of the executable, exactly the machine's order (F5.1 §4):
 * (1) Configuration — loaded and validated FIRST, ALL violations reported
 * ("jamais seulement la première") → (2) the Root builds the whole graph
 * (machinery, engine client, registry, Agreement composition — itself
 * boot-validated fail closed —, relay, container) → (3) container.boot():
 * Construction → Configuration → Validation (proofs; one failure = death)
 * → Warmup (modules start in dependency order: persistence, relay, http)
 * → Ready → Active.
 */

export type ServerBootFailure =
  | { readonly kind: 'configuration'; readonly violations: readonly ConfigViolation[] }
  | { readonly kind: 'validation'; readonly failures: readonly string[] };

export const buildServerGraph = (
  sources: readonly ConfigSource[],
  overrides: ServerOverrides = {},
): Result<ServerGraph, ServerBootFailure> => {
  const config = loadServerConfig(sources);
  if (!config.ok) {
    return err({ kind: 'configuration', violations: config.error });
  }
  return ok(composeServer(config.value, overrides));
};

export const bootServer = async (
  graph: ServerGraph,
): Promise<Result<ServerGraph, ServerBootFailure>> => {
  let booted: Result<void, readonly string[]>;
  try {
    booted = await graph.container.boot();
  } catch (error) {
    // A module hook threw during Construction/Warmup (e.g. the engine is
    // unreachable): the executable converts it into a REPORTED refusal —
    // fail closed with its cause named, never an unhandled rejection.
    booted = err([
      `boot-construction: ${error instanceof Error ? error.message : String(error)}`,
    ]);
  }
  if (!booted.ok) {
    // "Mourir immédiatement" — the engine client is released; the instance
    // is dead and never re-boots (R-4); a NEW instance may be born.
    await graph.prisma.$disconnect().catch(() => undefined);
    return err({ kind: 'validation', failures: booted.error });
  }
  return ok(graph);
};
