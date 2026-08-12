import mentora from '@mentora/eslint-config';
import boundaries from '@mentora/eslint-config/boundaries';

export default [
  ...mentora,
  ...boundaries,
  {
    // The docs generator is a Node script; give it the Node globals it uses.
    files: ['scripts/**/*.mjs'],
    languageOptions: { globals: { console: 'readonly', process: 'readonly' } },
  },
];
