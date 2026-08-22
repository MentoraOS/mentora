import { accountRepositoryContractSuite } from './testing/account-repository-contract-suite.js';
import { availabilityFrameRepositoryContractSuite } from './testing/availability-frame-repository-contract-suite.js';
import {
  InMemoryAccountRepository,
  InMemoryAvailabilityFrameRepository,
} from './testing/in-memory-account-repository.js';

/**
 * The contract suites replayed on the REFERENCE implementations — the same
 * promises the PostgreSQL registries of Lot A04 must exhibit (I-10). The
 * references are proven here BEFORE any adapter exists (the CTO's rule:
 * contract suites before adapters, before persistence).
 */

accountRepositoryContractSuite('InMemoryAccountRepository', {
  make: () => Promise.resolve({ repository: new InMemoryAccountRepository() }),
});

availabilityFrameRepositoryContractSuite('InMemoryAvailabilityFrameRepository', {
  make: () => Promise.resolve({ repository: new InMemoryAvailabilityFrameRepository() }),
});
