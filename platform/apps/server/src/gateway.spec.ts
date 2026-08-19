import { environmentSource, inMemorySource } from '@mentora/runtime-config';
import { MemoryLogSink } from '@mentora/runtime-logging';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from 'vitest';

import type { ServerGraph } from './composition/server-composition.js';
import { startServerRuntime } from './runtime/server-runtime.js';
import { shutdownServer } from './shutdown/server-shutdown.js';

/**
 * THE GATEWAY GATE (Stories #79-#95) — real HTTP on an ephemeral port, real
 * PostgreSQL registries, the WHOLE road: login → session → authenticated
 * command → correlation in the Outbox de faits. The gate is session-bounded
 * (M-9): 401 is the TRANSPORT verdict; refusals stay motivated VALUES from
 * the owners (409); violations are the caller's defect (400); un-admitted
 * commands are closed doors (404).
 *
 * The credential is established through the ASSEMBLY service — the spec
 * stands in for the Account ACL (canon: "Credential établi par l'ACL du
 * Compte"; the ACL arrives with Account/Sprint 4). The entry surface never
 * exposes EstablishCredential — a closed door by constitutional state
 * (RFC-002 pending for the session verbs' emitters).
 */

const url = environmentSource().read('MENTORA_AGREEMENT_DATABASE_URL');
const identityUrl = environmentSource().read('MENTORA_IDENTITY_DATABASE_URL');
const ready = url !== undefined && identityUrl !== undefined;

const sources = [
  inMemorySource('gateway-spec', {
    MENTORA_AGREEMENT_DATABASE_URL: url ?? 'postgresql://void',
    MENTORA_IDENTITY_DATABASE_URL: identityUrl ?? 'postgresql://void',
    MENTORA_HTTP_PORT: '0',
    MENTORA_LOG_THRESHOLD: 'error',
    MENTORA_RELAY_INTERVAL_MILLIS: '3600000', // the spec never ticks the relay.
  }),
];

const PERSON = 'person-e2e';

describe.skipIf(!ready)('the Gateway M-10 (real HTTP, real registries)', () => {
  let graph: ServerGraph;
  let base: string;

  beforeAll(async () => {
    const started = await startServerRuntime(sources, { logSink: new MemoryLogSink() });
    if (!started.ok) throw new Error('boot refused');
    graph = started.value;
    base = `http://127.0.0.1:${String(graph.http.portInUse ?? 0)}`;
  }, 30_000);

  beforeEach(async () => {
    await graph.prisma.$executeRawUnsafe(
      'TRUNCATE "AgreementSnapshot", "AgreementFact", "AgreementOutbox", "AgreementInbox"',
    );
    await graph.identityPrisma.$executeRawUnsafe(
      'TRUNCATE "CredentialSnapshot", "CredentialFact", "CredentialOutbox", "CredentialInbox", "SessionSnapshot"',
    );
  });

  afterAll(async () => {
    await shutdownServer(graph);
  }, 30_000);

  const post = (path: string, body: unknown, headers: Record<string, string> = {}) =>
    fetch(base + path, {
      method: 'POST',
      headers: { 'content-type': 'application/json', ...headers },
      body: JSON.stringify(body),
    });

  /** The spec stands in for the Account ACL: the proof is established at the source. */
  const establishCredential = async (id = 'cred-e2e', person = PERSON): Promise<void> => {
    const outcome = await graph.identity.services.establishCredential.execute({
      payload: {
        type: 'EstablishCredential',
        contractVersion: 1,
        commandId: `cmd-est-${id}`,
        credentialId: id,
        personId: person,
        principalFactor: { factorId: `factor-${id}`, kind: 'password', strength: 'standard' },
      },
      actor: 'account-acl' as never,
      correlationId: 'corr-acl' as never,
    });
    if (outcome.kind !== 'executed') throw new Error(`ACL stand-in failed: ${outcome.kind}`);
  };

  const openSession = async (id = 'sess-e2e', credential = 'cred-e2e'): Promise<Response> =>
    post('/entry/open-session', {
      type: 'OpenSession',
      contractVersion: 1,
      commandId: `cmd-open-${id}`,
      sessionId: id,
      credentialId: credential,
      presentedStrength: 'standard',
    });

  it('the entry opens a session on ACCEPTED proof — and refuses the weak proof motivated (409)', async () => {
    await establishCredential();
    const opened = await openSession();
    expect(opened.status).toBe(200);
    expect(((await opened.json()) as { kind: string }).kind).toBe('executed');

    const weak = await post('/entry/open-session', {
      type: 'OpenSession',
      contractVersion: 1,
      commandId: 'cmd-open-weak',
      sessionId: 'sess-weak',
      credentialId: 'cred-e2e',
      presentedStrength: 'whisper',
    });
    expect(weak.status).toBe(409);
    const refusal = (await weak.json()) as { refusal: { reason: string } };
    expect(refusal.refusal.reason).toBe('ProofUnavailable');
  });

  it('the entry is ONE closed door: any other command there is 404', async () => {
    const foreign = await post('/entry/open-session', {
      type: 'EstablishCredential',
      contractVersion: 1,
      commandId: 'x',
      credentialId: 'x',
      personId: 'x',
      principalFactor: { factorId: 'x', kind: 'password', strength: 'standard' },
    });
    expect(foreign.status).toBe(404);
  });

  it('401 — the TRANSPORT verdicts of the gate, each with its named detail', async () => {
    const noSession = await post('/commands', { type: 'RequestAgreement' });
    expect(noSession.status).toBe(401);
    const ghost = await post('/commands', { type: 'RequestAgreement' }, { 'x-mentora-session': 'sess-ghost' });
    expect(ghost.status).toBe(401);
    expect(((await ghost.json()) as { detail: string }).detail).toBe('unknown session');
  });

  it('THE WHOLE ROAD: login → authenticated Agreement command → correlation in the Outbox de faits (RFC-001 e2e)', async () => {
    await establishCredential();
    await openSession();
    const now = Date.now();
    const commanded = await post(
      '/commands',
      {
        type: 'RequestAgreement',
        contractVersion: 1,
        commandId: 'cmd-agr-e2e',
        agreementId: 'agr-e2e',
        clientId: PERSON,
        expertId: 'exp-1',
        offerId: 'off-1',
        slot: { startMs: now + 10 * 3_600_000, endMs: now + 11 * 3_600_000 },
        availabilityWindows: [{ startMs: now, endMs: now + 100 * 3_600_000 }],
      },
      { 'x-mentora-session': 'sess-e2e', 'x-mentora-correlation': 'corr-road-1' },
    );
    expect(commanded.status).toBe(200);
    expect(commanded.headers.get('x-mentora-correlation')).toBe('corr-road-1');
    // The acknowledgement carries NO domain truth.
    const acked = (await commanded.json()) as Record<string, unknown>;
    expect(Object.keys(acked).sort()).toEqual(['attempts', 'kind']);
    // RFC-001, end to end: entry header → SequenceInput → pas 8 → outbox row.
    const outboxRow = await graph.prisma.agreementOutbox.findFirst();
    expect(outboxRow?.correlationId).toBe('corr-road-1');
    expect(outboxRow?.causationId).toBe('cmd-agr-e2e');
  });

  it('the authenticated read surface serves the party through the R-C grid (the owner judges, not the gate)', async () => {
    await establishCredential();
    await openSession();
    const now = Date.now();
    await post(
      '/commands',
      {
        type: 'RequestAgreement',
        contractVersion: 1,
        commandId: 'cmd-agr-q',
        agreementId: 'agr-q',
        clientId: PERSON,
        expertId: 'exp-1',
        offerId: 'off-1',
        slot: { startMs: now + 10 * 3_600_000, endMs: now + 11 * 3_600_000 },
        availabilityWindows: [{ startMs: now, endMs: now + 100 * 3_600_000 }],
      },
      { 'x-mentora-session': 'sess-e2e' },
    );
    const answered = await post(
      '/queries',
      { type: 'AgreementStateQuery', contractVersion: 1, agreementId: 'agr-q' },
      { 'x-mentora-session': 'sess-e2e' },
    );
    expect(answered.status).toBe(200);
    const body = (await answered.json()) as { response: { stateKind: string } };
    expect(body.response.stateKind).toBe('Requested');
  });

  it('a REVOKED proof breaks the chain at the gate: 401 immediately, before any cascade', async () => {
    await establishCredential();
    await openSession();
    const revoked = await graph.identity.services.revokeCredential.execute({
      payload: {
        type: 'RevokeCredential',
        contractVersion: 1,
        commandId: 'cmd-rev-e2e',
        credentialId: 'cred-e2e',
        motive: 'compromise',
      },
      actor: 'account-acl' as never,
      correlationId: 'corr-rev' as never,
    });
    expect(revoked.kind).toBe('executed');
    const barred = await post('/commands', { type: 'RequestAgreement' }, { 'x-mentora-session': 'sess-e2e' });
    expect(barred.status).toBe(401);
    expect(((await barred.json()) as { detail: string }).detail).toBe(
      'the proof behind this session is revoked',
    );
  });

  it('the closed admission table: identity verbs on /commands are 404, never dispatched (RFC-002 pending)', async () => {
    await establishCredential();
    await openSession();
    const foreign = await post(
      '/commands',
      { type: 'EndSession', contractVersion: 1, commandId: 'x', sessionId: 'sess-e2e' },
      { 'x-mentora-session': 'sess-e2e' },
    );
    expect(foreign.status).toBe(404);
  });

  it('a malformed payload is the caller defect — 400 with the violations listed', async () => {
    await establishCredential();
    await openSession();
    const malformed = await post(
      '/commands',
      { type: 'RequestAgreement', contractVersion: 1 },
      { 'x-mentora-session': 'sess-e2e' },
    );
    expect(malformed.status).toBe(400);
    const body = (await malformed.json()) as { violations: readonly unknown[] };
    expect(body.violations.length).toBeGreaterThan(0);
  });

  it('an absent correlation is MINTED at the entry — never lost (M-3)', async () => {
    await establishCredential();
    const opened = await openSession();
    const minted = opened.headers.get('x-mentora-correlation');
    expect(minted).toBeTruthy();
  });
});
