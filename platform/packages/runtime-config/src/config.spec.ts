import { describe, expect, it } from 'vitest';

import { environmentSource, inMemorySource } from './config-sources.js';
import { asSharedConfig, loadConfig } from './load-config.js';

const SCHEMA = {
  serviceName: { kind: 'string', nonBlank: true },
  poolSize: { kind: 'number', min: 1, max: 64, default: 8 },
  drainMillis: { kind: 'number', min: 0 },
  verboseBoot: { kind: 'boolean', default: false },
  logSinkKind: { kind: 'choice', values: ['console', 'memory'], default: 'console' },
} as const;

describe('loadConfig (fail closed — F4.4 §7)', () => {
  it('loads a fully valid, typed configuration with defaults applied', () => {
    const loaded = loadConfig(SCHEMA, [
      inMemorySource('test', { serviceName: 'agreement-app', drainMillis: '2500' }),
    ]);
    expect(loaded.ok).toBe(true);
    if (loaded.ok) {
      expect(loaded.value).toEqual({
        serviceName: 'agreement-app',
        poolSize: 8,
        drainMillis: 2500,
        verboseBoot: false,
        logSinkKind: 'console',
      });
    }
  });

  it('collects the COMPLETE violation list — one report, then death', () => {
    const loaded = loadConfig(SCHEMA, [
      inMemorySource('test', {
        serviceName: '   ',
        poolSize: '9000',
        drainMillis: 'soon',
        verboseBoot: 'yes',
        logSinkKind: 'syslog',
      }),
    ]);
    expect(loaded.ok).toBe(false);
    if (!loaded.ok) {
      expect(loaded.error.map((violation) => violation.code).sort()).toEqual([
        'CONFIG.BLANK',
        'CONFIG.BOUNDS',
        'CONFIG.CHOICE',
        'CONFIG.TYPE',
        'CONFIG.TYPE',
      ]);
    }
  });

  it('a required key with no source and no default is missing', () => {
    const loaded = loadConfig(SCHEMA, [inMemorySource('test', {})]);
    expect(!loaded.ok && loaded.error.some((violation) => violation.code === 'CONFIG.MISSING')).toBe(
      true,
    );
  });

  it('the first source that defines a key wins', () => {
    const loaded = loadConfig(SCHEMA, [
      inMemorySource('first', { serviceName: 'from-first', drainMillis: '1' }),
      inMemorySource('second', { serviceName: 'from-second', drainMillis: '2' }),
    ]);
    expect(loaded.ok && loaded.value.serviceName).toBe('from-first');
  });
});

describe('environmentSource (the one lawful process.env read)', () => {
  it('reads the process environment', () => {
    process.env['MENTORA_CONFIG_PROBE'] = 'probe-value';
    expect(environmentSource().read('MENTORA_CONFIG_PROBE')).toBe('probe-value');
    delete process.env['MENTORA_CONFIG_PROBE'];
    expect(environmentSource().read('MENTORA_CONFIG_PROBE')).toBeUndefined();
  });
});

describe('asSharedConfig (serves the shared-owned Config contract)', () => {
  it('answers Option<string> per the shared port', () => {
    const config = asSharedConfig({ poolSize: 8 });
    expect(config.get('poolSize')).toEqual({ some: true, value: '8' });
    expect(config.get('absent')).toEqual({ some: false });
  });
});

describe('remaining doors', () => {
  it('accepts a provided choice, a valid boolean and refuses a blank number', () => {
    const loaded = loadConfig(
      {
        logSinkKind: { kind: 'choice', values: ['console', 'memory'] },
        verboseBoot: { kind: 'boolean' },
        poolSize: { kind: 'number' },
      },
      [inMemorySource('test', { logSinkKind: 'memory', verboseBoot: 'true', poolSize: '  ' })],
    );
    expect(!loaded.ok && loaded.error).toEqual([
      { key: 'poolSize', code: 'CONFIG.TYPE', message: "'poolSize' must be a number" },
    ]);
    const clean = loadConfig(
      {
        logSinkKind: { kind: 'choice', values: ['console', 'memory'] },
        verboseBoot: { kind: 'boolean' },
      },
      [inMemorySource('test', { logSinkKind: 'memory', verboseBoot: 'true' })],
    );
    expect(clean.ok && clean.value).toEqual({ logSinkKind: 'memory', verboseBoot: true });
  });

  it('a blank string WITHOUT the nonBlank demand passes; sources carry names', () => {
    const loaded = loadConfig({ motd: { kind: 'string' } }, [inMemorySource('probe', { motd: ' ' })]);
    expect(loaded.ok && loaded.value.motd).toBe(' ');
    expect(inMemorySource('probe', {}).name).toBe('probe');
    expect(environmentSource().name).toBe('environment');
  });
});
