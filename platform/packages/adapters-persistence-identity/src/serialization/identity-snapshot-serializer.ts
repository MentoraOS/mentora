import type { CredentialSnapshot, SessionSnapshot } from '@mentora/domain-identity';
import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import {
  canonicalJson,
  fnv1aChecksum,
  readVersionedPayload,
  versionedPayload,
} from '@mentora/runtime-serialization';

/**
 * The PRIVATE photographs' bytes (RC-1 §1/§2): canonical JSON (same unit →
 * same text, always) wrapped in a VersionedPayload (formatVersion 1;
 * evolution ADDITIVE ONLY — a breaking change is an expand-contract
 * migration, S-7). Never crosses a port. One serializer pair per registry;
 * the mechanics are shared, the formats are each registry's own.
 */

export const SNAPSHOT_FORMAT_VERSION = 1;

export interface SerializedSnapshot {
  readonly payload: string;
  readonly checksum: string;
}

/** FNV-1a — the fingerprint demonstrates, never decides. */
export const identitySnapshotChecksum = (payload: string): string =>
  fnv1aChecksum.checksum(payload);

const serialize = (snapshot: unknown, subject: string): SerializedSnapshot => {
  const text = canonicalJson(versionedPayload(SNAPSHOT_FORMAT_VERSION, snapshot));
  if (!text.ok) {
    // A frozen-domain snapshot always canonicalizes; failing here is a defect.
    throw new Error(`the ${subject} photograph refused to canonicalize: ${text.error.message}`);
  }
  return { payload: text.value, checksum: identitySnapshotChecksum(text.value) };
};

const deserialize = <T>(payload: string): Result<T, string> => {
  let parsed: unknown;
  try {
    parsed = JSON.parse(payload);
  } catch {
    return err('payload is not JSON');
  }
  const versioned = readVersionedPayload(parsed);
  if (!versioned.ok) {
    return err(versioned.error.message);
  }
  if (versioned.value.version !== SNAPSHOT_FORMAT_VERSION) {
    return err(`unknown photograph format v${String(versioned.value.version)}`);
  }
  return ok(versioned.value.payload as T);
};

export const serializeCredentialSnapshot = (snapshot: CredentialSnapshot): SerializedSnapshot =>
  serialize(snapshot, 'Credential');

export const deserializeCredentialSnapshot = (payload: string): Result<CredentialSnapshot, string> =>
  deserialize<CredentialSnapshot>(payload);

export const serializeSessionSnapshot = (snapshot: SessionSnapshot): SerializedSnapshot =>
  serialize(snapshot, 'Session');

export const deserializeSessionSnapshot = (payload: string): Result<SessionSnapshot, string> =>
  deserialize<SessionSnapshot>(payload);
