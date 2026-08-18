import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { EstablishCredential, RevokeCredential } from './commands/credential-commands.js';
import { establishCredential } from './factories/credential-factory.js';
import { commandIdOf, credentialIdOf, factorIdOf, personIdOf } from './ids/identifiers.js';
import { factorKindOf } from './value-objects/factor-kind.js';
import { proofStrengthOf } from './value-objects/proof-strength.js';

const T0 = instantOf(1_000_000);
const T1 = instantOf(2_000_000);

const establishOf = (): EstablishCredential => ({
  commandId: commandIdOf('cmd-1'),
  credentialId: credentialIdOf('cred-1'),
  personId: personIdOf('person-1'),
  principalFactor: {
    factorId: factorIdOf('factor-1'),
    kind: factorKindOf('password'),
    strength: proofStrengthOf('standard'),
  },
  establishedAt: T0,
});

const revokeOf = (): RevokeCredential => ({
  commandId: commandIdOf('cmd-2'),
  credentialId: credentialIdOf('cred-1'),
  motive: 'compromise-suspected',
  revokedAt: T1,
});

describe('Credential — the frozen machine (Active → Revoked)', () => {
  it('is born Active through the factory, carrying CredentialEstablished as fact 1', () => {
    const born = establishCredential(establishOf());
    expect(born.ok).toBe(true);
    if (!born.ok) return;
    const credential = born.value;
    expect(credential.state.kind).toBe('Active');
    expect(credential.version).toBe(1);
    expect(credential.pendingFacts).toHaveLength(1);
    const fact = credential.pendingFacts[0];
    expect(fact?.type).toBe('CredentialEstablished');
    if (fact?.type === 'CredentialEstablished') {
      expect(fact.personId).toBe('person-1');
      expect(fact.principalFactorKind).toBe('password');
      expect(fact.sequence).toBe(1);
    }
    expect(credential.principalFactor.principal).toBe(true);
  });

  it('revokes immediately: Active → Revoked, terminal, fact carried, version bumped', () => {
    const born = establishCredential(establishOf());
    if (!born.ok) throw new Error('unreachable');
    const revoked = born.value.retained().revoke(revokeOf());
    expect(revoked.ok).toBe(true);
    if (!revoked.ok) return;
    expect(revoked.value.state.kind).toBe('Revoked');
    expect(revoked.value.version).toBe(2);
    expect(revoked.value.pendingFacts.map((fact) => fact.type)).toEqual(['CredentialRevoked']);
  });

  it('refuses to revoke a Revoked credential — TransitionUnavailable, a VALUE, never a throw (R-B)', () => {
    const born = establishCredential(establishOf());
    if (!born.ok) throw new Error('unreachable');
    const once = born.value.revoke(revokeOf());
    if (!once.ok) throw new Error('unreachable');
    const twice = once.value.revoke({ ...revokeOf(), commandId: commandIdOf('cmd-3') });
    expect(twice.ok).toBe(false);
    if (twice.ok) return;
    expect(twice.error.reason).toBe('TransitionUnavailable');
  });

  it('retained() empties the carried facts without touching state or version', () => {
    const born = establishCredential(establishOf());
    if (!born.ok) throw new Error('unreachable');
    const retained = born.value.retained();
    expect(retained.pendingFacts).toHaveLength(0);
    expect(retained.version).toBe(1);
    expect(retained.state.kind).toBe('Active');
  });
});
