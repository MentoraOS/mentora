// @mentora/eslint-config — shared flat config (ESLint 9+).
//
// This is the lint baseline every package composes. It is deliberately strict
// on correctness and quiet on style (style is Prettier's job — see
// eslint-config-prettier, applied last so no rule fights the formatter).
//
// Usage in a package's eslint.config.mjs:
//   import mentora from "@mentora/eslint-config";
//   export default [...mentora];

import js from "@eslint/js";
import tseslint from "typescript-eslint";
import importX from "eslint-plugin-import-x";
import prettier from "eslint-config-prettier";
import globals from "globals";

/** @type {import("eslint").Linter.Config[]} */
export default [
  {
    ignores: ["**/dist/**", "**/build/**", "**/node_modules/**", "**/.turbo/**", "**/coverage/**"],
  },
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    files: ["**/*.{ts,tsx,mts,cts}"],
    languageOptions: {
      parserOptions: {
        projectService: true,
        tsconfigRootDir: process.cwd(),
      },
      globals: { ...globals.node },
    },
    plugins: {
      "import-x": importX,
    },
    rules: {
      // Correctness — surface real defects, not taste.
      "@typescript-eslint/no-floating-promises": "error",
      "@typescript-eslint/no-misused-promises": "error",
      "@typescript-eslint/await-thenable": "error",
      "@typescript-eslint/no-unnecessary-condition": "warn",
      "@typescript-eslint/switch-exhaustiveness-check": "error",
      "@typescript-eslint/consistent-type-imports": [
        "error",
        { prefer: "type-imports", fixStyle: "separate-type-imports" },
      ],
      "@typescript-eslint/explicit-module-boundary-types": "warn",

      // Import hygiene — no cycles, resolvable specifiers, ordered imports.
      "import-x/no-cycle": ["error", { maxDepth: 1 }],
      "import-x/no-self-import": "error",
      "import-x/no-useless-path-segments": "error",
      "import-x/order": [
        "warn",
        {
          "newlines-between": "always",
          alphabetize: { order: "asc", caseInsensitive: true },
          groups: ["builtin", "external", "internal", "parent", "sibling", "index"],
        },
      ],
    },
  },
  // Config & script files: relax the type-aware rules (they are not part of the
  // typed project graph).
  {
    files: ["**/*.{js,mjs,cjs}", "**/*.config.{ts,mts}"],
    ...tseslint.configs.disableTypeChecked,
  },
  // Prettier LAST — turns off every stylistic rule that could conflict.
  prettier,
];
