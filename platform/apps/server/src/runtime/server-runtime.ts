import type { Result } from '@mentora/kernel';
import { err } from '@mentora/kernel';
import type { ConfigSource } from '@mentora/runtime-config';

import { bootServer, buildServerGraph } from '../bootstrap/server-bootstrap.js';
import type { ServerBootFailure } from '../bootstrap/server-bootstrap.js';
import type { ServerGraph, ServerOverrides } from '../composition/server-composition.js';

/**
 * startServerRuntime — configuration → composition → boot, one road, fail
 * closed at every gate. Returns the LIVING graph (state Active) or the
 * complete failure report (all configuration violations, or all boot proof
 * failures — never only the first).
 */
export const startServerRuntime = async (
  sources: readonly ConfigSource[],
  overrides: ServerOverrides = {},
): Promise<Result<ServerGraph, ServerBootFailure>> => {
  const graph = buildServerGraph(sources, overrides);
  if (!graph.ok) {
    return err(graph.error);
  }
  return bootServer(graph.value);
};
