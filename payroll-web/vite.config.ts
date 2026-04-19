import { defineConfig, loadEnv } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const proxyTarget = env.VITE_PROXY_TARGET || 'http://127.0.0.1:3000'

  return {
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
    server: {
      proxy: {
        '/api': {
          target: proxyTarget,
          changeOrigin: true,
        },
      },
    },
    plugins: [react()],
  }
})
