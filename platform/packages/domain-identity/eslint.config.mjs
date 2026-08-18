import mentora from '@mentora/eslint-config';
import boundaries from '@mentora/eslint-config/boundaries';
import mentoraPlugin from '@mentora/eslint-plugin-mentora';

export default [...mentora, ...boundaries, ...mentoraPlugin.configs.constitution];
