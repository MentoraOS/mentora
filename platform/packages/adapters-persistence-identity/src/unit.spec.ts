import { validateIdentityEvent } from '@mentora/contracts-identity';
import { describe, expect, it } from 'vitest';

import {
  classifyIdentityEngineError,
  previousCredentialVersionOf,
  previousSessionVersionOf,
} from './concurrency/identity-optimistic-concurrency-guard.js';
import { toFactRow, toWireFact } from './fact-stream/credential-fact-mapper.js';
import { ScryptPasswordHasher } from './proof/scrypt-password-hasher.js';
import {
  identitySnapshotChecksum,
  serializeCredentialSnapshot,
} from './serialization/identity-snapshot-serializer.js';
import { toCredentialRow, toCredentialUnit } from './snapshot/credential-snapshot-mapper.js';
import { toSessionRow, toSessionUnit } from './snapshot/session-snapshot-mapper.js';
import { IdentityPersistenceMother } from './testing/identity-persistence-mother.js';

const mother = new IdentityPersistenceMother();

describe('the private photographs (serializer + mappers)', () => {
  it('round-trips a Credential byte-identically through its own doors (S-2)', () => {
    const unit = mother.revoked().retained();
    const row = toCredentialRow(unit);
    expect(row.stateKind).toBe('Revoked');
    expect(row.version).toBe(2);
    expect(row.principalFactorKind).toBe('password');
    const back = toCredentialUnit(row);
    expect(back.snapshot()).toEqual(unit.snapshot());
    // Determinism: same unit, same bytes, always.
    expect(toCredentialRow(unit).payload).toBe(row.payload);
    expect(toCredentialRow(unit).checksum).toBe(row.checksum);
  });

  it('round-trips a Session — state only, both terminals faithful', () => {
    const unit = mother.ended();
    const row = toSessionRow(unit);
    expect(row.stateKind).toBe('Ended');
    expect(row.credentialId).toBe('cred-1');
    const back = toSessionUnit(row);
    expect(back.snapshot()).toEqual(unit.snapshot());
  });

  it('a corrupted checksum is an EXCEPTION, never a lying unit (PERSIST.CORRUPTION)', () => {
    const credentialRow = toCredentialRow(mother.established().retained());
    expect(() => toCredentialUnit({ ...credentialRow, checksum: 'deadbeef' })).toThrow(/corrupted/);
    const sessionRow = toSessionRow(mother.opened());
    expect(() => toSessionUnit({ ...sessionRow, checksum: 'deadbeef' })).toThrow(/corrupted/);
  });

  it('a malformed or foreign-format payload is an EXCEPTION', () => {
    const row = toCredentialRow(mother.established().retained());
    const malformed = { ...row, payload: '{broken', checksum: identitySnapshotChecksum('{broken') };
    expect(() => toCredentialUnit(malformed)).toThrow(/corrupted/);
    const foreign = JSON.stringify({ version: 99, payload: {} });
    expect(() =>
      toCredentialUnit({ ...row, payload: foreign, checksum: identitySnapshotChecksum(foreign) }),
    ).toThrow(/unknown photograph format/);
  });

  it('the serializer wraps in VersionedPayload v1', () => {
    const snapshot = mother.established().snapshot();
    const serialized = serializeCredentialSnapshot(snapshot);
    const parsed = JSON.parse(serialized.payload) as { version: number };
    expect(parsed.version).toBe(1);
  });
});

describe('the fact-mapper — every wire fact conforms to the PUBLISHED language (V-1)', () => {
  it('maps BOTH frozen facts to validator-clean wire contracts', () => {
    const unit = mother.revoked();
    for (const fact of unit.pendingFacts) {
      const wire = toWireFact(fact);
      const verdict = validateIdentityEvent(wire);
      expect(verdict.ok).toBe(true);
    }
    const wires = unit.pendingFacts.map(toWireFact);
    expect(wires.map((wire) => wire.type)).toEqual(['CredentialEstablished', 'CredentialRevoked']);
  });

  it('a fact row carries the deterministic payload and its checksum', () => {
    const [fact] = mother.established('cred-9', 'person-9').pendingFacts;
    if (fact === undefined) throw new Error('unreachable');
    const row = toFactRow(fact);
    expect(row.credentialId).toBe('cred-9');
    expect(row.sequence).toBe(1);
    expect(row.checksum).toBe(identitySnapshotChecksum(row.payload));
    // No matter, ever: natures and references only.
    expect(row.payload).toContain('"principalFactorKind":"password"');
    expect(row.payload).not.toMatch(/secret|material/);
  });
});

describe('the concurrency guard — a comparison, never a lock', () => {
  it('computes the expected previous versions (facts for Credential, one step for Session)', () => {
    expect(previousCredentialVersionOf(mother.established())).toBe(0);
    expect(previousCredentialVersionOf(mother.revoked())).toBe(0);
    expect(previousCredentialVersionOf(mother.established().retained())).toBe(1);
    expect(previousSessionVersionOf(mother.opened())).toBe(0);
    expect(previousSessionVersionOf(mother.ended())).toBe(1);
  });

  it('classifies engine collisions into their lawful channels — both spellings of the key', () => {
    expect(
      classifyIdentityEngineError(new Error('violates "credential_active_principal_ra_key"')),
    ).toBe('ra-key');
    expect(
      classifyIdentityEngineError(
        new Error('P2002 Unique constraint failed on the fields: (`personId`,`principalFactorKind`)'),
      ),
    ).toBe('ra-key');
    expect(
      classifyIdentityEngineError(
        new Error('23505 duplicate key value violates "CredentialSnapshot_pkey"'),
      ),
    ).toBe('version-conflict');
    expect(
      classifyIdentityEngineError(
        new Error('P2002 Unique constraint failed on the fields: (`sessionId`)'),
      ),
    ).toBe('version-conflict');
    expect(classifyIdentityEngineError(new Error('connection refused'))).toBe('engine');
    expect(classifyIdentityEngineError('not-an-error')).toBe('engine');
  });
});

describe('ScryptPasswordHasher (Story #97) — the platform KDF, self-describing digest, constant-time verify', () => {
  const hasher = new ScryptPasswordHasher();

  it('hashes and verifies; two digests of the same material differ (fresh salt)', async () => {
    const first = await hasher.hash('material-1');
    const second = await hasher.hash('material-1');
    expect(first).not.toBe(second);
    expect(first.startsWith('scrypt$16384$8$1$')).toBe(true);
    expect(await hasher.verify('material-1', first)).toBe(true);
    expect(await hasher.verify('material-1', second)).toBe(true);
  });

  it('refuses the wrong material and every malformed digest — false, never a throw', async () => {
    const digest = await hasher.hash('material-1');
    expect(await hasher.verify('material-2', digest)).toBe(false);
    expect(await hasher.verify('material-1', 'not-a-digest')).toBe(false);
    expect(await hasher.verify('material-1', 'bcrypt$x$y$z$s$h')).toBe(false);
  });
});
