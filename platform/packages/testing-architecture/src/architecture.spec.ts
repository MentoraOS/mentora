import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import { describe, expect, it } from 'vitest';

import {
  findDependencyCycles,
  findForbiddenDependencies,
  findLayerViolations,
  findNamingViolations,
} from './rules.js';
import { loadWorkspaceGraph } from './workspace-graph.js';

/**
 * These tests run against the REAL Mentora workspace: the platform must obey
 * its own architecture (ADR-0003) at all times. Any new package that breaks the
 * dependency law fails this suite immediately.
 */

const workspaceRoot = resolve(dirname(fileURLToPath(import.meta.url)), '../../..');
const graph = loadWorkspaceGraph(workspaceRoot);

/** ADR-0003 layer of a package, innermost first (undefined = not yet classified). */
const layerOf = (name: string): string | undefined => {
  if (name === '@mentora/kernel') return 'kernel';
  if (name === '@mentora/shared') return 'shared';
  if (name === '@mentora/contracts' || name.startsWith('@mentora/contracts-')) return 'contracts';
  if (name.startsWith('@mentora/testing')) return 'testing';
  if (name.startsWith('@mentora/domain-')) return 'domain';
  if (name.startsWith('@mentora/application-')) return 'application';
  if (name.startsWith('@mentora/infra-')) return 'infrastructure';
  if (name.startsWith('@mentora/adapter-')) return 'adapters';
  if (name.startsWith('@mentora/app-') || name.startsWith('@mentora/worker-')) return 'apps';
  return undefined;
};

describe('the Mentora workspace obeys its own architecture (ADR-0003)', () => {
  it('discovers the workspace packages', () => {
    const names = graph.packages.map((p) => p.name);
    expect(names).toContain('@mentora/kernel');
    expect(names).toContain('@mentora/shared');
    expect(names).toContain('@mentora/contracts');
  });

  it('has no runtime dependency cycles (I-12: the graph is a DAG)', () => {
    expect(findDependencyCycles(graph)).toEqual([]);
  });

  it('respects the ring layering (I-1: the arrow points inward)', () => {
    const layers = [
      'kernel',
      'shared',
      'contracts',
      'testing',
      'domain',
      'application',
      'infrastructure',
      'adapters',
      'apps',
    ];
    const violations = findLayerViolations(graph, layers, (pkg) => layerOf(pkg.name));
    expect(violations).toEqual([]);
  });

  it('kernel depends on nothing in the workspace', () => {
    const kernel = graph.byName('@mentora/kernel');
    expect(kernel).toBeDefined();
    expect(kernel?.workspaceDependencies).toEqual([]);
  });

  it('no package depends on an app (apps are leaves)', () => {
    const violations = findForbiddenDependencies(graph, (dep) => layerOf(dep) === 'apps');
    expect(violations).toEqual([]);
  });

  it('every package uses the @mentora scope', () => {
    const violations = findNamingViolations(graph, (name) => name.startsWith('@mentora/'));
    expect(violations).toEqual([]);
  });
});
