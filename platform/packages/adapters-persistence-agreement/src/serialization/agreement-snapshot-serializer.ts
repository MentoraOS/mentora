import type { AgreementSnapshot } from '@mentora/domain-agreement';
import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';
import {
  canonicalJson,
  fnv1aChecksum,
  readVersionedPayload,
  versionedPayload,
} from '@mentora/runtime-serialization';

/**
 * AgreementSnapshotSerializer — the PRIVATE photograph's bytes (RC-1 §1/§2):
 * canonical JSON (same unit → same text, always) wrapped in a
 * VersionedPayload (formatVersion 1; evolution ADDITIVE ONLY — a breaking
 * change is an expand-contract migration, S-7). Never crosses a port.
 */

export const SNAPSHOT_FORMAT_VERSION = 1;

export interface SerializedSnapshot {
  readonly payload: string;
  readonly checksum: string;
}

export const serializeAgreementSnapshot = (snapshot: AgreementSnapshot): SerializedSnapshot => {
  const text = canonicalJson(versionedPayload(SNAPSHOT_FORMAT_VERSION, snapshot));
  if (!text.ok) {
    // A frozen-domain snapshot always canonicalizes; failing here is a defect.
    throw new Error(`the Agreement photograph refused to canonicalize: ${text.error.message}`);
  }
  return { payload: text.value, checksum: agreementSnapshotChecksum(text.value) };
};

export const deserializeAgreementSnapshot = (
  payload: string,
): Result<AgreementSnapshot, string> => {
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
  return ok(versioned.value.payload as AgreementSnapshot);
};

/** AgreementSnapshotChecksum — FNV-1a: the fingerprint demonstrates, never decides. */
export const agreementSnapshotChecksum = (payload: string): string =>
  fnv1aChecksum.checksum(payload);
