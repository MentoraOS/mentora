import { readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

/**
 * Loads the workspace dependency graph from the packages' package.json files.
 * Pure data extraction — the assertion helpers live in `rules.ts`.
 */

export interface WorkspacePackage {
  /** npm name, e.g. `@mentora/kernel`. */
  readonly name: string;
  /** workspace-relative directory, e.g. `packages/kernel`. */
  readonly directory: string;
  /** Runtime dependencies that are workspace packages. */
  readonly workspaceDependencies: readonly string[];
  /** Dev dependencies that are workspace packages. */
  readonly workspaceDevDependencies: readonly string[];
}

export interface WorkspaceGraph {
  readonly packages: readonly WorkspacePackage[];
  byName(name: string): WorkspacePackage | undefined;
}

interface PackageJsonShape {
  readonly name?: string;
  readonly dependencies?: Readonly<Record<string, string>>;
  readonly devDependencies?: Readonly<Record<string, string>>;
}

const WORKSPACE_DIRS = ['packages', 'apps', 'tooling'] as const;

const workspaceDeps = (
  record: Readonly<Record<string, string>> | undefined,
  workspaceNames: ReadonlySet<string>,
): string[] => Object.keys(record ?? {}).filter((dep) => workspaceNames.has(dep));

/**
 * Load the graph from a workspace root (the directory containing
 * `pnpm-workspace.yaml`). Only `workspace:*`-style internal edges are kept.
 */
export const loadWorkspaceGraph = (workspaceRoot: string): WorkspaceGraph => {
  const found: Array<{ name: string; directory: string; json: PackageJsonShape }> = [];

  for (const family of WORKSPACE_DIRS) {
    const familyDir = join(workspaceRoot, family);
    let entries: string[];
    try {
      entries = readdirSync(familyDir);
    } catch {
      continue;
    }
    for (const entry of entries) {
      const pkgPath = join(familyDir, entry, 'package.json');
      let raw: string;
      try {
        raw = readFileSync(pkgPath, 'utf8');
      } catch {
        continue;
      }
      const json = JSON.parse(raw) as PackageJsonShape;
      if (json.name !== undefined) {
        found.push({ name: json.name, directory: `${family}/${entry}`, json });
      }
    }
  }

  const names = new Set(found.map((p) => p.name));
  const packages: WorkspacePackage[] = found.map((p) => ({
    name: p.name,
    directory: p.directory,
    workspaceDependencies: workspaceDeps(p.json.dependencies, names),
    workspaceDevDependencies: workspaceDeps(p.json.devDependencies, names),
  }));

  const byName = new Map(packages.map((p) => [p.name, p]));
  return {
    packages,
    byName: (name) => byName.get(name),
  };
};
