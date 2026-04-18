import { createTheme } from '@mui/material/styles'

export const theme = createTheme({
  palette: {
    background: {
      default: '#f6f8f7',
      paper: '#ffffff',
    },
    primary: {
      main: '#176b4f',
      dark: '#0f4e39',
      contrastText: '#ffffff',
    },
    secondary: {
      main: '#2f8f6b',
    },
    text: {
      primary: '#17211d',
      secondary: '#65756f',
    },
    error: {
      main: '#9f2f2f',
    },
  },
  shape: {
    borderRadius: 8,
  },
  typography: {
    fontFamily: [
      'Inter',
      'ui-sans-serif',
      'system-ui',
      '-apple-system',
      'BlinkMacSystemFont',
      'Segoe UI',
      'sans-serif',
    ].join(','),
    h1: {
      fontSize: 34,
      fontWeight: 700,
      letterSpacing: 0,
      lineHeight: 1.1,
    },
    h2: {
      fontSize: 20,
      fontWeight: 700,
      letterSpacing: 0,
    },
    button: {
      textTransform: 'none',
      fontWeight: 700,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 8,
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          border: '1px solid #dde5e1',
          borderRadius: 8,
          boxShadow: 'none',
        },
      },
    },
  },
})
