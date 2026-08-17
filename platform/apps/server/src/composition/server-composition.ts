import {
  createAgreementPrismaClient,
  AgreementFactStreamStore,
  AgreementOutboxStore,
  AgreementPersistenceModule,
  AgreementRetentionEngine,
  type AgreementPrismaClient,
  PrismaAgreementRelaySource,
  PrismaAgreementRepositoryAdapter,
  PrismaAgreementStateReadAdapter,
} from '@mentora/adapters-persistence-agreement';
import type { AgreementAssembly } from '@mentora/application-agreement';
import { composeAgreement } from '@mentora/application-agreement';
import type { SequenceJournalPort, ReadJournalPort } from '@mentora/application-kernel';
import type { ActorRef } from '@mentora/contracts';
import type { Clock } from '@mentora/kernel';
import { RuntimeBuilder } from '@mentora/runtime-bootstrap';
import type { RuntimeContainer } from '@mentora/runtime-bootstrap';
import { SystemClock } from '@mentora/runtime-clock';
import { HealthRegistry } from '@mentora/runtime-health';
import { UuidFactory } from '@mentora/runtime-identity';
import { consoleSink, createLoggerFactory } from '@mentora/runtime-logging';
import type { LoggerFactory } from '@mentora/runtime-logging';
import type { LogSink } from '@mentora/runtime-logging';
import type { MetricsRegistry } from '@mentora/runtime-metrics';
import { createMetricsRegistry } from '@mentora/runtime-metrics';
import {
  RelayDispatch,
  RelayHealth,
  RelayMetrics,
  RelayRetryEngine,
  RuntimeRelayModule,
} from '@mentora/runtime-relay';
import type { RelayPacer, RelayPublisherPort } from '@mentora/runtime-relay';
import { cryptoTraceIdSource, MemorySpanSink, RuntimeTrace } from '@mentora/runtime-tracing';

import type { ServerConfig } from '../config/server-config.js';
import { serverHealth } from '../health/server-health.js';
import { EmptyRoutingPublisher } from '../modules/empty-routing-publisher.js';
import { HttpServerModule } from '../modules/http-server-module.js';
import { LoggingSequenceJournal, LoggingReadJournal } from '../modules/logging-journals.js';

/**
 * THE COMPOSITION ROOT of the Mentora server — F4.4 §2: "le seul endroit du
 * système où des types concrets existent"; unique to THIS executable
 * (F4.4.99). Pure DI: the whole graph is built EXPLICITLY below — no
 * service locator, no resolve(), no get(). It builds the machinery, never
 * a truth (I-3).
 *
 * Dev-species note (F5.1 §3): this executable hosts the Application AND the
 * Relay — the mixed executable is "toléré en développement local";
 * production splits the species. SIGNALED.
 */

export interface ServerOverrides {
  readonly logSink?: LogSink;
  readonly clock?: Clock;
  readonly publisher?: RelayPublisherPort;
  readonly relayPacer?: RelayPacer;
  readonly httpPort?: number;
}

export interface ServerGraph {
  readonly container: RuntimeContainer;
  readonly assembly: AgreementAssembly;
  readonly prisma: AgreementPrismaClient;
  readonly loggers: LoggerFactory;
  readonly metrics: MetricsRegistry;
  readonly health: HealthRegistry;
  readonly http: HttpServerModule;
}

export const composeServer = (config: ServerConfig, overrides: ServerOverrides = {}): ServerGraph => {
  // ---- (3-8) machinery: logger, metrics, tracing, health, clock, identity.
  const clock = overrides.clock ?? new SystemClock();
  const loggers = createLoggerFactory({
    clock,
    sink: overrides.logSink ?? consoleSink,
    threshold: config.MENTORA_LOG_THRESHOLD as 'debug' | 'info' | 'warn' | 'error',
  });
  const rootLogger = loggers.loggerFor('server');
  const metrics = createMetricsRegistry(clock);
  const tracer = new RuntimeTrace({
    clock,
    source: cryptoTraceIdSource,
    sink: new MemorySpanSink(), // the telemetry well is interchangeable (O-10); a real well is an adapter.
  });
  const identity = new UuidFactory();

  // ---- (9-10) the engine client + the Agreement registry (2B-1).
  const prisma = createAgreementPrismaClient(config.MENTORA_AGREEMENT_DATABASE_URL);
  const repository = new PrismaAgreementRepositoryAdapter(
    prisma,
    new AgreementRetentionEngine(
      new AgreementFactStreamStore(),
      new AgreementOutboxStore(identity),
    ),
  );
  const readAdapter = new PrismaAgreementStateReadAdapter(
    prisma,
    config.MENTORA_TIME_TOOLING_ACTOR as ActorRef,
  );

  // ---- (11) the Agreement context over the REAL implementations (1C-7).
  const commandJournal: SequenceJournalPort = new LoggingSequenceJournal(
    loggers.loggerFor('journal-command'),
  );
  const readJournal: ReadJournalPort = new LoggingReadJournal(loggers.loggerFor('journal-read'));
  const assembly = composeAgreement({
    repository,
    stateReadPort: readAdapter,
    readRightsPort: readAdapter,
    clock,
    idGenerator: identity,
    commandJournal,
    readJournal,
    product: {
      reschedule: {
        minimumNoticeMillis: config.MENTORA_PRODUCT_RESCHEDULE_MIN_NOTICE_MILLIS,
        maximumReschedules: config.MENTORA_PRODUCT_RESCHEDULE_MAX_COUNT,
      },
      cancellation: { minimumNoticeMillis: config.MENTORA_PRODUCT_CANCEL_MIN_NOTICE_MILLIS },
    },
    technical: { commandMaxAttempts: config.MENTORA_COMMAND_MAX_ATTEMPTS },
  });

  // ---- (12) the relay over the SQL-bound Outbox de faits (2B-2 + binding).
  const relaySource = new PrismaAgreementRelaySource(prisma);
  const relayDispatch = new RelayDispatch(
    relaySource,
    overrides.publisher ?? new EmptyRoutingPublisher(loggers.loggerFor('relay')),
    new RelayRetryEngine({
      baseDelayMillis: config.MENTORA_RELAY_RETRY_BASE_MILLIS,
      maxDelayMillis: config.MENTORA_RELAY_RETRY_MAX_MILLIS,
      maxAttempts: config.MENTORA_RELAY_RETRY_MAX_ATTEMPTS,
      jitterMillis: config.MENTORA_RELAY_RETRY_JITTER_MILLIS,
    }),
    clock,
    new RelayMetrics(metrics),
    loggers.loggerFor('relay'),
    {
      batchSize: config.MENTORA_RELAY_BATCH_SIZE,
      claimDurationMillis: config.MENTORA_RELAY_CLAIM_MILLIS,
    },
    tracer,
  );
  const relayModule = new RuntimeRelayModule(
    relayDispatch,
    config.MENTORA_RELAY_INTERVAL_MILLIS,
    ...(overrides.relayPacer !== undefined ? [overrides.relayPacer] : []),
  );

  // ---- (6) health: the closed declared list of this executable's checks.
  const health = new HealthRegistry();
  serverHealth(health, prisma, new RelayHealth(relaySource, clock));

  // ---- (13-14) the container + the Application surface.
  const http = new HttpServerModule(
    overrides.httpPort ?? config.MENTORA_HTTP_PORT,
    health,
    rootLogger,
  );
  const container = new RuntimeBuilder()
    .withModule(new AgreementPersistenceModule(prisma))
    .withModule(relayModule)
    .withModule(http)
    .withValidator({
      name: 'database-reachable',
      validate: async () => {
        try {
          await prisma.$queryRaw`SELECT 1`;
          return { ok: true as const, value: undefined };
        } catch (error) {
          return {
            ok: false as const,
            error: error instanceof Error ? error.message : String(error),
          };
        }
      },
    })
    .build();

  return { container, assembly, prisma, loggers, metrics, health, http };
};
