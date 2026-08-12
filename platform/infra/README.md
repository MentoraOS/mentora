# infra/

Local development infrastructure — the backing services the platform runs
against. **Mechanisms, not domains** (F5: interchangeable, owned by operations,
never holding a business truth).

## Services (`docker-compose.dev.yml`)

| Service | Port(s) | Foundation role |
|---------|---------|-----------------|
| PostgreSQL 16 | 5432 | the store behind the Registry ports (F5.2) |
| Redis 7 | 6379 | cache / ephemeral projections (F5.2 — never a validity cache) |
| RabbitMQ 4 | 5672, 15672 | the Bus behind Circulation (F4.3) |
| OpenSearch 2 | 9200 | search projections behind the ACL (F5.2) |
| MinIO | 9000, 9001 | object storage behind the Deposit port (Storage, F3) |
| Jaeger | 16686, 4317/4318 | OTLP trace sink (F5.3 — telemetry is perdable) |

```bash
pnpm infra:up      # docker compose up -d
pnpm infra:down    # docker compose down
```

## Notes

- Credentials are **dev-only throwaway values**. Real secrets live in a vault,
  never in a committed file (F5.4 Secret Zero, F4.4 I-8).
- Data volumes live under `infra/.data/` and are git-ignored.
- Production infrastructure (IaC, Kubernetes, cell topology per F5.6) is **not**
  in scope for Lot 0A; this is the local loop only.
