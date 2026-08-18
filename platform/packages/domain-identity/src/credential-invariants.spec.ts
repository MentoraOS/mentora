import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import { Credential } from './aggregate/credential.js';
import { IdentityIdentifierBlankException, CredentialSnapshotCorruptException } from './errors/identity-exceptions.js';
import { establishCredential } from './factories/credential-factory.js';
import { commandIdOf, credentialIdOf, factorIdOf, personIdOf } from './ids/identifiers.js';
import type { CredentialSnapshot } from './snapshots/credential-snapshot.js';
import { ActiveCredentialUniquenessSpecification } from './specifications/active-credential-uniqueness.specification.js';
import { factorKindOf } from './value-objects/factor-kind.js';
import { proofStrengthOf } from './value-objects/proof-strength.js';

const born = (id: string, person: string, kind: string) => {
  const result = establishCredential({
    commandId: commandIdOf('cmd-' + id),
    credentialId: credentialIdOf(id),
    personId: personIdOf(person),
    principalFactor: {
      factorId: factorIdOf('factor-' + id),
      kind: factorKindOf(kind),
      strength: proofStrengthOf('standard'),
    },
    establishedAt: instantOf(1_000),
  });
  if (!result.ok) throw new Error('unreachable');
  return result.value;
};

describe('Credential — invariants', () => {
  it('NO SECRET MATERIAL BY CONSTRUCTION: the Factor shape carries nature and weight only', () => {
    const credential = born('cred-1', 'person-1', 'password');
    const factor = credential.principalFactor;
    // The whole surface of a Factor — if a field is added here, this test
    // forces the reviewer to justify it against "aucun secret, jamais".
    expect(Object.keys(factor).sort()).toEqual([
      'establishedAt',
      'factorId',
      'kind',
      'principal',
      'strength',
    ]);
  });

  it('facts carry references and natures — never strength, never material', () => {
    const credential = born('cred-1', 'person-1', 'password');
    const fact = credential.pendingFacts[0];
    if (fact?.type !== 'CredentialEstablished') throw new Error('unreachable');
    expect(Object.keys(fact).sort()).toEqual([
      'credentialId',
      'instant',
      'personId',
      'principalFactorId',
      'principalFactorKind',
      'sequence',
      'type',
    ]);
  });

  it('R-A rule declared: two ACTIVE credentials of one person on the same principal kind conflict', () => {
    const specification = new ActiveCredentialUniquenessSpecification();
    const first = born('cred-1', 'person-1', 'password');
    const samePersonSameKind = born('cred-2', 'person-1', 'password');
    const samePersonOtherKind = born('cred-3', 'person-1', 'federated');
    const otherPerson = born('cred-4', 'person-2', 'password');
    expect(specification.conflicts(samePersonSameKind, first)).toBe(true);
    expect(specification.conflicts(samePersonOtherKind, first)).toBe(false);
    expect(specification.conflicts(otherPerson, first)).toBe(false);
    expect(specification.conflicts(first, first)).toBe(false);
    const revoked = first.revoke({
      commandId: commandIdOf('cmd-x'),
      credentialId: first.id,
      motive: 'rotation',
      revokedAt: instantOf(2_000),
    });
    if (!revoked.ok) throw new Error('unreachable');
    expect(specification.conflicts(samePersonSameKind, revoked.value)).toBe(false);
  });

  it('blank identifiers are malformed calls — the Exception door, never a Refusal', () => {
    expect(() => credentialIdOf('  ')).toThrow(IdentityIdentifierBlankException);
    expect(() => factorKindOf('')).toThrow(IdentityIdentifierBlankException);
    expect(() => proofStrengthOf(' ')).toThrow(IdentityIdentifierBlankException);
  });

  it('snapshot round-trips faithfully; corruption throws PERSIST-grade exceptions', () => {
    const credential = born('cred-1', 'person-1', 'password').retained();
    const photo = credential.snapshot();
    const back = Credential.fromSnapshot(photo);
    expect(back.snapshot()).toEqual(photo);
    expect(back.pendingFacts).toHaveLength(0);
    const noFactors: CredentialSnapshot = { ...photo, factors: [] };
    expect(() => Credential.fromSnapshot(noFactors)).toThrow(CredentialSnapshotCorruptException);
    const twoPrincipals: CredentialSnapshot = {
      ...photo,
      factors: [...photo.factors, { ...photo.factors[0]!, factorId: 'factor-2' }],
    };
    expect(() => Credential.fromSnapshot(twoPrincipals)).toThrow(CredentialSnapshotCorruptException);
    const badVersion: CredentialSnapshot = { ...photo, version: 0 };
    expect(() => Credential.fromSnapshot(badVersion)).toThrow(CredentialSnapshotCorruptException);
  });

  it('revoked snapshot round-trips with motive and instant intact', () => {
    const revoked = born('cred-1', 'person-1', 'password')
      .retained()
      .revoke({
        commandId: commandIdOf('cmd-2'),
        credentialId: credentialIdOf('cred-1'),
        motive: 'device-lost',
        revokedAt: instantOf(3_000),
      });
    if (!revoked.ok) throw new Error('unreachable');
    const photo = revoked.value.retained().snapshot();
    const back = Credential.fromSnapshot(photo);
    expect(back.state.kind).toBe('Revoked');
    if (back.state.kind === 'Revoked') {
      expect(back.state.motive).toBe('device-lost');
      expect(back.state.revokedAt.epochMillis).toBe(3_000);
    }
  });
});
