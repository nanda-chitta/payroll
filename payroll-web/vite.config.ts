import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  build: {
    rolldownOptions: {
      output: {
        codeSplitting: {
          groups: [
            { name: 'react-vendor', test: /node_modules\/(react|react-dom)\// },
            { name: 'mui-vendor', test: /node_modules\/@mui\// },
            { name: 'form-vendor', test: /node_modules\/(react-hook-form|@hookform|zod)\// },
          ],
        },
      },
    },
  },
  plugins: [react()],
})
