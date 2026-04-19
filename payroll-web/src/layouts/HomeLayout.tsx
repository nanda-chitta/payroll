import { Box } from '@mui/material'
import { Outlet } from 'react-router'
import { Header } from '../components/navigations/Header'
import { useTheme } from '../hooks'

export const HomeLayout = () => {
  const { mode, toggleTheme } = useTheme()

  return (
    <Box
      sx={{
        bgcolor: 'background.default',
        color: 'text.primary',
        minHeight: '100vh',
        display: 'flex',
        flexDirection: 'column',
      }}
    >
      <Header mode={mode} toggleTheme={toggleTheme} />
      <Outlet />
    </Box>
  )
}

export default HomeLayout
