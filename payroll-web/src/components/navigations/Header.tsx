import {
  AppBar,
  Avatar,
  Badge,
  Box,
  Button,
  Divider,
  IconButton,
  ListItemText,
  Menu,
  MenuItem,
  Toolbar, Tooltip,
  Typography,
  useTheme as useMuiTheme,
} from '@mui/material'
import {
  DarkMode as DarkModeIcon,
  LightMode as LightModeIcon,
} from '@mui/icons-material'
import type { PaletteMode } from '@mui/material'
import { useState } from 'react'
import { BellIcon, UserIcon } from '../ui'
import { useSnackbarContext } from '../../providers'

type HeaderProps = {
  mode: PaletteMode
  toggleTheme: () => void
}

export const Header = ({ mode, toggleTheme }: HeaderProps) => {
  const theme = useMuiTheme()
  const { clearNotifications, notifications } = useSnackbarContext()
  const [notificationAnchor, setNotificationAnchor] = useState<null | HTMLElement>(null)
  const [profileAnchor, setProfileAnchor] = useState<null | HTMLElement>(null)
  const nextModeLabel = mode === 'dark' ? 'Light mode' : 'Dark mode'

  return (
    <AppBar
      color="inherit"
      elevation={0}
      position="sticky"
      sx={{
        bgcolor: 'background.paper',
        borderBottom: `1px solid ${theme.palette.divider}`,
      }}
    >
      <Toolbar sx={{ gap: 2, justifyContent: 'space-between' }}>
        <Box sx={{ minWidth: 0 }}>
          <Typography component="p" sx={{ color: 'text.secondary', fontSize: 13, fontWeight: 700 }}>
            Payroll workspace
          </Typography>
          <Typography
            component="h1"
            sx={{
              color: 'text.primary',
              fontSize: { sm: 22, xs: 18 },
              fontWeight: 800,
              lineHeight: 1.2,
            }}
          >
            Salary management
          </Typography>
        </Box>

        <Box sx={{ alignItems: 'center', display: 'inline-flex', gap: 1 }}>
          <IconButton
            aria-label="Open notifications"
            color="primary"
            sx={{ p: 1 }}
            onClick={(event) => setNotificationAnchor(event.currentTarget)}
          >
            <Badge badgeContent={notifications.length} color="error">
              <BellIcon />
            </Badge>
          </IconButton>

          <IconButton
            aria-label="Open profile menu"
            onClick={(event) => setProfileAnchor(event.currentTarget)}
            sx={{ p: 0.5 }}
          >
            <Avatar sx={{ bgcolor: 'primary.main', height: 36, width: 36 }}>
              <UserIcon fontSize="small" />
            </Avatar>
          </IconButton>
          <Tooltip title={mode === 'dark' ? 'Light mode' : 'Dark mode'}>
            <IconButton sx={{ p: 1, bgcolor: 'primary.main' }} size="small" onClick={toggleTheme}>
              {mode === 'dark' ? (
                  <LightModeIcon sx={{ color: 'text.primary' }} fontSize="small" />
              ) : (
                  <DarkModeIcon sx={{ color: 'text.primary' }} fontSize="small" />
              )}
            </IconButton>
          </Tooltip>
        </Box>
      </Toolbar>

      <Menu
        anchorEl={notificationAnchor}
        onClose={() => setNotificationAnchor(null)}
        open={Boolean(notificationAnchor)}
        slotProps={{ paper: { sx: { maxWidth: 'calc(100vw - 32px)', width: 340 } } }}
      >
        <Box sx={{ alignItems: 'center', display: 'flex', justifyContent: 'space-between', px: 2, py: 1 }}>
          <Typography sx={{ fontWeight: 800 }}>Notifications</Typography>
          <Button disabled={notifications.length === 0} onClick={clearNotifications} size="small">
            Clear
          </Button>
        </Box>
        <Divider />
        {notifications.length === 0 ? (
          <MenuItem disabled>
            <ListItemText primary="No notifications" secondary="Employee updates will appear here." />
          </MenuItem>
        ) : (
          notifications.map((notification) => (
            <MenuItem key={notification.id} sx={{ alignItems: 'flex-start', whiteSpace: 'normal' }}>
              <ListItemText
                primary={notification.message}
                secondary={`${notification.severity} | ${formatNotificationTime(notification.createdAt)}`}
              />
            </MenuItem>
          ))
        )}
      </Menu>

      <Menu
        anchorEl={profileAnchor}
        onClose={() => setProfileAnchor(null)}
        open={Boolean(profileAnchor)}
        slotProps={{ paper: { sx: { width: 240 } } }}
      >
        <MenuItem disabled>
          <ListItemText primary="HR Manager" secondary="Payroll admin" />
        </MenuItem>
        <Divider />
        <MenuItem onClick={toggleTheme}>{nextModeLabel}</MenuItem>
        <MenuItem onClick={() => setProfileAnchor(null)}>Profile</MenuItem>
        <MenuItem onClick={() => setProfileAnchor(null)}>Sign out</MenuItem>
      </Menu>
    </AppBar>
  )
}

export default Header

function formatNotificationTime(value: string) {
  return new Intl.DateTimeFormat(undefined, {
    hour: '2-digit',
    minute: '2-digit',
  }).format(new Date(value))
}
