# @mentora/prettier-config

Shared Prettier config. One formatter, one setting, zero debate.

## Usage

In a package's `package.json`:

```json
{ "prettier": "@mentora/prettier-config" }
```

Or the root already formats the whole workspace via `pnpm format`.

Style is not a matter of taste in a monorepo of hundreds of packages: it is a
matter of diff noise. A single shared config means every file looks the same,
so every diff shows only what actually changed.
