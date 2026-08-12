# @mentora/tsconfig

Shared TypeScript configuration presets. One source of truth for compiler
strictness across the whole platform.

## Presets

| Preset | Extend with | For |
|--------|-------------|-----|
| `base` | `"extends": "@mentora/tsconfig/base"` | any package; strictest safe flags |
| `library` | `"extends": "@mentora/tsconfig/library"` | shared libs under `packages/*` (composite, emits `.d.ts`) |
| `nestjs` | `"extends": "@mentora/tsconfig/nestjs"` | NestJS apps under `apps/*` (decorators + metadata) |

## Why a package instead of relative paths

A package extends `@mentora/tsconfig/library`, never `../../tsconfig.base.json`.
A package name is stable when a package moves in the tree; a relative path is
not. This is the same discipline the Foundation applies to truth ownership:
reference by stable identity, never by position.

## The strictness baseline (base.json)

All of TypeScript's correctness flags are on, plus the ones most teams leave
off but that catch real bugs: `noUncheckedIndexedAccess`,
`exactOptionalPropertyTypes`, `noImplicitOverride`,
`noPropertyAccessFromIndexSignature`, `isolatedModules`,
`verbatimModuleSyntax`. The cost is a little more ceremony; the return is that
the compiler carries contracts the runtime will not have to rediscover
(mirrors F1 §4: *"le compilateur porte les contrats que l'exécution n'aura pas
à rattraper"*).
