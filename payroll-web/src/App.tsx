import { CssBaseline, ThemeProvider } from '@mui/material'
import { SalaryManagementPage } from './pages/SalaryManagementPage'
import { theme } from './theme'

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <SalaryManagementPage />
    </ThemeProvider>
  )
}

export default App
