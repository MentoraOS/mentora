import { credentialRepositoryContractSuite } from './testing/credential-repository-contract-suite.js';
import { InMemoryCredentialRepository } from './testing/in-memory-credential-repository.js';

/**
 * The reference implementation replays the port's promises (I-10). The
 * PostgreSQL registry of the persistence lot (#64/#68) will replay the SAME
 * suite via '@mentora/domain-identity/contract-suite'.
 */
credentialRepositoryContractSuite('InMemoryCredentialRepository', {
  make: () => Promise.resolve({ repository: new InMemoryCredentialRepository() }),
});
