import type { AgreementPrismaClient } from '@mentora/adapters-persistence-agreement';
import type { IdentityPrismaClient } from '@mentora/adapters-persistence-identity';
import type { HealthRegistry } from '@mentora/runtime-health';
import { healthy, unhealthy } from '@mentora/runtime-health';
import type { RelayHealth } from '@mentora/runtime-relay';

/**
 * The executable's CLOSED, DECLARED health list (R-6): Readiness = "les
 * trois Séquences sont exécutables ici" — materialized as: the registry
 * engines answer (Agreement AND Identity — the gate reads the vestibule),
 * the relay sees its source. Liveness = the process — NEVER a business
 * judgment, never a backlog verdict.
 */
export const serverHealth = (
  registry: HealthRegistry,
  prisma: AgreementPrismaClient,
  identityPrisma: IdentityPrismaClient,
  relay: RelayHealth,
): void => {
  registry.register({
    name: 'registry-engine',
    kind: 'readiness',
    check: async () => {
      try {
        await prisma.$queryRaw`SELECT 1`;
        return healthy();
      } catch (error) {
        return unhealthy(error instanceof Error ? error.message : String(error));
      }
    },
  });
  registry.register({
    name: 'identity-registry-engine',
    kind: 'readiness',
    check: async () => {
      try {
        await identityPrisma.$queryRaw`SELECT 1`;
        return healthy();
      } catch (error) {
        return unhealthy(error instanceof Error ? error.message : String(error));
      }
    },
  });
  registry.register(relay.readinessCheck());
  registry.register(relay.livenessCheck());
};
