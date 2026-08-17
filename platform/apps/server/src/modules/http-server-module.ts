import { createServer } from 'node:http';
import type { Server } from 'node:http';
import type { AddressInfo } from 'node:net';

import type { RuntimeModule } from '@mentora/runtime-bootstrap';
import type { HealthRegistry, HealthReport } from '@mentora/runtime-health';
import type { Logger } from '@mentora/shared';

/**
 * HttpServerModule — the Application surface of this executable, I-11
 * lifecycle-owned: construire (create) → démarrer (listen — only reached
 * AFTER Validation: "l'application ne répond qu'après validation complète",
 * F4.4 §6) → drainer (stop accepting, finish in-flight — R-8) → libérer.
 *
 * Runtime surfaces ONLY (R-6 — no business logic, no business judgment):
 *   GET /live   → the Liveness verdict
 *   GET /ready  → the Readiness verdict
 *   GET /health → both reports
 * Everything else: 404 (no business endpoint exists yet — commands will
 * enter through the Dispatch when the API surface lot opens).
 */
export class HttpServerModule implements RuntimeModule {
  readonly name = 'http-server';
  private server: Server | undefined;
  private boundPort: number | undefined;

  constructor(
    private readonly port: number,
    private readonly health: HealthRegistry,
    private readonly logger: Logger,
  ) {}

  construct(): void {
    this.server = createServer((request, response) => {
      void this.handle(request.method, request.url).then(({ status, body }) => {
        response.writeHead(status, { 'content-type': 'application/json' });
        response.end(body);
      });
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
