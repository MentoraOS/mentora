/**
 * @mentora/runtime-serialization — deterministic runtime serialization.
 * The published-language serializers of the contracts packages remain the
 * owners of their contracts (V-1); the dialects die at the adapter (S-2).
 * Reserved words honored: nothing here is named Snapshot, Journal or
 * Export (F5.2 §12 — their technical doubles carry other names).
 */

export * from './canonical-json.js';
export * from './serializers.js';
export * from './versioned-payload.js';
export * from './checksum.js';
