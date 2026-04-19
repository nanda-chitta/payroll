import { Snackbar, Alert } from '@mui/material'
import { useState } from 'react'
import type { ReactNode } from 'react'
import { SnackbarContext } from './SnackbarContext'
import type { SnackbarSeverity } from './SnackbarContext'

export const SnackbarProvider = ({ children }: { children: ReactNode }) => {
    const [open, setOpen] = useState(false)
    const [message, setMessage] = useState('')
    const [severity, setSeverity] = useState<SnackbarSeverity>('success')

    const showSnackbar = (
        msg: string,
        sev: SnackbarSeverity = 'success'
    ) => {
        setMessage(msg)
        setSeverity(sev)
        setOpen(true)
    }

    const handleClose = () => setOpen(false)

    return (
        <SnackbarContext.Provider value={{ showSnackbar }}>
            {children}

            <Snackbar
                open={open}
                autoHideDuration={4000}
                onClose={handleClose}
                anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
            >
                <Alert
                    onClose={handleClose}
                    severity={severity}
                    variant="filled"
                    sx={{ width: '100%' }}
                >
                    {message}
                </Alert>
            </Snackbar>
        </SnackbarContext.Provider>
    )
}
