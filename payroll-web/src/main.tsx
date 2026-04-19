import React from 'react'
import { createRoot } from 'react-dom/client'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { SnackbarProvider } from './providers'
import App from './App'

const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            refetchOnWindowFocus: false,
            retry: 1,
            staleTime: 1000 * 60,
        },
    },
})

const container = document.getElementById('root')

if (!container) {
    throw new Error('Root container missing in index.html')
}

const root = createRoot(container)

root.render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      <SnackbarProvider>
        <App />
      </SnackbarProvider>
    </QueryClientProvider>
  </React.StrictMode>
)
