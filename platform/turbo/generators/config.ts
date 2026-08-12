import type { PlopTypes } from '@turbo/gen';

/**
 * Mentora generators — `turbo gen <name>`.
 *
 * Every generator produces SKELETONS ONLY: naming-correct files with the full
 * engineering wiring (tsconfig, eslint, vitest, README, spec) and TODO(Phase 1)
 * markers citing the R2 chapter that owns the concept. No business logic is
 * ever generated (Phase 0 law), and generated names are governed by
 * @mentora/eslint-plugin-mentora the moment they exist.
 */

/* eslint-disable no-template-curly-in-string -- handlebars templates */

const PKG_ROOT = 'packages/{{ kebabCase name }}';

export default function generator(plop: PlopTypes.NodePlopAPI): void {
  // ---------------------------------------------------------------- package
  plop.setGenerator('package', {
    description: 'A new library package with the full two-tsconfig wiring (ADR-0003 family chosen by name).',
    prompts: [
      { type: 'input', name: 'name', message: 'Package short name (kebab-case, e.g. shared-text):' },
      { type: 'input', name: 'description', message: 'One-line description:' },
    ],
    actions: [
      { type: 'add', path: `${PKG_ROOT}/package.json`, templateFile: 'templates/package/package.json.hbs' },
      { type: 'add', path: `${PKG_ROOT}/tsconfig.json`, templateFile: 'templates/package/tsconfig.json.hbs' },
      { type: 'add', path: `${PKG_ROOT}/tsconfig.build.json`, templateFile: 'templates/package/tsconfig.build.json.hbs' },
      { type: 'add', path: `${PKG_ROOT}/eslint.config.mjs`, templateFile: 'templates/package/eslint.config.mjs.hbs' },
      { type: 'add', path: `${PKG_ROOT}/vitest.config.ts`, templateFile: 'templates/package/vitest.config.ts.hbs' },
      { type: 'add', path: `${PKG_ROOT}/README.md`, templateFile: 'templates/package/README.md.hbs' },
      { type: 'add', path: `${PKG_ROOT}/src/index.ts`, templateFile: 'templates/package/index.ts.hbs' },
      { type: 'add', path: `${PKG_ROOT}/src/smoke.spec.ts`, templateFile: 'templates/package/smoke.spec.ts.hbs' },
    ],
  });

  // ------------------------------------------------------- domain block gen
  const block = (
    kind: string,
    fileSuffix: string,
    templateFile: string,
    description: string,
  ): void => {
    plop.setGenerator(kind, {
      description,
      prompts: [
        {
          type: 'input',
          name: 'packageDir',
          message: 'Target package directory (workspace-relative, e.g. packages/domain-engagement):',
        },
        { type: 'input', name: 'name', message: `${kind} name (PascalCase stem, e.g. Agreement):` },
      ],
      actions: [
        {
          type: 'add',
          path: `{{packageDir}}/src/{{kebabCase name}}${fileSuffix}.ts`,
          templateFile: `templates/blocks/${templateFile}.hbs`,
        },
        {
          type: 'add',
          path: `{{packageDir}}/src/{{kebabCase name}}${fileSuffix}.spec.ts`,
          templateFile: `templates/blocks/${templateFile}.spec.hbs`,
        },
      ],
    });
  };

  block('aggregate', '', 'aggregate', 'Aggregate skeleton (R2 F3.1) — no invariant invented, Phase 1 fills it.');
  block('policy', '.policy', 'policy', 'Policy skeleton `<Truth><Rule>Policy` (R2 F2.5 §9).');
  block('projection', '.projection', 'projection', 'Projection skeleton `<Name>Projection` (R2 F2.5 §9, P3).');
  block('adapter', '.adapter', 'adapter', 'Adapter skeleton `<Provider><Capability>Adapter` (R2 F2.5 §9, F4.4 I-4).');
  block('repository', '.repository', 'repository', 'Repository PORT skeleton `<Truth>Repository` (R2 F3.1, F5.2 S-1).');
}
