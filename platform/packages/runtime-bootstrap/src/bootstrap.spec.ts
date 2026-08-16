import { err, ok } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { lifecycleStateIndex, RUNTIME_LIFECYCLE_STATES, RuntimeLifecycle } from './lifecycle.js';
import { RuntimeBuilder } from './runtime-builder.js';
import type { RuntimeModule } from './runtime-module.js';

const witnessed: string[] = [];
const moduleOf = (name: string, log: string[]): RuntimeModule => ({
  name,
  construct: () => {
    log.push(`construct:${name}`);
  },
  start: () => {
    log.push(`start:${name}`);
  },
  drain: () => {
    log.push(`drain:${name}`);
  },
  dispose: () => {
    log.push(`dispose:${name}`);
  },
});

describe('the nine-state machine (F5.1 §4 — closed, returnless)', () => {
  it('freezes the nine states in the exact ratified order', () => {
    expect(RUNTIME_LIFECYCLE_STATES).toEqual([
      'Construction',
      'Configuration',
      'Validation',
      'Warmup',
      'Ready',
      'Active',
      'Draining',
      'Shutdown',
      'Destroyed',
    ]);
    expect(Object.isFrozen(RUNTIME_LIFECYCLE_STATES)).toBe(true);
    expect(lifecycleStateIndex('Validation')).toBeLessThan(lifecycleStateIndex('Warmup'));
  });

  it('refuses returns and skips — aucun retour', () => {
    const lifecycle = new RuntimeLifecycle();
    lifecycle.advance('Configuration');
    expect(() => lifecycle.advance('Construction')).toThrow();
    expect(() => lifecycle.advance('Warmup')).toThrow();
    lifecycle.advance('Validation');
    expect(lifecycle.state).toBe('Validation');
  });
});

describe('boot and shutdown sequences (R-5, I-11)', () => {
  it('boots in dependency order and dies in REVERSE order', async () => {
    const log: string[] = [];
    const container = new RuntimeBuilder()
      .withModule(moduleOf('store', log))
      .withModule(moduleOf('relay', log))
      .withValidator({ name: 'tables', validate: () => ok(undefined) })
      .build();
    const booted = await container.boot();
    expect(booted.ok).toBe(true);
    expect(container.state).toBe('Active');
    await container.shutdown();
    expect(container.state).toBe('Destroyed');
    expect(log).toEqual([
      'construct:store',
      'construct:relay',
      'start:store',
      'start:relay',
      'drain:relay',
      'drain:store',
      'dispose:relay',
      'dispose:store',
    ]);
  });

  it('one missing proof = no start: ALL failures reported, nothing served (R-5)', async () => {
    const log: string[] = [];
    const container = new RuntimeBuilder()
      .withModule(moduleOf('store', log))
      .withValidator({ name: 'tables', validate: () => err('a table is incoherent') })
      .withValidator({ name: 'generations', validate: () => ok(undefined) })
      .withValidator({ name: 'secrets', validate: () => err('a secret is missing') })
      .build();
    const booted = await container.boot();
    expect(booted.ok).toBe(false);
    if (!booted.ok) {
      expect(booted.error).toEqual([
        'tables: a table is incoherent',
        'secrets: a secret is missing',
      ]);
    }
    expect(log).toEqual(['construct:store']);
    expect(container.state).toBe('Validation');
  });

  it('a died instance never re-boots — a NEW instance is born (R-4)', async () => {
    const container = new RuntimeBuilder()
      .withValidator({ name: 'proof', validate: () => err('missing') })
      .build();
    await container.boot();
    await expect(container.boot()).rejects.toThrow();
  });

  it('boot runs once; shutdown demands an Active instance', async () => {
    const container = new RuntimeBuilder().build();
    await expect(container.shutdown()).rejects.toThrow();
    expect((await container.boot()).ok).toBe(true);
    await expect(container.boot()).rejects.toThrow();
  });

  it('two modules under one name refuse at assembly (I-11: closed list)', () => {
    const builder = new RuntimeBuilder().withModule(moduleOf('store', witnessed));
    expect(() => builder.withModule(moduleOf('store', witnessed))).toThrow();
  });
});
