import { describe, expect, it } from 'vitest';

import { validateIdentityCommand } from './identity-command-validation.js';

const wire = (over: Record<string, unknown> = {}): Record<string, unknown> => ({
  type: 'EstablishCredential',
  contractVersion: 1,
  commandId: 'cmd-1',
  credentialId: 'cred-1',
  personId: 'person-1',
  principalFactor: { factorId: 'factor-1', kind: 'password', strength: 'standard' },
  ...over,
});

describe('validateIdentityCommand — the published language validates its own wire', () => {
  it('accepts a well-formed EstablishCredential', () => {
    const result = validateIdentityCommand(wire());
    expect(result.ok).toBe(true);
  });

  it('refuses a non-object payload', () => {
    const result = validateIdentityCommand('nope');
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error[0]?.code).toBe('CONTRACT.MALFORMED');
  });

  it('refuses an unknown type', () => {
    const result = validateIdentityCommand(wire({ type: 'DoSomething' }));
    expect(result.ok).toBe(false);
    if (!result.ok) expect(result.error[0]?.code).toBe('CONTRACT.UNKNOWN_CONTRACT');
  });

  it('lists EVERY violation — generation, blanks, factor shape (never only the first)', () => {
    const result = validateIdentityCommand(
      wire({ contractVersion: 2, commandId: ' ', personId: '', principalFactor: 'nope' }),
    );
    expect(result.ok).toBe(false);
    if (!result.ok) {
      const fields = result.error.map((violation) => violation.field);
      expect(fields).toContain('contractVersion');
      expect(fields).toContain('commandId');
      expect(fields).toContain('personId');
      expect(fields).toContain('principalFactor');
      expect(result.error.length).toBeGreaterThanOrEqual(4);
    }
  });

  it('refuses blank factor fields, each named', () => {
    const result = validateIdentityCommand(
      wire({ principalFactor: { factorId: '', kind: 'password', strength: ' ' } }),
    );
    expect(result.ok).toBe(false);
    if (!result.ok) {
      const fields = result.error.map((violation) => violation.field);
      expect(fields).toContain('principalFactor.factorId');
      expect(fields).toContain('principalFactor.strength');
    }
  });
});
