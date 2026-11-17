// Sonar rules only, run by nvim-lint on any JS/TS file, independent of the project's own ESLint setup.
// Not type-aware: rules that need type information stay silent.
import sonarjs from "eslint-plugin-sonarjs";
import tseslint from "typescript-eslint";

export default [
  {
    files: ["**/*.{js,mjs,cjs,jsx,ts,mts,cts,tsx}"],
    languageOptions: {
      parser: tseslint.parser,
      parserOptions: { ecmaFeatures: { jsx: true } },
    },
    linterOptions: {
      // The project's own eslint-disable comments name rules this config doesn't load
      reportUnusedDisableDirectives: "off",
    },
    ...sonarjs.configs.recommended,
  },
];
