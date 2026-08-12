# MENTORA0016 — `mentora/no-framework-import-in-domain`

> Forbids framework/vendor imports (NestJS, Prisma, TypeORM, Express…) inside domain packages.

## Justification

The domain compiles no framework import; foreign types die at the Adapters. The domain must survive every vendor.

## R2 reference (the law this rule executes)

R2 source/application/04-infrastructure-composition-runtime.md I-7 (« aucun import de framework dans le domaine ; tout est scanné ») · F4.1 A-9

## Valid

```ts
import { ok } from '@mentora/kernel';
```

## Invalid

```ts
import { Injectable } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
```

*Permanent diagnostic code: `MENTORA0016`. Codes are never renumbered, never reused.*
