import { createServer } from 'node:http';
import type { IncomingMessage, Server } from 'node:http';
import type { AddressInfo } from 'node:net';

import type { RuntimeModule } from '@mentora/runtime-bootstrap';
import type { HealthRegistry, HealthReport } from '@mentora/runtime-health';
import type { Logger } from '@mentora/shared';

import type { GatewayRouter } from '../gateway/gateway-router.js';

/**
 * HttpServerModule — the Application surface of this executable, I-11
 * lifecycle-owned: construire (create) → démarrer (listen — only reached
 * AFTER Validation: "l'application ne répond qu'après validation complète",
 * F4.4 §6) → drainer (stop accepting, finish in-flight — R-8) → libérer.
 *
 * Runtime surfaces (R-6 — no business logic, no business judgment):
 *   GET /live   → the Liveness verdict
 *   GET /ready  → the Readiness verdict
 *   GET /health → both reports
 * Business entry (I-12 — the ENTERING adapter's unique mouth is the
 * Dispatch): POST surfaces delegated to the injected GatewayRouter, which
 * verifies the session at the gate (M-9) and dispatches. Everything else:
 * 404 — a closed door.
 */
export class HttpServerModule implements RuntimeModule {
  readonly name = 'http-server';
  private server: Server | undefined;
  private boundPort: number | undefined;

  constructor(
    private readonly port: number,
    private readonly health: HealthRegistry,
    private readonly logger: Logger,
    private readonly gateway?: GatewayRouter,
  ) {}

  construct(): void {
    this.server = createServer((request, response) => {
      void (async () => {
        if (request.method === 'POST' && this.gateway !== undefined) {
          const reply = await this.gateway.handle({
            method: request.method,
            url: request.url ?? '',
            headers: request.headers,
            body: await readBody(request),
          });
          if (reply !== undefined) {
            response.writeHead(reply.status, {
              'content-type': 'application/json',
              'x-mentora-correlation': reply.correlationId,
            });
            response.end(reply.body);
            return;
          }
        }
        const { status, body } = await this.handle(request.method, request.url);
        response.writeHead(status, { 'content-type': 'application/json' });
        response.end(body);
      })();
    });
  }

  async start(): Promise<void> {
    const server = this.server;
    if (server === undefined) {
      throw new Error('http server must be constructed before starting (I-11 order)');
    }
    await new Promise<void>((resolve, reject) => {
      server.once('error', reject);
      server.listen(this.port, () => {
        server.removeListener('error', reject);
        // listen(number) binds a TCP socket: address() is an AddressInfo here.
        this.boundPort = (server.address() as AddressInfo).port;
        this.logger.info('application surface open', { port: this.boundPort });
        resolve();
      });
    });
  }

  async drain(): Promise<void> {
    const server = this.server;
    if (server === undefined) {
      return;
    }
    await new Promise<void>((resolve) => {
      server.close(() => {
        resolve();
      });
      // Drainage closes the entrance; idle keep-alive sockets must not hold it.
      server.closeIdleConnections();
    });
    this.logger.info('application surface drained', {});
  }

  dispose(): void {
    this.server = undefined;
    this.boundPort = undefined;
  }

  /** The bound port (ephemeral ports in specs) — undefined before start. */
  get portInUse(): number | undefined {
    return this.boundPort;
  }

  private async handle(
    method: string | undefined,
    url: string | undefined,
  ): Promise<{ status: number; body: string }> {
    if (method !== 'GET') {
      return { status: 404, body: '{"error":"no such surface"}' };
    }
    if (url === '/live') {
      return render(await this.health.report('liveness'));
    }
    if (url === '/ready') {
      return render(await this.health.report('readiness'));
    }
    if (url === '/health') {
      const [liveness, readiness] = await Promise.all([
        this.health.report('liveness'),
        this.health.report('readiness'),
      ]);
      const ok = liveness.overall.kind === 'healthy' && readiness.overall.kind === 'healthy';
      return {
        status: ok ? 200 : 503,
        body: JSON.stringify({ liveness, readiness }),
      };
    }
    return { status: 404, body: '{"error":"no such surface"}' };
  }
}

const render = (report: HealthReport): { status: number; body: string } => ({
  status: report.overall.kind === 'healthy' ? 200 : 503,
  body: JSON.stringify(report),
});

/** Collects the request body (bounded by Node's own limits; JSON expected). */
const readBody = (request: IncomingMessage): Promise<string> =>
  new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    request.on('data', (chunk: Buffer) => chunks.push(chunk));
    request.on('end', () => {
      resolve(Buffer.concat(chunks).toString('utf8'));
    });
    request.on('error', reject);
  });
