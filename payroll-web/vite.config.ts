import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  build: {
    chunkSizeWarningLimit: 750,
    rolldownOptions: {
      output: {
        codeSplitting: {
          groups: [
            { name: 'react-vendor', test: /node_modules\/(react|react-dom)\// },
            { name: 'data-grid-vendor', test: /node_modules\/@mui\/x-data-grid\// },
            { name: 'mui-vendor', test: /node_modules\/@mui\/(material|system|utils|types|private-theming|styled-engine)\// },
            { name: 'form-vendor', test: /node_modules\/(react-hook-form|@hookform|zod)\// },
          ],
        },
      },
    },
  },
  plugins: [react()],
})
