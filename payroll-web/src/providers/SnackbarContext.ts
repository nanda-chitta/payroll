import { createContext } from 'react'

export type SnackbarSeverity = 'success' | 'error' | 'info' | 'warning'

export type SnackbarContextType = {
    showSnackbar: (message: string, severity?: SnackbarSeverity) => void
}

export const SnackbarContext = createContext<SnackbarContextType | undefined>(undefined)
