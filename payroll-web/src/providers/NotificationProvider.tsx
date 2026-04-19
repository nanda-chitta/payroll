import type { ReactNode } from 'react'
import { SnackbarProvider } from './SnackbarProvider'

export const NotificationProvider = ({ children }: { children: ReactNode }) => {
  return <SnackbarProvider>{children}</SnackbarProvider>
}
