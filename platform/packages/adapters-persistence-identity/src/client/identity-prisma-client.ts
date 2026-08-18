import { PrismaClient } from '../generated/prisma/client.js';

/**
 * The engine-client factory of the Identity & Access registries — the
 * GENERATED Prisma client belongs to THIS package (its schema lives here;
 * the `prisma-client` generator emits package-local ESM TypeScript, so the
 * Agreement package's generation is never overwritten). The executable's
 * Root calls this factory (F4.4 §2: concrete types live at the Root — and
 * the Root receives them from the adapter that owns them).
 */
export type IdentityPrismaClient = PrismaClient;

export const createIdentityPrismaClient = (databaseUrl: string): IdentityPrismaClient =>
  new PrismaClient({ datasources: { db: { url: databaseUrl } } });
