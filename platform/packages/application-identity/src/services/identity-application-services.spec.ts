import { RecordingJournal } from '@mentora/application-kernel';
import type { ActorRef, CorrelationId } from '@mentora/contracts';
import type { Credential, CredentialRefusal, CredentialRepository } from '@mentora/domain-identity';
import { credentialRefusal } from '@mentora/domain-identity';
import type { Option, Result } from '@mentora/kernel';
import { instantOf, none, ok, err, some } from '@mentora/kernel';
import { FakeClock } from '@mentora/testing-clock';
import { describe, expect, it } from 'vitest';

import { EstablishCredentialApplicationService } from './establish-credential.application-service.js';
import type { IdentitySequenceMachinery } from './identity-sequence.application-service.js';

/**
 * Conformity to the Séquence (F4.1 §10): the carrier is driven END TO END
 * with WIRE payloads through the Golden Pipeline — reception by the
 * published language, injections, loading, the seam, the unit's Decision,
 * atomic retention. The pipeline of 1C-2 is REUSED, never reimplemented.
 */

const T0 = instantOf(1_000_000_000);
const ACTOR = 'actor-1' as ActorRef;
const CORRELATION = 'corr-1' as CorrelationId;

class InMemoryCredentialRepository implements CredentialRepository {
  private readonly store = new Map<string, Credential>();
  structuralRefusal = false;

  byId(id: Credential['id']): Promise<Option<Credential>> {
    const found = this.store.get(id);
    return Promise.resolve(found === undefined ? none : some(found));
  }

  activeByPersonAndKind(): Promise<Option<Credential>> {
    return Promise.resolve(none);
  }

  retain(credential: Credential): Promise<Result<void, CredentialRefusal>> {
    if (this.structuralRefusal) {
      // The registry's structural R-A refusal — reason name is a recorded
      // canon gap; the generic transition family stands in for the double.
      return Promise.resolve(
        err(credentialRefusal('TransitionUnavailable', 'structural key refused (double)')),
      );
    }
    this.store.set(credential.id, credential.retained());
    return Promise.resolve(ok(undefined));
  }
}

const harness = () => {
  const repository = new InMemoryCredentialRepository();
  const journal = new RecordingJournal();
  const machinery: IdentitySequenceMachinery = {
    clock: FakeClock.at(T0),
    journal,
  };
  const service = new EstablishCredentialApplicationService({ repository }, machinery);
  return { repository, journal, service };
};

const wireOf = (over: Record<string, unknown> = {}): Record<string, unknown> => ({
  type: 'EstablishCredential',
  contractVersion: 1,
  commandId: 'cmd-1',
  credentialId: 'cred-1',
  personId: 'person-1',
  principalFactor: { factorId: 'factor-1', kind: 'password', strength: 'standard' },
  ...over,
});

describe('EstablishCredentialApplicationService — conformity to the Séquence', () => {
  it('executes the birth end to end: wire → pipeline → Active unit retained, instant injected', async () => {
    const { repository, service } = harness();
    const outcome = await service.execute({
      payload: wireOf(),
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('executed');
    const retained = await repository.byId('cred-1' as Credential['id']);
    expect(retained.some).toBe(true);
    if (retained.some) {
      expect(retained.value.state.kind).toBe('Active');
      expect(retained.value.principalFactor.kind).toBe('password');
      if (retained.value.state.kind === 'Active') {
        expect(retained.value.state.establishedAt.epochMillis).toBe(T0.epochMillis);
      }
    }
  });

  it('refuses a birth under an inhabited Identifier — R-B, a VALUE, journaled as refusal', async () => {
    const { service } = harness();
    await service.execute({ payload: wireOf(), actor: ACTOR, correlationId: CORRELATION });
    const second = await service.execute({
      payload: wireOf({ commandId: 'cmd-2' }),
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(second.kind).toBe('refused');
    if (second.kind === 'refused') {
      expect(second.refusal.reason).toBe('TransitionUnavailable');
    }
  });

  it('malformed wire dies at reception — the Exception channel, never a Refusal', async () => {
    const { service } = harness();
    const outcome = await service.execute({
      payload: wireOf({ personId: '' }),
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('exception');
  });

  it('a wire of ANOTHER use case is the caller defect (A-1: one carrier)', async () => {
    const { service } = harness();
    const outcome = await service.execute({
      payload: { ...wireOf(), type: 'RevokeCredential' },
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('exception');
  });

  it('the structural refusal of the registry surfaces as the Decision (never an error)', async () => {
    const { repository, service } = harness();
    repository.structuralRefusal = true;
    const outcome = await service.execute({
      payload: wireOf(),
      actor: ACTOR,
      correlationId: CORRELATION,
    });
    expect(outcome.kind).toBe('refused');
  });
});
