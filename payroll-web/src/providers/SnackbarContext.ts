import { createContext } from 'react'

export type SnackbarSeverity = 'success' | 'error' | 'info' | 'warning'

export type AppNotification = {
  id: number
  message: string
  severity: SnackbarSeverity
  createdAt: string
}

export type SnackbarContextType = {
  clearNotifications: () => void
  notifications: AppNotification[]
  showSnackbar: (message: string, severity?: SnackbarSeverity) => void
}

export const SnackbarContext = createContext<SnackbarContextType | undefined>(undefined)
