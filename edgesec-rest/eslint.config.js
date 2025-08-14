import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  ...tseslint.configs.strict,
  ...tseslint.configs.stylistic,
  {
    ignores: ['dist/', 'node_modules/'],
    rules: {
      '@typescript-eslint/no-unused-vars': ['warn'],
      'no-console': 'off',
    },
  },
];
