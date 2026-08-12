// @mentora/eslint-config/boundaries — architectural import boundaries.
//
// These rules make the dependency graph a LAW the linter enforces, not a
// convention people remember. They encode two invariants that mirror the
// Foundation's F4.4 rule I-1 ("la dépendance pointe vers le centre") and I-12
// ("le graphe est acyclique par construction"):
//
//   1. Applications may import libraries; libraries may NEVER import an app.
//   2. A package may only reach another package through its PUBLIC entrypoint
//      (its package name), never through a deep relative path into its src/.
//
// Deep-relative cross-package imports (../../other-package/src/...) are the
// classic way a monorepo rots into a big ball of mud; forbidding them keeps
// every package's public surface the only contract that exists.
//
// Usage in a package's eslint.config.mjs (compose after the base):
//   import mentora from "@mentora/eslint-config";
//   import boundaries from "@mentora/eslint-config/boundaries";
//   export default [...mentora, ...boundaries];

/** @type {import("eslint").Linter.Config[]} */
export default [
  {
    files: ["**/*.{ts,tsx,mts,cts}"],
    rules: {
      "no-restricted-imports": [
        "error",
        {
          patterns: [
            {
              group: ["**/apps/*", "@mentora/app-*"],
              message:
                "A library must never import an application (F4.4 I-1: dependency points to the center). Move the shared code into a package under packages/*.",
            },
            {
              group: ["*/src/*", "**/dist/*"],
              message:
                "Import a package through its public name (e.g. '@mentora/kernel'), never through its internal src/ or dist/. The package name is the only contract.",
            },
          ],
        },
      ],
    },
  },
];
