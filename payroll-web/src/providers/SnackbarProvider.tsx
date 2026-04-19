import { Snackbar, Alert } from '@mui/material'
import { useState } from 'react'
import type { ReactNode } from 'react'
import { SnackbarContext } from './SnackbarContext'
import type { AppNotification, SnackbarSeverity } from './SnackbarContext'

export const SnackbarProvider = ({ children }: { children: ReactNode }) => {
  const [open, setOpen] = useState(false)
  const [message, setMessage] = useState('')
  const [severity, setSeverity] = useState<SnackbarSeverity>('success')
  const [notifications, setNotifications] = useState<AppNotification[]>([])

  const showSnackbar = (msg: string, sev: SnackbarSeverity = 'success') => {
    setMessage(msg)
    setSeverity(sev)
    setOpen(true)
    setNotifications((currentNotifications) => [
      {
        createdAt: new Date().toISOString(),
        id: Date.now(),
        message: msg,
        severity: sev,
      },
      ...currentNotifications,
    ].slice(0, 10))
  }

  const handleClose = () => setOpen(false)
  const clearNotifications = () => setNotifications([])

  return (
    <SnackbarContext.Provider value={{ clearNotifications, notifications, showSnackbar }}>
      {children}

      <Snackbar
        anchorOrigin={{ vertical: 'top', horizontal: 'center' }}
        autoHideDuration={4000}
        onClose={handleClose}
        open={open}
      >
        <Alert onClose={handleClose} severity={severity} sx={{ width: '100%' }} variant="filled">
          {message}
        </Alert>
      </Snackbar>
    </SnackbarContext.Provider>
  )
}
