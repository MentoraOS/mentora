# @mentora/app-server

The FIRST living executable of Mentora — the **Application species** (F5.1)
hosting the Agreement context over real PostgreSQL, with the Outbox relay
mixed in (F5.1 §3: "toléré en développement local"; production splits the
species — SIGNALED).

## What this process is

- **One Root** ([server-composition.ts](src/composition/server-composition.ts)) —
  F4.4 §2: the only place where concrete types exist. Pure DI: no service
  locator, no `resolve()`, no `get()`. It builds machinery, never a truth (I-3).
- **One boot road** ([server-bootstrap.ts](src/bootstrap/server-bootstrap.ts)) —
  `.env` + environment → configuration validated FIRST with the **complete**
  violation list (F4.4 §7: never only the first error) → the Root builds the
  whole graph → `container.boot()` runs the nine-state machine
  (Construction → Configuration → Validation → Warmup → Ready → Active)
  with the `database-reachable` proof. One missing proof and it dies (R-5).
- **One shutdown road** ([server-shutdown.ts](src/shutdown/server-shutdown.ts)) —
  SIGINT and SIGTERM both drain in the exact REVERSE order (I-11): the HTTP
  surface stops accepting → the relay finishes its in-flight pass → the
  engine client closes last. Never a brutal exit. Pending Outbox rows are
  forgiven — the next boot's relay resumes them.
- **Runtime surfaces only** (R-6): `GET /live`, `GET /ready`, `GET /health` —
  readiness = "the three Sequences are executable here", liveness = the
  process. Never a business judgment. Everything else is 404 until the API
  surface lot opens.
- **Empty routing** ([empty-routing-publisher.ts](src/modules/empty-routing-publisher.ts)) —
  the routing table is a projection of DECLARED subscriptions (M-5) and that
  projection is empty today: fan-out to zero subscribers IS complete
  delivery. A broker adapter replaces it the day the first subscription is
  declared; the relay will not change.

## Running it

```bash
MENTORA_AGREEMENT_DATABASE_URL='postgresql://user:pass@localhost:5433/db' node dist/main.js
```

Configuration (all `MENTORA_*` keys, environment first, then `.env`):
see [server-config.ts](src/config/server-config.ts) — the schema is the
declared, closed list; every knob has a default except the database URL.
The URL is dev plumbing today; the vault-reference discipline (I-8) arrives
with the vault adapter — SIGNALED.

## Proving it

`vitest run` — the living tests (boot to Active over real PostgreSQL, the
full command → retention → relay loop, signals, health over real HTTP) are
gated on `MENTORA_AGREEMENT_DATABASE_URL`; without it only the pure tests
run. `src/main.ts` is a pure process wire (zero logic — everything lives in
[run-server-process.ts](src/startup/run-server-process.ts), fully proven)
and is excluded from coverage the way barrels are.
