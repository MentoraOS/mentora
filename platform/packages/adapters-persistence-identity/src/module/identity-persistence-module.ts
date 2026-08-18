import type { RuntimeModule } from '@mentora/runtime-bootstrap';

import type { PrismaClient } from '../generated/prisma/client.js';

/**
 * IdentityPersistenceModule — the lifecycle owner of the registries' engine
 * client (I-11: "toute ressource a un propriétaire-composant … construire →
 * démarrer → drainer → libérer; l'enregistrement au cycle de vie est une
 * condition d'assemblage"). The executable's Root registers it in its
 * RuntimeBuilder; it dies in reverse order with everything else. Crash
 * remains are waste, never inheritance (F5.1 §19).
 */
export class IdentityPersistenceModule implements RuntimeModule {
  readonly name = 'identity-persistence';

  constructor(private readonly prisma: PrismaClient) {}

  async construct(): Promise<void> {
    await this.prisma.$connect();
  }

  async dispose(): Promise<void> {
    await this.prisma.$disconnect();
  }
}
