import { defineConfig, globalIgnores } from 'eslint/config'
import nextVitals from 'eslint-config-next/core-web-vitals'

export default defineConfig([
  ...nextVitals,
  {
    rules: {
      '@next/next/no-img-element': 'off',
      // Existing NextAuth and invite flows intentionally derive loading states
      // from URL/session effects. They are safe and covered by build checks.
      'react-hooks/set-state-in-effect': 'off',
    },
  },
  globalIgnores(['.next/**', 'node_modules/**']),
])
