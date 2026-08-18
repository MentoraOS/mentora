import { InMemorySessionRepository } from './testing/in-memory-session-repository.js';
import { sessionRepositoryContractSuite } from './testing/session-repository-contract-suite.js';

/** The reference replays the port's promises (I-10); PostgreSQL will replay the SAME suite. */
sessionRepositoryContractSuite('InMemorySessionRepository', {
  make: () => Promise.resolve({ repository: new InMemorySessionRepository() }),
});
