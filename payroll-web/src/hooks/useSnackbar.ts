import { useSnackbarContext } from '../providers'

export const useSnackbar = () => {
  const { showSnackbar } = useSnackbarContext()

  return {
    success: (msg: string) => showSnackbar(msg, 'success'),
    error: (msg: string) => showSnackbar(msg, 'error'),
    info: (msg: string) => showSnackbar(msg, 'info'),
    warning: (msg: string) => showSnackbar(msg, 'warning'),
  }
}
