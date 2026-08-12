import type { WorkspaceGraph, WorkspacePackage } from './workspace-graph.js';

/**
 * Architecture rules as pure functions over the workspace graph. Each returns a
 * list of violations (empty = compliant), so a test is one line:
 *   expect(findDependencyCycles(graph)).toEqual([])
 *
 * These make ADR-0003's dependency law executable at the package level —
 * complementing the ESLint boundaries which work at the import level.
 */

const runtimeEdges = (pkg: WorkspacePackage): readonly string[] => pkg.workspaceDependencies;

/** Detect runtime dependency cycles (DFS). Returns each cycle as a name path. */
export const findDependencyCycles = (graph: WorkspaceGraph): string[][] => {
  const cycles: string[][] = [];
  const visiting = new Set<string>();
  const done = new Set<string>();

  const visit = (name: string, path: string[]): void => {
    if (done.has(name)) {
      return;
    }
    if (visiting.has(name)) {
      const start = path.indexOf(name);
      cycles.push([...path.slice(start), name]);
      return;
    }
    visiting.add(name);
    const pkg = graph.byName(name);
    for (const dep of pkg ? runtimeEdges(pkg) : []) {
      visit(dep, [...path, name]);
    }
    visiting.delete(name);
    done.add(name);
  };

  for (const pkg of graph.packages) {
    visit(pkg.name, []);
  }
  return cycles;
};

/**
 * Layering: given an ordered list of layers (innermost first) and a classifier,
 * a package may only have runtime deps on packages in its own or an INNER
 * layer. Returns human-readable violations.
 */
export const findLayerViolations = (
  graph: WorkspaceGraph,
  layersInnermostFirst: readonly string[],
  classify: (pkg: WorkspacePackage) => string | undefined,
): string[] => {
  const rank = new Map(layersInnermostFirst.map((layer, i) => [layer, i]));
  const violations: string[] = [];
  for (const pkg of graph.packages) {
    const layer = classify(pkg);
    const pkgRank = layer !== undefined ? rank.get(layer) : undefined;
    if (pkgRank === undefined) {
      continue;
    }
    for (const depName of runtimeEdges(pkg)) {
      const dep = graph.byName(depName);
      const depLayer = dep ? classify(dep) : undefined;
      const depRank = depLayer !== undefined ? rank.get(depLayer) : undefined;
      if (depRank !== undefined && depRank > pkgRank) {
        violations.push(
          `${pkg.name} (${layer ?? '?'}) must not depend on ${depName} (${depLayer ?? '?'}): the arrow points inward`,
        );
      }
    }
  }
  return violations;
};

/** Packages whose runtime deps include a package matching `forbidden`. */
export const findForbiddenDependencies = (
  graph: WorkspaceGraph,
  forbidden: (dependency: string, dependent: WorkspacePackage) => boolean,
): string[] => {
  const violations: string[] = [];
  for (const pkg of graph.packages) {
    for (const dep of runtimeEdges(pkg)) {
      if (forbidden(dep, pkg)) {
        violations.push(`${pkg.name} must not depend on ${dep}`);
      }
    }
  }
  return violations;
};

/** Package-naming rule: every package name must satisfy `isValid`. */
export const findNamingViolations = (
  graph: WorkspaceGraph,
  isValid: (name: string, pkg: WorkspacePackage) => boolean,
): string[] =>
  graph.packages
    .filter((pkg) => !isValid(pkg.name, pkg))
    .map((pkg) => `${pkg.name} (${pkg.directory}) violates the naming convention`);
