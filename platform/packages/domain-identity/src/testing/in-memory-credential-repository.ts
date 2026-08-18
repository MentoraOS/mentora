import type { Option, Result } from '@mentora/kernel';
import { err, none, ok, some } from '@mentora/kernel';

import type { Credential } from '../aggregate/credential.js';
import type { CredentialRefusal } from '../decisions/credential-refusal.js';
import { credentialRefusal } from '../decisions/credential-refusal.js';
import type { CredentialId, PersonId } from '../ids/identifiers.js';
import { ActiveCredentialUniquenessSpecification } from '../specifications/active-credential-uniqueness.specification.js';

/**
 * InMemoryCredentialRepository — the REFERENCE implementation of the
 * CredentialRepository port (I-10 precedent: InMemoryRelaySource): it
 * exhibits the exact behavior every real registry must replay, including
 * the DECLARED R-A key applied at retention (one ACTIVE credential per
 * person × principal-factor kind) and the version control (optimistic
 * concurrency, F5.2 §4). Pure class — no test-runner import: the barrel
 * stays loadable by a living process (the barrels lesson).
 *
 * The R-A refusal is voiced through the ratified transition family while
 * the dedicated reason name remains a recorded canon gap (persistence lot).
 */
export class InMemoryCredentialRepository {
  private readonly store = new Map<string, { credential: Credential; version: number }>();
  private readonly uniqueness = new ActiveCredentialUniquenessSpecification();

  byId(id: CredentialId): Promise<Option<Credential>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found.credential));
  }

  activeByPersonAndKind(personId: PersonId, principalFactorKind: string): Promise<Option<Credential>> {
    for (const { credential } of this.store.values()) {
      if (
        credential.state.kind === 'Active' &&
        credential.personId === personId &&
        credential.principalFactor.kind === principalFactorKind
      ) {
        return Promise.resolve(some(credential));
      }
    }
    return Promise.resolve(none);
  }

  retain(credential: Credential): Promise<Result<void, CredentialRefusal>> {
    const existing = this.store.get(credential.id);
    const expectedPrevious = credential.version - credential.pendingFacts.length;
    if (existing !== undefined && existing.version !== expectedPrevious) {
      // Version conflict is a transient FAILURE in real registries (S-3);
      // the reference voices it as an Error the caller's pipeline retries.
      return Promise.reject(
        new Error(
          `version conflict on ${credential.id}: retained ${existing.version}, expected ${expectedPrevious}`,
        ),
      );
    }
    // THE R-A KEY, applied structurally at retention.
    for (const { credential: other } of this.store.values()) {
      if (this.uniqueness.conflicts(credential, other)) {
        return Promise.resolve(
          err(
            credentialRefusal(
              'TransitionUnavailable',
              'An ACTIVE Credential already exists for this person and principal factor (R-A key)',
            ),
          ),
        );
      }
    }
    this.store.set(credential.id, {
      credential: credential.retained(),
      version: credential.version,
    });
    return Promise.resolve(ok(undefined));
  }
}
