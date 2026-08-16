import type { IdGenerator } from '@mentora/kernel';

/**
 * UuidFactory — the runtime implementation of the kernel IdGenerator port
 * (the port stays with its consumers; this is the mechanism below). The ONE
 * vestibule of randomness for identities: UUIDs come from the platform
 * cryptographic source, never from Math.random.
 */
export class UuidFactory implements IdGenerator {
  generate(): string {
    return globalThis.crypto.randomUUID();
  }
}
