# @mentora/eslint-config

Shared ESLint flat config. Correctness-strict, style-silent (Prettier owns
style). Ships the **architectural boundary rules** that make the dependency
graph enforceable.

## Exports

| Import | What it adds |
|--------|--------------|
| `@mentora/eslint-config` | base: `js.recommended` + `typescript-eslint` type-checked + import hygiene + Prettier-off |
| `@mentora/eslint-config/boundaries` | the two dependency-direction invariants (libs never import apps; cross-package imports go through the package name) |

## Usage

```js
// <package>/eslint.config.mjs
import mentora from "@mentora/eslint-config";
import boundaries from "@mentora/eslint-config/boundaries";

export default [...mentora, ...boundaries];
```

## The boundary invariants

1. **Libraries never import applications** — dependency points to the center
   (F4.4 I-1). A library reaching "up" into an app is a leak; the linter fails
   the build.
2. **Cross-package imports go through the package name** — never a deep
   relative path into another package's `src/`. A package's name is its only
   public contract; its internals are private (mirrors F3.1: an Aggregate is
   referenced by identity, never reached into).

These are errors, not warnings: a boundary that only warns is a boundary that
is already crossed.
