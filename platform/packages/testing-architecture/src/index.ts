/**
 * @mentora/testing-architecture — the dependency law, executable.
 *
 * Loads the workspace graph from package.json files and provides pure rule
 * functions (cycles, layering, forbidden deps, naming) that tests assert on.
 * This enforces ADR-0003 at the package level; the ESLint boundaries enforce it
 * at the import level. Two independent nets, same law (F4.4 I-1/I-12).
 */

export { loadWorkspaceGraph } from './workspace-graph.js';
export type { WorkspaceGraph, WorkspacePackage } from './workspace-graph.js';
export {
  findDependencyCycles,
  findLayerViolations,
  findForbiddenDependencies,
  findNamingViolations,
} from './rules.js';
