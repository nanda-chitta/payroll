import { useThemeStore } from '../../stores'

export const useTheme = () => {
  const mode = useThemeStore((state) => state.mode)
  const toggleTheme = useThemeStore((state) => state.toggleTheme)
  const setTheme = useThemeStore((state) => state.setTheme)

  return {
    mode,
    setTheme,
    toggleTheme,
  }
}
