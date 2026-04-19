import {create} from 'zustand'
import {persist} from 'zustand/middleware'
import type {PaletteMode} from '@mui/material'

interface ThemeState {
    mode: PaletteMode;
    toggleTheme: () => void;
    setTheme: (mode: PaletteMode) => void;
}

const getSystemTheme = (): PaletteMode => {
    if (typeof window === 'undefined') return 'light'
    return window.matchMedia('(prefers-color-scheme: dark)').matches
        ? 'dark'
        : 'light'
}

export const useThemeStore = create<ThemeState>()(
    persist(
        (set) => ({
            mode: getSystemTheme(),
            toggleTheme: () =>
                set((state) => ({
                    mode: state.mode === 'light' ? 'dark' : 'light',
                })),
            setTheme: (mode) => set({ mode }),
        }),
        {
            name: 'theme-mode',
            partialize: (state) => ({ mode: state.mode }),
            onRehydrateStorage: () => (state) => {
                if (!state?.mode) {
                    state?.setTheme(getSystemTheme())
                }
            },
        }
    )
)
