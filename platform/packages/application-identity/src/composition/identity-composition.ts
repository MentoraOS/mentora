import type { CommandCarrier, SequenceJournalPort } from '@mentora/application-kernel';
import { CommandDispatch, QueryDispatch, ReactionDispatch } from '@mentora/application-kernel';
import { IDENTITY_COMMAND_TYPES, SESSION_COMMAND_TYPES } from '@mentora/contracts-identity';
import type {
  CredentialRepository,
  ProofRequirementPolicyParams,
  SessionRepository,
} from '@mentora/domain-identity';
import { ProofRequirementPolicy } from '@mentora/domain-identity';
import type { Clock } from '@mentora/kernel';
import { invariant } from '@mentora/kernel';

import type {
  CredentialStateReadPort,
  SessionStateReadPort,
} from '../read/ports/identity-state-read.port.js';
import { EstablishCredentialApplicationService } from '../services/establish-credential.application-service.js';
import type { IdentitySequenceMachinery } from '../services/identity-sequence.application-service.js';
import { RevokeCredentialApplicationService } from '../services/revoke-credential.application-service.js';
import {
  EndSessionApplicationService,
  OpenSessionApplicationService,
  RevokeSessionApplicationService,
} from '../services/session-application-services.js';

/**
 * THE COMPOSITION of the Identity & Access context — F4.4 §2 verbatim, the
 * frozen composeAgreement pattern replicated: the Root is "le seul endroit
 * du système où des types concrets existent"; PURE DEPENDENCY INJECTION —
 * no locator, no hidden singleton, no container; above the Root everything
 * RECEIVES (I-2). The executable's Root (FEATURE-005, Sprint 3) calls
 * `composeIdentityAccess` with its real adapters and receives the complete,
 * boot-validated graph. Tests exercise it today with the references.
 */

/** What the executable's Root PROVIDES: implementations and configuration. */
export interface IdentityCompositionProviders {
  /** The registry ports — the domain's law, adapters below (I-12). */
  readonly credentialRepository: CredentialRepository;
  readonly sessionRepository: SessionRepository;
  /** The gate's read capabilities (M-10 consumer — NOT Queries; see the ports). */
  readonly credentialStateRead: CredentialStateReadPort;
  readonly sessionStateRead: SessionStateReadPort;

  /** The machinery — injected, never ambient (A-6). */
  readonly clock: Clock;
  readonly commandJournal: SequenceJournalPort;

  /** PRODUCT configuration (I-5): the published Policy parameters. */
  readonly product: {
    readonly proofRequirement: ProofRequirementPolicyParams;
  };

  /** TECHNICAL configuration (I-5: "comment vite", bounded — M-8). */
  readonly technical?: {
    readonly commandMaxAttempts?: number;
  };
}

/** The complete, validated Identity & Access graph the composition yields. */
export interface IdentityAccessAssembly {
  readonly commandDispatch: CommandDispatch;
  readonly queryDispatch: QueryDispatch;
  readonly reactionDispatch: ReactionDispatch;
  readonly services: {
    readonly establishCredential: EstablishCredentialApplicationService;
    readonly revokeCredential: RevokeCredentialApplicationService;
    readonly openSession: OpenSessionApplicationService;
    readonly endSession: EndSessionApplicationService;
    readonly revokeSession: RevokeSessionApplicationService;
  };
  readonly policies: {
    readonly proofRequirement: ProofRequirementPolicy;
  };
  /** Pass-through for the M-10 gate's Root wiring (Sprint 3). */
  readonly readPorts: {
    readonly credentialState: CredentialStateReadPort;
    readonly sessionState: SessionStateReadPort;
  };
  readonly machinery: {
    readonly clock: Clock;
    readonly commandJournal: SequenceJournalPort;
  };
}

/** The ratified catalogue 70-74 — the closed law of the command table. */
const RATIFIED_IDENTITY_COMMANDS: readonly string[] = [
  ...IDENTITY_COMMAND_TYPES,
  ...SESSION_COMMAND_TYPES,
];

export const composeIdentityAccess = (
  providers: IdentityCompositionProviders,
): IdentityAccessAssembly => {
  // ---- the Policy: built HERE with its injected PRODUCT parameters
  // (F4.1 §4: "construites … au démarrage, injectées ; jamais en chemin").
  const proofRequirement = new ProofRequirementPolicy(providers.product.proofRequirement);

  // ---- ONE shared machinery for the whole command side (A-6: one clock;
  // A-10: one correlated journal), technical retry budget bounded (M-8).
  const machinery: IdentitySequenceMachinery = {
    clock: providers.clock,
    journal: providers.commandJournal,
    ...(providers.technical?.commandMaxAttempts !== undefined
      ? { maxAttempts: providers.technical.commandMaxAttempts }
      : {}),
  };

  // ---- the FIVE Application Services (A-1: one Command, one carrier).
  const services = {
    establishCredential: new EstablishCredentialApplicationService(
      { repository: providers.credentialRepository },
      machinery,
    ),
    revokeCredential: new RevokeCredentialApplicationService(
      { repository: providers.credentialRepository },
      machinery,
    ),
    openSession: new OpenSessionApplicationService(
      { repository: providers.sessionRepository, proofRequirement },
      machinery,
    ),
    endSession: new EndSessionApplicationService(
      { repository: providers.sessionRepository },
      machinery,
    ),
    revokeSession: new RevokeSessionApplicationService(
      { repository: providers.sessionRepository },
      machinery,
    ),
  } as const;

  // ---- the Dispatchers AND THEIR TABLES (F4.4 §2) — closed, declared here.
  const commandCarriers: readonly CommandCarrier[] = [
    {
      commandType: 'EstablishCredential',
      execute: (input) => services.establishCredential.execute(input),
    },
    {
      commandType: 'RevokeCredential',
      execute: (input) => services.revokeCredential.execute(input),
    },
    { commandType: 'OpenSession', execute: (input) => services.openSession.execute(input) },
    { commandType: 'EndSession', execute: (input) => services.endSession.execute(input) },
    { commandType: 'RevokeSession', execute: (input) => services.revokeSession.execute(input) },
  ];
  const commandDispatch = new CommandDispatch(commandCarriers);

  // The query table is CLOSED AND EMPTY by constitutional state: the
  // ratified lecture catalogue (F3.3 §5) holds 11 Queries and NONE belongs
  // to Identity & Access. Declaring one here would complete the Corpus —
  // forbidden. The gate's session check is a capability PORT (readPorts),
  // never a public read (see identity-state-read.port.ts).
  const queryDispatch = new QueryDispatch([]);

  // The reaction table is CLOSED AND EMPTY by constitutional state: the
  // credential→sessions cascade is a FUTURE Réaction (consuming
  // CredentialRevoked over the relay; #118 will prove its latency) — not
  // ratified as code today. The cascade PROBE exists (activeByCredential);
  // the subscription does not.
  const reactionDispatch = new ReactionDispatch([]);

  // ---- BOOT VALIDATION, fail closed (F4.4 §7: "chaque Command a son
  // porteur unique … Une seule erreur = pas de démarrage").
  const carried = new Set(commandDispatch.commandTypes);
  for (const commandType of RATIFIED_IDENTITY_COMMANDS) {
    invariant(
      carried.has(commandType),
      `ratified Command '${commandType}' has no carrier — pas de démarrage (F4.4 §7)`,
    );
  }
  invariant(
    carried.size === RATIFIED_IDENTITY_COMMANDS.length,
    'the command table carries something outside the ratified catalogue 70-74 — pas de démarrage',
  );
  invariant(
    queryDispatch.queryTypes.length === 0,
    'no Identity & Access lecture is ratified (F3.3 §5) — a non-empty query table completes the Corpus',
  );

  return {
    commandDispatch,
    queryDispatch,
    reactionDispatch,
    services,
    policies: { proofRequirement },
    readPorts: {
      credentialState: providers.credentialStateRead,
      sessionState: providers.sessionStateRead,
    },
    machinery: { clock: providers.clock, commandJournal: providers.commandJournal },
  };
};
