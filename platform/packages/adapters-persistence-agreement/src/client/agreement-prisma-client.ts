import { PrismaClient } from '@prisma/client';

/**
 * The engine-client factory of the Agreement registry — the GENERATED
 * Prisma client belongs to THIS package (its schema lives here; hoist=false
 * keeps the generation local). The executable's Root calls this factory
 * (F4.4 §2: concrete types live at the Root — and the Root receives them
 * from the adapter that owns them, never by re-generating the vendor).
 */
export type AgreementPrismaClient = PrismaClient;

export const createAgreementPrismaClient = (databaseUrl: string): AgreementPrismaClient =>
  new PrismaClient({ datasources: { db: { url: databaseUrl } } });
