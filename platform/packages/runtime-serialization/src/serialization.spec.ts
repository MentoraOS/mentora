import { describe, expect, it } from 'vitest';

import { canonicalJson } from './canonical-json.js';
import { fnv1a32Hex, fnv1aChecksum } from './checksum.js';
import {
  deterministicSerializer,
  identityCompression,
  jsonDeserializer,
  jsonSerializer,
  utf8BinarySerializer,
} from './serializers.js';
import { readVersionedPayload, versionedPayload } from './versioned-payload.js';

describe('canonicalJson (same value → same text, always)', () => {
  it('sorts keys recursively — permutations collapse to ONE text', () => {
    const a = canonicalJson({ z: 1, a: { d: [3, { y: 1, x: 2 }], c: 'v' } });
    const b = canonicalJson({ a: { c: 'v', d: [3, { x: 2, y: 1 }] }, z: 1 });
    expect(a.ok && b.ok && a.value).toBe(b.ok && b.value);
    expect(a.ok && a.value).toBe('{"a":{"c":"v","d":[3,{"x":2,"y":1}]},"z":1}');
  });

  it('drops undefined object fields and refuses cycles and non-finite numbers', () => {
    const clean = canonicalJson({ kept: 1, dropped: undefined });
    expect(clean.ok && clean.value).toBe('{"kept":1}');
    const cyclic: Record<string, unknown> = {};
    cyclic['self'] = cyclic;
    const cycle = canonicalJson(cyclic);
    expect(!cycle.ok && cycle.error.code).toBe('SERIAL.CYCLE');
    const infinite = canonicalJson({ n: Number.POSITIVE_INFINITY });
    expect(!infinite.ok && infinite.error.code).toBe('SERIAL.UNSUPPORTED');
  });
});

describe('serializers', () => {
  it('deterministicSerializer serializes canonically; jsonDeserializer round-trips', () => {
    const text = deterministicSerializer.serialize({ b: 2, a: 1 });
    expect(text.ok && text.value).toBe('{"a":1,"b":2}');
    const back = jsonDeserializer.deserialize('{"a":1,"b":2}');
    expect(back.ok && back.value).toEqual({ a: 1, b: 2 });
  });

  it('malformed text and unsupported values are violations, never throws', () => {
    expect(jsonDeserializer.deserialize('{nope').ok).toBe(false);
    expect(jsonSerializer.serialize(undefined).ok).toBe(false);
  });

  it('utf8 bytes round-trip, accents included', () => {
    const bytes = utf8BinarySerializer.toBytes('Séquence échue — n°42');
    expect(utf8BinarySerializer.fromBytes(bytes)).toBe('Séquence échue — n°42');
  });

  it('identityCompression is a faithful no-op', () => {
    const bytes = new Uint8Array([1, 2, 3]);
    expect(identityCompression.decompress(identityCompression.compress(bytes))).toEqual(bytes);
  });
});

describe('versioned payloads (the wrapper carries, the owner judges — V-1)', () => {
  it('round-trips and validates the declared generation', () => {
    const wrapped = versionedPayload(2, { agreementId: 'agr-1' });
    const read = readVersionedPayload(wrapped);
    expect(read.ok && read.value).toEqual({ version: 2, payload: { agreementId: 'agr-1' } });
  });

  it('refuses non-objects, non-integer versions and missing payloads', () => {
    expect(readVersionedPayload('text').ok).toBe(false);
    expect(readVersionedPayload({ version: 0, payload: {} }).ok).toBe(false);
    expect(readVersionedPayload({ version: 1.5, payload: {} }).ok).toBe(false);
    expect(readVersionedPayload({ version: 1 }).ok).toBe(false);
  });
});

describe('checksums (a fingerprint demonstrates, never decides)', () => {
  it('is stable and collision-sensitive on known vectors', () => {
    expect(fnv1a32Hex('')).toBe('811c9dc5');
    expect(fnv1a32Hex('a')).toBe('e40c292c');
    expect(fnv1aChecksum.checksum('mentora')).toBe(fnv1aChecksum.checksum('mentora'));
    expect(fnv1aChecksum.checksum('mentora')).not.toBe(fnv1aChecksum.checksum('mentorb'));
    expect(fnv1aChecksum.algorithm).toBe('fnv1a-32');
  });
});

describe('remaining doors', () => {
  it('unsupported top-level values are violations — bigint, function, symbol, undefined', () => {
    for (const value of [BigInt(1), () => 1, Symbol('x'), undefined]) {
      const out = canonicalJson(value);
      expect(!out.ok && out.error.code).toBe('SERIAL.UNSUPPORTED');
    }
    const nul = canonicalJson(null);
    expect(nul.ok && nul.value).toBe('null');
    const truth = canonicalJson(true);
    expect(truth.ok && truth.value).toBe('true');
  });

  it('jsonSerializer serializes plainly and reports cycles as violations', () => {
    const plain = jsonSerializer.serialize({ b: 2, a: 1 });
    expect(plain.ok && plain.value).toBe('{"b":2,"a":1}');
    const cyclic: Record<string, unknown> = {};
    cyclic['self'] = cyclic;
    const cycle = jsonSerializer.serialize(cyclic);
    expect(!cycle.ok && cycle.error.code).toBe('SERIAL.CYCLE');
  });

  it('an array is not a versioned payload', () => {
    expect(readVersionedPayload([1]).ok).toBe(false);
  });
});
