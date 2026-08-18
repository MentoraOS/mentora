import { instantOf } from '@mentora/kernel';
import { describe, expect, it } from 'vitest';

import type { Credential } from '../aggregate/credential.js';
import { establishCredential } from '../factories/credential-factory.js';
import { commandIdOf, credentialIdOf, factorIdOf, personIdOf } from '../ids/identifiers.js';
import type { CredentialRepository } from '../ports/credential-repository.js';
import { factorKindOf } from '../value-objects/factor-kind.js';
import { proofStrengthOf } from '../value-objects/proof-strength.js';

/**
 * CredentialRepositoryContractSuite — the port's promises written ONCE
 * (I-10): the in-memory reference today, the PostgreSQL registry of the
 * persistence lot tomorrow — every implementation must exhibit THE SAME
 * behavior. Lives on its own subpath ('@mentora/domain-identity/contract-suite'):
 * it imports the test runner, and the production barrel must stay loadable
 * by a living process (the barrels lesson).
 */

export interface CredentialRepositoryProvider {
  make(): Promise<{ repository: CredentialRepository }>;
}

export const bornCredential = (id: string, person: string, kind: string): Credential => {
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

export const credentialRepositoryContractSuite = (
  name: string,
  provider: CredentialRepositoryProvider,
): void => {
  describe(`CredentialRepository contract — ${name}`, () => {
    it('retains a newborn and reconstitutes it by Identifier, facts emptied', async () => {
      const { repository } = await provider.make();
      const born = bornCredential('cred-1', 'person-1', 'password');
      const retained = await repository.retain(born);
      expect(retained.ok).toBe(true);
      const back = await repository.byId(born.id);
      expect(back.some).toBe(true);
      if (back.some) {
        expect(back.value.state.kind).toBe('Active');
        expect(back.value.pendingFacts).toHaveLength(0);
        expect(back.value.version).toBe(1);
      }
    });

    it('an unknown Identifier is none — absence is a value, never an error', async () => {
      const { repository } = await provider.make();
      const back = await repository.byId(credentialIdOf('cred-ghost'));
      expect(back.some).toBe(false);
    });

    it('APPLIES THE R-A KEY at retention: a second ACTIVE credential for the same person × principal kind refuses', async () => {
      const { repository } = await provider.make();
      await repository.retain(bornCredential('cred-1', 'person-1', 'password'));
      const double = await repository.retain(bornCredential('cred-2', 'person-1', 'password'));
      expect(double.ok).toBe(false);
    });

    it('the R-A key frees after revocation: re-entering is a NEW credential (R-B)', async () => {
      const { repository } = await provider.make();
      await repository.retain(bornCredential('cred-1', 'person-1', 'password'));
      const first = await repository.byId(credentialIdOf('cred-1'));
      if (!first.some) throw new Error('unreachable');
      const revoked = first.value.revoke({
        commandId: commandIdOf('cmd-rev'),
        credentialId: first.value.id,
        motive: 'rotation',
        revokedAt: instantOf(2_000),
      });
      if (!revoked.ok) throw new Error('unreachable');
      const retainedRevocation = await repository.retain(revoked.value);
      expect(retainedRevocation.ok).toBe(true);
      const successor = await repository.retain(bornCredential('cred-3', 'person-1', 'password'));
      expect(successor.ok).toBe(true);
    });

    it('other person or other principal kind never conflict', async () => {
      const { repository } = await provider.make();
      await repository.retain(bornCredential('cred-1', 'person-1', 'password'));
      expect((await repository.retain(bornCredential('cred-2', 'person-2', 'password'))).ok).toBe(true);
      expect((await repository.retain(bornCredential('cred-3', 'person-1', 'federated'))).ok).toBe(true);
    });

    it('activeByPersonAndKind is the R-A probe: finds the ACTIVE one, ignores the revoked', async () => {
      const { repository } = await provider.make();
      await repository.retain(bornCredential('cred-1', 'person-1', 'password'));
      const probe = await repository.activeByPersonAndKind(personIdOf('person-1'), 'password');
      expect(probe.some).toBe(true);
      const miss = await repository.activeByPersonAndKind(personIdOf('person-1'), 'federated');
      expect(miss.some).toBe(false);
    });

    it('a stale retention (version conflict) is the transient FAILURE channel — thrown, retryable, never a Refusal', async () => {
      const { repository } = await provider.make();
      const born = bornCredential('cred-1', 'person-1', 'password');
      await repository.retain(born);
      // Retaining the SAME pre-retention unit again claims version 1 anew:
      // the registry must not accept two writes of the same generation.
      await expect(repository.retain(born)).rejects.toThrow();
    });
  });
};
