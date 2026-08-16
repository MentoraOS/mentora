import type { Result } from '@mentora/kernel';
import { err, ok } from '@mentora/kernel';

import { canonicalJson } from './canonical-json.js';
import type { SerializationViolation } from './canonical-json.js';

/** Text serialization surfaces — runtime machinery, never a contract owner (V-1). */

export interface Serializer {
  serialize(value: unknown): Result<string, SerializationViolation>;
}

export interface Deserializer {
  deserialize(text: string): Result<unknown, SerializationViolation>;
}

/** Plain JSON — order as given (transport wells that do not demand canonicity). */
export const jsonSerializer: Serializer = {
  serialize: (value) => {
    try {
      const text = JSON.stringify(value) as string | undefined;
      if (text === undefined) {
        return err({ code: 'SERIAL.UNSUPPORTED', message: 'the value has no JSON text' });
      }
      return ok(text);
    } catch {
      return err({ code: 'SERIAL.CYCLE', message: 'the value cycles' });
    }
  },
};

/** Deterministic serializer — canonical JSON (same value, same text, always). */
export const deterministicSerializer: Serializer = {
  serialize: canonicalJson,
};

export const jsonDeserializer: Deserializer = {
  deserialize: (text) => {
    try {
      return ok(JSON.parse(text));
    } catch {
      return err({ code: 'SERIAL.MALFORMED', message: 'the text is not JSON' });
    }
  },
};

/** UTF-8 text ↔ bytes (globals only, no runtime import). */
export interface BinarySerializer {
  toBytes(text: string): Uint8Array;
  fromBytes(bytes: Uint8Array): string;
}

export const utf8BinarySerializer: BinarySerializer = {
  toBytes: (text) => new TextEncoder().encode(text),
  fromBytes: (bytes) => new TextDecoder('utf-8', { fatal: true }).decode(bytes),
};

/** Compression, ABSTRACT: real codecs are adapter resources (I-11). */
export interface CompressionStrategy {
  readonly name: string;
  compress(bytes: Uint8Array): Uint8Array;
  decompress(bytes: Uint8Array): Uint8Array;
}

export const identityCompression: CompressionStrategy = {
  name: 'identity',
  compress: (bytes) => bytes,
  decompress: (bytes) => bytes,
};
