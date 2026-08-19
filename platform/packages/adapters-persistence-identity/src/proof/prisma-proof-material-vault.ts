import type { PasswordHasher } from '@mentora/runtime-security';

import type { PrismaClient } from '../generated/prisma/client.js';

/**
 * PrismaProofMaterialVault — the DEV VAULT adapter of the proof-material
 * port (Story #96, "hash sous coffre"). The matter enters ONCE (sealed to
 * a one-way scrypt digest before touching the engine) and never exits:
 * `verify` answers a boolean, nothing else — no read-back surface exists
 * (I-8: one place for the secret; elsewhere only its NAME, the factorId).
 * The future ACL of the Account stores on establish; the entry verifies.
 * A production vault (KMS/HSM-backed) is an alternative adapter of the
 * same port — the port is the law, this is a mechanism (S-1).
 */
export class PrismaProofMaterialVault {
  constructor(
    private readonly prisma: PrismaClient,
    private readonly hasher: PasswordHasher,
  ) {}

  /** Seal material under a factor's NAME — upsert: re-establishing re-seals. */
  async store(factorId: string, kind: string, material: string): Promise<void> {
    const digest = await this.hasher.hash(material);
    await this.prisma.proofMaterial.upsert({
      where: { factorId },
      create: { factorId, kind, digest },
      update: { kind, digest },
    });
  }

  /** The ONLY read: a demonstration, never a revelation (T-24). */
  async verify(factorId: string, material: string): Promise<boolean> {
    const row = await this.prisma.proofMaterial.findUnique({ where: { factorId } });
    if (row === null) {
      return false;
    }
    return this.hasher.verify(material, row.digest);
  }

  /** Recovery hygiene (Story #104): a revoked credential's factor names are DISOWNED. */
  async disown(factorIds: readonly string[]): Promise<void> {
    await this.prisma.proofMaterial.deleteMany({ where: { factorId: { in: [...factorIds] } } });
  }
}
