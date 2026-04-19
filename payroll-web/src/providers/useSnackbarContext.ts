import { useContext } from 'react'
import { SnackbarContext } from './SnackbarContext'

export const useSnackbarContext = () => {
    const ctx = useContext(SnackbarContext)
    if (!ctx) {
        throw new Error('useSnackbarContext must be used inside SnackbarProvider')
    }
    return ctx
}
